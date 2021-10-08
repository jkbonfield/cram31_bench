#!/bin/bash -x

# Illumina HiSeq platinum genomes file.
wget ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR194/ERR194147/NA12878_S1.bam

# Illumina NovaSeq data and convert to BAM
wget ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239334/NA12878.final.cram
samtools view -@8 NA12878.final.cram -o NA12878.final.bam

# PacBio data and drop most tags
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20131209_na12878_pacbio/si/NA12878.pacbio.bwa-sw.20140202.bam
samtools view -@8 -F 0x100 -x AS -x PG -x SA -x XS NA12878.pacbio.bwa-sw.20140202.bam -o NA12878.pacbio.noaux.bam

# Unaligned FASTQ files
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR174/ERR174310/ERR174310_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR174/ERR174310/ERR174310_2.fastq.gz
