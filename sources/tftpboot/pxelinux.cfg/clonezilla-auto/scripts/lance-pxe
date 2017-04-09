#!/bin/bash
#script du 25 mars 2017 Marc Bansse
#Ce script permet de lancer  des commandes pxe pour un/plusieurs postes.
#ces commandes pxe peuvent être des commandes de restauration de postes par clonezilla, d'une image disque située sur un partage samba.
#ces commandes sont à mettre dans le répertoire pxeperso. plusieurs modèles y figure déjà
#variables
TEMP="/tftpboot/pxelinux.cfg/clonezilla-auto/temp"
PXE_PERSO="/tftpboot/pxelinux.cfg/clonezilla-auto/pxeperso"
CHEMIN="/tftpboot/pxelinux.cfg/clonezilla-auto/"
DATE=`date +%Y-%m-%d-%H-%M`
#récupération des variables se3
. /etc/se3/config_m.cache.sh
BASE=$(grep "^BASE" /etc/ldap/ldap.conf | cut -d" " -f2 )

#Le répertoire pxeperso contient des commandes pxe déjà renseignées, pour ne pas à avoir à entrer ip,login,mdp et nom de l'imag à déployer;

#On efface le contenu du répertoire temp au cas où un précédent clonage aurait été arrêté manuellement
rm -Rf "$TEMP"/*
#on créé le répertoire temp au cas où il n'existerait pas.
mkdir -p "$TEMP"

#création du répertoire contenant la date du lancement de script pour les logs
mkdir "$CHEMIN"/log/"$DATE"

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

#On génère le nouveau fichier d'inventaire d'après la branche computer ldap
echo "le script génère le nouveau fichier d'inventaire des machines à partir de la branche computer de l'annuaire"
bash "$CHEMIN"/scripts/import_inventaire

echo ""
#On effectue une recherche ldap pour  afficher l'ensemble des parcs  mis en place. Chaque parc est espacé d'un autre.
LISTE_PARCS=$(ldapsearch -xLLL  -b ou=Parcs,$BASE|grep dn:|sed 's/.*cn=//'|sed 's/,ou.*//' |sed '1d' |sed 1n |sed 's/$/ /'| tr '\n' ' ' |sed 's/>%/>\n/g')
echo -e "\033[4mPour rappel, voici la liste des parcs\033[0m"
echo "$LISTE_PARCS"
echo""
echo -e "Entrer le \033[31m nom du parc\033[0m (ex sciences) ou les \033[31mpremiers octets\033[0m de l'ip du parc à cloner (ex 172.20.50.)"
echo "s'il faut restaurer seulement un poste, on entrera l'adresse ip (ex 172.20.50.101) ou le nom  du poste (ex s218-2)"
read debutip


# on affiche uniquementt les entrées du fichier d'export contenant ce début d'ip
cat  "$CHEMIN"/temp/inventaire* |grep "$debutip" > "$TEMP"/exportauto

#############################################################################
#Il faut maintenant confirmer que les postes à restaurer sont bien ceux qui sont attendus.
echo " vous avez choisi les postes dont l'ip est/commence par "$debutip" "
cut -d';' -s -f2   "$TEMP"/exportauto > "$TEMP"/posteverif

POSTES=$(cat "$TEMP"/posteverif)

#si la liste des postes est vide, c'est qu'aucun ordinateur ne correspond à la demande
if [ "$POSTES" = "" ]; then echo "aucun poste ne correspond à cette demande"
exit
else echo "les postes suivants seront effacés puis restaurés"
echo "$POSTES"
echo "taper 'oui' pour continuer ou 'nano' pour éditer le fichier (faire CTRL+X pour quitter)"
read REPONSE
fi

###########################################################################################################
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
echo "$POSTES2"
echo " ATTENTION, le mdp du partag samba va apparaitre très brievement en clair sur l'écran des postes lors du montage automatique du serveur, veillez à ce que la salle soit vide"
echo "taper '"oui"' pour continuer ou autre chose pour quitter"
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





#le fichier exportauto a été vérifié et ne contient maintenant que les postes qui doivent bien être restaurés
#on supprime les deux premières colonnes contenant le nom et l'ip pour ne garder que la troisième colonne contenant l'adresse mac et le nom de poste.
cut -d';' -s -f3   "$TEMP"/exportauto > "$TEMP"/liste1
cut -d';' -s -f2   "$TEMP"/exportauto > "$TEMP"/postes



# on modifie  le fichier liste1 pour remplacer les ":" par des "-" pour la création du fichier 01-suitedel'adressemac
sed 's/\:/\-/g' "$TEMP"/liste1 > "$TEMP"/listeok



cp "$TEMP"/exportauto "$CHEMIN"/log/"$DATE"/

#On place la première adresse mac de la listemac  dans une variable pour créer ensuite le fichier de commande pxe personnalisé du poste.
mac=$(sed -n "1p" "$TEMP"/listeok| sed 's/.*/\L&/' )
cp "$TEMP"/listeok "$CHEMIN"/log/"$DATE"/
#On place la même adresse mac avec : dans une variable mac2 pour le wakeonlan du poste
mac2=$(sed -n "1p" "$TEMP"/liste1)
cp "$TEMP"/liste1 "$CHEMIN"/log/"$DATE"/
#On place le nom du client pour allumer/reboot le poste avec le script start_poste.sh 
NOM_CLIENT=$(sed -n "1p" "$TEMP"/postes)



#on  créer notre boucle ici: On va supprimer la première ligne de la liste des adresses mac. Dès que le fichier contenant les adresses mac est vide, il y a arret de la boucle
until [ "$mac" = "" ]
do 
 
#le fichier de commande pxe choisi pour les xp est copié dans le répertoire pxelinux.cfg. Il faut ajouter '01'-devant l'adresse mac
cp "$PXE_PERSO"/"$choix" /tftpboot/pxelinux.cfg/01-"$mac"
chmod 644  /tftpboot/pxelinux.cfg/01-*
cp "$PXE_PERSO"/"$choix" "$CHEMIN"/log/"$DATE"/01-"$mac"-"$NOM_CLIENT"


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
rm -f /tftpboot/pxelinux.cfg/clonezilla-auto/temp/*
exit

