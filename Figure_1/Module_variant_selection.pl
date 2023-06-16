#!/usr/bin/perl

$LENGTH_CUTOFF=26000; # minimal length for a variant to be selected
$PERCENT_N_CUTOFF=5; # maximal percent of "N" in sequence for a variant to be selected

if ($ARGV[0] eq '')
{
    print "Please enter script input (e.g., ./Module_variant_selection.pl Corrected_April22_gisaid_cov2020_sequences.fasta).\n";
}
else
{
    open(IN,$ARGV[0]);
    while(<IN>)
    {
	chomp;
	if (/^>/)
	{
	    $name=$_;
	}
	else
	{
	    uc; # to convert every sequence into capital letters
	    s/ //g; # to remove space characters in sequence
	    $seq{$name}=$seq{$name}.$_;
	}
    }
    close(IN);

    for $name (keys %seq)
    {
	if (length($seq{$name})>=$LENGTH_CUTOFF)
	{
	    @array=split('',$seq{$name});
	    $nb_N=0;
	    for ($nt=0;$nt<length($seq{$name});++$nt)
	    {
		if ($array[$nt] eq 'N')
		{
		    ++$nb_N;
		}
	    }
	    if ($nb_N/length($seq{$name})*100<=$PERCENT_N_CUTOFF)
	    {
		if (($name !~ /^>mink\//) && ($name !~ /^>cat\//) && ($name !~ /^>pangolin\//)&& ($name !~ /^>tiger\//) && ($name !~ /^>dog\//) && ($name !~ /^>lion\//) && ($name !~ /^>bat\//) && ($name !~ /^>mouse\//)) # These are the non-human hosts in the 2021-01-08 dataset of GISAID (make sure they didn't include additional animals in later releases!)
		{
		   print "$name\n$seq{$name}\n";
		}
	    }
	}
    }
}
