#!/usr/bin/perl

if ($ARGV[0] eq '')
{
    print "Please enter input file name (e.g., ./Module_extract_pairing_proba.pl Human_orthopneumovirus_assembly_1133566604.fa).\n";
}
else
{
    $radical=$ARGV[0];
    $radical=~s/\.fa$//;
    open(FASTA,$ARGV[0]);
    while (<FASTA>)
    {
        chomp;
        if (/^>/)
        {
            s/^> *//;
            s/ .*//;
	    s/\|/_/g;
            $name=$_;
        }
        else
        {
            $seq{$name}=$seq{$name}.$_;
        }
    }
    close(FASTA);

    for $ref (keys(%seq))
    {
        $length=length($seq{$ref});
	%proba=();
	open(FOLDED,$ref."_dp.ps");
	while(<FOLDED>)
	{
		chomp;
		if ((/ ubox$/) && ($_ ne '% i  j  sqrt(p(i,j)) ubox'))
		{
			@array=split(' ',$_);
			$proba{$array[0]}+=$array[2]**2;
                        $proba{$array[1]}+=$array[2]**2;
		}
	}
	close(FOLDED);
	open(OUT,">Full_folding_pairing_proba_in_$ref"."_from_$radical".".dat");
        for ($nt=1;$nt<$length+1;++$nt)
	{
		if ($proba{$nt})
		{
			$display=$proba{$nt};
		}
		else
		{
			$display=0;
		}
		print OUT "$nt $display\n";
        }
	close(OUT);
    }
}
