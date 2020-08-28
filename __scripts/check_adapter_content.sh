#!/bin/bash


dn=Data/01_fastq
QC1=Data/Quality_Control/01_fastq

for file in $dn/*.fastq.gz; do

  folder="$(basename $file .fastq.gz)_fastqc"
  echo $file

  adapt_cont=($(grep "Adapter Content" $QC1/"$folder"/summary.txt | cut -f1))

  if [[ $adapt_cont == "PASS" ]]; then
    echo "move"
  fi
done
