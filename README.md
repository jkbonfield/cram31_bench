This repository holds scripts for running the benchmarks used in the
"CRAM 3.1: advances in CRAM" paper.


Obtain the reference sequences
------------------------------

ref_build.sh downloads GRCh37, GRCh38 and HG19 fasta files.  If you
have these already, you can comment out the wget commands and put
symbolic links in place.  This uses the seq_cache_populate.pl script,
which is a local copy from the samtools/misc source directory.

It then builds .fai indices on them using samtools, used by Deez.

For Samtools/CRAM it runs the seq_cache_populate script to extract the
sequences and populate an MD5sum-based directory.  This isn't
required, but gives faster CRAM encoding and decoding as no parsing of
fasta is necessary and the lack of newlines means we can simply mmap
the reference files.

For Genozip it runs the --make-reference command to build the genozip
compressed reference files.


Obtain the test data sets
-------------------------

fetch_data.sh downloads the various test data sets.  These are large!
The script is here mainly as documentation for data sources.

This also contains the samtools command to convert any CRAM files into
BAM, prior to running the benchmarks.


Tool specific encode and decode scripts
---------------------------------------

{deez,genozip,samtools}_encode.sh and {deez,genozip,samtools}_decode.sh
convert from BAM to their Deez, Genozip and CRAM formats respectively,
and to read them back again.

Note Deez and Genozip decode scripts create uncompressed BAM and/or
SAM and discard this to /dev/null as there is no adequate way to
benchmark decode only.  The samtools CRAM test discards the data
without first creating a new output file.

On the NovaSeq data set, outputting uncompressed BAM in samtools
instead of discarding adds 27% overhead to the default CRAM profile
data (from 21m40s to 27m29s CPU time).  This additional cost (~6min)
is about 6% of the CPU used for the next fastest competitor, Deez.
The same additional time would be incurred for the slower CRAM
profiles, making the percentage change smaller.

The *_encode_unaligned.sh scripts perform a similar benchmark, but
with the gzipped fastq inputs instead.  We did not benchmark the
decoding step, but for CRAM this will be similar to the decompression
of aligned data and can be achieved using "samtools fastq".


Run_aligned / summarise_aligned
-------------------------------

run_aligned.sh takes an input BAM file, a reference name (filename
prefix) and a thread count and then runs the three tools to produce
output. Eg:

    ./run_aligned.sh 10mill.bam GRCh38_full_analysis_set_plus_decoy_hla 12 2>&1 | tee aligned.out

This can then be processed with summarise_aligned.sh to dump out a
table of results from the aligned.out file:

    ./summarise_aligned aligned.out

