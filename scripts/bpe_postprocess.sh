#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Example call:
#   bash scripts/bpe_postprocess.sh


# set paths
scripts=`dirname "$(readlink -f "$0")"`
base=$scripts/..

infile=$base/assignments/03/new_model/translations.txt
outfile=$base/assignments/03/new_model/translations_wo_bpe.txt
lang=en


sed -r 's/(@@ )|(@@ ?$)//g' $infile > $outfile