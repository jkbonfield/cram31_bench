#!/usr/bin/perl -w

my $fmt="";
my $file;
my $enc = 1;
my %time;
my $size;

# Put thousands comma separators in numbers
sub comma {
    ($n=reverse(@_))=~s/(\d\d\d)/\1,/g;
    ($n=reverse($n))=~s/^,//;
    return $n;
}

my $first_line=1;
my $last_prog="";
sub dump_line {
    if ($first_line) {
	print << 'EOT';
\begin{table}[ht]
\centering 
\caption{... detailed compression timings\label{Tab:...}}
{\begin{tabular}{@{}lr|rr|rr@{}}\toprule
                   & & \multicolumn{2}{c|}{Encode time(s)} & \multicolumn{2}{c}{Decode time(s)}\\
Format             & Size (bytes) &      CPU & Elapsed &      CPU & Elapsed \\
\midrule
EOT

	$first_line = 0;
    }

    my @prog=split(",",$fmt);
    my $prog = $prog[0] eq "CRAM" ? "$prog[0] $prog[1]" : $prog[0];
    $prog[1] = "(normal)" if ("@prog" eq "Deez normal");
    $prog[1] = "(normal)" if ("@prog" eq "Genozip normal");
    if ($last_prog && $last_prog ne $prog) {
	print "\\midrule\n";
    }
    $last_prog = $prog;
    $size = comma($size);
    $tu0  = comma(sprintf("%.0f", $time{user}[0]+$time{sys}[0]));
    $tr0  = comma(sprintf("%.0f", $time{real}[0]));
    $tu1  = comma(sprintf("%.0f", $time{user}[1]+$time{sys}[1]));
    $tr1  = comma(sprintf("%.0f", $time{real}[1]));

    printf("%-18s & %15s & %7s & %6s & %7s & %6s \\\\\n", 
	   "@prog", $size, $tu0, $tr0, $tu1, $tr1);
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

print << 'EOT';
\bottomrule
\end{tabular}}\\
{}
\end{table}
EOT
