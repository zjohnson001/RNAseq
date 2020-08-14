#!/bin/bash

for bam_file in $sortedBAM/*.bam
do
  echo "Running quality control on $bamfile with qualimap"

  #name each summary statistic in the file
  name="$(basename $bam_file _mapped_sorted.bam)"

  qualimap bamqc \
  -outdir $QC3/$name \
  -bam $bam_file \
  -gff $gtf
