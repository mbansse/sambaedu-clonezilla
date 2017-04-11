# clonezilla-auto

Cet ensemble de scripts est fait pour être utilisé avec les serveurs se3 (sambaedu 3). Il utilise le logiciel libre 'clonezilla'.

## *Clonezilla-auto* va permettre plusieurs opérations:
* **Créer un partage samba** (appelé partimag)  sur le se3. Clonezilla sera ensuite téléchargé sur le serveur, puis modifié de façon à ce qu'**adminse3 puisse y écrire/lire des images automatiquement**. 
* Des entrées dans le menu PXE (perso) seront ajoutées pour que la **création d'image** se fasse en trois touches de clavier. 
* Déployer **automatiquement** à partir d'un shell se3, une image clonezilla préalablement fabriquée vers un/plusieurs poste, ou **tout un parc de machine** si ces images sont sont un partage samba (se3 ou un autre serveur).
* Envoyer des **commandes personnalisées** (*restauration d'une image avec paramètres déjà entrés, faire une sauvegarde/restauration locale,etc*)


## Pour fonctionner correctement il faut:
* Que le serveur tftp du se3 soit activé.
* Que les images clonezilla de postes à déployer soient sur un partage samba accessible en lecture (Travail en cours avec un 'NAS').A défaut, on pourra lancer l'un des scripts qui crééra sur le se3 ce partage (vérifier la place disponible!!!)
* Que les ordinateurs bootent en priorité par le pxe, avec fonction Wakeonlan activée.
* Que chaque poste client ait une adresse ip réservée dans l'interface dhcp du se3.

*Le répertoire *clonezilla-auto* doit être placé dans le répertoire /tftpboot/pxelinux.cfg/ du se3. Si on le met ailleurs, il faudra modifier les variables d'environnement dans les scripts, ainsi que certains emplacements écrits sans variable.*
*CLonezilla-auto doit être lancé en root sur le se3*

## Intégration automatique
Si les postes ont déjà été intégrés (et sont donc considérés commes tels par le serveur) et qu'ils possèdent déjà le compte adminse3 et administrateur avec les mots de passe (utilisateurs à ajouter avant de créer l'image), alors l'integration automatique via l'interface (réservation ip > réintégrer le poste) est possible.

## Utilisation par un débutant
Clonezilla-auto a été conçu pour être simple d'utilisation. Il suffit de lancer *clonezilla-auto.sh* à partir d'un terminal du serveur, puis de se laisser guider. 
