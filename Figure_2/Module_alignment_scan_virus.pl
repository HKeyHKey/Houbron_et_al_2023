#!/usr/bin/perl

$GUIDE_LENGTH=13; # Length (in nt) of stretches of perfect identity to be extracted

if ($ARGV[0] eq '')
{
    print "Please enter input file name (must be an ALN file; e.g., ./Module_alignment_scan_virus.pl Sampled_variants.aln).\n";
}
else
{
    open(IN,$ARGV[0]);
    while(<IN>)
    {
	chomp;
	if (/ +[A-Z-]+$/)
	{
	    @array=split(' ',$_);
	    ($id,$sequence)=($array[0],$array[1]);
	    $seq{$id}=$seq{$id}.uc($sequence);
	    push(@ified_id,$id);
	}
    }
    close(IN);
}

my @unified_id = do { my %seen; grep { !$seen{$_}++ } @ified_id };
$nb_id=push(@unified_id);

# Below: I just measure on the last sequence, because anyway, all the aligned sequences have the same length (filled with dashes where it's needed)
$l=length($seq{$id});


foreach $id (keys %seq)
{
    $no_dash_seq{$id}=$seq{$id};
    $no_dash_seq{$id}=~s/-//g;
}

for ($nt=0;$nt<$l;++$nt)
{
    foreach $id (keys %seq)
    {
	$extract=substr $seq{$id},$nt,1;
	push(@{$record{$id}},$extract);
	if ($extract ne '-')
	{
	    ++$counter{$id};
	}
	$convert{$id}[$nt]=$counter{$id}-1;
    }
}

$outfile=$ARGV[0];
$outfile=~s/^/Variant_homogeneity_/;
$outfile=~s/\.aln$/.dat/;
open(OUT,">$outfile");
print OUT "Nucleotide Homogeneity";
foreach $id (@unified_id)
{
    print OUT " $id";
}
print OUT "\n";

for ($nt=0;$nt<$l;++$nt)
{
    %count=();
    foreach $id (@unified_id)
    {
	foreach $nucleotide ('A','C','G','T')
	{
#	    print "record=$record{$id}[$nt]\n";
	    if ($record{$id}[$nt] eq $nucleotide)
	    {
		++$count{$nucleotide};
	    }
	}
    }
    $max=0;
    $champion='';
    foreach $nucleotide ('A','C','G','T')
    {

	if ($count{$nucleotide}>$max)
	{
	    $champion=$nucleotide;
	    $max=$count{$nucleotide};
	}
    }
    $heterogeneity=$max/$nb_id;
    $display=$nt+1;
    print OUT "$display $heterogeneity";
    foreach $id (@unified_id)
    {
	$extract=substr $seq{$id},$nt,1;
	print OUT " $extract";
    }
    print OUT "\n";
}
close(OUT);

$radical=$outfile;
$radical=~s/\.dat$//;

`Rscript R_commands_extracts_common_sequences_virus $outfile;tail -n +2 First_set_$radical'.csv' | sed 's|^"[0-9]*",||' > First_set_$radical'.dat';rm -f First_set_$radical'.csv'`;


    $counter=0;
open(FIRST_SET,"First_set_$radical.dat");
while(<FIRST_SET>)
{
    chomp;
    @array=split(',',$_);
    $start=$array[0]-1;
    $end=$array[1]-1;
    if ($end-$start+1>=$GUIDE_LENGTH) # Focus on stretches of perfect identity among variants, on at least $GUIDE_LENGTH nucleotides
    {
	$extracted=substr $seq{$id},$start,$end-$start+1; # extract it from the last analyzed sequence (anyway, they are all identical on that stretch)
	$len=$end-$start+1;
	++$counter;
	print ">stretch_$counter ($len nt long constant stretch)\n$extracted\n";
    }
}

