#!/usr/bin/perl

$LENGTH_CUTOFF=26000; # minimal length for a variant to be selected
$PERCENT_N_CUTOFF=5; # maximal percent of "N" in sequence for a variant to be selected
$PAIRING_PROBA_CUTOFF=0.1; # maximal pairing probability (according to any metrics) for any given nucleotide in a seed match for that match to be selected

if ($ARGV[3] eq '')
{
    print "Please enter script input (e.g., ./Module_extends_from_sampled_to_every_variant.pl Corrected_gisaid_cov2020_sequences.fasta Variant_homogeneity_Sampled_variants.dat First_set_Variant_homogeneity_Sampled_variants.dat EPI_ISL_402119).\n";
}
else
{
    open(FA,$ARGV[0]);
    while(<FA>)
    {
	chomp;
	if (/^>/)
	{
	    s/^> *//;
	    $name=$_;
	}
	else
	{
	    s/ //g; # to remove space characters in sequence
	    $seq{$name}=$seq{$name}.uc $_; # to convert every sequence into capital letters
	}
    }
    close(FA);

    for $name (keys %seq)
    {
	if (length($seq{$name})>=$LENGTH_CUTOFF)
	{
	    @array=split('',$seq{$name});
	    $nb_N=0;
	    for ($nt=0;$nt<length($seq{$name});++$nt)
	    {
		if ($array[$nt] eq 'N')
		{
		    ++$nb_N;
		}
	    }
	    if ($nb_N/length($seq{$name})*100<=$PERCENT_N_CUTOFF)
	    {
		$_=$name;
		s/^>hCoV-19\///;
		s/\/.*//;
		push(@selected_variants,$name);
	    }
	}
    }
    
    open(ALIGN,$ARGV[1]);
    while(<ALIGN>)
    {
	chomp;
	if ($_ !~ /^Nucleotide Homogeneity /)
	{
	    @array=split(' ',$_);
	    $homogeneity[$array[0]]=$array[1]; # so indexes in this array will be 1-based
	    $aligned_seq[$array[0]]=$array[2]; # so indexes in this array will be 1-based
	}
    }
    close(ALIGN);

    open(REF,"Fused_$ARGV[3]".".fa");
    while(<REF>)
    {
	chomp;
	if (/^>/)
	{
	    $name_ref=$_;
	}
	else
	{
	    uc; # to convert every sequence into capital letters
	    s/ //g; # to remove space characters in sequence
	    $seq_ref=$seq_ref.$_;
	}
    }
    close(REF);
    

    
    open(FIRST_SET,$ARGV[2]);
    $stretch=0;
    open(COORD_IN_REF,">Stretch_coordinates_in_".$ARGV[3].".dat");
    while(<FIRST_SET>)
    {
	chomp;
	@array=split(',',$_);
	$extract='';
	for ($nt=$array[0];$nt<=$array[1];++$nt)
	{
	    if ($homogeneity[$nt]!=1)
	    {
		print "Warning: found heterogeneous position in one of your candidates:\nNucleotide $nt in alignment (homogeneity score: $homogeneity[$nt]).\n";
	    }
	    $extract=$extract.$aligned_seq[$nt];
	}
	$ind=index $seq_ref,$extract;
	++$stretch;
	$start=$ind+1;
	$end=$ind+length($extract);
	print COORD_IN_REF "stretch_$stretch $start $end\n";
    }
    close(FIRST_SET);
    close(COORD_IN_REF);

    `Rscript R_commands_accessibility_of_first_set $ARGV[3] $PAIRING_PROBA_CUTOFF`; # Selection of stretches with high accessibility (these candidates are described in 'Second_set.txt').

    open(ACCESSIBLE,'Second_set.txt');
    while(<ACCESSIBLE>)
    {
	chomp;
	if (/^ *\[/)
	{
	    s/^ *\[\d*,\] *//;
	    ($start_in_ref,$end_in_ref)=split(' ',$_);
	    $extract=substr $seq_ref,$start_in_ref-1,$end_in_ref-$start_in_ref+1; # Because $start_in_ref is 1-based
	    push(@second_set,$start_in_ref.'-'.$end_in_ref);
	    $second_set_stretch{$start_in_ref.'-'.$end_in_ref}=$extract;
	}
    }
    close(ACCESSIBLE);

    $radical=$ARGV[0];
    open(EXTENDED,">Hits_to_second_set_in_selected_variants_from_$radical".".dat");
    print EXTENDED "Coordinate_of_13mer_in_alignment Sequence_of_13mer Number_of_missed_variants Missed_variants\n";
    open(DETAILS,">Details_variants_without_hit_to_second_set_candidates.txt");
    foreach $stretch (@second_set)
    {
	foreach $name (@selected_variants)
	{
	    $c=0;
	    if ($seq{$name}=~/$second_set_stretch{$stretch}/)
	    {
		$c=1;
	    }
	    else
	    {
		push(@{$missed{$stretch}},$name);
	    }
	    $count{$stretch}=$count{$stretch}+$c;
	}
	$ref_hit='';
	$i=0;
	while ($ref_hit eq '')
	{
	    if ($seq{$selected_variants[$i]}=~/$second_set_stretch{$stretch}/)
	    {
		$ref_hit=$selected_variants[$i];
### Below: extract a <1 kb chunk of the reference sequence containing the hit (aligning the whole sequence with clustalw does not always align variants well; see reference "hCoV-19/Netherlands/NoordBrabant_10/2020|EPI_ISL_414431|2020-03-02" with "hCoV-19/Netherlands/NoordBrabant_29/2020|EPI_ISL_414538|2020-03-08" and "hCoV-19/USA/WA-UW31/2020|EPI_ISL_414618|2020-03-08" for example
		$pos=index $seq{$ref_hit},$second_set_stretch{$stretch};
		if ($pos>=500)
		{
		    $start_ref=$pos-500;
		}
		if ($pos<length($seq{$ref_hit})-500)
		{
		    $end_ref=$pos+500;
		}
		$ref_extract=substr $seq{$ref_hit},$start_ref,$end_ref-$start_ref+1;
	    }
	    else
	    {
		++$i;
	    }
	}
	$nb_missed=push(@{$missed{$stretch}});
	if ($nb_missed>0)
	{
	    $timestamp=`date +%s`;
	    chomp $timestamp;
	    open(FOR_ALIGN,">tmp_for_alignment".$timestamp.".fa");
	    print FOR_ALIGN ">$ref_hit\n$ref_extract\n>hit\n$second_set_stretch{$stretch}\n";
	    foreach $name (@{$missed{$stretch}})
	    {
		$align_extract=substr $seq{$name},$start_ref,$end_ref-$start_ref+1;
		print FOR_ALIGN ">$name\n$align_extract\n";
	    }
	    close(FOR_ALIGN);
#	    print "timestamp=$timestamp\n";
	    `clustalw tmp_for_alignment$timestamp.fa`;
	    %aligned=();
	    open(ALIGNED,"tmp_for_alignment".$timestamp.".aln");
	    while(<ALIGNED>)
	    {
		chomp;
		if (($_ ne 'CLUSTAL 2.1 multiple sequence alignment') && ($_ !~ /^ *$/))
		{
		    ($aligned_name,$aligned_seq)=split(' ',$_);
		    $aligned{$aligned_name}=$aligned{$aligned_name}.$aligned_seq;
		}
	    }
	    close(ALIGNED);
	    `rm tmp_for_alignment$timestamp.fa;rm tmp_for_alignment$timestamp.aln`;
	    $indA=index $aligned{'hit'},A;
	    $indC=index $aligned{'hit'},C;
	    $indG=index $aligned{'hit'},G;
	    $indT=index $aligned{'hit'},T;
	    $ind=$indA;
	    if ($indC < $ind)
	    {
		$ind=$indC;
	    }
	    if ($indG < $ind)
	    {
		$ind=$indG;
	    }
	    if ($indT < $ind)
	    {
		$ind=$indT;
	    }

	    print DETAILS "Stretch: $stretch:\n";
	    foreach $aligned_name (keys %aligned)
	    {
		$aligned_hit=substr $aligned{$aligned_name},$ind,length($second_set_stretch{$stretch});
		$display_name=$aligned_name;
		if ($aligned_name eq $ref_hit)
		{
		    $display_name=$display_name.' (positive control, with hit)';
		}
		print DETAILS "$aligned_hit $display_name\n";
	    }
	    print DETAILS "\n";
	}
	print EXTENDED "$second_set_stretch{$stretch} $stretch $nb_missed @{$missed{$stretch}}\n";

#	print "stretch $second_set_stretch{$stretch} $count{$stretch} @{$missed{$stretch}}\n";
    }
    close(EXTENDED);
 
}
