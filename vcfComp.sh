#!/bin/bash
oldFilePath=$1

rm oldFile.tsv
rm newFile.tsv

cp $oldFilePath oldFile.vcf
bash convert_Cordova_VCF_to_mysqlimport_TSV.sh oldFile.vcf > oldFile.tsv

if [ "$2" ]
  then
  newFilePath=$2
  rm newFile.tsv
  cp $newFilePath newFile.vcf
  bash convert_Cordova_VCF_to_mysqlimport_TSV.sh newFile.vcf > newFile.tsv
  sqlite3 -init setup2.sql
else
  sqlite3 -init setup1.sql
fi


