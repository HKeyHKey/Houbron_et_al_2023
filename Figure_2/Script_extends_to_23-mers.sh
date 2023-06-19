#!/bin/bash

file=Selected_sequences_2021-01-08_08-46.fasta
seq=$1

grep -o '.\{'9'\}'$seq $file | sort | uniq -c > Perfect_hits_to_13-mer_$seq
