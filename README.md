# clonezilla-auto
Ce script est fait pour être utilisé avec les serveurs se3

Il va permettre de restaurer automatiquement une image clonezilla préalablement fabriquée sur un/plusieurs postes de l'établissement 


Pour fonctionner correctement il faut:
* Que Clonezilla soit installé par l'interface de gestion du se3 (serveur tftp activé)
* Que les images clonezilla de postes à déployer soient sur un partage samba accessible en lecture (Travail en cours avec un 'NAS').
* Que les ordinateurs bootent en priorité par le pxe, avec fonction Wakeonlan activée.
* Que chaque poste client ait une adresse ip réservée dans l'interface dhcp du se3.

Le répertoire 'clonezilla-auto' doit être placé dans le répertoire /tftpboot/pxelinux.cfg/ du se3. Si on le met ailleurs, il faudra modifier les variables d'environnement dans les scripts, ainsi que certains emplacements écrits sans variable.

Ce répertoire possède deux scripts à rendre executables.

→ *clonezilla_manuel_samba permet de restaurer une image clonezilla placée sur un partage samba. 
En lançant ce script, il vous est demandé de renseigner l'ip,nom du partage, login et mdp d'un compte autorisé à lire l'image.
Un fichier de commande de boot par pxe (placé dans /ttpboot/pxelinux.cfg/ et nommé par l'adresse mac) est créé pour chaque poste. Le client va démarrer ou redémarrer puis va recevoir les consignes pxe. Clonezilla est alors lancé avec les consignes de montage, clonage d'image puis redémarrage.

→ *lance-pxe permet lui de lancer directement des consignes pxe à l'aide d'un fichier type 'pxe' placé dans le répertoire 'pxeperso'. Un modèle est présent dans le répertoire.
Ces fichiers pxe devront contenir le nom de l'image à restaurer, l'ip,login et mdp du partage samba. 
Ici il s'agit d'une restauration d'image, mais on peut créer un fichier de consignes PXE servant à faire autre chose. 

Si les postes ont déjà été intégrés et qu'ils possèdent déjà le compte adminse3 et administrateur avec les mots de passe (du compte adminse3), alors l'integration automatique via l'interface (réservation ip > réintégrer le poste) est possible.

