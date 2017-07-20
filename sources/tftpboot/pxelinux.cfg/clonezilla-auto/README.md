# clonezilla-auto

Ce script est fait pour être utilisé avec les serveurs se3 (sambaedu 3). Il utilise le logiciel libre 'clonezilla'.

Son principe est simple: Le script va créer un fichier ayant pour nom l'adresse mac d'un poste, le faire démarer/redémarrer. Celui-ci va donc recevoir une commande de boot PXE personnalisée qu'il suivra.

## *Clonezilla-auto* va permettre plusieurs opérations:
* **Créer un partage samba** (appelé partimag)  sur le se3. Clonezilla sera ensuite téléchargé sur le serveur, puis modifié de façon à ce qu'**adminse3 puisse y écrire/lire des images automatiquement**. 
* Des entrées dans le menu PXE (perso) seront ajoutées pour que la **création d'image** se fasse en quelques touches de clavier: on fabrique un poste modèle, on boote en PXE et on fabrique l'image. 
* Déployer **automatiquement** à partir d'un shell se3, une image clonezilla préalablement fabriquée vers un/plusieurs poste, ou **tout un parc de machine** si ces images sont sont un partage samba (se3 ou un autre serveur). Il est donc possible d'installer plusieurs salles informatiques pendant un week-end  de chez soi si on a un accès à distance au se3.
* Envoyer des **commandes personnalisées** (*restauration d'une image avec paramètres déjà entrés, faire une sauvegarde/restauration locale,démarrer tout un parc de machine en mode client lors de l'utilisation de clonezilla en mode /client/Serveur.)
* Mettre la dernière version de clonezilla (basée sur **Ubuntu Zesty** qui ajoute un mode **client/serveur** simple d'utilisation).


## Pour fonctionner correctement il faut:
* Que le serveur tftp du se3 soit activé.
* Que les images clonezilla de postes à déployer soient sur un partage samba accessible en lecture (Travail en cours avec un 'NAS').A défaut, on pourra lancer l'option n°1 du script qui crééra sur le se3 ce partage (vérifier la place disponible!!!)
* Que les ordinateurs bootent en priorité par le pxe, avec fonction Wakeonlan activée.
* Que chaque poste client ait une adresse ip réservée dans l'interface dhcp du se3.

*Le répertoire *clonezilla-auto* peut être placé n'importe où sur le serveur.Il faudra juste éditer le script pour indiquer l'emplacement des fichiers contenant des commandes PXE personnalisées.*
*Clonezilla-auto doit être lancé en root sur le se3*.
*A chaque clonage, un répertoire situé dans /var/log/clonezilla-auto/date contient les différents fichiers temporaires effacés.*

## Intégration automatique
Si les postes ont déjà été intégrés (et sont donc considérés commes tels par le serveur) et qu'ils possèdent déjà le compte adminse3 et administrateur avec les mots de passe (utilisateurs à ajouter avant de créer l'image), alors l'integration automatique via l'interface (réservation ip > réintégrer le poste) est possible.

## Utilisation par un débutant
Clonezilla-auto a été conçu pour être simple d'utilisation. Il suffit de lancer *clonezilla-auto.sh* à partir d'un terminal du serveur, puis de se laisser guider.
