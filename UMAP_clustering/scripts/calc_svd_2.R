#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
mydatafile = args[1]
min_prevalence = args[2]
library(data.table)
library(tidytext)
library(Matrix)
library(dplyr)
library(RSpectra)

print("READING IN FILE")
mydt = fread(mydatafile,header=F)
# remove column 2. not necessary
mydt[,V2:=NULL]
mydt2 = unique(mydt) # we want a binary matrix so only unique values are needed
mydt2[, `:=`(freq = 1)]
rm(mydt) # save space
gene_num = as.numeric(as.factor(mydt2$V3))
sample_num = as.numeric(as.factor(mydt2$V1))
sparse_mat <- sparseMatrix(i=gene_num, j=sample_num, x = mydt2$freq)
genes_to_keep = which(Matrix::rowSums(sparse_mat) > as.numeric(min_prevalence)) # 0 would keep all genes
sparse_mat <- sparse_mat[genes_to_keep,]

TF.IDF.custom <- function(data, verbose = TRUE) {
npeaks <- Matrix::colSums(x = data)
tf <- Matrix::t(x = Matrix::t(x = data) / npeaks)
idf <- log(1+ ncol(x = data) / Matrix::rowSums(x = data))
norm.data <- Diagonal(n = length(x = idf), x = idf) %*% tf
norm.data[which(x = is.na(x = norm.data))] <- 0
return(norm.data)
}
print("Performing TF_IDF normalization")
tf_idf_mat <- TF.IDF.custom(sparse_mat)
sample_names = levels(as.factor(mydt2$V1))

calcSVD = function(tfidf_mat,svd_dims,sampleNames) {
set.seed(123)
print("Calculating SVDs")
mat.lsi <- svds(tfidf_mat,k=svd_dims)
# plot the percent variaility of each PC
pdf(paste("percent_var_eachPC",svd_dims,"PCs.pdf",sep="_"))
plot(mat.lsi$d^2/sum(mat.lsi$d^2)*100,ylab="Percent variability explained")
dev.off()
d_diagtsne <- matrix(0, svd_dims, svd_dims)
diag(d_diagtsne) <- mat.lsi$d
mat_pcs <- t(d_diagtsne %*% t(mat.lsi$v))
print("DONE WITH SVD CALCULATION")
rownames(mat_pcs)<- sampleNames
mat_pcs = cbind(sample=rownames(mat_pcs),mat_pcs)
return(mat_pcs)
}

svd_mat_10pcs = calcSVD(tfidf_mat=tf_idf_mat,svd_dims=10,sampleNames=sample_names)
svd_mat_50pcs = calcSVD(tfidf_mat=tf_idf_mat,svd_dims=50,sampleNames=sample_names)
svd_mat_100pcs = calcSVD(tfidf_mat=tf_idf_mat,svd_dims=100,sampleNames=sample_names)


data_name = basename(mydatafile)
data_name = gsub(".csv","",data_name)
write.table(svd_mat_10pcs,file=paste(data_name,"_10PCs_min_prevalence",min_prevalence,".txt",sep=""),col.names=F,row.names=F,sep="\t",quote=F)
write.table(svd_mat_50pcs,file=paste(data_name,"_50PCs_min_prevalence",min_prevalence,".txt",sep=""),col.names=F,row.names=F,sep="\t",quote=F)
write.table(svd_mat_100pcs,file=paste(data_name,"_100PCs_min_prevalence",min_prevalence,".txt",sep=""),col.names=F,row.names=F,sep="\t",quote=F)

