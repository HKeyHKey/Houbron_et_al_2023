#!/usr/bin/perl

$SHORTEST=3; # shortest window half-length, to be folded
$LONGEST=50; # longest window half-length, to be folded
$INCREMENT=2; # increment in window length while exploring possible lengths (choose an even number, to make sure that window length is always an odd number, centered on a given nucleotide

if ($ARGV[0] eq '')
{
    print "Please enter input file name (e.g., ./Module_substructure_folding.pl Methylated_hsa_rRNAs.fa).\n";
}
else
{
    $timestamp=`date +%s`;
    chomp $timestamp;
    $radical=$ARGV[0];
    $radical=~s/\.fa$//;
    open(FASTA,$ARGV[0]);
    while (<FASTA>)
    {
        chomp;
        if (/^>/)
        {
            s/^> *//;
            s/ .*//;
            $name=$_;
        }
        else
        {
            s/T/U/g;
            $seq{$name}=$seq{$name}.$_;
        }
    }
    close(FASTA);

    for $ref (keys(%seq))
    {
        $length=length($seq{$ref});
        for ($size=2*$SHORTEST+1;$size<=2*$LONGEST+1;$size+=$INCREMENT)
        {
            print "Now working on $size nt-long windows on $ref...\n";
            $half=int $size/2;
            $id=$half+1;
            open(OUT,">Substructure_pairing_proba_".$size."_nt_window_in_".$ref.".dat");
            for ($nt=0;$nt<$half;++$nt)
            {
                $n=$nt+1; # So that nucleotides are 1-based numbered in the output file
                print OUT "$n NA\n";
            }
            for ($nt=$half;$nt<$length-$half;++$nt)
            {
                $extract=substr $seq{$ref},$nt-$half,$size;
                open(TMP,">tmp_$timestamp"."_$ARGV[0]");
                print TMP ">extract_$timestamp"."_$radical\n$extract\n";
                close(TMP);
                $p=`cat tmp_$timestamp"_"$ARGV[0] | RNAfold -p > /dev/null;grep ' ubox\$' extract_"$timestamp"_"$radical"_dp.ps | awk '\$1=="'$id'" || \$2=="'$id'" {s+=\$3^2} END {print s}'`;
                chomp $p;
                if ($p eq '')
                {
                    $p=0;
                }
                $n=$nt+1;
                print OUT "$n $p\n";
            }
            for ($nt=$length-$half;$nt<$length;++$nt)
            {
                $n=$nt+1;
                print OUT "$n NA\n";
            }
            close(OUT);
        }

    }
}
