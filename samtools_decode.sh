#!/bin/bash

# Set these in the environment if you wish to override the path
samtools=${SAMTOOLS:-samtools}
cram_size=${CRAM_SIZE:-cram_size}

if [ $# -lt 1 ]
then
    echo "Usage: samtools_decode in-file args..."
    echo "For example:"
    echo "    samtools_decode foo.cram -@12"
    echo ""
    echo "Output is automatically discarded, to test decode rather than"
    echo "transcode to SAM.  To test CRAM to SAM, use samtools_encode with"
    echo "a .sam file or /dev/null as the output".
    exit 1
fi

in=$1; shift
args=${@+"$@"}; # anythingd else, like -@12

cmd="$samtools view -f 0xffff $in $args"

echo "=== Executing $cmd ==="
eval time $cmd
ret=$?
if [ $ret -ne 0 ]
then
   exit $ret
fi




