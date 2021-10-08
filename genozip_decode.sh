#!/bin/bash

# Set these in the environment if you wish to override the path
genocat=${GENOCAT:-genocat}

if [ $# -lt 1 ]
then
    echo "Usage: genozip_decode in-file args..."
    echo "For example:"
    echo "    genozip_decode foo.genozip -@12 -e ref.genozip"
    exit 1
fi

in=$1;
shift 1
args=${@+"$@"}; # anything else, like -@12

# Or: $genounzip -t -f $in
cmd="$genocat -f $in -o /dev/null -z0 $args"

echo "=== Executing $cmd ==="
eval time $cmd
