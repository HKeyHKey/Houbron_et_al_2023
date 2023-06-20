#!/usr/bin/perl

if ($ARGV[2] eq '')
{
    print "Please enter script inputs (fasta file with sequences to screen [sequences have to fit on single lines], then 13-mer to look for in these sequences, then list of sequence names from non-human donors; e.g., ./Module_13mers_in_2022_09_26_dataset.pl Selected_sequences_2022_09_26.fa GUGUCUUUAGCUA Non_human_hosts_in_2022_09_26_release.txt).\n";
}
else
{
    $target=$ARGV[1];
    $target=~tr/U/T/;

    open(FLAGGED,$ARGV[2]);
    while(<FLAGGED>)
    {
	chomp;
	if ($_ ne 'Virus_name Host')
	{
		@array=split(' ',$_);
		$host{$array[0]}=$array[1];
	}
    }
    close(FLAGGED);

    open(IN,$ARGV[0]);
    while(<IN>)
    {
	chomp;
	if (/^>/)
	{
	    s/^> *//;
	    s/\|.*//;
	    $name=$_;
	}
	else
	{
	    $seq=$_;
	    if ($seq!~/$target/)
	    {
		if ($host{$name} eq '')
		{
			$h='Human';
		}
		else
		{
			$h=$host{$name};
		}
		print "$name does not contain $target (host: $h)\n";
	    }
	}
    }
    close(IN);
}
