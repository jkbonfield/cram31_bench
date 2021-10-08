#!/usr/bin/perl -w

my $fmt="";
my $file;
my $enc = 1;
my %time;
my $size;

my $first_line=1;
sub dump_line {
    if ($first_line) {
	print "File: $file\n\n";
	$first_line = 0;

	printf("Format                     Size |  Encode real/cpu |  Decode real/cpu\n");
	printf("--------------------------------+------------------+-----------------\n");
    }

    printf("%-18s %12d | %7.1f %8.1f | %7.1f %8.1f\n", 
	   $fmt, $size,
	   $time{real}[0], $time{user}[0]+$time{sys}[0],
	   $time{real}[1], $time{user}[1]+$time{sys}[1],
	);
}

# Produce a summary of the run_aligned.sh output
while (<>) {
    chomp($_);
    @F=split(/\s+/,$_);
    if (/^###/) {
	dump_line if ($fmt);
	$file=$F[2];

	if (/-O (.*)/) {
	    $fmt=$1;
	} elsif (/### (\S+):.*-(.*)/) {
	    $fmt="$1,$2";
	}
	$enc = -1;
    }

    $enc++ if (/^===/);

    if (/^(real|user|sys)/) {
	/(\d+)m([0-9.]+)s/;
	my $sec = $1*60 + $2;
	$time{$F[0]}[$enc] = $sec;
    }

    $size = $F[4] if (/^-rw/);
}

dump_line;
