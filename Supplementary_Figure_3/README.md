## Extraction of variant sequences from the Sept. 26, 2022 GISAID release: ##

Download of sample variant sequences: on September 27, 2022 from https://gisaid.org/hcov19-variants/ (see 'Screenshot1_GISAID.png' and 'Screenshot2_GISAID.png'). Files renamed 'recentReportedOccurrences_*.csv'.

``for variant in Alpha Beta Delta Gamma GH490R Lambda Mu Omicron;do grep -v '"Country","Virus Name","Submitted"' recentReportedOccurrences_$variant'.csv' | awk -F ',' '{print $2}' | sed 's|"||g' > $variant'.txt';done;for variant in Alpha Beta Delta Gamma GH490R Lambda Mu Omicron;do ./Script_extract.sh $variant;sleep 2;done``

## Selecting variants from human donors, at least 26 kb long with no more than 5% N: ##

Files 'dates_and_locations_tsv_2022_09_26.tar.xz', 'metadata_tsv_2022_09_26.tar.xz', 'sequences_fasta_2022_09_26.tar.xz' and 'variant_surveillance_tsv_2022_09_26.tar.xz': downloaded from https://www.epicov.org/epi3/frontend#4aac5d on Septembe
r 27, 2022. Uncompressing and renaming:

``tar -xJf dates_and_locations_tsv_2022_09_26.tar.xz;tar -xJf metadata_tsv_2022_09_26.tar.xz;tar -xJf variant_surveillance_tsv_2022_09_26.tar.xz;mv dates_and_locations.tsv dates_and_locations_2022_09_26.tsv;mv metadata.tsv metadata_2022_09_26.tsv;mv variant_surveillance.tsv variant_surveillance_2022_09_26.tsv``

Identifying sequences collected from non-human hosts:

``awk -F '\t' '$10!="Human" {print $1,$10}' metadata_2022_09_26.tsv > Non_human_hosts_in_2022_09_26_release.txt;sed -i '1 s|Virus name|Virus_name|' Non_human_hosts_in_2022_09_26_release.txt``

Extraction of mutation description for variants (correctly sequenced, from a human donor) in the 2022_09_26 dataset:

``awk -F '\t' '$10=="Human" && $16<=0.05 && $18>=26000 {OFS="\t";print $1,$7,$6}' variant_surveillance_2022_09_26.tsv > Variant_description_2022_09_26.tsv;awk -F '\t' '{print $2}' Variant_description_2022_09_26.tsv | sort | uniq -c > Variant_count_2022_09_26.txt``

``./Script_variant_selection.sh``

## Description of mutations in variants of concern in the 2022-09-26 dataset: ##

``./Script_mutation_statistics_in_variants_of_concern.sh``
