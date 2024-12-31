# FreeBSD-shellinabox
build + install shellinabox on FreeBSD without using FreeBSD package management system

Alternative to: https://www.freshports.org/www/shellinabox/ which is

    Deprecated DEPRECATED: Abandonware and outdated, last release in 2016. Use sysutils/ttyd instead
    Expired This port expired on: 2024-12-24

needs root/sudo privileges for install on OS and run

Typical usage:
```
make
make install
make start

make stop
```

TODO: automatically create and use SSL cert cause you don't want OS user credentials plain text over network
