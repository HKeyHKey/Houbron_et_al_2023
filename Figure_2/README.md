## Initial screen for accessible regions in conserved genomic segments of the SARS-CoV-2 variant collection dated Mar. 17, 2020: ##

Variant fasta file 'gisaid_cov2020_sequences.fasta' downloaded on March 17, 2020 from [GISAID](https://gisaid.org/), selecting "human" as a host.

``./Script_candidate_target_sites.sh gisaid_cov2020_sequences.fasta;./Script_off-target_prediction.sh``

Intermediary files: 'Variant_homogeneity_Sampled_variants.dat' measures sequence conservation across the picked variants; 'EPI_ISL_402119_predicted_folding.tar.bz2' contains nucleotide pairing probability along the EPI_ISL_402119 variant genome and using various metrics (full-length genomic RNA folding; fill-length ORF folding; sliding window folding with various window sizes).

Result files: 'Candidate_13mers.fa' (contains the list of 13-mer sequences which are both conserved and structurally accessible in the Mar. 17, 2020 dataset) and 'Off-target_predictions.dat' (contains the number of human genes with 3´ UTR 7mer or 8mer match; both total genes and known haplo-insufficient genes).

## Final selection of candidate target sites, in an extended set of viral variants (dated Jan. 8, 2021): ##

See [commands for Figure 1C](https://github.com/HKeyHKey/Houbron_et_al_2023/tree/main/Figure_1) for download of file 'sequences_2021-01-08_08-46.fasta'.

``./Script_target_sites_in_updated_variant_dataset.sh sequences_2021-01-08_08-46.fasta Candidate_13mers.fa``

Resulting files: 'siRNA_candidate_ranking_data.csv' and 'siRNA_selection.pdf'. After examination of the list, we selected 8 candidate target sites (minimizing either the number of missed variants, or the number of predicted human haplo-insufficient off-targets, or both): they are listed in 'Selected_13-mers.fa'.

## Design of siRNA duplexes against these 8 target sites: ##

For each targeted 13-mer, extract its genomic context (for a total length of 22 nt; will be extended to 23 nt by adding a 5´ uridine to candidate guide strands) for every viral variant, and identify the most frequent 22-mer among them:

``for seq in `grep -v '^>' Selected_13-mers.fa`;do ./Script_extends_to_23-mers.sh $seq;done;for f in `ls Perfect_hits_to_13-mer_*`;do sort -g $f | tail -3;echo "";done``

Result: each of the 8 candidate 13-mers can nucleate a 22-nt perfect match which is conserved in a large majority of known variants (at least 310,000 out of 312,029 sequences in 'Selected_sequences_2021-01-08_08-46.fasta'). Optimization of guide/passenger duplexes for these eight 13-mers (trying to maximize duplex asymmetry while staying as close as possible to a 22 nt length; having a 5´ U for the guide, and 2 nt 3´ overhangs; fraying the 3´-most nt of the guide when paired to the target, in order to minimize the risks of TDMD against the guide):

``./Script_siRNA_duplex_design.sh``

Resulting file: 'siRNAs.fa'.
