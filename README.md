# debain-autoinstall-template
automated installation of debian 12, with remote script fetching via URLs


# Notes
The files in this repository are meant to be served with NGINX or Apache2
1) replace `dev.example.com` with your subdomain
2) replace `example.com` with your domain
3) Using debian 12 installer ISO, open advanced -> automated -> dev.example.com -> enter

# Files included in this repo
- index.html to signify root of webserver (running on `dev.example.com`)
- /d-i/bookworm/preseed.cfg being the debian installer preseed config for "bookworm" (debian 12) [Current Debian Releases](https://wiki.debian.org/DebianReleases)
- /d-i/bookworm/preseed.sh that runs in live ISO, which installs a service which will fetch and download scripts into the finished installation.
- /d-i/post-install.sh that will be fetched and ran upon boot and every 1-2 minutes thereafter.
