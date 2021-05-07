

iterative linclust > cluster > 




# orfleton-v2

###Cluster sizes

iterative clustering data (parse_iterative_clustering\*.py)

###iterative clustering plot

iterative clustering data (parse_iterative_clustering\*.py)

###iterative linclust mapping file

You also need the mapping between each unclustered ORF and the consensus genes. Need to run create_linclust_mapping_file.py

Before doing next steps need to run global overlap sampling (get_body_site_overlaps.py), which gives the genes unique to different combinations of sites. These IDs can then be grepped out of the multi_map_30 overlap file to create smaller, more manageable datasets for the subsampling analysis. 

You then need to get get_raw_orfs_from_genecat to get the consensus gene raw gene mapping for each of the files of interest.

###Global vs unique to sample (with supp of other overlaps and network graph)

subsampled overlap sampling (get_body_site_overlaps_subsampled.py)

###total overlap across samples

global overlap sampling (get_body_site_overlaps.py)

then you'll need to run get_raw_orfs.py to get the raw orfs from the congenes

you can then compute prevalence

you can then get raw sequences from file

###tsv files

cat all the tsv files from prokka together 

get lists of all the COGS, names, and ecnumbers of interest (everything in the pan tsv files column 4,5,6)



















run extract_orf_annotations_from_tsv_file.py. Args are "all_genes" file, with con genes in second col and raw genes in first and the right tsv file given the body site(s) of interest. You will likely need to batch the larger files (eg gut/env/global/human-host) into multiples, and you will also need to batch the pan tsv file into multiple. Use split command, 50M lines in former, 100M in latter, then 40G of ram with 1 core was sufficiently fast.

You will now need to make the additional combination files of interest for the tsv data. For example, ALL annotations unique to the human microbiome, etc (see list of catalogs at top of readme).

After getting the right tsv data, be sure you generate the overall feature counts 

###raw sequences

run parse_orfs.py with the "specific_genes" files as inputs (raw orf on left and environment on right) to get the raw sequences

run it again on the consensus genes (one column, congenes on left) to get congene sequences




