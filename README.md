** Debian port of Mitel/Aastra SIP-DECT Open Mobility Manager **
By Guillaume "Elektordi" Genty

Project page on github: https://github.com/Elektordi/debian-sip-dect-omm


You need the original SIP-DECT OMM rpm from Mitel website. (CentOS version)

Install:
	# dpkg --add-architecture i386
	# apt-get update
	# apt-get install libc6:i386 libstdc++6:i386 zlib1g:i386
	Unpack the /opt folder from the rpm file to the target server
	Copy contents of the custom/ filder of this project to / on the target server
	# update-rc.d sip-dect-omm defaults
	# update-rc.d sip-dect-omm enable 2
	/etc/init.d/sip-dect-omm start

Then login the the webinterface on http port 80.
