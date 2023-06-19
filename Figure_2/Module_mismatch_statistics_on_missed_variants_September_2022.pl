#!/usr/bin/perl

if ($ARGV[0] eq '')
{
    print "Please enter script arguments (e.g., ./Module_mismatch_statistics_on_missed_variants.pl Missed_hits_for_AAACAGATTTAAT.fa).\n";
}
else
{
    open(FA,$ARGV[0]);
    while(<FA>)
    {
	chomp;
	if (/^>/)
	{
	    s/^> *//;
	    $name=$_;
	    if (/^REF_/)
	    {
		$ref_sequence=$name;
	    }
	}
	else
	{
	    $seq{$name}=$seq{$name}.$_;
	}
    }
    close(FA);

    @ref=split('',$seq{$ref_sequence});

    $radical=$ARGV[0];
    $radical=~s/\.fa$//;
    open(OUT,">Mismatch_details_in_$radical".".dat");
    for $name (keys %seq)
    {
	if ($name ne $ref_sequence)
	{
	    @explanation=();
	    @array=split('',$seq{$name});
	    for ($nt=0;$nt<length($seq{$name});++$nt)
	    {
		if ($array[$nt] ne $ref[$nt])
		{
		    $display=14-$nt; # 1-based nucleotide numbering in guide strand (whereas "$nt" is 0-based in the 13-mer, which starts on the second nucleotide of the guide strand)
		    if (($array[$nt] ne 'A') && ($array[$nt] ne 'C') && ($array[$nt] ne 'G') && ($array[$nt] ne 'T'))
		    {
			push(@explanation,'Ambiguity');
		    }
		    else
		    {
			push(@explanation,'Mismatch');
		    }
		}
	    }
	    %seen=();
	    @unique = do {%seen; grep { !$seen{$_}++ } @explanation };
	    print OUT "$name: @unique\n";
	}
    }
    close(OUT);
}
