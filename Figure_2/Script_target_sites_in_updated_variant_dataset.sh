#!/bin/sh

if test "$2" = ""
then echo "Please enter input file name (fasta file containing variant sequences, then fasta file containing candidate list of 13-mer target sites; e.g.: ./Script_target_sites_in_updated_variant_dataset.sh sequences_2021-01-08_08-46.fasta Candidate_13mers.fa)."
     exit
fi

file=$1
candidate_13mers=$2

### Below: because in 'sequences_2021-01-08_08-46.fasta', variant "USA/WA-UW-4572/2020" contains U's instead of T's, beause some variants from California have a weird character string (HMSHNNCAMNTCSCYGWNHMSHNCVGSADBATCHCM...) appended after their 3´ end (in the sequence, not the header!), and because variant "Georgia/Tb-72720/2020" is in the reverse orientation:
./Module_variant_selection.pl $file | sed -e '/^>/ !s|U|T|g' -e '/^>/ !s|HMSHNNCAMNTCSCYGWNHMSHNCVGSADBATCHCM.*||' | sed '/^>/ {
N       
s|\(.*\)\n\(.*\)|\1@\2|
}' > tmp_reorient_$file
grep -v 'Georgia/Tb-72720/2020@' tmp_reorient_$file | sed 's|@|\
|' > Selected_$file
grep 'Georgia/Tb-72720/2020@' tmp_reorient_$file | sed 's|@|\
|' | head -1 | sed 's|>|>ANTI|' >> Selected_$file
grep 'Georgia/Tb-72720/2020@' tmp_reorient_$file | sed 's|@|\
|' | tail -1 | rev | tr ACGT TGCA >> Selected_$file
for s in `grep -v '>' $candidate_13mers`;do head -2 Selected_$file | tail -1 | grep -c $s;done | sort | uniq -c # OK: the first sequence in 'sequences_2021-01-08_08-46.fasta' (i.e.: Denmark/DCGC-10274/2020) contains a perfect match to each of the 18 candidate 13-mers (we will use it as a reference)

### Below: for each candidate 13-mer target site: for each variant in Selected_$file, identifies those which do not match perfectly the candidate 13-mer, and extract their sequence at that location (only 14 out of 18 candidates could be analyzed: 2 candidates map too close to the genome's end, and they are absent in truncated variants; and 2 candidates are not perfectly matched by so many variants, that their alignment [for extraction of their mismatched sequence] is extremely long - and anyway they are not the most interesting candidates):

for candidate in `grep -v '>' $candidate_13mers`
do ./Script_extracts_missed.sh $file $candidate # output files: 'Missed_hits_for_*'
done

### For the remaining 14 candidate target sites: 

./Script_siRNA_candidate_ranking.sh $file



