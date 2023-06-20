#!/bin/bash

target=$1
./Module_13mers_in_2022_09_26_dataset.pl Selected_sequences_2022_09_26.fa $target Non_human_hosts_in_2022_09_26_release.txt > Missed_2022_09_26_for_$target'.txt'
