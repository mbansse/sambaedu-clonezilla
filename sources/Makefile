#!/usr/bin/make -f
# Makefile for sambaedu-clonezilla

all:

install:
    # Add here commands to install the package into folders.
    # Install des fichiers de configuration et de cron.
	#cp -R tftpboot $(DESTDIR)/
	cp -R scripts/* $(DESTDIR)/usr/share/sambaedu/scripts/sambaedu-clonezilla
	cp -R www/* $(DESTDIR)/var/www/sambaedu/
	cp conf/sambaedu_action_tftp_cron $(DESTDIR)/etc/cron.d/
	cp conf/sudoers-sambaeduclonezilla $(DESTDIR)/etc/sudoers.d/sudoers-sambaeduclonezilla
	
clean:
