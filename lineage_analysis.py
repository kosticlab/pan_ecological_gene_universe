#!/usr/bin/env python3


#taxonomic analysis 

import pandas as pd
import sys


def load_taxa_dictionaries(databasedir,hits):
	prottaxid = databasedir + '/prot.accession2taxid'
	nodesfile = databasedir + '/nodes.dmp'
	namesfile = databasedir + '/names.dmp'
	prot={}
	names={}
	with open(prottaxid) as f:
			for line in f:
				if line.split('\t')[1] in hits:
					prot[line.split('\t')[1]]=line.split('\t')[2]	
	taxid2parent, taxid2rank = import_nodes(nodesfile)
	taxid2name = import_names(namesfile)
	return [prot,taxid2parent,taxid2rank,taxid2name]

def import_nodes(nodes_dmp):
	taxid2parent = {}
	taxid2rank = {}
	with open(nodes_dmp, 'r') as f1:
		for line in f1:
			line = line.split('\t')
			taxid = line[0]
			parent = line[2]
			rank = line[4]
			taxid2parent[taxid] = parent
			taxid2rank[taxid] = rank
	return [taxid2parent, taxid2rank]

def import_names(names_dmp):
	taxid2name = {}
	with open(names_dmp, 'r') as f1:
		for line in f1:
			line = line.split('\t')
			if line[6] == 'scientific name':
				taxid = line[0]
				name = line[2]
				taxid2name[taxid] = name
	return taxid2name

def parse_diamond_output(diamond_output_name):
	aligned_data = []
	with open(diamond_output_name) as f: 
		for line in f:
			aligned_data.append(line.rstrip().split('\t')[:2])
	aligned_data_df = pd.DataFrame(aligned_data)
	aligned_data_df.loc[:,'colvals']=list(aligned_data_df.groupby([0]).cumcount())
	aligned_data_df = aligned_data_df.pivot(index = 0, columns = 'colvals' ,values = 1)
	return aligned_data_df


def find_lineage(taxid, taxid2parent, lineage=None):
	if lineage is None:
		lineage = []
	lineage.append(taxid)
	if taxid2parent[taxid] == taxid:
		return lineage
	else:
		return find_lineage(taxid2parent[taxid], taxid2parent, lineage)

def map_genes_and_run_LCA(aligned_data_df,ncbi_tax_data,cutoff):
	prot_tax_map,taxid2parent,taxid2rank,taxid2name = ncbi_tax_data
	aligned_data_df.columns=['temp']+list(aligned_data_df.columns[1:])
	aligned_data_wide_list = aligned_data_df.reset_index(level=0).values.tolist()
	taxonomic_analysis = []
	for line in aligned_data_wide_list:
		lineages=[]
		ranks=[]
		mapped = []
		names=[]
		for cell in line[1:cutoff+1]:
			try:
				mapped.append(prot_tax_map[cell])
			except:
				mapped.append('No annotation')
			try:
				lineage=find_lineage(prot_tax_map[cell],taxid2parent)
				lineage=[x for x in lineage if 'species' not in taxid2rank[x] and 'strain' not in taxid2rank[x]]
				lineages.append(lineage)
			except:
				pass
			try:
				rank = taxid2rank[prot_tax_map[cell]]
				if 'species' in rank or 'strain' in rank:
					name = taxid2name[prot_tax_map[cell]]
					ranks.append(name)
			except:
				pass
		for x in mapped:
			try:
				names.append(taxid2name[prot_tax_map[cell]])
			except:
				names.append(x)
		try:
			lineages=collapse_lineages(lineages)
			lineage_count=len(lineages)
		except:
			lineage_count=-1
		try:
			rank_count=len([x for x in list(set(ranks)) if x!='no rank'])
		except:
			rank_count=-1
		taxonomic_analysis.append([line[0],'|'.join(mapped),'|'.join(names),lineages,lineage_count,'|'.join(list(set(ranks))),rank_count])
	return taxonomic_analysis

def collapse_lineages(lineages):
	output=[]
	toskip=[]
	for i,l in enumerate(lineages):
		matched = False
		l2 = '|'.join(l)
		if l2 in toskip:
			continue
		for ll in lineages[i+1:]:
			ll2 = '|'.join(ll)
			if ll2 in toskip: 
				continue
			if l2 in ll2:
				output.append(ll2)
				toskip.append(l2)
				matched=True
			elif ll2 in l2 and l2 not in toskip: #and done == False:
				output.append(l2)
				toskip.append(ll2) 
				matched=True
		if matched==False:
			output.append(l2)
	output=list(set(output))
	#output=[x.split('_') for x in list(output)]
	return output

databasedir='taxa_databases'
diamond_output_name=sys.argv[1]
cutoff=int(sys.argv[2])

#databasedir = download_prepared_databases()
aligned_data_df = parse_diamond_output(diamond_output_name)
hits = set()
for col in aligned_data_df:
	hits.update(aligned_data_df[col])

ncbi_tax_data = load_taxa_dictionaries(databasedir,hits)
taxonomic_output = pd.DataFrame(map_genes_and_run_LCA(aligned_data_df,ncbi_tax_data,10))
taxonomic_output.to_csv('%s_taxonomic_lineage_analysis.csv'%diamond_output_name)
taxonomic_output_subset = taxonomic_output.iloc[:,[0,4,6]]
taxonomic_output_subset.columns = ['consensus_gene_id','lineage_count','rank_count']
taxonomic_output_subset.to_csv('%s_taxonomic_lineage_analysis_subset.csv'%diamond_output_name)

