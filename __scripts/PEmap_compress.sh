#!/bin/bash

#Create files for std/sterr output
: >> $mappedSAM/err.txt
: >> $mappedSAM/out.txt

#Create an array to loop over for input PE R1 in trimmomatic
sample_arrPR1=($(ls $tfastq/ | grep "_R1"))
#Create an array to loop over for input PE R2 in trimmomatic
sample_arrPR2=($(ls $tfastq/ | grep "_R2"))

#Loop over trimmed paired files to generate output
for ((i=0;i<${#sample_arrPR1[@]};++i)); do

  #create a new file name for output from bowtie2
  mapped_file="$(basename ${sample_arrPR1[i]} _R1_001_ptrimmed.fastq.gz)_mapped.sam"
  mapped_outfile="$(basename ${sample_arrPR1[i]} _R1_001_ptrimmed.fastq.gz)_out.txt"

  echo "Sample: $mapped_file" | cat >> $mappedSAM/$mapped_outfile

  echo "
  " | cat >> $mappedSAM/$mapped_outfile

  bowtie2 -x $bowtie2_indexed \
  -1 $tfastq/${sample_arrPR1[i]} -2 $tfastq/${sample_arrPR2[i]} \
  -S $mappedSAM/$mapped_file \
  1>>$mappedSAM/err.txt \
  2>>$mappedSAM/$mapped_outfile

  echo "
  " | cat >> $mappedSAM/$mapped_outfile

  #convert SAM files to BAM files
  echo "Converting $mapped_file to sorted BAM file"
  sortedBAM_file="$(basename $mapped_file .sam)_sorted.bam"

  samtools view -b $mappedSAM/$mapped_file | \
  samtools sort -o $sortedBAM/$sortedBAM_file

  #find the BAM file if it is over 1MB
  over1MB=$(find $sortedBAM -name $sortedBAM_file -size +1MB)


  #If the variable wasn't assigned a file, remove the
  if [[ ! -z $over1MB ]]; then
    echo "cleaning"
    rm $mappedSAM/$mapped_file
    rm $tfastq/${sample_arrPR1[i]}
    rm $tfastq/${sample_arrPR2[i]}
  else
    rm $sortedBAM_file
  fi

done
