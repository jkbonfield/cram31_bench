#!/bin/bash

# This is a proof of concept and will need editing to match local indices
# Note it just tests SNAP + CRAM only.

snap=${SNAP:-snap-aligner}
#snap_ref=grch37.1.0beta.18.hg19-large.snap
snap_ref=grch37.1.0beta.18.hg19.snap
ref=/nfs/srpipe_references/references/Human/1000Genomes_hs37d5/all/fasta/hs37d5.fa
samtools=${SAMTOOLS:-samtools}

# Please use snap version 1.0beta.18 or 1.0beta.24

# Index produced using:
#   snap-aligner index grch37.fa snap -hg19 -Bspace
# Consider adding -large too (although it doesn't seem a major change).

time \
$samtools import -@2 -N -Obam -u \
    -1 ERR174310_1.fastq.gz  -2 ERR174310_2.fastq.gz | \
mbuffer -m 1G -q | \
$snap single $snap_ref --b -t 8 -d 8 -D 0 -f -bam - -o -sam - -map | \
$samtools view -@8 -T $ref -o ERR174310.snap.cram \
    -O cram,version=3.1,small,multi_seq_per_slice=1,seqs_per_slice=100000

ls -l ERR174310.snap.cram
