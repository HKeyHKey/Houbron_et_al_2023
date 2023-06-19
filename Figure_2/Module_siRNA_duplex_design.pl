#!/usr/bin/perl
if ($ARGV[0] eq '')
{
    print "Please enter script argument (e.g., ./Module_siRNA_duplex_design.pl CTAGCATAAAGAACTTTAAGTC Candidate_1).\n";
}
else
{
    $guide_core=reverse($ARGV[0]);
    $guide_core=~tr/ACGT/UGCA/;
    $guide='U'.$guide_core; # Add a 5´ uridine (nt1 does not pair to the target, so it's OK if it doesn't match the conserved target; and most endogenous miRNAs start with a U, so it may help their biogenesis
    
    ### Below: try to find a 22 nt guide, with its 3´ end unpaired to the intended target:
    $guide_22=substr $guide,0,22;
	    
    ### Below: if it turns out that a 21-nt or 23-nt guide would be more asymmetric than the 22-nt guide, switch to 21 or 23 nt:
    $eval_22=substr $guide_22,18,2;
    $eval_21=substr $guide_22,17,2;
    $eval_23=substr $guide,19,2;

    $final_guide=$guide_22;
    if ($eval_22=~/[AU]/) # only attempts to change guide length if the terminal 2 bp (on the guide 3´ end side) are not two GC pairs
    {
	if ($eval_23!~/[AU]/) # a 23-nt guide would be more asymmetric than the 22-nt guide
	{
	    $final_guide=$guide;
	}
	else
	{
	    if ($eval_21!~/[AU]/) # a 21-nt guide would be more asymmetric than the 22-nt guide
	    {
		$final_guide=substr $guide,0,21;
	    }
	}
    }
    # replace 3´-most nucleotide with a C (to avoid introducing a purine-purine mismatch while fraying the guide'3´ end relatively to its intended target: not sure it would be well tolerated, so just in case let's avoid it), except when it was originally a C (then I have to introduce a purine-purine mismatch: replacing C with U would still pair the guide's 3´ end by a GU wobble)
    if (($final_guide=~/A$/) || ($final_guide=~/G$/) || ($final_guide=~/U$/))
    {
	$final_guide=~s/.$/C/;
    }
    else
    {
	$final_guide=~s/.$/A/;
    }

    

    ### Below: now, design a passenger strand for that guide
    $addition=join(' ',@ARGV);
    $addition=~s/^$ARGV[0] //;
    $passenger=reverse $final_guide;
    $passenger=~tr/ACGU/UGCA/;
    $passenger=~s/^..//;
    $passenger=~s/.$/U/; # replace the passenger nt facing guide's 5´ U by a U (which won't pair to it)
    ($nt1,$nt2,$nt3,$nt4)=($passenger,$passenger,$passenger,$passenger);
    $nt4=~s/.*(.)...$/\1/;
    $nt3=~s/.*(.)..$/\1/;
    $nt2=~s/.*(.).$/\1/;
    $nt1=~s/.*(.)$/\1/;

    $passenger=$passenger.'CU'; # add a 3´ end that cannot pair to the guide's 5´ nucleotide
    $passenger_5p_dinucl=$passenger;
    $passenger_5p_dinucl=~s/^(..).*/\1/;    
    if ($passenger_5p_dinucl!~/[GC]/) # if passenger strand starts with 2 A/U nucleotides: fray the guide's 5´ end a bit more
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
    $passenger=~s/(.*)C(...)/\1U\2/; # if guide strand nt2 is a G, pair it to a U on the passenger strand, rather than to a C, in order to favor duplex asymmetry
    print "> guide $addition\nP-$final_guide\n> passenger $addition\n$passenger\n";
    $addition_display=$addition;
    $addition_display=~s/ .*//;
    `echo $passenger"&"$final_guide | RNAcofold;mv rna.ps siRNA_duplex_$addition_display'.ps'`;
    `echo $ARGV[0]"&"$final_guide | RNAcofold;mv rna.ps target-guide_duplex_$addition_display'.ps'`;
}
