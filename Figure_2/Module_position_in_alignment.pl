#!/usr/bin/perl
if ($ARGV[0] eq '')
{
    print "Please enter script arguments (e.g., ./Module_position_in_alignment.pl USA/FL-BPHL-1296/2020 TAAACAGATTTAA).\n";
}
else
{
    $length=length($ARGV[1]);
    open(ALIGN,"formatted_extract_missed_".$ARGV[1].".aln");
    while(<ALIGN>)
    {
	chomp;
	@array=split(' ',$_);
	$line_length=length($array[1]);
	if ($array[0] eq $ARGV[0])
	{
	    $bp=0;
	    $hit=0;
	    while (($bp<$line_length) && ($hit==0))
	    {
		$end=$bp+$length-1;
		$extract='';
		while (($end<$line_length) && ($hit==0) && (length($extract)<=$length))
		{
		    $extract=substr $array[1],$bp,$end-$bp+1;
		    $extract=~s/-//g;
		    if ($extract eq $ARGV[1])
		    {
			$hit=1;
		    }
		    ++$end;
		}
		++$bp;
	    }
	}
    }
    close(ALIGN);
    print "$bp-$end";
}
