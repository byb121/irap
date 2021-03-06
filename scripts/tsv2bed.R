#!/usr/bin/env Rscript
# =========================================================
#
# This file is part of iRAP.
#
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with iRAP.  If not, see <http://www.gnu.org/licenses/>.
#
#
#    $Id: irap.txt Nuno Fonseca Sun Jan 13 14:02:59 2013$
# =========================================================
# tsv2bedGraph.R test_se_2l/tophat1/htseq1/SE1.se.genes.raw.htseq1.tsv gene test_se_2l/data/chr19.gff3 > a.bg
args <- commandArgs(trailingOnly=TRUE)

usage<-"tsv2bedGraph tsv_file feature@(gene,exon,CDS)  gff3_file.csv [chr_file]\n";
if (length(args)<3||length(args)>4) {
  cat("ERROR!");
  cat(usage);
  q(status=1);
}
# chr file: should contain the name of all chromossomes (can be used to filter)
#    chr_name\tlength


# TODO: add option to filter by source (e.g protein coding)
# validate arguments
tsv_file <-args[1]
feature<-args[2]
gff3_file<-args[3]
chr_file <- args[4]
chrs <- c()
#feature<-"gene"
#gff3_file<-"test_se_2l/data/chr19.gff3"
#tsv_file <-"test_se_2l/tophat1/htseq1/SE2.genes.htseq1.tsv"

# load the tsv file (2 cols)
tsv<-read.table(tsv_file,sep="\t",header=F,quote="\"",comment.char="")
# first column should have the ID
colnames(tsv) <- c('ID','Value')
# exclude NAs or replace by 0?
# exclude for now
tsv <- tsv[!is.na(tsv$Value),]

# load the gff3 file in CSV format (it can take a while to do it, hence do it only once)
gff3<-read.table(gff3_file,sep=",",header=T,quote="\"",comment.char="")

sel<-gff3[gff3$feature==feature,]

#
sel<-sel[,c('ID','seqname','start','end','feature','strand')]
sel$ID <- as.character(sel$ID)
tsv$ID <- as.character(tsv$ID)
t1<-merge(sel,tsv,by="ID")
t1<-t1[order(t1$start),]
# filter
if ( ! is.null(chr_file) ) {
  if ( ! is.null(chr <- file) ) {
    chr.table<-read.table(chr_file,sep="\t",header=F)
    chrs <- as.character(chr.table[,1])
    #print(chrs)
  }
  selection <- (t1$seqname %in% chrs)
  t1 <- t1[selection,]
}
# 
#chr star end feature score strand
write.table(t1[,c(2,3,4,5,7,6)],sep='\t',row.names=F,col.names=F,quote=F)
q(status=0)

