#!/bin/bash

# Specify CRAM_OPTS environment to add additional options to the
# samtools_encode.sh script.  This can be useful to use -T ref.fa for BAM
# files that lack M5 tags.

if [ $# -lt 3 ]
then
    echo "Usage: run_aligned in-file ref-prefix Nthreads"
    echo "For example:"
    echo "    run_encode NA12878_S1.bam hg19 12"
    exit 1
fi

in=$1;
ref=$2;
threads=$3;

#----------
# samtools
export REF_PATH=./cram_cache/%2s/%2s/%s
for p in normal small archive
do
    echo
    echo "### Samtools: $in -@ $threads -O BAM,$p"
    ./samtools_encode.sh $in $in.bam $p -@ $threads
    ./samtools_decode.sh $in -@ $threads
done

# Could also add 2.1 here.
for v in 3.0 3.1 4.0
do
    echo
    for p in normal small archive archive9
    do
        echo
        echo "### Samtools: $in -@ $threads -O CRAM,$v,$p"
        eval ./samtools_encode.sh $in $in.cram $p -@ $threads --output-fmt-option version=$v ${CRAM_OPTS}
        ./samtools_decode.sh $in.cram -@ $threads
    done
done

#----------
# Deez
for p in normal q1 q2
do
    echo
    echo "### Deez: $in -r $ref.fa -t $threads -$p"
    ./deez_encode.sh $in $in.dz $p -r $ref.fa -t $threads
    ./deez_decode.sh $in.dz        -r $ref.fa -t $threads
done

#----------
# Genozip
for p in fast normal
do
    echo
    echo "### Genozip: $in -r $ref -@ $threads -$p"
    ./genozip_encode.sh $in $in.genozip $p -e $ref.ref.genozip -@ $threads
    ./genozip_decode.sh $in.genozip        -e $ref.ref.genozip -@ $threads
done

