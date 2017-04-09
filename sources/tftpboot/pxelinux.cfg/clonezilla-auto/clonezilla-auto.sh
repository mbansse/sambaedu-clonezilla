#!/bin/bash
CHEMIN=(/tftpboot/pxelinux.cfg/clonezilla-auto)
clear
echo " Ce script va permettre de:"
echo ""
echo "(1)Mettre en place un partage samba  appelé 'partimag' sur /var/se3, télécharger clonezilla sur le serveur et le rendre accéssible automatiquement ^par adminse3."
echo ""
echo "(2)Restaurer automatiquement une image clonezilla placée dans le partage samba 'partimag du se3' sur un parc de machine (ou machine seule)."
echo ""
echo "(3)Restaurer automatiquement une image clonezilla placée dans un partage samba (autre que sur SE3) sur un parc de machine (ou machine seule)."
echo ""
echo "(4)Lancer des commandes  pxe personnalisées sur une mchine ou un ensemble de machines"
echo ""
echo "Entrer le numero correspondant à votre choix ou n'importe quoi pour quitter, puis la touche entrée"
read  choixlanceur
if [ "$choixlanceur" = "1" ] 
then
        bash  "$CHEMIN"/scripts/mise_en_place_partimag_et_clonezilla2.sh

elif [ "$choixlanceur" = "2" ]
then
bash  "$CHEMIN"/scripts/clonezilla-manuel-se3
elif [  "$choixlanceur" = "3"  ] 
then 
bash  "$CHEMIN"/scripts/clonezilla-manuel-samba

elif [  "$choixlanceur" = "4"  ]
then
bash  "$CHEMIN"/scripts/lance-pxe
else exit
fi
