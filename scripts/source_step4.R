#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
options(scipen = 999)
# AA names
tableAA = data.table::fread(args[1], header = F)
colnames(tableAA) = c("codon","aa","aaname")
### Codon input
codons = data.table::fread(args[2], stringsAsFactors = F, fill=T)
#########################################################################################################################
# with methionine
freqs = as.data.frame(table(codons$V2[grep("TGA|TAG|TAA", codons$V2, invert = T)]))
colnames(freqs) = c("codon","freq")
### calculate cAI
merged = merge(tableAA,freqs,by="codon",all.y = T)
ncod = as.data.frame(table(merged$aa))
colnames(ncod) = c("aa","num")
ncod$aa = as.character(ncod$aa)
merged = merge(merged,ncod,by="aa")
for (i in 1:nrow(ncod)) {
  aa=ncod$aa[i]
  merged$expected[merged$aa==aa] = sum(merged$freq[merged$aa==aa])/ncod$num[ncod$aa==aa]
}
merged$ratio = merged$freq/merged$expected
for (i in 1:nrow(ncod)) { # warning issued because of lack of stop codons
  aa = ncod$aa[i]
  maxaa = max(merged$ratio[merged$aa==aa])
  merged$cAI[merged$aa==aa] = merged$ratio[merged$aa==aa]/maxaa
}
write.table(merged[,c("codon","aa","freq","ratio","cAI")],"cAI.tsv", sep = "\t", quote = F, row.names = F, col.names = T)
#########################################################################################################################
# without methionine
freqs = freqs[grep("ATG", freqs$codon, invert = T),]
###
merged = merge(tableAA,freqs,by="codon",all.y = T)
colnames(merged) = c("codon","aa","aaname","freq")
ncod = as.data.frame(table(merged$aa))
colnames(ncod) = c("aa","num")
ncod$aa = as.character(ncod$aa)
merged = merge(merged,ncod,by="aa")
for (i in 1:nrow(ncod)) {
  aa=ncod$aa[i]
  merged$expected[merged$aa==aa] = sum(merged$freq[merged$aa==aa])/ncod$num[ncod$aa==aa]
}
merged$ratio = merged$freq/merged$expected
for (i in 1:nrow(ncod)) {
  aa = ncod$aa[i]
  maxaa = max(merged$ratio[merged$aa==aa])
  merged$cAI[merged$aa==aa] = merged$ratio[merged$aa==aa]/maxaa
}
write.table(merged[,c("codon","aa","freq","ratio","cAI")],"cAI_noMET.tsv", sep = "\t", quote = F, row.names = F, col.names = T)
