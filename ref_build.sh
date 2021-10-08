#!/bin/bash

# Fetches references used for the paper data sets and builds tool specific
# versions.
#
# For genozip this is its own internal .genozip format.
#
# For samtools this is an expanded copy with one reference per file
# and newlines removed.

seq_cache_populate=${SEQ_CACHE_POPULATE:-./seq_cache_populate.pl}
genozip=${GENOZIP:-genozip}
snap-aligner=${SNAP:-snap-aligner}

#----------
# Fetch reference files and build indices

# PacBio data set uses GRCh37
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
gunzip hs37d5.fa.gz
HREF37=hs37d5.fa

# Just to be awkward, NA12878_S1.bam uses HG19 rather than GRCh37
wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
gunzip hg19.fa.gz
HG19=hg19.fa

# NovaSeq data is aligned against GRCh38
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
HREF38=Homo_sapiens.GRCh38_full_analysis_set_plus_decoy_hla.fa

samtools faidx $HREF37
samtools faidx $HG19
samtools faidx $HREF38

#----------
# CRAM cache
#
# Copied from samtools misc directory
echo ==========
echo Building CRAM cache.  After completion, set environment as follows:
echo
$seq_cache_populate -root cram_cache $HG19
$seq_cache_populate -root cram_cache $HREF37
$seq_cache_populate -root cram_cache $HREF38


#----------
# Genozip indices
echo ==========
echo Building Genozip compressed references
echo
$genozip --make-reference $HG19
$genozip --make-reference $HREF37
$genozip --make-reference $HREF38


# #----------
# # SNAP indices, optimised for speed
# echo ==========
# echo Building SNAP index
# echo
# $snap index -Bspace $HREF37 $HREF37.snap -hg19 -large
