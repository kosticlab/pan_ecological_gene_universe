## Overview

This repository contains code to reproduce the work in the manuscript "A pan-ecological metagenomic database reveals over 1,800 genes conserved across microbial ecosystems" by Braden T Tierney, Samuel Zimmerman, Chirag J Patel, Aleksandar D Kostic.

## Abstract:

The human microbiome has pan-ecological evolutionary origins, yet a systematic gene-level analysis of microbial life across ecologies is lacking. We quantified the gene content from 14,183 samples across 17 ecologies -- 6 human-associated, 7 non-human-host associated (e.g. mouse gut), and 4 in other environmental niches (e.g. soil). At 30% amino acid identity, we identified 117,629,181 non-redundant genes across all samples, 66% of which were singletons, only being observed in one sample. We quantified the genetic similarity and “uniqueness” between different ecologies, showing that sites like the human vaginal and skin ecologies had low genetic alpha-diversity yet high beta-diversity, indicating few species but high pangenomic variation. We further identified a set of 1,864 sequences conserved across all ecologies, which indicates an overwhelming gene-level conservation to microbial life despite extreme taxonomic variation. Critically, using the literature standard of 90% clustering identity for microbiome gene catalogs, we did not observe any globally conserved genes, even those known to be present in all bacteria. This suggests that prior studies have not estimated microbial gene content accurately. We additionally found genes that were differentially abundant in particular groups of ecologies (e.g. human gut and non-human gut genes), identifying discrete functions among these groups. We showed that genes associated with pathogenic taxa tend to be the most likely to appear in multiple ecologies. We provide our databases, as well as the sets of genes described above, as a resource at https://microbial-genes.bio/. 


## Resource location:

https://microbial-genes.bio/

## Code and scripts

This code is provided for reproducibility and clarify of our methods. Some scripts were run on a High-Performance-Computing cluster with a slurm-based job submission system. This will be apparent based on certain absolute paths and submission commands used in specific text files.

### Get all annotation data for every consensus sequence in our database

get_full_consensus_seq_annotations.Rmd

### Assemble samples

The scripts used in assemble/assembly_scripts were used to assemble and functionally annotate our samples. Input files needed are in assemble/files_for_gene_catalogue and assemble/example_input.txt is an example of the input used in the scripts

### Run (iterative) clustering

These scripts are in the "clustering" folder. The second round of clustering for 90%, 50%, and 30% identity used mmseqs cluster instead of linclust, lacked the loop but otherwise had the same parameters. The python parsing scripts help map between raw and consensus genes.

This also contains a python script for finding "overlaps" between genes in terms of the ecologies they assemble in (find_gene_ecology_overlaps.py). The output of this file is used to find the pan-ecological-genes. The input file is made by cutting (the bash command) the first column of the iterative mapping file made by create_linclust_mapping_file.py and whatever consensus gene ID column corresponds to your percent identity of interest.

### Get functional and taxonomic annotations for our consensus genes

The scripts used in get_protein_taxa_annotations_cons_seqs/scripts were used to get the functional and taxonomic annotations for all 117 million consensus sequences

### UMAP Cluster samples

The scripts used in UMAP_clustering/scripts were used to cluster the samples by there gene content.

calc_svd_2.R is used by calc_svd.bash inside the Rmd run_SVD_on_clusters.Rmd to run LSA on  our samples. 
calc_svd.bash runs calc_svd_2.R

cluster_OV2_samples_many_params.Rmd is used to create the supplementary figures that creates UMAPs with different parameters.

clustering_OV2_v2.Rmd creates UMAPs and clusters our samples.

get_cluster_and_taxa_each_gene.Rmd gets the taxonomy and cluster for every consensus gene in the 30% identity gene catalogue. Not used in manuscript

run_SVD_on_clusters.Rmd uses calc_svd.bash to run SVD on our samples.

### Enrichments

The scripts used in UMAP_enrichments/scripts were used to see what taxa and functions were enriched in each UMAP cluster.

calculate_enrichment.Rmd gets the taxa and functions enriched in each cluster.

umap_function_enrichments.Rmd plots the functions enriched in each cluster

umap_taxa_enrichments.Rmd plots the taxa enriched in each cluster

### Get prevalence of highly conserved genes and the 120 GTDB bacterial genes those highly conserved genes align to

prevalence_highly_conserved_genes/scripts/get_global_conserved_gene_prevalence_each_ecology.Rmd gets the prevalence of each highly conserved gene in all samples. It also gets the taxa and function of each gene and outputs to a file. Output file is global_conserved_genes_prevalence_annotated.txt

prevalence_highly_conserved_genes/plot_global_conserved_gene_annotations.Rmd plots the most represented functions annotated to each conserved gene. While there are many plots here, COG_category_proportions.pdf is the one used in the manuscript

