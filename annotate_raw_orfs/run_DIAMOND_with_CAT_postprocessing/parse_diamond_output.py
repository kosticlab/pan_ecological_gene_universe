
import decimal
import sys

input_file = sys.argv[1]
r_param = decimal.Decimal(sys.argv[2]) # default is 10
nodes_dmp_file = sys.argv[3]
names_dmp_file = sys.argv[4]
fastaid2LCAtaxid_file_name = sys.argv[5]
taxids_with_multiple_offspring_file_name = sys.argv[6]
no_stars = sys.argv[7] # False by default
ORF2LCA_output_file = sys.argv[8]
def parse_tabular_alignment(alignment_file, R):
    one_minus_r = (100 - R) / 100
    message = "Parsing alignment file {0}.".format(alignment_file)
    print(message)
    compressed = False
    if alignment_file.endswith(".gz"):
        compressed = True

        f1 = gzip.open(alignment_file, "rb")
    else:
        f1 = open(alignment_file, "r")

    ORF2hits = {}
    all_hits = set()
    all_ORFS = set()

    ORF = "first ORF"
    ORF_done = False
    for line in f1:
        if compressed:
            line = line.decode("utf-8")

        if line.startswith(ORF) and ORF_done == True:
            # The ORF has already surpassed its minimum allowed bit-score.
            continue

        line = line.rstrip().split("\t")

        if not line[0] == ORF:
            # A new ORF is reached.
            ORF = line[0]
            all_ORFS.add(ORF)
            top_bitscore = decimal.Decimal(line[11])
            ORF2hits[ORF] = []

            ORF_done = False

        bitscore = decimal.Decimal(line[11])

        if bitscore >= one_minus_r * top_bitscore:
            # The hit has a high enough bit-score to be included.
            hit = line[1]

            ORF2hits[ORF].append(
                (hit, bitscore),
            )
            all_hits.add(hit)
        else:
            # The hit is not included because its bit-score is too low.
            ORF_done = True

    f1.close()

    return (ORF2hits, all_hits,all_ORFS)


def import_nodes(nodes_dmp):
    message = 'Loading file {0}.'.format(nodes_dmp)
    print(message)
    
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

    return (taxid2parent, taxid2rank)


def import_names(names_dmp):
    message = 'Loading file {0}.'.format(names_dmp)
    print(message)

    taxid2name = {}

    with open(names_dmp, 'r') as f1:
        for line in f1:
            line = line.split('\t')

            if line[6] == 'scientific name':
                taxid = line[0]
                name = line[2]

                taxid2name[taxid] = name

    return taxid2name


def import_fastaid2LCAtaxid(fastaid2LCAtaxid_file, all_hits):
    message = 'Loading file {0}.'.format(fastaid2LCAtaxid_file)
    print(message)
    fastaid2LCAtaxid = {}

    with open(fastaid2LCAtaxid_file, 'r') as f1:
        for line in f1:
            line = line.rstrip().split('\t')

            if line[0] in all_hits:
                # Only include fastaids that are found in hits.
                fastaid2LCAtaxid[line[0]] = line[1]

    return fastaid2LCAtaxid


def import_taxids_with_multiple_offspring(taxids_with_multiple_offspring_file):
    message = 'Loading file {0}.'.format(taxids_with_multiple_offspring_file)
    print(message)

    taxids_with_multiple_offspring = set()

    with open(taxids_with_multiple_offspring_file, 'r') as f1:
        for line in f1:
            line = line.rstrip()

            taxids_with_multiple_offspring.add(line)

    return taxids_with_multiple_offspring

def find_LCA_for_ORF(hits, fastaid2LCAtaxid, taxid2parent):
    list_of_lineages = []
    top_bitscore = 0

    for (hit, bitscore) in hits:
        if bitscore > top_bitscore:
            top_bitscore = bitscore
            
        try:
            taxid = fastaid2LCAtaxid[hit]
            lineage = find_lineage(taxid, taxid2parent)

            list_of_lineages.append(lineage)
        except:
            # The fastaid does not have an associated taxid for some reason.
            pass
        
    if len(list_of_lineages) == 0:
        return ('no taxid found ({0})'.format(';'.join([i[0] for i in hits])),
                top_bitscore)

    overlap = set.intersection(*map(set, list_of_lineages))

    for taxid in list_of_lineages[0]:
        if taxid in overlap:
            return (taxid, top_bitscore)

def find_lineage(taxid, taxid2parent, lineage=None):
    if lineage is None:
        lineage = []

    lineage.append(taxid)

    if taxid2parent[taxid] == taxid:
        return lineage
    else:
        return find_lineage(taxid2parent[taxid], taxid2parent, lineage)

def find_questionable_taxids(lineage, taxids_with_multiple_offspring):
    questionable_taxids = []

    if lineage == ['1'] or lineage == ['root']:
        return questionable_taxids
    
    if len(lineage) == 2 and (lineage[1:] == ['1'] or lineage[1:] == ['root']):
        return questionable_taxids 
    
    for (i, taxid) in enumerate(lineage):
        taxid_parent = lineage[i + 1]
        if taxid_parent in taxids_with_multiple_offspring:
            return questionable_taxids

        questionable_taxids.append(taxid)


def star_lineage(lineage, taxids_with_multiple_offspring):
    questionable_taxids = find_questionable_taxids(lineage,
                                                   taxids_with_multiple_offspring)

    starred_lineage = [taxid if
            taxid not in questionable_taxids else
            '{0}*'.format(taxid) for taxid in lineage]

    return starred_lineage


(ORF2hits, all_hits, all_ORFS) = parse_tabular_alignment(input_file, r_param)

(taxid2parent, taxid2rank) = import_nodes(nodes_dmp_file)

fastaid2LCAtaxid = import_fastaid2LCAtaxid(fastaid2LCAtaxid_file_name, all_hits)

taxids_with_multiple_offspring = import_taxids_with_multiple_offspring(taxids_with_multiple_offspring_file_name)

with open(ORF2LCA_output_file, 'w') as outf2:
    outf2.write('# ORF\tnumber of hits\tlineage\ttop bit-score\n')
    
    LCAs_ORFs = []
    for ORF in all_ORFS:
        if ORF not in ORF2hits:
            outf2.write('{0}\tORF has no hit to database\n'.format(ORF))
            continue
        n_hits = len(ORF2hits[ORF])
        (taxid, top_bitscore) = find_LCA_for_ORF(ORF2hits[ORF], fastaid2LCAtaxid, taxid2parent)
        if taxid.startswith('no taxid found'):
            outf2.write('{0}\t{1}\t{2}\t{3}\n'.format(ORF, n_hits, taxid, top_bitscore))
        else:
            lineage = find_lineage(taxid, taxid2parent)
            
            #if not no_stars:
            if no_stars == "False":
                lineage = star_lineage(lineage, taxids_with_multiple_offspring)
            
            outf2.write('{0}\t{1}\t{2}\t{3}\n'.format(
                        ORF, n_hits, ';'.join(lineage[::-1]), top_bitscore))

            LCAs_ORFs.append((taxid, top_bitscore),)

        
