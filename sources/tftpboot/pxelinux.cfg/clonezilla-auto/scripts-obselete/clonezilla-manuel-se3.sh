#!/bin/bash
# Script du 15 Mars 2017, Marc Bansse 
#variables
TEMP=$(mktemp -d --suffix=-clonezilla-auto)
#récupération des variables se3 (variable se3ip)
. /etc/se3/config_m.cache.sh
BASE=$(grep "^BASE" /etc/ldap/ldap.conf | cut -d" " -f2 )
DATE=`date +%Y-%m-%d-%H-%M`

#----- -----
# les fonctions
#----- -----

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



prealable_se3()
{
#creation du répertoire de montage pour la première utilisation et mise en variable
LISTE_IMAGE="/var/se3/partimag/"
#création du répertoire contenant les fichiers temporaires et mise en variable
mkdir -p /var/log/clonezilla-auto/$DATE
LOG="/var/log/clonezilla-auto/$DATE/"
}

choix_clonezilla_se3()
{
echo " Vous devez choisir si vous voulez utiliser la version 32 bits (clonezilla), ou la version 64 bits (clonezilla64) "
echo -e "Taper \033[31mclonezilla\033[0m  ou   \033[31mclonezilla64\033[0m puis appuyer sur entrée ."
read CLONEZILLA
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
<<<<<<< HEAD
#rm -Rf "$TEMP"
=======
bash "$CHEMIN"/scripts/efface-temp
>>>>>>> 8a7c38d8ff6adf1942c98e75cdec2e688a7d2eb0
exit
else
clear
echo -e "L'image appelée \033[31m$choix \033[0m a été choisie."
fi
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

fin_script()
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

accueil_se3
prealable_se3
choix_clonezilla_se3
choix_image_se3
creation_pxe_perso_se3
maj_machines
choix_machines
generation_variables
boucle
fin_script

exit

