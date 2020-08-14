#!/bin/bash

for read in $dn/*.fastq.gz; do

  echo "processing $read"
  #run the fastQC analysis for the raw read
  fastqc --extract -o $QC1 $read

done

#make an initial report for raw reads
multiqc . -p -o $initialQC
