#!/usr/bin/env bash
set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)

CONFIG_PATH=/data/options.json
PGSQLDB_DATA=/data/databases

DATABASES=$(jq --raw-output ".databases[]" $CONFIG_PATH)
LOGINS=$(jq --raw-output '.logins | length' $CONFIG_PATH)
RIGHTS=$(jq --raw-output '.rights | length' $CONFIG_PATH)

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
	echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
	exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
	val="${!var}"
    elif [ "${!fileVar:-}" ]; then
	val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

if [ "${1:0:1}" = '-' ]; then
    set -- postgres "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'postgres' ] && [ "$(id -u)" = '0' ]; then
    mkdir -p "$PGDATA"
    chown -R postgres "$PGDATA"
    chmod 700 "$PGDATA"

    mkdir -p $PGSQLDB_DATA
    chown -R postgres $PGSQLDB_DATA
    chmod 775 $PGSQLDB_DATA

    # Create the transaction log directory before initdb is run (below) so the directory is owned by the correct user
    if [ "$POSTGRES_INITDB_WALDIR" ]; then
	mkdir -p "$POSTGRES_INITDB_WALDIR"
	chown -R postgres "$POSTGRES_INITDB_WALDIR"
	chmod 700 "$POSTGRES_INITDB_WALDIR"
    fi

    exec su-exec postgres "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'postgres' ]; then
    mkdir -p "$PGDATA"
    chown -R "$(id -u)" "$PGDATA" 2>/dev/null || :
    chmod 700 "$PGDATA" 2>/dev/null || :

    # look specifically for PG_VERSION, as it is expected in the DB dir
    if [ ! -s "$PGDATA/PG_VERSION" ]; then
	# "initdb" is particular about the current user existing in "/etc/passwd", so we use "nss_wrapper" to fake that if necessary
	# see https://github.com/docker-library/postgres/pull/253, https://github.com/docker-library/postgres/issues/359, https://cwrap.org/nss_wrapper.html
	if ! getent passwd "$(id -u)" &> /dev/null && [ -e /usr/lib/libnss_wrapper.so ]; then
	    export LD_PRELOAD='/usr/lib/libnss_wrapper.so'
	    export NSS_WRAPPER_PASSWD="$(mktemp)"
	    export NSS_WRAPPER_GROUP="$(mktemp)"
	    echo "postgres:x:$(id -u):$(id -g):PostgreSQL:$PGDATA:/bin/false" > "$NSS_WRAPPER_PASSWD"
	    echo "postgres:x:$(id -g):" > "$NSS_WRAPPER_GROUP"
	fi

	file_env 'POSTGRES_USER' 'postgres'
	file_env 'POSTGRES_PASSWORD'

	file_env 'POSTGRES_INITDB_ARGS'
	if [ "$POSTGRES_INITDB_WALDIR" ]; then
	    export POSTGRES_INITDB_ARGS="$POSTGRES_INITDB_ARGS --waldir $POSTGRES_INITDB_WALDIR"
	fi
	eval 'initdb --username="$POSTGRES_USER" --pwfile=<(echo "$POSTGRES_PASSWORD") '"$POSTGRES_INITDB_ARGS"

	# unset/cleanup "nss_wrapper" bits
	if [ "${LD_PRELOAD:-}" = '/usr/lib/libnss_wrapper.so' ]; then
	    rm -f "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"
	    unset LD_PRELOAD NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP
	fi

	# check password first so we can output the warning before postgres
	# messes it up
	if [ -n "$POSTGRES_PASSWORD" ]; then
	    authMethod=md5
	else
	    # The - option suppresses leading tabs but *not* spaces. :)
	    cat >&2 <<-'EOWARN'
		****************************************************
		WARNING: No password has been set for the database.
		         This will allow anyone with access to the
		         Postgres port to access your database. In
		         Dockers default configuration, this is
		         effectively any other container on the same
		         system.
		         Use "-e POSTGRES_PASSWORD=password" to set
		         it in "docker run".
		****************************************************
	    EOWARN

	    authMethod=trust
	fi

	{
	    echo
	    echo "host all all all $authMethod"
	} >> "$PGDATA/pg_hba.conf"

	# internal start of server in order to allow set-up using psql-client
	# does not listen on external TCP/IP and waits until start finishes
	PGUSER="${PGUSER:-$POSTGRES_USER}" \
	pg_ctl -D "$PGDATA" \
	    -o "-c listen_addresses=''" \
	    -w start

	file_env 'POSTGRES_DB' "$POSTGRES_USER"

	export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
	psql=( psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password )

	if [ "$POSTGRES_DB" != 'postgres' ]; then
	    "${psql[@]}" --dbname postgres --set db="$POSTGRES_DB" -c 'CREATE DATABASE :"db" ;'
	    echo
	fi
	psql+=( --dbname "$POSTGRES_DB" )

	echo
	# creating databases
	echo "[INFO] Init custom database"
	for line in $DATABASES; do
	    echo "[INFO] Create database $line"
	    "${psql[@]}" -c "CREATE DATABASE $line;" 2> /dev/null || true
	done

	# creating/updating logins
	echo "[INFO] Init/Update users"
	for (( i=0; i < "$LOGINS"; i++ )); do
	    USERNAME=$(jq --raw-output ".logins[$i].username" $CONFIG_PATH)
	    PASSWORD=$(jq --raw-output ".logins[$i].password" $CONFIG_PATH)

	    if ${psql[@]} -c "ALTER USER $USERNAME WITH PASSWORD '$PASSWORD';" 2> /dev/null; then
		echo "[INFO] Update user $USERNAME"
	    else
		echo "[INFO] Create user $USERNAME"
		${psql[@]} -c "CREATE USER $USERNAME WITH PASSWORD '$PASSWORD';" 2> /dev/null || true
	    fi
	done

	# setting permissions
	echo "[INFO] Init/Update rights"
	for (( i=0; i < "$RIGHTS"; i++ )); do
	    USERNAME=$(jq --raw-output ".rights[$i].username" $CONFIG_PATH)
	    DATABASE=$(jq --raw-output ".rights[$i].database" $CONFIG_PATH)
	    GRANT=$(jq --raw-output ".rights[$i].grant" $CONFIG_PATH)

	    echo "[INFO] Alter rights for $USERNAME - $DATABASE"
	    "${psql[@]}" -c "GRANT $GRANT DATABASE $DATABASE TO $USERNAME;" 2> /dev/null || true
	done

	PGUSER="${PGUSER:-$POSTGRES_USER}" \
	pg_ctl -D "$PGDATA" -m fast -w stop

	unset PGPASSWORD

	echo
	echo 'PostgreSQL init process complete; ready for start up.'
	echo
    fi
fi

exec "$@"
