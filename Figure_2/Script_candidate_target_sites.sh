#!/bin/sh

if test "$1" = ""
then echo "Please enter input file name (fasta file containing variant sequences; e.g.: ./Script_candidate_target_sites.sh gisaid_cov2020_sequences.fasta)."
     exit
fi

variant_file=$1

### Below: variant "hCoV-19/Guangzhou/GZMU0047/2020|EPI_ISL_414690|2020-02-25" is in the reverse orientation in the March 17, 2020 dataset (it has been removed from newer datasets)
~/Fuses_lines_clean.pl $variant_file | sed 's|\r||' > Fused_$variant_file
sed '/^>/ {
N
s|\(.*\)\n\(.*\)|\1@\2|
}' Fused_$variant_file | grep -v 'EPI_ISL_414690' | sed 's|@|\
|' > Corrected_$variant_file


### Below: from a set of virus variants (picked from every listed geographic location), find a first set of candidate target sites (perfectly conserved among all these picked variants):
sed '/^>/ s| |_|g' Corrected_$variant_file > Arranged_$variant_file
./Module_alignment_of_sampled_variants.pl Arranged_$variant_file # among variants at least 26 kb long, with no more than 5% N ambiguous nucleotides, pick variants from various locations and various sampling dates, then align them (for the GISAID dataset of March 17, 2020: that's 101 variants)
./Module_alignment_scan_virus.pl Sampled_variants.aln # quantifies sequence homogeneity among the picked variants, and issue a first set of candidate target sites (perfectly conserved among all picked variants); output files: 'Variant_homogeneity_Sampled_variants.dat' and 'First_set_Variant_homogeneity_Sampled_variants.dat'.


### Below: compute predicted RNA secondary structure for one reference variant ("EPI_ISL_402119"), with various metrics (full-length genomic RNA; full-lengths ORFs; sequence windows of various size ranges):

echo ">EPI_ISL_402119" > EPI_ISL_402119.fasta
grep -A 1 'EPI_ISL_402119' Corrected_$variant_file | tail -1 >> EPI_ISL_402119.fasta
./Script_folding.sh EPI_ISL_402119.fasta ORF_coordinates_in_EPI_ISL_402119.txt # file 'ORF_coordinates_in_EPI_ISL_402119.txt' was filled by hand, using the information in https://www.ncbi.nlm.nih.gov/nucleotide/MN996528.1 and https://genome.ucsc.edu/cgi-bin/hgTracks?db=wuhCor1&lastVirtModeType=default&lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&position=NC_045512v2%3A1%2D29903&hgsid=1006744413_JOafae2QKcQsCaatCMyrAZM50LRQ
# output files: stored in 'EPI_ISL_402119_predicted_folding.tar.bz2'


### Below: from the first set of candidate target sites, extract those which are perfectly conserved in every variant in $variant_file while being structurally accessible (pairing probability <= 0.1 according to every metric: full-length, ORF, and sequence window folding):

./Module_extends_from_sampled_to_every_variant.pl Corrected_$variant_file Variant_homogeneity_Sampled_variants.dat First_set_Variant_homogeneity_Sampled_variants.dat EPI_ISL_402119 # for every candidate in the first set, selects those which are structurally accessible, then counts how many variants are matched and unmatched among every variant at least 26 kb long, with no more than 5% N ambiguous nucleotides, in $variant_file; output file: 'Hits_to_second_set_in_selected_variants_from_Corrected_gisaid_cov2020_sequences.fasta.dat'
awk '$3==0 {print ">alignment_"$2"\n"$1}' Hits_to_second_set_in_selected_variants_from_Corrected_$file'.dat' > Candidate_13mers.fa

### Below: for each candidate target site, compute the potential guide strand (well, its 14 first nucleotides):

for id in `grep '>' Candidate_13mers.fa | sed 's|^>||'`
do seq=`grep -A 1 '^>'$id'$' Candidate_13mers.fa | tail -1 | rev | tr ACGT UGCA | sed 's|^|U|'`
   echo ">Guide_strand_nt_1-13_for_"$id
   echo $seq
done > Candidate_guide_strand_13mers.fa