prevalence_highly_conserved_genes/gtdbtk_analysis/code has all the scripts used to get the GTDB genes that mapped to our highly conserved genes. 
	
	align_GTDB_genes_to_conserved_seqs.Rmd has the code to perform and output the alignments for the 30% gene catalogue.
	align_GTDB_genes_to_conserved_seqs_50perc.Rmd has the code to perform and output the alignments for the 50% gene catalogue.
	add_GTDB_annotations_to_conserved_seq_annotations.Rmd has the code to annotate each highly conserved gene with the GTDB gene it aligns best to. Output file is global_conserved_genes_prevalence_GTDB_annotated.txt 
	get_number_GTDB_in_conserved_genes_50perc.Rmd gets the number of bac 120 genes that align to the highly conserved genes in the 50% gene catalogue.
	get_number_GTDB_in_conserved_Genes.Rmd gets the number of bac 120 genes that align to highly conserved genes (consensus and raw) in the 30% gene catalogue
	fetch_HMMs.bash is used in align_GTDB_genes_to_conserved_seqs.Rmd to get each of the 120 bac HMMs from PFAM.
	get_bac120_in_conserved_consensus_genes.bash is used in align_GTDB_genes_to_conserved_seqs.Rmd to align the bac 120 HMMs to our list of highly conserved genes in the 30% gene catalogue.
	get_bac120_in_conserved_consensus_genes_50perc.bash is used in align_GTDB_genes_to_conserved_seqs_50perc.Rmd to align the bac 120 HMMs to our list of highly conserved genes in the 50% gene catalogue.
	get_bac120_in_conserved_raw_genes.bash is used in align_GTDB_genes_to_conserved_seqs.Rmd to align the bac 120 HMMs to the raw genes that are represented by the ~1,800 highly conserved genes in the 30% gene catalogue.
	subseq_highly_conserved_consensus_genes_50perc.bash is used in align_GTDB_genes_to_conserved_seqs_50perc.Rmd to extract the highly conserved sequences in the 50% gene catalogue from the file with all 1.6 billion sequences in it
	subseq_highly_conserved_consensus_genes.bash is used in align_GTDB_genes_to_conserved_seqs.Rmd to extract the highly conserved sequences in the 30% gene catalogue from the file with all 1.6 billion sequences in it.
	subseq_highly_conserved_raw_genes.bash is used in align_GTDB_genes_to_conserved_seqs.Rmd to extract the highly conserved raw genes in the 30% gene catalogue from the file with all 1.6 billion sequences in it.
	
prevalence_highly_conserved_genes/scripts/conserved_intersection_genes_prevalence.Rmd plots the prevalence of our global conserved genes and the 120 GTDB genes

prevalence_highly_conserved_genes/scripts/conserved_gene_analysis.Rmd outputs the prevalence of each highly conserved gene in the file global_conserved_genes_prevalence_by_gene.txt. It also outputs the prevalence of each highly conserved gene in each ecology in the file global_conserved_genes_prevalence_by_ecosystem.txt. Difference between this script and get_global_conserved_gene_prevalence_each_ecology.Rmd is that this one does not deal with annotations. The tables are also in the long format, instead of wide. 

prevalence_highly_conserved_genes/scripts/get_global_conserved_gene_prevalences_50perc.Rmd  outputs the prevalence of each highly conserved gene in the 50% amino acid identity gene catalogue

prevalence_highly_conserved_genes/scripts/get_gtdb_consensus_seq_stats.Rmd is used to get statistics in figure 6C, comparing GTDB alignments in the 30% and 50% gene catalogue.

### ABUNDANCE

### abundance of human specific genes

Abundance/human_specific/code has all the code needed to find the abundance of human specific genes.

Abundance/human_specific/scripts/get_human_specific_gene_abundance.Rmd has code used to get alignments, calculate differential abundance, get significant genes, and annotate the functions and taxa of those genes. 
	get_pval_in_chunks_human_vs_all_batch.bash is used inside get_human_specific_gene_abundance.Rmd. It launches the jobs on the cluster to run the differential abundance analysis. It also determines the lines at which to break up the file containing human specific genes. This is necessary because the file is extremely large. get_pval_in_chunks_human_vs_all.bash is used by  get_pval_in_chunks_human_vs_all_batch.bash. Its job is to run get_pval_in_chunks_human_vs_all.R which is the actual R script that does the differential abundance analysis. 

plot_human_specific_upsetr.Rmd makes upsetR plots that show the number of genes abundant in the different human ecologies.

### Abundance of genes shared between environmental and gut ecologies

Abundance/gut_env_intersections has the code needed to find the abundance of genes shared between guts and environments, shared between different environments, and shared between different gut microbiomes.

