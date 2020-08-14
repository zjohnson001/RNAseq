#!/bin/bash

#Create files for std/sterr output
: >> $mappedSAM/err.txt
: >> $mappedSAM/out.txt


#Run FastQC on trimmed reads
for trimmed_file in $tfastq/*.fastq.gz; do
  echo "mapping $trimmed_file"


#create a new file name for output from bowtie
mapped_file="$(basename $trimmed_file _trimmed.fastq.gz)_mapped.sam"
mapped_outfile="$(basename $trimmed_file _trimmed.fastq.gz)_out.txt"

echo "Sample: $mapped_file" | cat >> $mappedSAM/$mapped_outfile

echo "
" | cat >> $mappedSAM/$mapped_outfile


bowtie2 -x $bowtie2_indexed \
$trimmed_file -S $mappedSAM/$mapped_file \
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
  rm $tfastq/$trimmed_file
else
  rm $sortedBAM_file
fi
done
