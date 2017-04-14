#!/bin/bash

#####################################################################################
##### Script permettant de lancer des commandes PXE
##### Il servira essentiellement à restaurer des images clonezilla sur des postes clients
##### pour une restauration du serveur SE3
##### version du 16/04/2014
##### modifiée le 29/06/2016
#
# Auteurs :      Marc Bansse marc.bansse@ac-versailles.fr
#
# Modifié par :  
#
# Ce programme est un logiciel libre : vous pouvez le redistribuer ou
#    le modifier selon les termes de la GNU General Public Licence tels
#    que publiés par la Free Software Foundation : à votre choix, soit la
#    version 3 de la licence, soit une version ultérieure quelle qu'elle
#    soit.
#
# Ce programme est distribué dans l'espoir qu'il sera utile, mais SANS
#    AUCUNE GARANTIE ; sans même la garantie implicite de QUALITÉ
#    MARCHANDE ou D'ADÉQUATION À UNE UTILISATION PARTICULIÈRE. Pour
#    plus de détails, reportez-vous à la GNU General Public License.
#
# Vous devez avoir reçu une copie de la GNU General Public License
#    avec ce programme. Si ce n'est pas le cas, consultez
#    <http://www.gnu.org/licenses/>]





#définition des variables
TEMP=$(mktemp -d --suffix=-clonezilla-auto)
#récupération des variables se3 (variable se3ip)
. /etc/se3/config_m.cache.sh
BASE=$(grep "^BASE" /etc/ldap/ldap.conf | cut -d" " -f2 )
DATE=`date +%Y-%m-%d-%H-%M`
#variable  à changer et à décommenter
PXE_PERSO="/tftpboot/pxelinux.cfg/clonezilla-auto/pxeperso"
mkdir -p /var/log/clonezilla-auto/$DATE
LOG="/var/log/clonezilla-auto/$DATE/"







logo()
{
clear
echo "...............................?~~~~=..............~+=.................................................................."
echo "..............................?~~~.?~.............=+++~.................~~=++++:...........................,~~~,........"
echo "..............................~~~...~?...........~++++~...............+++++++++~.......................~~III~=III7~....."
echo ".............................=~~....=~...........++++~~................++++++~~......................~???~.....~7777~..."
echo ".............................~~~....=~..........~+~~~~.................:+++++~......................~???III=:...?7777~.."
echo ".?=~+?..++~~~=?.?+=~=??+~~=.+~~?~~?.~~I=~~~=?....~......................=+++++...............+~,....~???IIIII~.~77777~.."
echo "?~~=..=~~+.~~~:+~~?=~~~.~~~.~~~.:~~?+~~?.~~~....~:+++++~~...............~+++++~..............++++++~~???IIIII,.~77777~.."
echo ":+~~~??:~~=~~=.~~~.:~:.+~~??~~~~~~+~+~~~?:~?.~++++++++++++:.....:++++:...+++++~..+++++++++~.,++++~~~.:~=?=~~..~777777~.."
echo ".......................~~:.........=~?......~+++:~~~:,~:+++~...~++++++++.+++++~.~~~~~~+++:~.~+++:,..........~II7777~~..."
echo "......................~~~=.........~~......~++++~......:++++:.~+++++++++++++++~.....:++++~..~+++~........~IIIII~~~......"
echo "....................?I~~~?........=~~......+++++++++++++++++~,++++++++++++++++~....:++++~:..?+++~........:~~~~IIIIII=~.."
echo ".....................:~~=?~.......~~~......++++++~~+++++++++~:+++++:~~~~~+++++~...~+++++~..,++++~.............~IIIIIII~."
echo ".....................,:?~~~=.....?~~.......++++++~...~~~~~++~+++~~~......~+++=~...+++++~,..~++++~......:~~.....~??????+."
echo "......................,~~~~??....~::.......:+++++~..:?+~~..:~+++~.......:++++~...~+++++~...+++++~...~=+++???~..~???????~"
echo ".......................,~~+.....=~?........:+++++~.+++++++~..++++~:..:~++++++~...++++++~..~+++++~..~++++++++?~..???????,"
echo ".......................?~~:....+~~..........~++++~.++++++++~.+++++++++++++++~++:.++++++~..+++++++++~+++++++++...?+++++~."
echo ".......................~~~.....~~............++++:.~+++++++~.++++++++++++++++++~,+++++++:++=+++++++~+++++++~:...++++++:."
echo ".......................~~~....~~..............++++~..:++++~~..+++++++++~~+++++?~.++++++++~~+++++~~~~~+++=~.....~+++++:.."
echo ".......................+~:...~?................~=++++++++~~....~~~~~~~~,~:~~~~.~.,++++++~~.++~~~......:++~::=++++++~...."
echo "........................~~+?+....................~~~~~~~~................~.........~~~~~..::~,..........,~~~~~~~,......."
echo "...........................................................................................:............................"
echo ""
echo " Ce script va permettre de:"
echo ""
echo -e "\033[31m(1)\033[0m\033[4mMettre en place un partage samba  appelé \033[1mpartimag\033[0m sur /var/se3, télécharger clonezilla sur le serveur et le rendre accessible automatiquement par adminse3."
echo ""
echo -e "\033[31m(2)\033[0mRestaurer automatiquement une image clonezilla placée dans le partage samba \033[1mpartimag du se3\033[0m sur un parc de machine (ou machine seule)."
echo ""
echo -e "\033[31m(3)\033[0mRestaurer automatiquement une image clonezilla placée dans un partage samba (autre que sur SE3) sur un parc de machine (ou machine seule)."
echo ""
echo -e "\033[31m(4)\033[0mLancer des commandes  pxe personnalisées sur une mchine ou un ensemble de machines"
echo ""
echo -e "Entrer le \033[31mnumero\033[0m correspondant à votre choix ou \033[4mn'importe quoi\033[0m pour quitter, puis la touche entrée."
read  choixlanceur
}

