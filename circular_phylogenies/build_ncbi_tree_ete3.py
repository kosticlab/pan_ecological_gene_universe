import pandas as pd
import os
from ete3 import NCBITaxa

ncbi = NCBITaxa()
#ncbi.update_taxonomy_database()

f='for_ete3_intersections.csv'
data=pd.read_csv(f)
tree = ncbi.get_topology(list(set(data.taxaID)))
tree.write(format=1, outfile="ncbi_tree_intersections.nw")

f='for_ete3_bs.csv'
data=pd.read_csv(f)
tree = ncbi.get_topology(list(set(data.taxaID)))
tree.write(format=1, outfile="ncbi_tree_bs.nw")

f='for_ete3_cluster_species.csv'
data=pd.read_csv(f)
tree = ncbi.get_topology(list(set(data.taxaID)))
tree.write(format=1, outfile="ncbi_tree_intersections_cluster_species.nw")

f='for_ete3_human_nongut_species.csv'
data=pd.read_csv(f)
tree = ncbi.get_topology(list(set(data.taxaID)))
tree.write(format=1, outfile="ncbi_tree_intersections_human_nongut_species.nw")
