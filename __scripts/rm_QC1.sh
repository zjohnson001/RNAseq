#!/bin/bash

for file in $dn/processed/*.fastq.gz; do

  folder="$(basename $file .fastq.gz)_fastqc"
  html="$(basename $file .fastq.gz)_fastqc.html"
  zip="$(basename $file .fastq.gz)_fastqc.zip"

  rm $QC1/$html
  rm $QC1/$zip

  for item in $QC1/"$folder"/*; do
    rm "$item"
    for item1 in $QC1/"$folder"/Icons/*; do
      rm "$item1"
    done
    for item2 in $QC1/"$folder"/Images/*; do
      rm "$item2"
    done
  done
done