Abundance/gut_env_intersections/get_gene_abundance_gut_environment_intersections.Rmd has the code necessary to run alignments, compute differential abundance, get significant genes, annotate genes, and get files needed for plotting and visualizing data.

Abundance/gut_env_intersections/align_OV2_intersections_batch.bash has the code to launch jobs on compute cluster to run alignments. It is used in get_gene_abundance_gut_environment_intersections.Rmd. align_OV2_intersections_withdups.bash is used by align_OV2_intersections_batch.bash to do the actual alignments.

Abundance/gut_env_intersections/get_all_pvals.bash is also used inside get_gene_abundance_gut_environment_intersections.Rmd. It launches the script get_all_pvals.R to perform the differential abundance analysis.

Abundance/gut_env_intersections/scripts/ecology_functional_comparisons.Rmd is used to create figures illustrating the functional and taxonomic annotations of the intersecting gene lists.

Abundance/gut_env_intersections/create_intersectio_abundance_boxplots.Rmd creates box-lots showing the abundance of genes in each ecology.

Abundance/gut_env_intersections/make_intersection_abundance_upsetr_plots.Rmd is used to create the upsetr plot that shows the number of genes that are shared between different ecologies.

### Abundance of highly conserved genes

Abundance/global_conserved/scripts/get_abundance_highly_conserved_genes.Rmd performs the alignments and exports the abundance of each gene to a file for visualization.

align_OV2_intersections_batch.bash is used by get_abundance_highly_conserved_genes.Rmd to launch the alignment jobs on the cluster. align_OV2_intersections_withdups.bash is used in  align_OV2_intersections_batch.bash and actually does the alignments.

Abundance/global_conserved/scripts/make_diamond_dbs.bash makes the diamond databases to use for the alignments.

Abundance/global_conserved/scripts/plot_high_conserved_gene_abundance_each_ecology.Rmd creates a boxplot of the abundance of the highly conserved genes in each ecology.

### Prevalence of the 120 GTDB genes

These scripts get the prevalence of the 120 bacterial genes from GTDB in our gene catalogue.

gtdb_prevalence/scripts/gtdbtk_prevalence.Rmd has the code to align each of the 120 HMMs to our gene catalogue and concatenate the output into a file for visualization.

gtdb_prevalence/scripts/get_pan_gene_prev.bash is used in gtdbtk_prevalence.Rmd for running the alignments.

gtdb_prevalence/scripts/make_gtdbtk_prevalence_plots.Rmd visualizes the prevalence of each GTDB gene in our gene catalogue and each GTDB gene in each ecology.

### Get circular phylogeny plots (F6/7)

The python script is used to build the phylogenetic tree in the circular phylogeny plot. The R script is used to generate the plots themselves (and must be run both before and after the python script). Data used to generate plots are in the circ_plot_data.zip file on the Figshare resource.

The latest scripts to make circular phylogeny plots can be found in circular_phylogenies_revision

#### Count number of genes in each sample

number_consensus_genes_per_sample/scripts contains code to count the number of consensus genes at 30% identity in each sample

number_consensus_genes_per_sample/scripts/get_number_genes_per_sample_clean.Rmd has code to cluster the genes in each sample at 30% identity. 

get_number_genes_per_sample_clean.Rmd uses count_gene_number_OV2.bash which clusters the human specific genes at 30% identity. 

get_number_genes_per_sample_clean.Rmd also uses count_gene_number_nonhuman_OV2.bash which gets the sequences of each gene in non human samples and then clusters them at 30% identity.

### Annotate every raw open reading frame in every sample using LCA algorithm

annotate_raw_orfs/annotate_raw_orfs.Rmd is the master file used to run all code.

annotate_raw_orfs/run_CAT contains scripts that use the CAT software to run the LCA algorithm on each ORF.

annotate_raw_orfs/run_DIAMOND_with_CAT_postprocessing contains scripts that use the DIAMOND to align ORFs to the NR database and then uses the CAT post-processing scripts. 

The only difference between scripts in run_DIAMOND_with_CAT_postprocessing and run_CAT is that run_CAT also annotates contigs but we don't use that information anyway.

### Calculate the heatmap showing distance between each ecology

subsampled_overlap_analysis_revision has all scripts to calculate heatmap in Figure 2 as well as the alpha and beta diversities at the species and gene level. Also, unique cow gene figures are also in this folder.

### Compare the number and type of unique genes in our gene catalog to other gene catalogs like KEGG, orthoDB, and eggNOG

Find all scripts to do the above in gene_cat_to_other_gene_cat_comparisons

### Compare the number of correct species level annotations between pathogens and non-pathogens

Find all related scripts in pathogen_nonpathogen_annotations 


### Perform rarefaction analysis to see if the number of genes change with the sequencing depth of samples from each ecology

Find all scripts to perform rarefaction analyis in folder rarefaction_analysis


