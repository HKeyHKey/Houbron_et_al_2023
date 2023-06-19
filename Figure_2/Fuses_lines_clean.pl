#!/usr/bin/perl
if ($ARGV[0] eq '')
{
    print "Please give script arguments (e.g., ./Extracts_extended_premiRs.pl dmel-all-chromosome-r5.6.fasta)."."\n";
}
else
{
    $file=$ARGV[0];
    open(HITS,$file);
    @lines=<HITS>;
    close(HITS);
    foreach $line (@lines)
    {
	if ($line =~ /^>/)
	{
	    if ($already)
	    {
		print "\n".$line;
	    }
	    else
	    {
                print $line;
		$already=1;
	    }
	}
	else
	{
	    $seq=$line;
	    $seq =~ s/\n//;
	    print $seq;
	}
    }
    print "\n";
}

