#!/usr/bin/make -f
# Makefile for se3-clonezilla

all:

install:
    # Add here commands to install the package into folders.
    # Install des fichiers de configuration et de cron.
	#cp -R tftpboot $(DESTDIR)/
	cp -R scripts/* $(DESTDIR)/usr/share/se3/scripts/se3-clonezilla
	cp -R www/* $(DESTDIR)/var/www/se3/
	cp conf/se3_action_tftp_cron $(DESTDIR)/etc/cron.d/
	cp conf/sudoers-se3clonezilla $(DESTDIR)/etc/sudoers.d/sudoers-se3clonezilla
	
clean:
