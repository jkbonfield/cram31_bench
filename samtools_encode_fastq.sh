#!/bin/bash

# Set these in the environment if you wish to override the path
samtools=${SAMTOOLS:-samtools}
cram_size=${CRAM_SIZE:-cram_size}

if [ $# -lt 4 ]
then
    echo "Usage: samtools_encode_fastq file1.fq file2.fq out-file profile args..."
    echo "For example:"
    echo "    samtools_encode_fastq ERR174310_[12].fastq.gz out.u.cram archive \\"
    echo "        -@ 8 -N --output-fmt-option version=3.1"
    echo ""
    echo "Output format is automatically selected by samtools based on the filename."
    exit 1
fi

in1=$1;
in2=$2;
out=$3;
profile=$4;
shift 4
args=${@+"$@"}; # anything else, like -@12

case "$profile" in
    "normal")   args="$args --output-fmt-option normal";;
    "small")    args="$args --output-fmt-option small";;
    "archive")  args="$args --output-fmt-option archive";;
    "archive9")
	args="--output-fmt-option level=9 --output-fmt-option archive";;
    *)
	echo "Unknown profile $profile" 1>&2
	echo "Please choose from normal, small, archive or archive9." 1>&2
	exit 1;;
esac

cmd="$samtools import -1 $in1 -2 $in2 -o $out $args"

echo "=== Executing $cmd ==="
eval time $cmd
ret=$?
if [ $ret -ne 0 ]
then
   exit $ret
fi

case "$out" in
   *".cram")  $cram_size $out;;
esac
ls -l $out




