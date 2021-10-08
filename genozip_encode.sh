#!/bin/bash

# Set these in the environment if you wish to override the path
genozip=${GENOZIP:-genozip}
genocat=${GENOCAT:-genocat}

if [ $# -lt 3 ]
then
    echo "Usage: genozip_encode in-file out-file profile args..."
    echo "For example:"
    echo "    genozip_encode foo.bam foo.genozip normal -@12 -e ref.genozip"
    exit 1
fi

in=$1;
out=$2;
profile=$3;
shift 3
args=${@+"$@"}; # anything else, like -@12

case "$profile" in
    "fast")   args="$args --fast";;
    "normal") ;;
    *)
	echo "Unknown profile $profile" 1>&2
	echo "Please choose from normal or fast." 1>&2
	exit 1;;
esac

cmd="$genozip -f $in -o $out $args"

echo "=== Executing $cmd ==="
eval time $cmd
ret=$?
if [ $ret -ne 0 ]
then
   exit $ret
fi

ls -l $out
$genocat -w -f $out

