#!/usr/bin/perl


$FLANK=500; # length (in nt) of the flank to be extracted on each side of the target site for clustalw alignment
$ORI_CUTOFF=0.9; # minimal accepted ratio of minus-aligned lengths / plus-aligned lengths for the variant to be flagged as "minus-oriented" (and reciprocally, with cutoff=1-$ORI_CUTOFF, for the variant to be flagged as "plus-oriented")
$CHUNK_SIZE=1000; # number of sequences to be clustalw-aligned with the reference sequence in each chunk (we won't clustalw-align all of them at once: takes too much time; so we'll split the sequence set into as many chunks as required)

if ($ARGV[5] eq '')
{
    print "Please enter input file name then reference sequence name, then target start and end positions in reference sequence, then fasta file containing variant sequences of interest, then fasta file with reference sequence (e.g., ./Module_extracts_for_alignment.pl Blast_output_missed_UGUCUUUAGCUAU.txt 'BetaCoV/Wuhan/IVDC-HB-01/2019|EPI_ISL_402119' 16019 16031 Missed_for_UGUCUUUAGCUAU.fa Fused_EPI_ISL_402119.fasta).\n";
    die;
}

open(FASTA,$ARGV[4]);
while(<FASTA>)
{
    chomp;
    if (/^>/)
    {
	s/^> *//;
	$name=$_;
    }
    else
    {
	$seq{$name}=$seq{$name}.$_;
    }
}
close(FASTA);

open(REF_FASTA,$ARGV[5]);
while(<REF_FASTA>)
{
    chomp;
    if (/^>/)
    {
	s/^> *//;
	if ($_ ne $ARGV[1])
	{
	    print "Warning! Sequence name in reference sequence file (file $ARGV[5]) is not the same than the one you provided as a script argument ($ARGV[1]). Please make sure that the sequence and its name are correct (I will proceed anynway).\n";
	}
    }
    else
    {
	$ref_sequence=$ref_sequence.$_;
    }
}
close(REF_FASTA);

  
open(BLAST,$ARGV[0]);
while(<BLAST>)
{
    chomp;
    @array=split('\t',$_);
    if ($array[9]<$array[8])
    {
	push(@{$minus_orientation{$array[0]}},$array[8]-$array[9]+1)
    }
    else
    {
	push(@{$plus_orientation{$array[0]}},$array[9]-$array[8]+1)
    }
    @positions_of_interest=($ARGV[2],$ARGV[3]);
    for ($position_index=0;$position_index<=1;++$position_index)
    {
	if ((($array[8]<=$positions_of_interest[$position_index]) && ($array[9]>=$positions_of_interest[$position_index])) || (($array[9]<=$positions_of_interest[$position_index]) && ($array[8]>=$positions_of_interest[$position_index])))
	{
	    $converted_position=$array[6]+($positions_of_interest[$position_index]-$array[8])/($array[9]-$array[8])*($array[7]-$array[6]);
	    $converted_position=sprintf "%.0f",$converted_position;
	    $conv=$position_index.'_'.$array[3].'_'.$converted_position; # storing information about alignment block length (we'll keep the position deduced from the longest block)
	    push(@{$converted{$array[0]}},$conv);
	}

    }
}
close(BLAST);

$extract_start=$ARGV[2]-$FLANK;
if ($extract_start<0)
{
    $extract_start=0;
}
$extract_end=$ARGV[2]+$FLANK;
$ref_extract=substr $ref_sequence,$extract_start,$extract_end-$extract_start+1;
$ref_header=">".$ARGV[1]." nt ".$extract_start."-".$extract_end;

$chunk=0;
$count_in_chunk=0;
open(OUT,">For_alignment_chunk_$chunk"."_$ARGV[4]");

for $id (keys %converted)
{
    $sum_minus=0;
    for $block (@{$minus_orientation{$id}})
    {
	$sum_minus+=$block;
    }
    $sum_plus=0;
    for $block (@{$plus_orientation{$id}})
    {
	$sum_plus+=$block;
    }

    $minus_ratio=$sum_minus/($sum_minus+$sum_plus);
    if (($minus_ratio>1-$ORI_CUTOFF) && ($minus_ratio<$ORI_CUTOFF))
    {
	print "Problem identifying the orientation of variant $id (here are the cumulated lengths in each orientation: minus: $sum_minus; plus: $sum_plus; percentage of minus: ".$sum_minus*100/($sum_minus+$sum_plus)."). I will ignore that variant.\n";
    }
    else
    {
	@longest=(0,0);
	@position_longest=('NA','NA');
	for $conv (@{$converted{$id}})
	{
	    @array=split('_',$conv);
	    $position_index=$array[0];
	    $block_length=$array[1];
	    $position=$array[2];
	    if ($block_length>$longest[$position_index])
	    {
		$longest[$position_index]=$block_length;
		$position_longest[$position_index]=$position;
	    }
	}

	$mean=0;
	$count=0;
	for ($position_index=0;$position_index<=1;++$position_index)
	{
	    if ($position_longest[$position_index] ne 'NA')
	    {
		$mean+=$position_longest[$position_index];
		++$count;
	    }
	}
	$mean=sprintf "%.0f",$mean/$count;
	$extract_start=$mean-$FLANK;
	if ($extract_start<0)
	{
	    $extract_start=0;
	}
	$extract_end=$mean+$FLANK;
	$extract=substr $seq{$id},$extract_start,$extract_end-$extract_start+1;
	if ($minus_ratio>=$ORI_CUTOFF) # then this variant sequence is in reverse orientation (possibly the target sequence itself may have been inverted and may appear in the sense orientation, but the overall variant sequence shows that the genome has to be reverse-complemented; see hCoV-19/India/KA-SEQ_12900_S165_R1_001/2022 for an example, with target segment at nt 16019-16031 of BetaCoV/Wuhan/IVDC-HB-01/2019|EPI_ISL_402119 in a locally sense segment in that variant)
	{
	    $extract=reverse($extract);
	    $extract=~tr/ACGTRYKMBVDH/TGCAYRMKVBHD/;
	    print OUT ">$id ANTI nt $extract_start-$extract_end\n$extract\n";
	}
	else
	{
	    print OUT ">$id nt $extract_start-$extract_end\n$extract\n";
	}
	++$count_in_chunk;
	if ($count_in_chunk==$CHUNK_SIZE)
	{
	    print OUT "$ref_header\n$ref_extract\n";
	    close(OUT);
	    ++$chunk;
	    $count_in_chunk=0;
	    open(OUT,">For_alignment_chunk_$chunk"."_$ARGV[4]");
	}
	
    }
}
print OUT "$ref_header\n$ref_extract\n";
close(OUT);
