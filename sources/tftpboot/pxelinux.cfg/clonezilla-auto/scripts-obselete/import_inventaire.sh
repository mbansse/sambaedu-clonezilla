#!/bin/bash
#
##### Script de génération du fichier de correspondance NOM;IP;MAC;PARCS #####
#
# Auteur : Stephane Boireau (Bernay/Pont-Audemer (27))
#
## $Id$ ##
# modifié par Marc Bansse pour générer l'inventaire simple dans le script /tftpboot/pxelinux.cfg/clonezilla-auto/temp/ et ajouter les parcs dans lequels une machine est inscrite.

if [ "$1" = "--help" -o "$1" = "-h" ]; then
	echo "Script permettant de générer un fichier de correspondances NOM;IP;MAC;PARCS pour"
	echo "l'outil se3-clonezilla"
	echo ""
	echo "Usage : Pas d'option."
	exit
fi


dest=/tftpboot/pxelinux.cfg/clonezilla-auto/temp/

fich_nom_ip_mac_parcs="$dest/inventaire.csv"

BASE=$(grep "^BASE" /etc/ldap/ldap.conf | cut -d" " -f2 )
ldapsearch -xLLL -b ou=computers,$BASE cn | grep ^cn | cut -d" " -f2 | while read nom
do
	if [ ! -z $(echo ${nom:0:1} | sed -e "s/[0-9]//g") ]; then
		# PB: on récupère les cn des entrées machines aussi (xpbof et xpbof$)
		ip=$(ldapsearch -xLLL -b ou=computers,$BASE cn=$nom ipHostNumber | grep ipHostNumber | cut -d" " -f2)
		mac=$(ldapsearch -xLLL -b ou=computers,$BASE cn=$nom macAddress | grep macAddress | cut -d" " -f2)
		parcs=$( ldapsearch -xLLL  -b ou=Parcs,$BASE | sed -e '/./{H;$!d;}' -e 'x;/'$nom'/!d;'|grep dn: |sed 's/.*cn=//' |sed 's/,ou.*//'|sed 1n | tr '\n' ' ' |sed 's/>%/>\n/g')
		if [ ! -z "$ip" -a ! -z "$mac" ]; then
			echo "$ip;$nom;$mac;$parcs" >> $fich_nom_ip_mac_parcs
			
		fi
	fi
done

echo "Les fichiers ont été générés dans $dest"
echo "Terminé."
