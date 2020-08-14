#!/bin/bash

sample_arr1=($dn/"*.fastq.gz")
#Run FastQC analysis and trimmomatic process
for fastq_file in ${sample_arr1[@]}; do
  echo "trimming $fastq_file"

  #create a new file name to output to from trimmomatic
  trimmed_files="$(basename $fastq_file .fastq.gz)_trimmed.fastq.gz"

  #run trimmomatic
  trimmomatic SE \
  $fastq_file $tfastq/$trimmed_files \
  ILLUMINACLIP:$SEadapters:2:30:10 \
  SLIDINGWINDOW:5:20 \
  LEADING:15 \
  TRAILING:15 \
  SLIDINGWINDOW:4:15 \
  MINLEN:36 \
  1>>$tfastq/err.txt \
  2>>$tfastq/out.txt

  #Run FastQC on trimmed reads
  #fastqc --extract -o $QC2 $trimmed_files

  #Move processed raw reads files
  processed_file="$(basename $fastq_file)"

  if [[ ! -s $trimmed_files ]]; then
    mv $fastq_file $dn/processed/$processed_file
  else
    :
  fi
done
