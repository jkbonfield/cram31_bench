#!/bin/bash

# Set these in the environment if you wish to override the path
deez=${DEEZ:-deez}

if [ $# -lt 3 ]
then
    echo "Usage: deez_encode in-file out-file profile args..."
    echo "For example:"
    echo "    deez_encode foo.bam foo.deez normal -t12 -r ref.fa"
    exit 1
fi

in=$1;
out=$2;
profile=$3;
shift 3
args=${@+"$@"}; # anything else, like -@12

case "$profile" in
    "normal") ;;
    "q1")    args="$args -q1";;
    "q2")    args="$args -q2";;
    *)
	echo "Unknown profile $profile" 1>&2
	echo "Please choose from normal, q1 or q2." 1>&2
	exit 1;;
esac

cmd="$deez -v1 -! $in -o $out $args"

echo "=== Executing $cmd ==="
eval time $cmd
ret=$?
if [ $ret -ne 0 ]
then
   exit $ret
fi

ls -l $out
