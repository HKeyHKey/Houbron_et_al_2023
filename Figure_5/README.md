## Number of variants missed by 3-siRNA combinations (Figure 5A): ##

Files 'sequences_fasta_2022_09_26.tar.xz' and 'metadata_2022_09_26.tsv' downloaded from https://www.epicov.org/epi3/frontend#4aac5d on September 27, 2022.

``tar -xJf sequences_fasta_2022_09_26.tar.xz;tar -xJf metadata_tsv_2022_09_26.tar.xz;./Module_variant_selection_RAM_savvy.pl sequences.fasta > Selected_sequences_2022_09_26.fa;awk -F '\t' '$10!="Human" {print $1,$10}' metadata_2022_09_26.tsv > Non_human_hosts_in_2022_09_26_release.txt;grep -v '^Virus_name Host$' Non_human_hosts_in_2022_09_26_release.txt | awk '{print $1}' | sort | uniq > tmp_non_human;grep '^>' Selected_sequences_2022_09_26.fa | sed -e 's|^> *||' -e 's/|.*//' | sort | uniq > tmp_selected;echo "Counting selected sequences from human and non-human hosts (flag=1: selected variants from human donor; flag=2: unselected (because of too many N's or too short sequence) variants from non-human donor; flag=3: selected variants from non-human donor):"
cat tmp_selected tmp_non_human tmp_non_human | sort | uniq -c | awk '{print $1}' | sort -g | uniq -c``

Result: 13,033,077 correctly-sequenced variants from human donors; 133 uncorrectly-sequenced variants from other donors; 10,972 correctly-sequenced variants from other donors.

``for target in GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA;do sbatch Script_13mers_in_2022_09_26_dataset.sh $target;done;./Fuses_lines_clean.pl EPI_ISL_402119.fasta > Fused_EPI_ISL_402119.fasta;for target in GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA;do ./Script_reasons_for_missed_variants_step1.sh $target;done;for file in `ls For_alignment_chunk_*.fa`;do clustalw $file;done;for file in `ls For_alignment_chunk_*.aln`;do ./Module_reasons_for_missed_variant_in_September_2022.pl $file 'BetaCoV/Wuhan/IVDC-HB-01/2019|';done;for target in GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA;do cat Missed_not_because_of_ambiguity_in_For_alignment_chunk_*_Missed_for_$target'.fa' > Missed_not_because_of_ambiguity_for_$target'.fa';done;for target in `ls Missed_not_because_of_ambiguity_for_* | sed -e 's|Missed_not_because_of_ambiguity_for_||' -e 's|\.fa$||'`;do grep '>' Missed_not_because_of_ambiguity_for_$target'.fa' | sed -e 's|^>||' -e 's| .*||' > missed_not_because_of_ambiguity_for_$target;done;for f in `ls missed_not_because_of_ambiguity_for_*`;do n=`cat $f | wc -l`;echo `echo $f | sed 's|missed_not_because_of_ambiguity_for_||'` $n;done``

Result: number of missed variants (not for sequence ambiguity) for each of the six siRNAs of interest:
AAUGAUGCACUCA 29433
AUGAUGCACUCAA 29389
CCAUUUGUAGUUU 14163
GUAAACAGAUUUA 7918
GUGUCUUUAGCUA 8696
UGUCUUUAGCUAU 7937

``for target1 in `ls missed_not_because_of_ambiguity_for_* | sed 's|missed_not_because_of_ambiguity_for_||'`;do for target2 in `ls missed_not_because_of_ambiguity_for_* | sed 's|missed_not_because_of_ambiguity_for_||' | sed '0,/^'$target1'$/ d'`;do for target3 in `ls missed_not_because_of_ambiguity_for_* | sed 's|missed_not_because_of_ambiguity_for_||' | sed '0,/^'$target2'$/ d'`;do if test `cat missed_not_because_of_ambiguity_for_$target1 missed_not_because_of_ambiguity_for_$target2 missed_not_because_of_ambiguity_for_$target2 missed_not_because_of_ambiguity_for_$target3 missed_not_because_of_ambiguity_for_$target3 missed_not_because_of_ambiguity_for_$target3 missed_not_because_of_ambiguity_for_$target3 | sort | uniq -c | awk '{print $1}' | sort -g | uniq -c | awk '$2==7 {print}' | wc -l` -eq 0;then echo $target1 $target2 $target3;fi;done;done;done``

Result: 12 distinct 3-siRNA combinations do not miss any of the correctly sequenced variants (as of September 26, 2022), excluding variants that were not matched perfectly because of sequence ambiguities.

## Extraction of siRNA target sites for variants of concern and variants of interest (Figure 5B): ##

Sample variant sequence ID's were downloaded from https://gisaid.org/hcov19-variants/ on September 27, 2022 (files renamed 'recentReportedOccurrences_\*.csv').

``for variant in Alpha Beta Delta Gamma Lambda Mu Omicron;do grep -v '"Country","Virus Name","Submitted"' recentReportedOccurrences_$variant'.csv' | awk -F ',' '{print $2}' | sed 's|"||g' > $variant'.txt';done;for variant in Alpha Beta Delta Gamma Lambda Mu Omicron;do ./Module_extracts_sequences_from_fasta.pl sequences.fasta $variant'.txt' > Extracted_sequences_$variant'.fa';done``

Verification that all these sequences are in the standard orientation:

``for lineage in Alpha Beta Delta Gamma Lambda Mu Omicron;do blastn -db EPI_ISL_402119.fasta -query Extracted_sequences_$lineage'.fa' -evalue 0.001 -word_size 12 -outfmt 6 | awk -F '\t' '$4>=200 && $10<$9 {print}';done``

(they are).

Selection of correctly sequenced variants (at least 26 kb long, no more than 5% N, and: isolated from a human host):

``for f in `ls Extracted_sequences_*.fa`;do ./Module_variant_selection_with_host_selection.pl $f metadata_2022_09_26.tsv > Selected_$f;done``

Extraction of siRNA target sites on each correctly sequenced variant for these 7 lineages:

``for target in AGAACUUUAAGUC GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAGAACUUUAAGU AAUGAUGCACUCA;do ./Script_hits_on_variants_of_interest_September_2022.sh $target > Reasons_for_variant_missing_$target'.txt';done``

## Recorded mino acid substitutions per ORF in each variant of concern or of interest (Figure 5C and Supplementary Figure 2): ##

File 'variant_surveillance_tsv_2022_09_26.tar.xz': downloaded from https://www.epicov.org/epi3/frontend#4aac5d on September 27, 2022.

``tar -xJf variant_surveillance_tsv_2022_09_26.tar.xz;mv variant_surveillance.tsv variant_surveillance_2022_09_26.tsv;awk -F '\t' '$10=="Human" && $16<=0.05 && $18>=26000 {OFS="\t";print $1,$7,$6}' variant_surveillance_2022_09_26.tsv > Variant_description_2022_09_26.tsv;./Script_mutation_statistics_in_variants_of_concern.sh;Rscript R_commands_amino_acid_substitutions_in_VOC_VOI_VUM Amino_acid_substitution_per_gene_in_VOC_VOI_VUM_2022_09_26.dat ORF_lengths.dat``
