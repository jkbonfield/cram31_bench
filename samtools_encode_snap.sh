#!/bin/bash

# Note this script doubles the number of threads; one set for the aligner
# and another set for samtools.

# Run it under task set, or via a job queueing system that uses cgroups.
# eg locally within a new shell:
#
# bsub -R "select[mem>100000] rusage[mem=100000]" -M100000 -n8 -R "span[hosts=1]" bash -i

# Example usage:
# time SNAP=../NovaSeq2/snap-aligner /nfs/users/nfs_j/jkb/work/papers/CRAM/cram31_bench/samtools_encode_snap.sh grch37.1.0beta.18.hg19-large.snap 1m_[12].fastq _.cram small -@8 -T $HREF

# Set these in the environment if you wish to override the path
samtools=${SAMTOOLS:-samtools}
cram_size=${CRAM_SIZE:-cram_size}
snap=${SNAP:-snap-aligner}

if [ $# -lt 4 ]
then
    echo "Usage: samtools_encode_snap snap.ref file1.fq file2.fq out-file profile args..."
    echo "For example:"
    echo "    samtools_encode_fastq ERR174310_[12].fastq.gz out.u.cram archive \\"
    echo "        -@ 8 -N --output-fmt-option version=3.1"
    echo ""
    echo "Output format is automatically selected by samtools based on the filename."
    exit 1
fi

snap_ref=$1
in1=$2;
in2=$3;
out=$4;
profile=$5;
shift 5
args=${@+"$@"}; # anything else, like -@12

threads=`echo $args | sed 's/.*-@ *\([0-9]*\).*/\1/'`
threads=${threads:-1}

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

#Adding -map helps sometimes, but can have bad interaction with cgroups.
#cmd="$snap paired $snap_ref -t $threads -b -d 8 -D 0 -f $in1 $in2 -o -sam - -map | mbuffer -m 1G | $samtools view -o $out $args"

cmd="$snap paired $snap_ref -t $threads -b -d 8 -D 0 -f $in1 $in2 -o -sam - | mbuffer -m 1G | $samtools view -o $out $args"

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




