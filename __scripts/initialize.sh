#!/bin/bash

fastq_files=_unprocessed_fastq_files
ref_seqs_dir=__metadata/ref_seqs
adapters=__metadata/adapters
config=__metadata/multiqc_config.yaml

project_name=$1 #NAME OF PROJECT
ref_seq=$2 #USER SPECIFIED REFERENCE SEQUENCES

#provide a link to the reference sequenes directory
lref_seq=$ref_seqs_dir/$ref_seq

#Get the number of samples
sample_num=$(find $fastq_files/ -name "*.fastq.gz" | wc -l)

#Check to see that all input is correct
if [[ ! -z $ref_seq ]] && [[ ! -d $lref_seq ]]; then
  echo "  command 2 must be valid ref_seq directory
  example: <project_name> <reference_sequences>
  Reference sequences:"
    ls $ref_seqs_dir/
    echo "exiting..."
  exit 1
elif [[ -z $project_name ]]; then
  echo "command 1 empty, enter project name.
example: <project_name> <reference_sequences>
Exiting..."
  exit 1
else
  echo "moving $sample_num files to $project_name/Data/01_fastq"
fi

#Create a file containing all unique sequence names
find $fastq_files -name "*.fastq.gz" | \
sed 's=.*/==;s/\.[^.]*$//;s/\.[^.]*$//' | \
grep -oE ".*BR[1-9]" | sort -u > $fastq_files/samples.txt

#create the directory structure under the project name
mkdir -p $project_name/Data/{01_fastq/processed,02_trimmed_fastq,03_mapped_reads/{SAM,sBAM/processed},Quality_Control/{01_fastq,02_trimmed_fastq,03_mapped_reads}}
mkdir -p $project_name/Output/{gene_counts,rawQC_report,finalQC_report}

#move files to the new directory under 01_fastq
for file in $fastq_files/"*.fastq.gz"
do
  echo "moving $file to $project_name/Data/01_fastq"
  mv $file $project_name/Data/01_fastq/
done

#Move the fastq files from staging to processing directory
mv $fastq_files/samples.txt $project_name/Data/01_fastq/samples.txt

#move the config file to the RNA-seq directory
cp -v $config $project_name/multiqc_config.yaml
#Make a ref_seqs directory
mkdir -p $project_name/Data/ref_seqs/adapters
#Copy over all reference sequences
cp -Rv $lref_seq/* $project_name/Data/ref_seqs/
cp -Rv $adapters/* $project_name/Data/ref_seqs/adapters/