#----- -----
# les fonctions

#Les fonctions notées  *_samba proviennent du script pour restaurer une image placée sur un partage samba quelconque
#----- -----

accueil_mise_en_place()
{
echo " le se3 a pour ip: $se3ip"
echo " ce script  permet de créer un partage partimag sur le se3"
echo " Ce partage sera accéssible pour adminse3 et admin"
echo " Ensuite, le dispositif clonezilla sera mis en place, puis modifié de façon à ce qu'adminse3 puisse s'y connecter automatiquement"
PLACE=$(df -h /var/se3)
echo " La partition /var/se3 est dans l'état: "$PLACE" "
}

accueil_samba()
{
 #On demande à l'utilisateur quelle image restaurer parmi celles qui sont présentes dans le répertoire image
# On affiche une liste de type d images ( dans un répertoire): on demande quel type d'image sera à restaurer: il faudra donc creer un fichier commande-pxe-parc (appelé M72-tertaire par ex) pour chaque type d image.
clear
echo "Ce script permet de restaurer une image clonezilla existante  sur un/plusieurs postes du réseau"
echo ""
echo "Les images existantes doivent être stockées sur un partage samba "
echo ""
echo "Les postes doivent avoir le wakeonlan d'activé et un boot par défaut en pxe "
    }

accueil_se3()
{
 #On demande à l'utilisateur quelle image restaurer parmi celles qui sont présentes dans le répertoire image
# On affiche une liste de type d images ( dans un répertoire): on demande quel type d'image sera à restaurer: il faudra donc creer un fichier commande-pxe-parc (appelé M72-tertaire par ex) pour chaque type d image.
clear
echo "Ce script permet de restaurer une image clonezilla existante  sur un/plusieurs postes du réseau"
echo ""
echo -e "Les images existantes doivent être stockées sur le partage \033[31m "partimag"\033[0m créé sur le se3 par le script de mise en place (choix n°1 du script "clonezilla-auto") "
echo ""
echo "Les postes doivent avoir le wakeonlan d'activé et un boot par défaut en pxe "
}
accueil_pxeperso()
{
#On demande à l'utilisateur quelle image restaurer parmi celles qui sont présentes dans le répertoire pxeperso
# On affiche une liste des commandes personnalises dans le répertoire): on demande laquelle sera à appliquer:
#il faudra donc creer un fichier commande-pxe pour chaque type de poste (appelé M72-tertaire par ex).
clear
echo " Ce script permet d'envoyer une consigne de boot par pxe(par exemple restaurer une image clonezilla existante, faire une sauvegarde locale)  sur un/plusieurs postes"
echo "Les postes doivent avoir le wakeonlan d'activé, un boot par défaut en pxe "
echo "recopier parmi la liste suivante la commande pxe à envoyer ( type d'image à restaurer dans le cadre de clonezilla) "
#la liste des fichiers de commande pxe est placée dans le répertoire pxeperso, son contenu va être lu ici.
ls  "$PXE_PERSO"
read choix

#On vérifie que ce qui a été tapé correspond bien à une image existante
VERIF=$(ls "$PXE_PERSO" |grep "$choix")
#si ce qui a été  tapé ne correspond à aucune ligne de la liste, alors le script s'arrête.
if [ "$VERIF" = ""  ]; then  echo "pas d'image choisie ou image inexistante, le script est arrêté"
exit
else
echo "les commandes pxe personnalisées contenues dans  $choix seront envoyées sur les postes"
fi
}
creation_partage()
{
echo -e " Voulez vous installer un partage samba situé dans /var/se3/partimag ? répondre  \033[1moui pour valider ou n'importe quoi d'autre pour sauter cette étape "
read reponse1

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

modif_clonezilla()
{
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
}

ajout_pxe()
{
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
}

choix_clonezilla()
{
echo " Vous devez choisir si vous voulez utiliser la version 32 bits (clonezilla), ou la version 64 bits (clonezilla64) "
echo -e "Taper \033[31mclonezilla\033[0m  ou   \033[31mclonezilla64\033[0m puis appuyer sur entrée ."
read CLONEZILLA
}

prealable_samba()
{
#creation du répertoire de montage pour la première utilisation et mise en variable
mkdir -p /mnt/liste-image/
LISTE_IMAGE="/mnt/liste-image/"
#création du répertoire contenant les fichiers temporaires et mise en variable
mkdir -p /var/log/clonezilla-auto/$DATE
LOG="/var/log/clonezilla-auto/$DATE/"
}

prealable_se3()
{
#creation du répertoire de montage pour la première utilisation et mise en variable
LISTE_IMAGE="/var/se3/partimag/"
#création du répertoire contenant les fichiers temporaires et mise en variable
mkdir -p /var/log/clonezilla-auto/$DATE
LOG="/var/log/clonezilla-auto/$DATE/"
}


choix_samba()
{
#L'utilisateur doit entrer l'ip du partage samba, le nom du partage, le login de l'utilisateur et le mdp
#echo ""
#echo ""
#echo " Vous devez choisir si vous voulez utiliser la version 32 bits (clonezilla), ou la version 64 bits (clonezilla64) "
#echo -e "Taper \033[31mclonezilla\033[0m  ou   \033[31mclonezilla64\033[0m puis appuyer sur entrée ."
#read CLONEZILLA
echo -e "\033[34mEntrer l'ip du partage samba\033[0m (ex  172.20.0.6)"
read IPSAMBA
echo -e "\033[34mEntrer le nom du partage samba\033[0m  (ex partimag) "
read PARTAGE
echo -e "\033[34mEntrer le nom d'un utilisateur autorisé à lire sur le partage\033[0m (ex clonezilla)"
read USER
echo -e "\033[34mEntrer le mot de passe de l'utilisateur\033[0m  (le mot de passe n'apparait pas sur l'écran )"
read -s MDP
}
montage_samba()
{
echo " le partage samba est monté provisoirement dans $LISTE_IMAGE"
#le partage samba contenant les images est monté dans le répertoire liste_image juste pour établir le fichier  contenant la liste des images disponibles.
mount -t cifs //$IPSAMBA/$PARTAGE $LISTE_IMAGE -o user=$USER,password=$MDP
#vérification que le montage s'est fait correctement (si le répertoire liste-image n'est pas monté, on quitte le script)
VERIFMONTAGE=$(mount |grep liste-image)
if [ "$VERIFMONTAGE" = ""  ]; then  echo " le montage de partage samba a échoué, veuillez vérifier les paramètres entrés puis relancer le script"
rm -Rf "$TEMP"
exit
else
clear
echo -e "le montage du partage samba est effectué,recopier parmi la liste suivante le \033[31m\033[1m NOM EXACT\033[0m  de l'image à restaurer."
fi
}

choix_image_samba()
{
# on affiche la liste des images disponibles sur le partage.
ls   "$LISTE_IMAGE"
#la liste des  images est écrite dans un fichier liste 
ls   "$LISTE_IMAGE" > "$TEMP"/liste
read choix
#On démonte le partage samba du se3
umount  "$LISTE_IMAGE"
#On vérifie que ce qui a été tapé correspond bien à une image existante
VERIF=$(cat $TEMP/liste |grep $choix)
if [ "$VERIF" = ""  ]; then  echo "pas d'image choisie ou image inexistante, le script est arrêté"
rm -Rf "$TEMP"
exit
else
clear
echo -e "L'image appelée \033[31m$choix \033[0m a été choisie."
fi
}

choix_image_se3()
{

# on vérifie qu'il y a bien une image à restaurer sur le partage (on va voir directement le contenu de /var/se3/partimag/).
ls   "$LISTE_IMAGE"
if [ "$LISTE_IMAGE" = ""  ]; then echo " pas d'image dans le répertoire /var/se3/partimag/"
exit
else
clear
echo -e "Recopier parmi la liste suivante le \033[31m\033[1m NOM EXACT\033[0m  de l'image à restaurer."
fi


#la liste des  images est écrite dans un fichier liste
ls   "$LISTE_IMAGE"
ls   "$LISTE_IMAGE" > "$TEMP"/liste
read choix

#On vérifie que ce qui a été tapé correspond bien à une image existante
VERIF=$(cat $TEMP/liste |grep $choix)
if [ "$VERIF" = ""  ]; then  echo "pas d'image choisie ou image inexistante, le script est arrêté"
#rm -Rf "$TEMP"
exit
else
clear
echo -e "L'image appelée \033[31m$choix \033[0m a été choisie."
fi
}


creation_pxe_perso_samba()
{
# On peut maintenant créer un fichier de commande pxe personnalisé pour le clonage clonezilla
cat <<EOF> "$TEMP"/pxe-perso
# Script de boot pour personnalisé: image déployée = "$choix" 

# Echappatoires pour booter sur le DD:
label 0
   localboot 0x80
label a
   localboot 0x00
label q
   localboot -1
label disk1
   localboot 0x80
label disk2
  localboot 0x81

label clonezilla
#MENU LABEL Clonezilla restore "$choix" (partimag)
KERNEL $CLONEZILLA/vmlinuz
APPEND initrd=$CLONEZILLA/initrd.img boot=live config noswap nolocales edd=on nomodeset  ocs_prerun="mount -t cifs //$IPSAMBA/$PARTAGE /home/partimag/ -o user=$USER,password=$MDP "  ocs_live_run="ocs-sr  -e1 auto -e2  -r -j2  -p reboot restoredisk  $choix sda" ocs_live_extra_param="" keyboard-layouts="fr" ocs_live_batch="no" locales="fr_FR.UTF-8" vga=788 nosplash noprompt fetch=tftp://$se3ip/$CLONEZILLA/filesystem.squashfs

# Choix de boot par défaut:
default clonezilla

# On boote après 6 secondes:
timeout 60

# Permet-on à l'utilisateur de choisir l'option de boot?
# Si on ne permet pas, le timeout n'est pas pris en compte.
prompt 1
EOF
}

creation_pxe_perso_se3()
{
# On peut maintenant créer un fichier de commande pxe personnalisé pour le clonage clonezilla
cat <<EOF> "$TEMP"/pxe-perso
# Script de boot pour personnalisé: image déployée = "$choix"

# Echappatoires pour booter sur le DD:
label 0
   localboot 0x80
label a
   localboot 0x00
label q
   localboot -1
label disk1
   localboot 0x80
label disk2
  localboot 0x81

label clonezilla
#MENU LABEL Clonezilla restore "$choix" (partimag)
KERNEL $CLONEZILLA/vmlinuz
APPEND initrd=$CLONEZILLA/initrd.img boot=live config noswap nolocales edd=on nomodeset  ocs_prerun="mount -t cifs //$se3ip/partimag /home/partimag/ -o credentials=/root/credentials "  ocs_live_run="ocs-sr  -e1 auto -e2  -r -j2  -p reboot restoredisk  $choix sda" ocs_live_extra_param="" keyboard-layouts="fr" ocs_live_batch="no" locales="fr_FR.UTF-8" vga=788 nosplash noprompt fetch=tftp://$se3ip/$CLONEZILLA/filesystem.squashfs

# Choix de boot par défaut:
default clonezilla

# On boote après 6 secondes:
timeout 60

# Permet-on à l'utilisateur de choisir l'option de boot?
# Si on ne permet pas, le timeout n'est pas pris en compte.
prompt 1
EOF
}


maj_machines()
{
#On génère le nouveau fichier d'inventaire d'après la branche computer ldap en lançant le script prévu à cet effet.
echo "le script génère le nouveau fichier d'inventaire des machines( cela prendra quelques secondes)"

##### Script de génération du fichier de correspondance NOM;IP;MAC;PARCS #####
#
# Auteur : Stephane Boireau (Bernay/Pont-Audemer (27))
#
## $Id$ ##
# modifié par Marc Bansse pour générer l'inventaire simple dans le script /tftpboot/pxelinux.cfg/clonezilla-auto/temp/ et ajouter les parcs dans lequels une machine est inscrite.


fich_nom_ip_mac_parcs="$TEMP/inventaire.csv"

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

echo "Les fichiers ont été générés dans $TEMP"
echo "Terminé."

#on a ainsi placé dans le répertoire temp un export des entrées computer du ldap.  Chaque ligne est du genre ip;nom-netbios;mac;parcs   (ex:172.20.50.101;virtualxp1;08:00:27:0e:5a:d0;m72e sciences)

echo ""
#On effectue une recherche ldap pour  afficher l'ensemble des parcs  mis en place. Chaque parc est espacé d'un autre.
LISTE_PARCS=$(ldapsearch -xLLL  -b ou=Parcs,$BASE|grep dn:|sed 's/.*cn=//'|sed 's/,ou.*//' |sed '1d' |sed 1n |sed 's/$/ /'| tr '\n' ' ' |sed 's/>%/>\n/g')
}

choix_machines()
{
echo -e "\033[4mPour rappel, voici la liste des parcs\033[0m"
echo "$LISTE_PARCS"
echo""
echo -e "Entrer \033[1mle nom du parc\033[0m (ex sciences) ou \033[1mles premiers octets\033[0m de l'ip du parc à cloner (ex 172.20.50.)\033[0m"
echo -e "S'il faut restaurer seulement \033[1mun poste\033[0m, on entrera l'adresse ip (ex 172.20.50.101) ou le nom  du poste (ex s218-2)" 
read debutip

# on affiche uniquementt les entrées du fichier d'export contenant ce début d'ip
cat  $TEMP/inventaire* |grep "$debutip" > "$TEMP"/exportauto
#On a créé un fichier "exportauto" à partir du fichier d'inventaire dhcp qui contient quatre colonnes ip;nom-netbios;mac;parcs   (ex:172.20.50.101;virtualxp1;08:00:27:0e:5a:d0;m72e sciences) 

#on ne garde que la deuxième colonne pour avoir la liste des postes sensés être clonés qu'il faudra vérifier.
cut -d';' -s -f2   "$TEMP"/exportauto > "$TEMP"/verifpostes


#Il faut maintenant confirmer que les postes à restaurer sont bien ceux qui sont attendus.
echo " vous avez choisi les postes dont l'ip est/commence par \033[34mA"$debutip"\033[0m. "

echo -e " \033[31mATTENTION, le mdp du partag samba va apparaitre très brievement en clair sur l'écran des postes lors du montage automatique du serveur\033[0m."
echo -e "\033[1mVeillez à ce que la salle soit vide\033[Om"
POSTES=$(cat "$TEMP"/verifpostes)


clear
#si la liste des postes est vide, c'est qu'aucun ordinateur ne correspond à la demande
if [ "$POSTES" = "" ]; then echo "aucun poste ne correspond à cette demande"
exit
else echo "les postes suivants seront effacés puis restaurés. "
echo -e "\033[34m"$POSTES"\033[0m"
echo -e "taper \033[31moui\033[0m pour continuer ou \033[34mnano\033[0m pour éditer la liste des postes à restaurer"
echo -e "Pour éditer la liste, il suffit de \033[31msupprimer les lignes entières inutiles \033[0m. On enregistre \033[31m(CTRL+O)\033[0m , suivi de quitter \033[31m(CTRL+X)\033[0m ." 
read REPONSE
fi

#On relance la procédure de vérification avec le nouveau exportauto
if [ "$REPONSE" = nano ]; then  nano "$TEMP"/exportauto 
else echo "On continue"
 fi
cut -d';' -s -f2   "$TEMP"/exportauto > "$TEMP"/verifpostes2
POSTES2=$(cat "$TEMP"/verifpostes2)

clear
#si la liste des postes est vide, c'est qu'aucun ordinateur ne correspond à la demande
if [ "$POSTES2" = "" ]; then echo "aucun poste ne correspond à cette demande"
exit
else echo " Etes-vous sur de vouloir restaurer ces postes?"
echo -e "\033[31m "$POSTES2"\033[0m"
echo -e " \033[4mATTENTION, le mdp du partag samba va apparaitre très brievement en clair sur l'écran des postes lors du montage automatique du serveur, veillez à ce que la salle soit vide\033[0m"
echo -e "taper \033[31moui\033[0m pour continuer ou autre chose pour quitter"
read REPONSE2
fi

# On continue le script uniquement si la réponse oui est faite. tout autre choix provoque l'arret du script.

if [ "$REPONSE2" = oui ]; then  echo "On lance le clonage" 
else
 echo "Clonage annulé"
 #on efface les fichiers temporaires créés
rm -f "$TEMP"/*
 exit  
fi
}

generation_variables()
{
#ici, le fichier exportauto a été  édité et contient donc la véritable liste des postes à restaurer
#On le sauvegarde dans log pour vérifier en cas de problème.
cp "$TEMP"/exportauto "$LOG"

#on supprime les deux premières colonnes contenant le nom et l'ip pour ne garder que la troisième colonne contenant l'adresse mac.
cut -d';' -s -f3   "$TEMP"/exportauto > "$TEMP"/liste1
cp "$TEMP"/liste1 "$LOG"mac

#on ne garde que la deuxième colonne pour avoir la liste des postes cloné
cut -d';' -s -f2   "$TEMP"/exportauto > "$TEMP"/postes
cp "$TEMP"/postes "$LOG"

# on modifie  le fichier liste1 pour remplacer les ":" par des "-" pour la création du fichier 01-suitedel'adressemac
sed 's/\:/\-/g' "$TEMP"/liste1 > "$TEMP"/listeok
cp "$TEMP"/listeok "$LOG"mac_tirets


#On place la première adresse mac de la listemac  dans une variable pour créer ensuite le fichier de commande pxe personnalisé du poste.
#toutes les majuscules de l'adresse mac doivent être transformées en minuscules, ou le pxe du poste ne sera pas pris en compte par la machine
mac=$(sed -n "1p" "$TEMP"/listeok | sed 's/.*/\L&/')
#On met en variable le nom du premier poste de la liste pour le lancer avec le script se3 lance_poste
NOM_CLIENT=$(sed -n "1p" "$TEMP"/postes)
}



boucle()
{
#on  crée notre boucle ici: On va supprimer la première ligne de la liste des adresses mac. Dès que le fichier contenant les adresses mac est vide, il y a arret de la boucle
until [ "$mac" = "" ]
do 
 
#le fichier de commande pxe choisi pour les xp est copié dans le répertoire pxelinux.cfg. Il faut ajouter '01'-devant l'adresse mac
cp  "$TEMP"/pxe-perso /tftpboot/pxelinux.cfg/01-"$mac"
cp  "$TEMP"/pxe-perso "$LOG"01-"$mac"-"$NOM_CLIENT"
chmod 644 /tftpboot/pxelinux.cfg/01-*
 

#si le poste est déjà allumé sous windows, on lui envoie un signal de reboot
/usr/share/se3/scripts/start_poste.sh  "$NOM_CLIENT" reboot
/usr/share/se3/scripts/start_poste.sh  "$NOM_CLIENT" wol



#la première ligne du fichier listeok/liste1/postes est à supprimer pour que l'opération continue avec les adresses mac suivantes
sed -i '1d' "$TEMP"/listeok
sed -i '1d' "$TEMP"/liste1
sed -i '1d' "$TEMP"/postes

#On  actualise la vairable mac.
mac=$(sed -n "1p" "$TEMP"/listeok | sed 's/.*/\L&/')

#On actualise les variables NOM_CLIENT
NOM_CLIENT=$(sed -n "1p" "$TEMP"/postes)


done
}

boucle_pxeperso()
{
#on  créer notre boucle ici: On va supprimer la première ligne de la liste des adresses mac. Dès que le fichier contenant les adresses mac est vide, il y a arret de la boucle
until [ "$mac" = "" ]
do

#le fichier de commande pxe choisi pour les xp est copié dans le répertoire pxelinux.cfg. Il faut ajouter '01'-devant l'adresse mac
cp "$PXE_PERSO"/"$choix" /tftpboot/pxelinux.cfg/01-"$mac"
chmod 644  /tftpboot/pxelinux.cfg/01-*
cp "$PXE_PERSO"/"$choix" "$LOG"/01-"$mac"-"$NOM_CLIENT"


#Il faut ensuite allumer le poste qui va donc détecter les instructions pxe.
/usr/share/se3/scripts/start_poste.sh "$NOM_CLIENT" reboot
/usr/share/se3/scripts/start_poste.sh "$NOM_CLIENT" wol
#la première ligne du fichier listeok est à supprimer pour que l'opération continue avec les adresses mac suivantes. Idem avec les autres fichiers
sed -i '1d' "$TEMP"/listeok
sed -i '1d' "$TEMP"/liste1
sed -i '1d' "$TEMP"/postes

#On actualise la variable en mettant des majuscules dans les adresses mac au lieu des minuscules!
mac=$(sed -n "1p" "$TEMP"/listeok | sed 's/.*/\L&/')

#On actualise la variable.
mac2=$(sed -n "1p" "$TEMP"/liste1)
#On actualise la variable.
NOM_CLIENT=$(sed -n "1p" "$TEMP"/postes)

done
}

fin_script_samba()
{

if [ "$mac" = "" ]; then  echo "On attends deux minutes pour que les postes aient le temps de booter en pxe et de récupérer les consignes"
sleep 2m
else echo " ça continue..."
# Normalement on ne devrait pas avoir  besoin de du if, car cette partie est lancée seulement quand la boucle est terminée
fi


#On attend deux minutes que les ordinateurs se lancent, recoivent leur instruction pour ensuite effacer les fichiers nommés avec l'adresse mac ou le poste se clonera en boucle.
#echo "On attends deux minutes pour que les postes aient le temps de booter en pxe et de récupérer les consignes"
#sleep 2m

#on efface tous les fichiers commecnant par 01- , seuls les fichiers générés par le script  sont donc effacés.
rm -f /tftpboot/pxelinux.cfg/01*
rm -Rf "$TEMP"
}

####fin des fonctions###



###début du programme###
#logo est commun à tous les sous-scripts
logo


if [ "$choixlanceur" = "1" ]
then
accueil_mise_en_place
creation_partage
modif_clonezilla
ajout_pxe
exit

elif [ "$choixlanceur" = "2" ]
then
#bash  "$CHEMIN"/scripts/clonezilla-manuel-se3
accueil_se3
prealable_se3
choix_clonezilla
choix_image_se3
creation_pxe_perso_se3
maj_machines
choix_machines
generation_variables
boucle
fin_script_samba
echo "bonjour choix n°2"
elif [ "$choixlanceur" = "3" ]
then
accueil_samba
prealable_samba
choix_clonezilla
choix_samba
montage_samba
choix_image_samba
creation_pxe_perso_samba
maj_machines
choix_machines
generation_variables
boucle
fin_script_samba

elif [  "$choixlanceur" = "4"  ]
then
accueil_pxeperso
maj_machines
choix_machines
generation_variables
boucle_pxeperso
fin_script_samba
else exit
fi


