# clonezilla-auto
Ce script est fait pour être utilisé avec les serveurs se3

Il va permettre de restaurer automatiquement une image clonezilla préalablement fabriquée sur un/plusieurs postes de l'établissement.
Pour fonctionner correctement il faut:
* Que CLonezilla soit installé par l'interface de gestion du se3 (serveur tftp)*
* QU'un export des réservations dhcp soit placé dans le répertoire inventaire.*
* QUu'n fichier 'liste' soit placé dans le répertoire 'liste-images'. Ce fichier doit contenir le nom de toutes les images clonezilla *

Ce répertoire possède deux scripts à rendre executables.

→ clonezilla_manuel permet de restaurer une image clonezilla placée sur un partage samba. 
En lançant ce script, il vous est demandé de renseigner l'ip,nom du partage, login et mdp d'un compte autorisé à lire l'image.
Un fichier de commande de boot par pxe est créé pour chaque poste. Celui-ci va démarrer ou redémarrer puis va recevoir les consignes pxe. Clonezilla est lancé avec les consignes de clonage.

→lance-clonage permet lui de mlancer directement des consignes pxe à l'aide d'un fichier type 'pxe' placé dans le répertoire 'pxeperso'. Un modèle est présent dans le répertoire.
Ces fichiers pxe devront contenir le nom de l'image à restaurer, l'ip,login et mdp du partage samba.
