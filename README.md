# Freeradius

1. INSTALLATION

  If you do not need to modify the default configuration, then take
the following steps to build and install the server:


	$ sudo make

  The first time after installation, you should run the server as
"root" in $(PREFIX_BUILD_DIR) file.  This will cause the server to create the certificates it
needs for EAP.

	$ cd $(PREFIX_BUILD_DIR) (ex. cd /usr/joe/freeradius-server)
	$ sudo sbin/radiusd -X

  Once that is done, the server can be run from an unpriviledged user
account.
