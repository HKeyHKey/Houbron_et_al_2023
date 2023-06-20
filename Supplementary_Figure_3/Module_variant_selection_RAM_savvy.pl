#!/usr/bin/perl

$LENGTH_CUTOFF=26000; # minimal length for a variant to be selected
$PERCENT_N_CUTOFF=5; # maximal percent of "N" in sequence for a variant to be selected

sub select_and_display
{
	$sequence=$_[0];
	$sequence_name=$_[1];
	if (length($sequence)>=$LENGTH_CUTOFF)
	{
		@array=split('',$seq{$name});
		$nb_N=0;
		for ($nt=0;$nt<length($sequence);++$nt)
		{
			if ($array[$nt] eq 'N')
			{
				++$nb_N;
			}
		}
		if ($nb_N/length($sequence)*100<=$PERCENT_N_CUTOFF)
		{
                   print "$sequence_name\n$sequence\n";
                }
 	}
}



if ($ARGV[0] eq '')
{
    print "Please enter script input (e.g., ./Module_variant_selection.pl Corrected_April22_gisaid_cov2020_sequences.fasta).\n";
}
else
{
    $already=0;
    open(IN,$ARGV[0]);
    while(<IN>)
    {
	chomp;
	if (/^>/)
	{
	    if ($already)
	    {
		select_and_display($seq,$name);
	    }
	    $already=1;
	    $name=$_;
	    $seq='';
	}
	else
	{
	    uc; # to convert every sequence into capital letters
	    s/ //g; # to remove space characters in sequence
	    $seq=$seq.$_;
	}
    }
    close(IN);
    select_and_display($seq,$name);
}
