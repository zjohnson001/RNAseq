#!/bin/bash

loc1=$1 #FASTQ FILES LOCATION
loc2=$2 #LOCATION TO CREATE PROJECT FOLDER
project_name=$3 #NAME OF PROJECT



#Generate unique samples names & biological replicates
#ignores read number
find $loc1 -name "*.fastq.gz" | \
sed 's=.*/==;s/\.[^.]*$//;s/\.[^.]*$//' | \
grep -oE ".*BR[1-9]" | sort -u > $loc1/samples.txt

#Get the number of samples
sample_num=$(find $loc1/ -name "*.fastq.gz" | wc -l)

#Check to see that all input is correct
if [[ ! -d $loc1 ]] || [[ ! -d $loc2 ]]; then
  echo "command 1 & 2 must be valid directories
example: <path/to/dir1> <path/to/dir2> <project_name>
Exiting..."
  exit 1
elif [[ -z $project_name ]]; then
  echo "name project in command 3. \n
example: <path/to/dir1> <path/to/dir2> <project_name> \n
Exiting..."
  exit 1
else
  echo "moving $sample_num files from $loc1 to $loc2/$project_name/Data/01_fastq"
fi



#create the directory structure under the project name
mkdir -p $loc2/"$project_name"/Data/{01_fastq/processed,02_trimmed_fastq,03_mapped_reads/{SAM,sBAM/processed},04_gene_counts,Quality_Control/{01_fastq,02_trimmed_fastq,03_mapped_reads}}
mkdir -p $loc2/"$project_name"/Output/{gene_counts,rawQC_report,finalQC_report}

#move files to the new directory under 01_fastq
for file in $loc1/"*.fastq.gz"
do

  echo "moving $file to $loc2/$project_name/Data/01_fastq"
  cp $file  $loc2/"$project_name"/Data/01_fastq/

done

mv $loc1/samples.txt $loc2/"$project_name"/Data/01_fastq/samples.txt
