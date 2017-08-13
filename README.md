# Debian port of Mitel/Aastra SIP-DECT Open Mobility Manager

*By Guillaume "Elektordi" Genty*

[![gitcheese.com](https://s3.amazonaws.com/gitcheese-ui-master/images/badge.svg)](https://www.gitcheese.com/donate/users/1229473/repos/48825306)

**Project page on github: https://github.com/Elektordi/debian-sip-dect-omm**

> I will find some time one day to make a real deb package, I will...
> But currently, here is the manual way to install it on Debian:

## Install:

You need the original SIP-DECT OMM rpm from Mitel website. (CentOS version)

    # dpkg --add-architecture i386
    # apt-get update
    # apt-get install libc6:i386 libstdc++6:i386 zlib1g:i386
    Unpack the /opt folder from the rpm file to the target server
    Copy contents of the custom/ folder from this project to / on the target server
    # update-rc.d sip-dect-omm defaults
    # update-rc.d sip-dect-omm enable 2
    /etc/init.d/sip-dect-omm start

Then login on the web admin panel on http port 80.
