#!/bin/bash

#USER INPUTS
export seqtype=$1
export count_type=$2

#Reference Sequences
ref_seqs=Data/ref_seqs
export gtf=$(find $ref_seqs -name "*.gtf")
export bowtie2_indexed=$(find $ref_seqs -name "*.bt2" | sed 's/\..*.bt2//' | sort -u)
export bowtie1_indexed=$(find $ref_seqs -name "*.ebwt" | sed 's/\..*.ebwt//' | sort -u)
export SEadapters=Data/ref_seqs/adapters/TruSeq3-SE.fa
export PEadapters=Data/ref_seqs/adapters/TruSeq3-PE.fa

#Central Pipeline Outputs
export dn=Data/01_fastq
export tfastq=Data/02_trimmed_fastq
export mappedSAM=Data/03_mapped_reads/SAM
export sortedBAM=Data/03_mapped_reads/sBAM

#Quality Control Outputs
export QC1=Data/Quality_Control/01_fastq
export QC2=Data/Quality_Control/02_trimmed_fastq
export QC3=Data/Quality_Control/03_mapped_reads

#Final Outputs
export counts=Output/gene_counts
export initialQC=Output/rawQC_report
export finalQC=Output/finalQC_report

#Check to see that count_type is valid
echo "analyzing $fil_num files"

if [[ $count_type == "transcript" ]]; then
  echo "counting $count_type"
  cat $gtf $cut -f3 | sort -u | grep -i "^[a-z].*"
elif [[ $count_type == "CDS" ]]; then
  echo "counting $count_type"
elif [[ $count_type == "gene" ]]; then
  echo "counting $count_type"
elif [[ $count_type == "exon" ]]; then
  echo "counting $count_type"
elif [[ $count_type == "start_codon" ]]; then
  echo "counting $count_type"
elif [[ $count_type == "stop_codon" ]]; then
  echo "counting $count_type"
else
  echo "Enter valid count type
  command: <SE/PE> <transcript/gene/CDS/exon/start_codon/stop_codon>"
  exit 1
fi

#Check to see if the count type is a part of the GTF file
 #cat $gtf $cut -f3 | sort -u | grep -i

#Check to see if read-type was input
if [[ $seqtype == "PE" ]]; then
  echo "Starting PE Analysis"
elif [[ $seqtype == "SE" ]]; then
  echo "Starting SE Analysis"
else
  echo "Enter either PE or SE to start analysis
  command: <SE/PE> <transcript/gene/CDS/exon/start_codon/stop_codo>"
  exit 1
fi


#Get cumulative sample data
#names of sample base names
sample_names=$(cut -f 1 $dn/samples.txt)
#number of base names
sample_num=$(cut -f 1 $dn/samples.txt | wc -l)
#number of raw data files
fil_num=$(find $dn/ -name "*.fastq.gz" | wc -l)


prereport=($initialQC/*.html)
#if there is no pre-report
if [[ ! -s $prereport ]]; then
  #FastQC & generate pre analysis report in multiqc
  echo "generating pre-report"
  init_QC.sh
else
  echo "pre-report has been generated"
fi

pfil_num=$(find $dn/processed/ -name "*.fastq.gz" | wc -l)

#if the num of processed trimmed reads doesn't equal the number of raw reads
tfil_num=$(find $tfastq/ -maxdepth 1 -name "*.fastq.gz" | wc -l)
if [[ $tfil_num != $pfil_num ]] || (( $tfil_num < 1 )); then
  #Check to run PE or SE script
  if [[ $seqtype == "PE" ]]; then
    #Run PE script for trimming reads
    #Run FastQC on trimmed reads
    #Move processed files to processed directory
    echo "trimming reads"
    PEtrim.sh
  else
    #SE script
    echo "trimming reads"
    SEtrim.sh
  fi
else
  echo "Sample files have been trimmed"
fi

bfil_num=$(find $sortedBAM/ -name "*.bam" | wc -l)
if [[ $bfil_num != $sample_num ]] || (( $tfil_num < 1 )); then

  echo "mapping reads"
  if  [[ $seqtype == "PE" ]]; then
  #map with bowtie2 and compress into BAM files
  #delete the trimmed file and SAM file once sorted BAM file in created
    PEmap_compress.sh
  else
  #Run the same analysis for SE data
    SEmap_compress.sh
  fi
  #Mapped Quality control
  Qualimap.sh
  #Remove inital QC data (needed for seq_len)
  #rm_QC1.sh
  else
  echo "reads have been mapped"
fi

cfil_num=$(find $counts/ -name "*.txt" | wc -l)
if [[ $cfil_num != $sample_num ]] || (( $tfil_num < 1 )); then
#Generate the count tables for the biological element of interest
#Move processed BAM files to processed Directory
#Generate the MultiQC report
  get_counts.sh
else
  echo "
  Analysis already complete
  To get new count type remove count files from Output/counts and
  move files from 03_mapped_reads/sBAM/procossed to 03_mapped_reads/sBAM"
fi
