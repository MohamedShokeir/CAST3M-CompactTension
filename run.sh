#!/bin/bash

matrice="matrice.csv"
mfront="Voce_IRR_faible.mfront"
salome="Ct.med"
mesh="CT_mesh.dgibi"
data_calcul="data_calcul.dgibi"
calcul="CT_calc.dgibi"
post="CT_post.dgibi"
procedur="procedur.tar"

OLDIFS=$IFS
IFS=";"

[ ! -f $matrice ] && { echo "$matrice file not found"; exit 99; }
#while read B_ DIME0 GTN LINEAR PHI
while read DIME0 LINE0 BBAR0 REDU0 GTN PHI 
do
  echo "-- 2D / 3D : $DIME0"
  echo "-- Linear elements : $LINE0"
  echo "-- Selective integration elements : $BBAR0"
  echo "-- Reduced integration elements : $REDU0"
  echo "-- Damage : $GTN"
  echo "-- Thermal fluence : $PHI"
  PHI0=${PHI:0:3}

# Calcul
  sed -i "/DIME0/c\ $DIME0 DIME0" $data_calcul
  sed -i "/LINE0/c\ $LINE0 LINE0" $data_calcul
  sed -i "/BBAR0/c\ $BBAR0 BBAR0" $data_calcul
  sed -i "/REDU0/c\ $REDU0 REDU0" $data_calcul
  sed -i "/GTN/c\ $GTN GTN" $data_calcul
  sed -i "/PHI/c\ $PHI0 PHI" $data_calcul

# Creer le repertoire de l essai
  B_="12_50"
  mkdir -p CT"$B_"_phi$PHI0
  cd CT"$B_"_phi$PHI0
  cp ../$mfront .
  cp ../$data_calcul .
  cp ../$salome .
  cp ../$mesh .
  cp ../$calcul .
  cp ../$post .
  cp ../$procedur .

# MFront
  #tar xvf $mfront
  mfront --obuild --interface=castem $mfront

# Maillage
  if [[ $DIME0 == 3 && $REDU0 == 1 ]]
  then
    cp ../*eso .
    compilcast19 elquoi.eso
    essaicast19
  fi
  castem19 -u $mesh > out_mesh_CT$B_
  tar -xvf $procedur

# Calcul
  tar -xvf $procedur
  castem19 -u $calcul > out_calcul_CT$B_

# Post-traitement
  mkdir -p POST/
  cd POST/
  cp ../*.sauv .
  cp ../$data_calcul .
  cp -r ../src/ .
  cp ../$post .
  castem19 $post > out_post_CT$B_

# Sortir du repertoire d essai
  cd ../..

done < $matrice
IFS=$OLDIFS
