#!/usr/bin/perl
if ($ARGV[1] eq '')
{
    print "Please give script arguments (e.g., ./Module_extracts_sequences_from_fasta.pl sequences.fasta Alpha.txt).\n";
}
else
{
    open(LIST,$ARGV[1]);
    while(<LIST>)
    {
	chomp;
	$select{$_}='Y';
    }
    close(LIST);

    open(FASTA,$ARGV[0]);
    while(<FASTA>)
    {
	chomp;
	if (/^>/)
	{
		s/^> *//;
		s/\|.*//;
		$name=$_;
		$display=0;
#	print "name=$name et select=$select{$name}\n";
		if ($select{$name})
		{
			$display=1;
			print ">$_\n";
		}
	}
	else
	{
		if ($display)
		{
			print "$_\n";
		}
	}
    }
    close(FASTA);
}
