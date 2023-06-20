#!/bin/bash

awk -F '\t' '{print $2}' Variant_description_2022_09_26.tsv | sort | uniq -c > Variant_count_2022_09_26.txt
for lineage in `awk '$3!="" {print $3}' Variant_count_2022_09_26.txt`
do awk -F '\t' '$2~/V[OU][CIM] '$lineage' / {print $3}' Variant_description_2022_09_26.tsv | sed -e 's|[()]||g' -e 's|,|\
|g' | sed 's|_.*||' | sort | uniq -c | sed 's|^ *|'$lineage' |'
done > Amino_acid_substitution_per_gene_in_VOC_VOI_VUM.dat
