#!/bin/bash

ref_seqs=__metadata/ref_seqs
gtf=_gtf_file
seqs=_fasta_map_sequences

#User inputs the organism name as arguement 1
org=$1
#User inputs the database the files were sourced as arguement 2
db=$2

#Check that the arguements were input
if [[ -z $org ]]; then
  echo "organism name not supplied
  command gen_refseqs.sh <organism_name> <database>"
  exit 1
fi

if [[ -z $db ]]; then
  echo "database name not supplied
  command: gen_refseqs.sh <organism_name> <database>"
  exit 1
fi


#create the necessary folders to store data
dir=$ref_seqs/"$org"_"$db"_"$(date +"%m%d%Y")"
seq_dir="$dir"/"$db"_"$(date +"%m%d%Y")"
indexed="$dir"/"$org"_indexed

#If a reference directory doesn't exist
if [[ ! -d $seq_dir ]]; then
  #make directories for indexed files to store reference fasta files
  mkdir -p $seq_dir
  mkdir -p $indexed
else
  echo "Reference directory already exists"
fi

if [[ -f $seq_dir/$org.fa.gz ]]; then
  echo "Reference directory complete"
  exit 1
  #Check to see if the file is ready for indexing
elif [[ ! -f $indexed/$org.fa.gz ]]; then
  map_files=($seqs/*.gz)
  #Check to see if files are present
  if [[ $map_files != "$seqs/*.gz" ]]; then
    #Merge reference files under the organism name
    cat $seqs/*.gz > $seqs/$org.fa.gz
    merged_file=$seqs/"$org".fa.gz
    bm="$(basename $merged_file)"
    #move the merged file into the index directory for indexing
    mv $merged_file $indexed/$bm

    #Move all other reference sequneces to the reference directory
    for seq in $seqs/*.gz; do
      bseq="$(basename $seq)"
      echo "$bseq moved to reference directory"
      mv $seq $seq_dir/$bseq
    done
  else
    echo "    Reference Sequences for mapping not present
    place all fasta reference sequences into _fasta_map_sequences"
    exit 1
  fi
else
  echo "fasta file ready for indexing"
fi

#Check to see if there is already a gtf in the reference folder
pross_gtf_file=($dir/*.gtf)
if [[ ! -f $pross_gtf_file ]]; then
  gtf_staged=($gtf/*.gtf)
  #Check to see there is a gtf file in _gtf_file staging area
  if [[ $gtf_staged != "$gtf/*.gtf" ]]; then
    #Check to see that there is only one file in staging
    if [ ${#gtf_staged[@]} == 1 ]; then
      bp="$(basename $gtf_staged)"
      mv $gtf_staged $dir/$bp
    else
      echo "only one gtf file can be used as a reference"
      exit 1
    fi
  else
    echo "no file in _gtf_file directory"
    exit 1
  fi
else
  echo "gtf file located in reference directory"
fi

indexed_files=($indexed/*.bt2)
#Check to see if files have been indexed
if [ $indexed_files == "$indexed/*.bt2" ]; then
  filetoindex=($indexed/*.gz)
  bfi="$(basename $filetoindex)"
  #index the file and move the file which was indexed to seqs
  bowtie2-build $filetoindex $indexed/$org
  mv $filetoindex $seq_dir/$bfi
else
  echo "Reference folder already exists"
fi
