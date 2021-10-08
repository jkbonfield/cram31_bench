#!/bin/bash

# Set these in the environment if you wish to override the path
samtools=${SAMTOOLS:-samtools}

if [ $# -lt 3 ]
then
    echo "Usage: samtools_decode_fastq in-file args..."
    echo "For example:"
    echo "    samtools_decode_fastq foo.u.cram out_1.fq out_2.fq -@8"
    echo ""
    exit 1
fi

in=$1;
out1=$2;
out2=$3
shift 3
args=${@+"$@"}; # anything else, like -@12

cmd="$samtools fastq -1 $out1 -2 $out2 $in $args"

echo "=== Executing $cmd ==="
eval time $cmd




