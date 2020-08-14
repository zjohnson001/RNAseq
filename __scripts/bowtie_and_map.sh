cd $indexed

echo "Building bowtie2 index from $fasta_reference..."

#Builds bowtie2 index within $indexed
bowtie2-build $fasta_reference $organism_name

> $mappedSAM/sam_mapping_stdout.txt
> $mappedSAM/sam_mapping_stderr.txt

mate1=""
mate2=""

for files in $tfastq/*_trimmed.fastq.gz
do

  file_name="$(basename $files _trimmed.fastq.gz)"

  cut_name="${file_name: -6}"


  #echo "$cut_name"


  if [[ "$cut_name" == *"R1"* ]]; then
    mate1="$files"
    basename_mate1="$(basename $mate1)"
    echo "Assigning $basename_mate1 to mate1 in pair"
  fi

  if [[ "$cut_name" == *"R2"* ]]; then
    mate2="$files"
    basename_mate2="$(basename $mate2)"
    echo "Assigning $basename_mate2 to mate2 in pair"
  fi

  if [ "$mate1" != "" ] && [ "$mate2" != "" ]; then

    cut_name_file="$(basename $mate1 _R1_001_trimmed.fastq.gz)_mapped.sam"
    basename_mate1="$(basename $mate1)"
    basename_mate2="$(basename $mate2)"

    echo "Converting $basename_mate1 and $basename_mate2 into $cut_name_file SAM file ..."

    echo "Sample: $cut_name_file" | cat >> $mappedSAM/sam_mapping_stdout.txt

    bowtie2 -x $organism_name \
    -1 $mate1 -2 $mate2 -S $mappedSAM/$cut_name_file \
    1>>$mappedSAM/sam_mapping_stderr.txt \
    2>>$mappedSAM/sam_mapping_stdout.txt

    echo "
    " | cat >> $mappedSAM/sam_mapping_stdout.txt

    mate1=""
    mate2=""

    echo "Sleeping for 30 seconds"
    sleep 30
  fi
done

cd $parent_directory
