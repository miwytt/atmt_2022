#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Example call:
#   bash scripts/bpe_preprocess.sh

set -e

# set languages
src_lang=fr
tgt_lang=en

# set paths
scripts=`dirname "$(readlink -f "$0")"`
base=$scripts/..
preprocessed=$base/data/en-fr/preprocessed
prepared_bpe=$base/data/en-fr/prepared_bpe
echo $preprocessed
echo $prepared

# Learn byte pair encoding on the concatenation of the tokenization on normalized, truecased and word level tokenized training text, and get resulting vocabulary for each
subword-nmt learn-joint-bpe-and-vocab --input $preprocessed/vocab.$src_lang $preprocessed/train.$tgt_lang -o $preprocessed/bpe_output --write-vocabulary $preprocessed/vocab.$src_lang $preprocessed/vocab.$tgt_lang

for split in train tiny_train
	do
		# re-apply byte pair encoding with vocabulary filter
		subword-nmt apply-bpe -c $preprocessed/bpe_output --vocabulary $preprocessed/vocab.$src_lang --vocabulary-threshold 1 < $preprocessed/$split.$src_lang > $preprocessed/$split.BPE.$src_lang --dropout 0.1 --seed 42
		subword-nmt apply-bpe -c $preprocessed/bpe_output --vocabulary $preprocessed/vocab.$tgt_lang --vocabulary-threshold 1 < $preprocessed/$split.$tgt_lang > $preprocessed/$split.BPE.$tgt_lang --dropout 0.1 --seed 42
	done

for split in test valid
	do
		# re-apply byte pair encoding with vocabulary filter
		subword-nmt apply-bpe -c $preprocessed/bpe_output --vocabulary $preprocessed/vocab.$src_lang --vocabulary-threshold 1 < $preprocessed/$split.$src_lang > $preprocessed/$split.BPE.$src_lang
		subword-nmt apply-bpe -c $preprocessed/bpe_output --vocabulary $preprocessed/vocab.$tgt_lang --vocabulary-threshold 1 < $preprocessed/$split.$tgt_lang > $preprocessed/$split.BPE.$tgt_lang
	done

echo "preparing data for model training..."

python $base/preprocess.py \
    --source-lang $src_lang \
    --target-lang $tgt_lang \
    --dest-dir $prepared_bpe \
    --train-prefix $preprocessed/train.BPE \
    --valid-prefix $preprocessed/valid.BPE \
    --test-prefix $preprocessed/test.BPE \
    --tiny-train-prefix $preprocessed/tiny_train.BPE \
    --threshold-src 1 \
    --threshold-tgt 1 \
    --num-words-src 4000 \
    --num-words-tgt 4000

echo "done."