#!/bin/bash

# Set these in the environment if you wish to override the path
deez=${DEEZ:-deez}

if [ $# -lt 1 ]
then
    echo "Usage: deez_decode in-file args..."
    echo "For example:"
    echo "    deez_decode foo.deez -t12 -r ref.fa"
    exit 1
fi

in=$1;
shift 1
args=${@+"$@"}; # anything else, like -@12

#cmd="$deez -v1 -! -c -f 65535 $in $args"
cmd="$deez -v1 -! -c $in $args > /dev/null"

echo "=== Executing $cmd ==="
eval time $cmd
