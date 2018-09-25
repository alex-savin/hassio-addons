# SmartHouse Hass.io Add-ons: Live555 RTSP Proxy Server

## About

[Live555 RTSP Proxy Server][live555] is a unicast RTSP server - built from the
"LIVE555 Streaming Media" software - that acts as a 'proxy' for one or more
'back-end' unicast or multicast RTSP/RTP streams (i.e., served by other server(s)).

The key feature of a proxy server is that it reads each 'back-end' stream only once, regardless of how many separate clients are streaming from the proxy server. This makes the proxy server ideal, for example, for streaming from a RTSP-enabled video camera (which might not be able to handle more than one connection at a time).
```
                                                              --> [RTSP client1]
        [back-end RTSP/RTP stream] --> [LIVE555 Proxy Server] --> [RTSP client2]
                                                              ...
                                                              --> [RTSP clientN]
```
Basic operation
The "LIVE555 Proxy Server" is a command-line (i.e., 'console') application. The simplest way to run it is to type:
```
        live555ProxyServer <url>
```
where <url> is a RTSP URL (i.e., beginning with "rtsp://") of a 'back-end' stream (e.g., from a video camera). 
After starting up, the server will display its own "rtsp://" URL for the proxy stream. RTSP clients can then use 
this URL to play (i.e., receive) the proxy stream.
The server can act as a proxy for many 'back-end' streams - not just one. If you enter more than one "rtsp://" URL 
on the command line, i.e.,
```
        live555ProxyServer <url1> <url2> ... <urlN>
```
then the server will - after starting up - display "rtsp://" URLs for proxying each one. (Of course, you should 
proxy multiple streams only if you have sufficient network bandwidth to receive all of them.)


This add-on is a port of Live555 RTSP Proxy Server to be able to run on Hass.io 
and is based on Alpine Linux and is using Docker.

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Hass.io add-on.

**NOTE**: Your Hass.io machine MUST HAVE a static IP for this add-on to function
properly/fully.

1. [Add our Hass.io add-ons repository][repository] to your Hass.io instance.
1. Install the "Live555 RTSP Proxy Server" add-on
1. Start the "Live555 RTSP Proxy Server" add-on
1. Check the logs of the "Live555 RTSP Proxy Server" add-on to see it in action.

**NOTE**: Do not add this repository to Hass.io, please use:
`https://github.com/alex-savin/hassio-addons`.

## Docker status


## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```json
{
  "log_level": "info",
  "streams": [
    "rtsp://[username]:[password]@[camera_ip]:[port]/[stream_uri]"
  ]
}
```

**Note**: _This is just an example, don't copy and past it! Create your own!_

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`:  Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

### Option: `streams`

This option allows you to a list of camera streams (e.g., point 
`rtsp://[username]:[password]@[camera_ip]:[port]/[stream_uri]`to the IP address of your camera stream).

See the example above this chapter for a more visual representation.

**Note**: _We STRONGLY suggest picking a stronger/safer password instead of
using this option! USE AT YOUR OWN RISK!_

## Changelog & Releases

This repository keeps a change log using [GitHub's releases][releases]
functionality. The format of the log is based on
[Keep a Changelog][keepchangelog].

Releases are based on [Semantic Versioning][semver], and use the format
of ``MAJOR.MINOR.PATCH``. In a nutshell, the version will be incremented
based on the following:

- ``MAJOR``: Incompatible or major changes.
- ``MINOR``: Backwards-compatible new features and enhancements.
- ``PATCH``: Backwards-compatible bugfixes and package updates.

## Support

Got questions?

You have several options to get them answered:

- The [Community Hass.io Add-ons Discord chat server][discord] for add-on
  support and feature requests.
- The [Home Assistant Discord chat server][discord-ha] for general Home
  Assistant discussions and questions.
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

You could also [open an issue here][issue] GitHub.

## Contributing

This is an active open-source project. We are always open to people who want to
use the code or contribute to it.

We have set up a separate document containing our
[contribution guidelines](CONTRIBUTING.md).

Thank you for being involved! :heart_eyes:

## Authors & contributors

The original setup of this repository is by [Alex Savin][alex-savin].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## We have got some Hass.io add-ons for you

Want some more functionality to your Hass.io Home Assistant instance?

We have created multiple add-ons for Hass.io. For a full list, check out
our [GitHub Repository][repository].

## Trademark legal notice

This add-on is not created, developed, affiliated, supported, maintained
or endorsed by Live Networks, Inc.

All product names, logos, brands, trademarks and registered trademarks are
property of their respective owners. All company, product, and service names
used are for identification purposes only.

Use of these names, logos, trademarks, and brands does not imply endorsement.

## License

MIT License

Copyright (c) 2018 Alex Savin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[commits]: https://github.com/alex-savin/hassio-addons/live555/commits/master
[contributors]: https://github.com/alex-savinhassio-addons/live555/graphs/contributors
[discord-ha]: https://discord.gg/c5DvZ4e
[discord-shield]: https://img.shields.io/discord/478094546522079232.svg
[discord]: https://discord.me/hassioaddons
[forum-shield]: https://img.shields.io/badge/community-forum-brightgreen.svg
[alex-savin]: https://github.com/alex-savin
[issue]: https://github.com/alex-savin/hassio-addons/issues
[keepchangelog]: http://keepachangelog.com/en/1.0.0/
[license-shield]: https://img.shields.io/github/license/hassio-addons/addon-pi-hole.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2018.svg
[live555]: http://www.live555.com/proxyServer/
[reddit]: https://reddit.com/r/homeassistant
[releases]: https://github.com/alex-savin/hassio-addons/releases
[repository]: https://github.com/alex-savin/hassio-addons/
[semver]: http://semver.org/spec/v2.0.0.html
