#!/usr/bin/perl

@ACCEPTED=(1,15,17,18,19,20,21); # Positions of accepted mismatches (according to Figure 3B of Schwarz et al., 2006: https://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.0020140 for nt 1, 15, 17, 18 and 19; according to Figure 6E of Wee et al., 2012: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3595543/ for nt 20 and 21)
@ACCEPTED_WOBBLES=(4,7); # Positions of accepted wobble GU pairs, where complete mismatches are not accepted (according to Figure 3C of Schwarz et al., 2006: https://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.0020140)

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
		    if ($array[$nt] eq 'N')
		    {
			push(@explanation,'N');
		    }
		    else
		    {
			$accept=0;
			foreach $position (@ACCEPTED)
			{
			    if ($display==$position)
			    {
				$accept=1;
			    }
			}
			foreach $position (@ACCEPTED_WOBBLES)
			{
			    if (($display==$position) && (($array[$nt] eq 'G' && $ref[$nt] eq 'A') || ($array[$nt] eq 'T' && $ref[$nt] eq 'C')))
			    {
				$accept=1;
			    }
			}
			if ($accept==1)
			{
			    push(@explanation,'Accepted_mismatch');
			}
			else
			{
			    push(@explanation,'Unaccepted_mismatch');
			}
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
