#!/bin/bash
mmseqs/bin/mmseqs createdb $1 all_seqs_db_"$2"

mmseqs/bin/mmseqs linclust -c 0.9 --min-seq-id 0.5 all_seqs_db_"$2" all_seqs_clu_100_"$2" tmpfolder_"$2"

mmseqs/bin/mmseqs createtsv all_seqs_db_"$2" all_seqs_db_"${2}" all_seqs_clu_100_"$2" all_seqs_clu_100_"$2".tsv

mmseqs/bin/mmseqs result2repseq all_seqs_db_"$2" all_seqs_clu_100_"$2" all_seqs_rep_100_"$2"

mmseqs/bin/mmseqs result2flat all_seqs_db_"$2" all_seqs_db_"$2" all_seqs_rep_100_"$2" all_seqs_rep_100_"$2".fasta --use-fasta-header

rm -r tmpfolder_"$2"
#rm -r tmpfolder_"$2" all_seqs_rep_${i} *dbtype *index all_seqs_db*
#ls all_seqs_clu_* | grep -v 'tsv' | xargs rm
#ls all_seqs_rep_* | grep -v 'fasta' | grep '.' | xargs rm

nextfile=all_seqs_rep_100_"${2}".fasta

for i in $(seq 45 -5 30);

do
mmseqs/bin/mmseqs createdb $nextfile all_seqs_rep_seed_db_"${2}"

mmseqs/bin/mmseqs linclust -c 0.9 --min-seq-id 0.${i} all_seqs_rep_seed_db_"${2}" all_seqs_clu_${i}_"${2}" tmpfolder_"${2}"

mmseqs/bin/mmseqs createtsv all_seqs_rep_seed_db_"${2}" all_seqs_rep_seed_db_"${2}" all_seqs_clu_${i}_"${2}" all_seqs_clu_${i}_"${2}".tsv

mmseqs/bin/mmseqs result2repseq all_seqs_rep_seed_db_"${2}" all_seqs_clu_${i}_"${2}" all_seqs_rep_${i}_"${2}"

mmseqs/bin/mmseqs result2flat all_seqs_rep_seed_db_"${2}" all_seqs_rep_seed_db_"${2}" all_seqs_rep_${i}_"${2}" all_seqs_rep_${i}_"${2}".fasta --use-fasta-header

tmpfolder_"$2"
#rm -r tmpfolder all_seqs_rep_${i} *dbtype *index all_seqs_rep_seed*
#ls all_seqs_clu_* | grep -v 'tsv' | xargs rm
#ls all_seqs_rep_* | grep -v 'fasta' | grep '.' | xargs rm

nextfile=all_seqs_rep_${i}_"${2}".fasta

done

