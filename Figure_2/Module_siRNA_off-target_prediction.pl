#!/usr/bin/perl

$CUTOFF=0.5; # minimal average number of seed matches (across all 3´ UTR isoforms) for a gene to be considered a "predicted off-target"

if ($ARGV[3] eq '')
{
    print "Please enter script arguments (fasta file containing candidate guide strands, and fasta file containing the sequences to be scanned). For example: ./Module_siRNA_off-target_prediction.pl Candidate_guide_strand_13mers.fa Fused_Human_3pUTRome.fa hsa_haploinsufficient_genes.txt Gene_name_synonyms.txt\n";
}
else
{
    open(GUIDES,$ARGV[0]);
    while(<GUIDES>)
    {
	    chomp;
	    if (/^>/)
	    {
		    s/^> *//;
		    s/ .*//;
		    $guide=$_;
	    }
	    else
	    {
		    tr/Uu/Tt/;
		    $_=uc $_;
		    $guide_seed{$guide}=substr $_,1,6;
		    $nt8=substr $_,7,1;
		    $nt8=~tr/ACGT/TGCA/;
		    $anti_nt8{$guide}=$nt8;
	    }
    }
    close(GUIDES);
    
    $guide_file=$ARGV[0];
    $guide_file=~s/\.fa$//;
    $db_file=$ARGV[1];
    $db_file=~s/\.fa$//;
    
    open(SEQUENCES,$ARGV[1]);
    while (<SEQUENCES>)
    {
	chomp;
	if (/^>/)
	{
	    ($gene,$transcript)=($_,$_);
	    $gene=~s/.*\|//;
	    $transcript=~s/^>ENSG[0-9]*\|//;
	    $transcript=~s/\|.*//;
	}
	else
	{
	    if ($_ ne 'Sequence unavailable')
	    {
		$seq{$gene}{$transcript}=$seq{$gene}{$transcript}.$_;
	    }
	}
    }
    close(SEQUENCES);

    $nb_genes=0;
    for $gene (keys %seq)
    {
	++$nb_genes;
	for $transcript (keys %{$seq{$gene}})
	{
	    $_=$seq{$gene}{$transcript};
	    tr/U/T/;
	    foreach $guide (keys %guide_seed)
	    {
		$count=0;
		$offset=0;
		$seed_match=reverse $guide_seed{$guide};
		$seed_match=~tr/ACGT/TGCA/;
		$result=index(uc $_,$seed_match,$offset);
		while ($result != -1)
		{
		    if ($result>0)
		    {
			$M8=substr $_,$result-1,1;
		    }
		    else
		    {
			$M8='';
		    }
		    if (($M8 eq $anti_nt8{$guide}) || ((substr $_,$result+6,1) eq 'A')) # Only counts 7-mers and 8-mers
		    {
			++$count;
		    }
		    $offset=$result+1;
		    $result=index(uc $_,$seed_match,$offset);
		}
		$hits{$guide}{$transcript}=$count;
	    }
	}
    }
    print "Total number of genes for which I could analyze 3´ UTR sequences: $nb_genes\n";
    
    foreach $guide (keys %guide_seed)
    {	
	for $gene (keys %seq)
	{
	    $average=0;
	    $nb_isoforms=0;
	    for $transcript (keys %{$seq{$gene}})
	    {
		$average+=$hits{$guide}{$transcript};
		++$nb_isoforms;
	    }
	    $average=$average/$nb_isoforms;
	    if ($average>=$CUTOFF)
	    {
		push(@{$offtargets{$guide}},$gene);
	    }
        }
    }

    open(SYNONYMS,$ARGV[3]);
    while(<SYNONYMS>)
    {
	chomp;
	@array=split(' ',$_);
	push(@{$synonyms{$array[0]}},$array[2]);
    }
    close(SYNONYMS);

    open(HAPLO,$ARGV[2]);
    while(<HAPLO>)
    {
	chomp;
	push(@haploinsufficient,$_);
    }
    close(HAPLO);
   
    
#    open(OUT,">Predicted_off-targets_in_".$guide_file.".dat");
    foreach $guide (keys %guide_seed)
    {
	$total=0;
	$haplo=0;
	foreach $gene (@{$offtargets{$guide}})
	{
	    ++$total;
	    if (grep(/^$gene$/,@haploinsufficient))
	    {
		++$haplo;
	    }
	}
	print "$guide $guide_seed{$guide} $total $haplo\n";
    }
}
