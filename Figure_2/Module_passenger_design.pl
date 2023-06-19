#!/usr/bin/perl
if ($ARGV[0] eq '')
{
    print "Please enter script argument (e.g., ./Module_passenger_design.pl UACUUAAAGUUCUUUAUGCUAGC Candidate_1 (recommended on April 27, 2020; guide strand: UGACUUAAAGUUCUUUAUGCUC)).\n";
}
else
{
    $guide=$ARGV[0];
    $addition=join(' ',@ARGV);
    $addition=~s/^$guide //;
    $passenger=reverse $guide;
    $passenger=~tr/ACGU/UGCA/;
    $passenger=~s/^..//;
    ($nt1,$nt2,$nt3,$nt4)=($passenger,$passenger,$passenger,$passenger);
    $nt4=~s/.*(.)...$/\1/;
    $nt3=~s/.*(.)..$/\1/;
    $nt2=~s/.*(.).$/\1/;
    $nt1=~s/.*(.)$/\1/;
    if (($nt3 eq 'G') || ($nt3 eq 'C') || ($nt1 eq 'A') || ($nt1 eq 'U'))
    {
	$passenger=~s/(.*).$/\1/; # if it does not harm duplex asymmetry: use a 22 nt-long guide instead of 23 (22 is more frequent among human miRNAs: it will probably be better matured).
    }
    else
    {
	if ((($nt4 eq 'G') || ($nt4 eq 'C')) && (($nt2 eq 'A') || ($nt2 eq 'U'))) # if it helps duplex asymmetry: use a 21 nt-long guide instead of 23
	{
	    $passenger=~s/(.*)..$/\1/;
	}
    }
    $passenger=$passenger.'CCU';
    $passenger_5p_dinucl=$passenger;
    $passenger_5p_dinucl=~s/^(..).*/\1/;
    if (($passenger_5p_dinucl!~/G/) && ($passenger_5p_dinucl!~/C/)) # if passenger strand starts with 2 A/U nucleotides: fray the guide's 5´ end a bit more
    {
	$guide_nt2=substr $guide,1,1;
	$l=length($passenger);
	if ($guide_nt2 eq 'A')
	{
	    substr $passenger,$l-4,1,'C';
	}
	if ($guide_nt2 eq 'G')
	{
	    substr $passenger,$l-4,1,'U';
	}
	if ($guide_nt2 eq 'C')
	{
	    substr $passenger,$l-4,1,'A';
	}
	if ($guide_nt2 eq 'U')
	{
	    substr $passenger,$l-4,1,'C';
	}
    }
    print "> guide $addition\nP-$guide\n> passenger $addition\n$passenger\n";
}
