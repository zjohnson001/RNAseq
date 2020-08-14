#!/bin/bash

mkdir $tfastq/Unpaired

#Create an array to loop over for input PE R1 in trimmomatic
sample_arrR1=($(ls $dn | grep "_R1"))
#Create an array to loop over for input PE R2 in trimmomatic
sample_arrR2=($(ls $dn | grep "_R2"))


for ((i=0;i<${#sample_arrR1[@]};++i)); do

  #Names for Trimmed reads which pair
  ptrimmed_filesR1="$(basename ${sample_arrR1[i]} .fastq.gz)_ptrimmed.fastq.gz"
  ptrimmed_filesR2="$(basename ${sample_arrR2[i]} .fastq.gz)_ptrimmed.fastq.gz"

  #Names for Trimmed reads which dont pair
  uptrimmed_filesR1="$(basename ${sample_arrR1[i]} .fastq.gz)_uptrimmed.fastq.gz"
  uptrimmed_filesR2="$(basename ${sample_arrR2[i]} .fastq.gz)_uptrimmed.fastq.gz"

  #Run trimmomatic for PE reads
  trimmomatic PE \
  $dn/${sample_arrR1[i]} $dn/${sample_arrR2[i]} \
  $tfastq/$ptrimmed_filesR1 \
  $tfastq/Unpaired/$uptrimmed_filesR1 \
  $tfastq/$ptrimmed_filesR2 \
  $tfastq/Unpaired/$uptrimmed_filesR2 \
  ILLUMINACLIP:$PEadapters:2:30:10 \
  SLIDINGWINDOW:5:20 \
  LEADING:15 \
  TRAILING:15 \
  MINLEN:36 \
  1>>$tfastq/err.txt \
  2>>$tfastq/out.txt

  #Run FastQC on trimmed files
  #fastqc --extract -o $QC2 $tfastq/$ptrimmed_filesR1
  #fastqc --extract -o $QC2 $tfastq/$ptrimmed_filesR2

  #Move trimmed file to a new directory named trimmed (seperate processed from unprocessed)
  processed_fileR1="$(basename ${sample_arrR1[i]})"
  processed_fileR2="$(basename ${sample_arrR2[i]})"

  if [[ ! -s $ptrimmed_filesR1 ]] && [[ ! -s $ptrimmed_filesR2 ]]; then
    mv $dn/${sample_arrR1[i]} $dn/processed/$processed_fileR1
    mv $dn/${sample_arrR2[i]} $dn/processed/$processed_fileR2
  else
    :
  fi
done
