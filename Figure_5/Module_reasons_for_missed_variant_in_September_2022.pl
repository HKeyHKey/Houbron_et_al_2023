#!/usr/bin/perl

if ($ARGV[1] eq '')
{
    print "Please enter input file name then reference sequence name (e.g., ./Module_reasons_for_missed_variant_in_September_2022.pl For_alignment_chunk_28_Missed_for_AUGAUGCACUCAA.aln 'BetaCoV/Wuhan/IVDC-HB-01/2019|').\n";
    die;
}

$complete_seq=$ARGV[0];
$complete_seq=~s/\.aln$/.fa/;
open(COMPLETE,$complete_seq);
while(<COMPLETE>)
{
    chomp;
    if (/^>/)
    {
	s/^>//;
	$name=$_;
    }
    else # below: only works because sequences in my files fit on single lines (adapt if it is not the case for yours)
    {
	push(@{$seq_name{$_}},$name);
    }
}
close(COMPLETE);

$target=$ARGV[0];
$target=~s/.*_Missed_for_//;
$target=~s/\.aln$//;
$target=~tr/U/T/;

$id=0;
open(IN,$ARGV[0]);
while(<IN>)
{
    chomp;
    if ($_ ne 'CLUSTAL 2.1 multiple sequence alignment')
    {
	if (/^\S/)
	{
	    @array=split(' ',$_);
	    $seq{$array[0].'_unifier_'.$id}=$seq{$array[0].'_unifier_'.$id}.$array[1]; # adding a unifier tag because clustalw truncates sequences names (therefore occasionally creating ambiguities)
	    ++$id;
	    if ($array[0] eq $ARGV[1])
	    {
		push(@reference_candidates,$array[0].'_unifier_'.$id);
	    }
	}
	else
	{
	    $id=0;
	}
    }
}
close(IN);

@unique = do { my %seen; grep { !$seen{$_}++ } @reference_candidates};
if (scalar(@unique)!=1)
{
    print "Problem: found several (or none) sequence names matching $ARGV[1]...\n";
    print "ARGV[0]=$ARGV[0] and sequence names matching $ARGV[1]: @unique\n";
    die;
}

for $id (keys %seq)
{
    if ($id=~/^$ARGV[1]''_unifier_/)
    {
	$with_dashes=$seq{$id};
	$without_dashes=$with_dashes;
	$without_dashes=~s/-//g;
	@seq_array=split('',$with_dashes);
	$bp_without=-1;
	for ($bp_with=0;$bp_with<length($with_dashes);++$bp_with)
	{
	    if ($seq_array[$bp_with] ne '-')
	    {
		++$bp_without;
		$converted[$bp_without]=$bp_with;
	    }
	}

	$offset=0;
	$result=index(uc $without_dashes,$target,$offset);
	push(@hits,$result);
	while ($result != -1)
	{
	    $offset=$result+1;
	    $result=index(uc $without_dashes,$target,$offset);
	    if ($result!=-1)
	    {
		push(@hits,$result);
	    }
	}
	if (scalar(@hits)!=1)
	{
	    print "Problem: found several hits to $target in $ARGV[1]...\n";
	    die;
	}
	$hit_start_with_dashes=$converted[$hits[0]];
	$hit_end_with_dashes=$converted[$hits[0]+length($target)-1];
    }
}

for $id (keys %seq)
{
    $extract{$id}=substr $seq{$id},$hit_start_with_dashes,$hit_end_with_dashes-$hit_start_with_dashes+1;
    if ($id=~/^$ARGV[1]''_unifier_/)
    {
	@ref_extract=split('',$extract{$id});
    }
}

for $id (keys %seq)
{
    $mismatched=0;
    @array=split('',$extract{$id});
    if ($id!~/^$ARGV[1]''_unifier_/)
    {
	for ($nt=0;$nt<scalar(@ref_extract);++$nt)
	{
	    if (($array[$nt] ne $ref_extract[$nt]) && ($array[$nt]=~s/^[ACGT-]$//)) # if that variant differs from the target site by something else than a sequence ambiguity
	    {
		$mismatched=1;
	    }
	}
    }
    if ($mismatched)
    {
	$seq_without_dashes=$seq{$id};
	$seq_without_dashes=~s/-//g;
	for $name (@{$seq_name{$seq_without_dashes}})
	{
	    $truncated_id=$id;
	    $truncated_id=~s/_unifier_\d+$//;
	    if ($name=~/^$truncated_id/)
	    {
		$mismatch_extract{$name}=$extract{$id};
	    }
	}
    }
}

$radical=$ARGV[0];
$radical=~s/\.aln$//;
open(OUT,">Missed_not_because_of_ambiguity_in_$radical".".fa");
for $name (keys %mismatch_extract)
{
    print OUT ">$name\n$mismatch_extract{$name}\n";
}
close(OUT);
