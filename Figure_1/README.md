## Data submission timeline on GISAID (Figure 1A): ##

File 'dates_and_locations_tsv_2022_09_26.tar.xz': downloaded from https://www.epicov.org/epi3/frontend#4aac5d on September 27, 2022.

``tar -xJf dates_and_locations_tsv_2022_09_26.tar.xz;awk -F '\t' '$4=="Human" {print $2,$5}' dates_and_locations.tsv | grep '^[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9] [0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]$' > peeled.dat;R CMD BATCH R_commands_GISAID_collection_dates``


## Conceptual folding of viral RNA (Figure 1B): ##

See commands for [Figure 2](https://github.com/HKeyHKey/Houbron_et_al_2023/tree/main/Figure_2), section "Initial screen for accessible regions in conserved genomic segments of the SARS-CoV-2 variant collection dated Mar. 17, 2020".

## Conservation along SARS-CoV-2 genome (Figure 1C): ##

File 'sequences_2021-01-08_08-46.fasta.gz' downloaded from [GISAID](https://gisaid.org/) on January 11, 2021. Selection of variants (at least 26 kb long, and no more than 5% N; elimination of samples from non-human animal donors) (N.B.: variant "USA/WA-UW-4572/2020" contains U's instead of T's; some variants from California have a weird character string (HMSHNNCAMNTCSCYGWNHMSHNCVGSADBATCHCM...) appended after their 3´ end (in the sequence, not the header); and variant "Georgia/Tb-72720/2020" is in the reverse orientation):

``file=sequences_2021-01-08_08-46.fasta;gunzip $file'.gz';./Module_variant_selection.pl $file | sed -e '/^>/ !s|U|T|g' -e '/^>/ !s|HMSHNNCAMNTCSCYGWNHMSHNCVGSADBATCHCM.*||' | sed '/^>/ {
N       
s|\(.*\)\n\(.*\)|\1@\2|
}' > tmp_reorient_$file;grep -v 'Georgia/Tb-72720/2020@' tmp_reorient_$file | sed 's|@|\
|' > Selected_$file;grep 'Georgia/Tb-72720/2020@' tmp_reorient_$file | sed 's|@|\
|' | head -1 | sed 's|>|>ANTI|' >> Selected_$file;grep 'Georgia/Tb-72720/2020@' tmp_reorient_$file | sed 's|@|\
|' | tail -1 | rev | tr ACGT TGCA >> Selected_$file``

Random picking 100 non-overlapping sets of 100 sequences each, aligning each of them, and plotting conservation score along genomic coordinates:

``./Script_random_pick.sh Selected_sequences_2021-01-08_08-46.fasta;for set in `seq 1 100`;do ./Script_align_random_set.sh $set;done;./Script_parse_aligned_random_sets.sh``
