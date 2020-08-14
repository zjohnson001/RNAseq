#!/bin/bash

#Grep seq length from raw data FastQC
for file in $dn/processed/*.fastq.gz; do
	sample_name="$(basename $file .fastq.gz)_fastqc"

#Check the mapping QC folder for the folder containing the genome_results
#Select all samples which have over 5x genome coverage
	export seq_len=($(grep "Sequence length" $QC1/"$sample_name"/fastqc_data.txt | \
	cut -f2))
done

echo "$seq_len"
