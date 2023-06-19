#!/usr/bin/perl

$LENGTH_CUTOFF=26000; # minimal length for a variant to be selected
$PERCENT_N_CUTOFF=5; # maximal percent of "N" in sequence for a variant to be selected

if ($ARGV[0] eq '')
{
    print "Please enter script input (e.g., ./Module_alignment_of_sampled_variants.pl gisaid_cov2020_sequences.fasta).\n";
}
else
{
    open(IN,$ARGV[0]);
    while(<IN>)
    {
	chomp;
	if (/^>/)
	{
	    $name=$_;
	}
	else
	{
	    uc; # to convert every sequence into capital letters
	    s/ //g; # to remove space characters in sequence
	    $seq{$name}=$seq{$name}.$_;
	}
    }
    close(IN);

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
		push(@loc,$_);
		push(@{$names_for_loc{$_}},$name);
	    }
	}
    }

    @unique_loc = do {my %seen; grep { !$seen{$_}++ } @loc };

    foreach $loca (@unique_loc)
    {
	%patient_for_date=();
	@ified_dates_for_loca=();
	foreach $patient (@{$names_for_loc{$loca}})
	{
	    $date=$patient;
	    $date=~s/.*\|//;
	    push(@{$patient_for_date{$date}},$patient);
	    push(@ified_dates_for_loca,$date);
	}

	%seen=();
	@dates_for_loca = do {my %seen; grep { !$seen{$_}++ } @ified_dates_for_loca };

	$nb_dates=push(@dates_for_loca);
	if ($nb_dates>1)
	{
	    $date=$dates_for_loca[$nb_dates-1];
	    push(@select,${$patient_for_date{$date}}[0]); # pick the first patient for the last date for that localization
	    $date=$dates_for_loca[int rand($nb_dates-1)]; # pick randomly a different date for that same localization
	    push(@select,${$patient_for_date{$date}}[0]); # and pick the first patient 
	}
	else
	{
	    push(@select,${$patient_for_date{$date}}[0]); # if there was just a single date for that localization, just pick the first patient for that localization and date
	}
    }

    open(OUT,">Sampled_variants.fa");
    foreach $patient (@select)
    {
	print OUT "$patient\n$seq{$patient}\n";
    }
    close(OUT);
    `clustalw Sampled_variants.fa`;
}
