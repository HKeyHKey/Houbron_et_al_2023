## Collection of published siRNA sequences: ##

See file 'Published_siRNA_sequence_collection_notes.txt'. Sequences copied in file 'Published_siRNAs.fa'.

## Comparison of guide sequences:

``grep -A 1 'guide' Published_siRNAs.fa | grep -v '\-\-' | sed -e '/^>/ s|^> *|>|' -e '/^>/ s| |_|g' > For_guide_alignment.fa;grep -A 1 'guide' Our_siRNAs.fa | grep -v '\-\-' | sed -e '/^>/ s|^> *|>|' -e '/^>/ s| |_|g' >> For_guide_alignment.fa;clustalw For_guide_alignment.fa;njplot For_guide_alignment.dnd``

None of our siRNA candidates seems to overlap largely with a previously published siRNA guide.

With another method:

``makeblastdb -in For_guide_alignment.fa -dbtype nucl;blastn -db For_guide_alignment.fa -query For_guide_alignment.fa -evalue 0.001 -word_size 4 -outfmt 6 > Guide_self-blast.txt``


## Mapping on EPI_ISL_402119:

``makeblastdb -in EPI_ISL_402119.fasta -dbtype nucl;blastn -db EPI_ISL_402119.fasta -query For_guide_alignment.fa -evalue 0.001 -word_size 4 -outfmt 6 > Guide_blast.txt``

A few guides are not aligned:

``for id in `grep '>' For_guide_alignment.fa | sed 's|^>||'`;do if test `grep -wc $id Guide_blast.txt` -eq 0;then echo $id;fi;done;for i in `seq 4 11`;do grep -A 1 'Ambike22_34928377_N'$i'_guide_strand' For_guide_alignment.fa;done > missing.fa;grep -A 1 'Nabiabad22_34714580_siRNA_1031-1253_guide_strand' For_guide_alignment.fa >> missing.fa``

Blasting them on an index for the 312029 sequences in 'Selected_sequences_2021-01-08_08-46.fasta':

``makeblastdb -in /home/herve/Covid19/Ex_vivo_experiment/Selected_sequences_2021-01-08_08-46.fasta -dbtype nucl;blastn -db /home/herve/Covid19/Ex_vivo_experiment/Selected_sequences_2021-01-08_08-46.fasta -query missing.fa -evalue 0.001 -word_size 4 -outfmt 6 > Missing_blast.txt``

Result: siRNA "1031-1253" descrbied by Nabiabad et al., 2022, does not appear to map on the SARS-CoV-2 genome. Ambike et al., 2022 designed siRNAs purposedly raised against the negative strand (siRNA named starting with "N"), to see whether they would work (they don't): let's exclude them, for the fairness of comparison with positive strand-targeting siRNAs.
