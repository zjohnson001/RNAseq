#!/bin/bash

#count the number of genes
for bam_file in $sortedBAM/*.bam; do

  echo "Getting gene counts for $bam_file"

	bam_count_file="$(basename $bam_file _mapped_sorted.bam).txt"

	htseq-count \
  --order=pos\
	--format=bam \
	--stranded=reverse \
	--type=$count_type \
	--idattr=gene_id \
	$bam_file \
	$gtf > \
	$counts/$bam_count_file

  processed_file="$(basename $bam_file)"

  if [[ ! -s $bam_count_file ]]; then
    mv $bam_file $sortedBAM/processed/$processed_file
  else
    :
  fi
done

#Get multiQC report
multiqc . -p -o $finalQC
