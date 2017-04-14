#!/bin/bash

#Variables

DATE=`date +%Y-%m-%d-%H-%M`

#récupération des paramètres se3 (ipse3 et xppass) 
. /etc/se3/config_m.cache.sh
accueil_mise_en_place()
{
echo " le se3 a pour ip: $se3ip"
echo " ce script  permet de créer un partage partimag sur le se3"
echo " Ce partage sera accéssible pour adminse3 et admin"
echo " Ensuite, le dispositif clonezilla sera mis en place, puis modifié de façon à ce qu'adminse3 puisse s'y connecter automatiquement"
PLACE=$(df -h /var/se3)
echo " La partition /var/se3 est dans l'état: "$PLACE" "
}
creation_partage()
{
echo -e " Voulez vous installer un partage samba situé dans /var/se3/partimag ? répondre  \033[1moui pour valider ou n'importe quoi d'autre pour sauter cette étape "
read reponse1

{
if [ "$reponse1" = "oui"  ]; then  echo "Création du partage samba "
mkdir -p /var/se3/partimag/

cat <<EOF>> /etc/samba/smb_etab.conf

[partimag]
        comment = images_clonezilla
        path    = /var/se3/partimag
        read only       = No
        valid users     = adminse3
        admin users     = adminse3
#</partimag>

EOF

chown -R admin:admins /var/se3/partimag
chmod -R 775 /var/se3/partimag/

#On relance le service samba
/etc/init.d/samba restart
echo "Le partage samba  'partimag' est maintenant fonctionnel et accessible par adminse3"
else
clear
echo "Le partage samba n'a pas été créé, passage à l'étape suivante"
fi
}

#etape 2
#On vérifie que clonezilla est bien installé
VERIF=$(ls -l /var/se3/ |grep clonezilla )
if [ "$VERIF" = ""  ]; then  echo " Clonezilla n'est pas installé sur le se3, l'archive va être téléchargée."
#on lance le script de téléchargement de clonezilla

bash /usr/share/se3/scripts/se3_get_clonezilla.sh

else
clear
echo "clonezilla est déjà installé sur le se3, pas besoin de le retélécharger."
fi

#etape 3
#on va modifier le livecd contenu dans le fichier filesystem.squashfs
#on installe le paquet squashfs-tools
apt-get install -y --force-yes squashfs-tools

#Modification du livecd clonezilla x86
cd /var/se3/clonezilla
mkdir -p /var/se3/temp/
cp /var/se3/clonezilla/filesystem.squashfs /var/se3/temp/
mv /var/se3/clonezilla/filesystem.squashfs  /var/se3/clonezilla/filesystem.squashfs-sav
cd /var/se3/temp/
unsquashfs filesystem.squashfs
#le fichier filesystem est décompressé dans un sous-répertoire squashfs-root, le fichier  filesystem.squashfs n'est donc plus utile
rm -f /var/se3/temp/filesystem.squashfs
#on va ensuite ajouter au livecd un fichier credentials situé dans /root du livecd contenant login et mdp d'adminse3
cd /var/se3/temp/squashfs-root/root/
touch credentials

cat <<EOF>> /var/se3/temp/squashfs-root/root/credentials
username=adminse3
password=$xppass
EOF

#On refabrique le fichier filesystem.squashfs
cd /var/se3/temp/
mksquashfs squashfs-root filesystem.squashfs -b 1024k -comp xz -Xbcj x86 -e boot
rm -Rf squashfs-root
mv /var/se3/temp/filesystem.squashfs /var/se3/clonezilla/filesystem.squashfs
chmod 444 /var/se3/clonezilla/filesystem.squashfs
touch /var/se3/clonezilla/modif_ok
rm -Rf /var/se3/temp/


#Modification du livecd clonezilla 64
cd /var/se3/clonezilla64
mkdir -p /var/se3/temp/
cp /var/se3/clonezilla64/filesystem.squashfs /var/se3/temp/
mv /var/se3/clonezilla64/filesystem.squashfs  /var/se3/clonezilla64/filesystem.squashfs-sav
cd /var/se3/temp/
unsquashfs filesystem.squashfs
#le fichier filesystem est décompressé dans un sous-répertoire squashfs-root, le fichier  filesystem.squashfs n'est donc plus utile
rm -f /var/se3/temp/filesystem.squashfs
#on va ensuite ajouter au livecd un fichier credentials situé dans /root du livecd contenant login et mdp d'adminse3
cd /var/se3/temp/squashfs-root/root/
touch credentials

cat <<EOF>> /var/se3/temp/squashfs-root/root/credentials
username=adminse3
password=$xppass
EOF

#On refabrique le fichier filesystem.squashfs
cd /var/se3/temp/
mksquashfs squashfs-root filesystem.squashfs -b 1024k -comp xz -e boot
rm -Rf squashfs-root
mv /var/se3/temp/filesystem.squashfs /var/se3/clonezilla64/filesystem.squashfs
chmod 444 /var/se3/clonezilla64/filesystem.squashfs
touch /var/se3/clonezilla/modif_ok
rm -Rf /var/se3/temp/



#etape 4, on va ajouter dans le menu perso.menu l'intrée clonezilla avec le montage du partage déjà fait
cat <<EOF>> /tftpboot/pxelinux.cfg/perso.menu
label Clonezilla-live
MENU LABEL restauration d'une image (sur se3)
KERNEL clonezilla64/vmlinuz
APPEND initrd=clonezilla64/initrd.img boot=live config noswap nolocales edd=on nomodeset  ocs_prerun="mount -t cifs //$ipse3/partimag /home/partimag/ -o credentials=/root/credentials"  ocs_live_run="ocs-sr  -e1 auto -e2  -r -j2  -p reboot restoredisk  ask_user sda" ocs_live_extra_param="" keyboard-layouts="fr" ocs_live_batch="no" locales="fr_FR.UTF-8" vga=788 nosplash noprompt fetch=tftp://$ipse3/clonezilla64/filesystem.squashfs

label Clonezilla-live
MENU LABEL creation d'une image (sur se3)
KERNEL clonezilla64/vmlinuz
APPEND initrd=clonezilla64/initrd.img boot=live config noswap nolocales edd=on nomodeset  ocs_prerun="mount -t cifs //$ipse3/partimag /home/partimag/ -o credentials=/root/credentials"  ocs_live_run="ocs-sr  -q2 -c -j2 -z1 -i 4096   -p reboot savedisk  ask_user sda" ocs_live_extra_param="" keyboard-layouts="fr" ocs_live_batch="no" locales="fr_FR.UTF-8" vga=788 nosplash noprompt fetch=tftp://"$ipse3"/clonezilla64/filesystem.squashfs

label Clonezilla-live
MENU LABEL restauration d'une image x86 (sur se3)
KERNEL clonezilla/vmlinuz
APPEND initrd=clonezilla/initrd.img boot=live config noswap nolocales edd=on nomodeset  ocs_prerun="mount -t cifs //$ipse3/partimag /home/partimag/ -o credentials=/root/credentials"  ocs_live_run="ocs-sr  -e1 auto -e2  -r -j2  -p reboot restoredisk  ask_user sda" ocs_live_extra_param="" keyboard-layouts="fr" ocs_live_batch="no" locales="fr_FR.UTF-8" vga=788 nosplash noprompt fetch=tftp://$ipse3/clonezilla/filesystem.squashfs

label Clonezilla-live
MENU LABEL creation d'une image x86 (sur se3)
KERNEL clonezilla/vmlinuz
APPEND initrd=clonezilla/initrd.img boot=live config noswap nolocales edd=on nomodeset  ocs_prerun="mount -t cifs //$ipse3/partimag /home/partimag/ -o credentials=/root/credentials"  ocs_live_run="ocs-sr  -q2 -c -j2 -z1 -i 4096   -p reboot savedisk  ask_user sda" ocs_live_extra_param="" keyboard-layouts="fr" ocs_live_batch="no" locales="fr_FR.UTF-8" vga=788 nosplash noprompt fetch=tftp://"$ipse3"/clonezilla/filesystem.squashfs




EOF

exit

