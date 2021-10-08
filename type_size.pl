#!/usr/bin/perl -w
use strict;

# Summarises the data size by type.
# Inputs the .out files from the run_align.sh script.

# Eg:
#
# Tool		Name	Qual	Seq	Aux	Other	File
# CRAM-2.1	148.33 	23631 	6982.2 	 0	34.173  30795.6
# CRAM-2.1	114.997 21922 	6625.36  0 	33.0011 28695.3
# ""		0	0	0	 0	0	0     0

# Break down to Name, Qual, Seq, Aux, Other
my %sz = ("name" => 0, "qual" => 0, "seq" => 0, "aux" => 0, "other" => 0);

my $category = "";
my $fmt = "";

sub dump_line {
    # Filter some line types out
    return if ($fmt =~ /^BAM/);

    # Interesting, but not random access so drop
    return if ($fmt =~ /^Deez,q1/);

    # Simplify the plot; keep archive9 but not archive
    return if ($fmt =~ /^CRAM,.*,archive$/);

    # CRAM 4.0 isn't our focus with this paper
    #return if ($fmt =~ /^CRAM,4\.0/);

    my $fmt2 = $fmt;
    $fmt2 =~ s/,[^,]*$//;
    if ($category ne $fmt2) {
	printf("\"\" 0 0 0 0 0\n") if ($category ne "");
	$category = $fmt2;
    }

    $fmt=~s/,[^,]*$//;
    $fmt=~s/,/-/;
    printf("%-18s %6.0f %6.0f %6.0f %6.0f %6.0f\n",
           $fmt, $sz{name}, $sz{qual}, $sz{seq}, $sz{aux}, $sz{other});
}

sub gz_conv {
    my ($sz,$units) = @_;
    return 0 if (!$units);
    if ($units ne "GB" && $units ne "MB" && $units ne "KB" && $units ne "B") {
	return 0;
    }
    $sz *= 1024**3 if ($units eq "GB");
    $sz *= 1024**2 if ($units eq "MB");
    $sz *= 1024**1 if ($units eq "KB");
    return $sz / 1e6; # MB
}

my %cram_seq = ("IN"=>1, "SC"=>1, "AP"=>1, "FN"=>1, "FC"=>1, "DL"=>1,
		"BA"=>1, "BS"=>1, "FP"=>1, "RI"=>1);

print "Tool                 Name   Qual    Seq    Aux  Other\n";
my $dz_sections=0;
while (<>) {
    chomp($_);
    my @F=split(/\s+/,$_);
    if (/^###/) {
        dump_line if ($fmt ne "");

        if (/-O (.*)/) {
            $fmt=$1;
        } elsif (/### (\S+):.*-(.*)/) {
            $fmt="$1,$2";
        }

	%sz = ("name" => 0, "qual" => 0, "seq" => 0, "aux" => 0, "other" => 0);
	$dz_sections = 0;
    }

    # CRAM
    if ($fmt =~ m/CRAM/ && /Block content_id/) {
	if ($F[-1] =~ /RN$/) {
	    #print "name: ", $F[-1], " ",length($F[-1]), "\n";
	    $sz{name} = $F[5]/1e6;
	} elsif ($F[-1] =~ /QS$/) {
	    #print "qual: ", $F[-1], " ",length($F[-1]), "\n";
	    $sz{qual} = $F[5]/1e6;
	} elsif ($cram_seq{$F[-1]} || /CORE/) {
	    #print "seq: ", $F[-1], " ",length($F[-1]), "\n";
	    $sz{seq} += $F[5]/1e6;
	} elsif (length($F[-1]) eq 3 or $F[-1] eq "TL") {
	    #print "aux: ", $F[-1], " ",length($F[-1]), "\n";
	    $sz{aux} += $F[5]/1e6;
	} else {
	    #print "Other: ", $F[-1], " ",length($F[-1]), "\n";
	    $sz{other} += $F[5]/1e6;
	}
    }

    # Deez
    if ($fmt =~ m/Deez/) {
	if (/^Reference/ || /^Sequences/) {
	    #print "Seq: $_\n";
	    $sz{seq} += $F[-1]/1e6;
	} elsif (/^Read Names/) {
	    #print "Name: $_\n";
	    $sz{name} += $F[-1]/1e6;
	} elsif (/^Qualities/) {
	    #print "Qual: $_\n";
	    $sz{qual} += $F[-1]/1e6;
	} elsif (/^Optionals/) {
	    #print "Aux: $_\n";
	    $sz{aux} += $F[-1]/1e6;
	} elsif (/^Flags/ || /^Paired End/ || /^Map\. Quals/) {
	    #print "Other: $_\n";
	    $sz{other} += $F[-1]/1e6;
	}
    }

    # Genocat.  Uses KiB, MiB and GiB instead of KB, MB and GB.
    $dz_sections=1 if ($fmt =~ m/Genozip/ && /^Sections/);
    $dz_sections=0 if ($fmt =~ m/Genozip/ && (!$F[1] || /^===/ || $F[1] eq "vs"));

    if ($fmt =~ m/Genozip/ && $dz_sections) {
	#print "Line: $_\n";
	if (/^QNAME/) {
	    $sz{name} += gz_conv($F[1], $F[2]);
	} elsif (/^QUAL/) {
	    $sz{qual} += gz_conv($F[1], $F[2]);
	} elsif (/^SEQ/ || /^@?CIGAR/ || /^POS/ || /^RNAME/ || /^Reference/) {
	    $sz{seq} += gz_conv($F[1], $F[2]);
	} elsif (/^..:./) {
	    $sz{aux} += gz_conv($F[1], $F[2]);
	} elsif (/^\S+/) {
	    #print "Other: $_\n";
	    $sz{other} += gz_conv($F[1], $F[2]);
	}
    }
}

dump_line;
