# clonezilla-auto
Ce script est fait pour être utilisé avec les serveurs se3

Il va permettre de restaurer automatiquement une image clonezilla préalablement fabriquée sur un/plusieurs postes de l'établissement 


Pour fonctionner correctement il faut:
* Que Clonezilla soit installé par l'interface de gestion du se3 (serveur tftp activé)
* Qu'un export des réservations dhcp (fait à partir de l'interface se3) soit placé dans le répertoire inventaire.
* Qu'un fichier 'liste' soit placé dans le répertoire 'liste-images'. Ce fichier doit contenir le nom 'exact' de toutes les images clonezilla placées dans le partage samba (modèle déjà présent dans le répertoire 'liste-image') 
* Que les ordinateurs bootent en priorité par le pxe, avec fcontion Wakeonlan activée.

Le répertoire clonezilla-auto peut être placé dans le répertoire /tftpboot/pxelinux.cfg/ du se3. Si on le met ailleurs, il faudra modifier les variables d'environnement dans les scripts, ainsi que certaines emplacement écrits sans variable dans le script.

Ce répertoire possède deux scripts à rendre executables.

→ clonezilla_manuel_samba permet de restaurer une image clonezilla placée sur un partage samba. 
En lançant ce script, il vous est demandé de renseigner l'ip,nom du partage, login et mdp d'un compte autorisé à lire l'image.
Un fichier de commande de boot par pxe est créé pour chaque poste. Celui-ci va démarrer ou redémarrer puis va recevoir les consignes pxe. Clonezilla est lancé avec les consignes de clonage.

→lance-clonage permet lui de lancer directement des consignes pxe à l'aide d'un fichier type 'pxe' placé dans le répertoire 'pxeperso'. Un modèle est présent dans le répertoire.
Ces fichiers pxe devront contenir le nom de l'image à restaurer, l'ip,login et mdp du partage samba. 
Ici il s'agit d'une restauration d'image, mais on peut créer un fichier de consignes PXE servant à faire autre chose. 

