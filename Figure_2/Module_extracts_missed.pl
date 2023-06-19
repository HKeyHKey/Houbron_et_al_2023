#!/usr/bin/perl

if ($ARGV[1] eq '')
{
print "Please enter script arguments (sequence motif to be searched, and fasta file [with sequences fused on 1 line each] where it should be searched) (e.g., ./Module_extracts_missed.pl GATTTACTCATTC Fused_sequences_2021-01-08_08-46.fasta).\n";
}
else
{
    open(FA,$ARGV[1]);
    while(<FA>)
    {
	chomp;
	if (/^>/)
	{
	    $name=$_;
	}
	else
	{
	    if ($_!~/$ARGV[0]/)
	    {
		print "$name\n$_\n";
	    }
	}
    }
    close(FA);
}
