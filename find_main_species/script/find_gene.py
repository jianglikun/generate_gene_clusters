#! /usr/bin/python 

import sys

gene_list=[]
dic_readcount = {}
with open(sys.argv[1]) as fi:
	for line in fi:
		line = line.strip()
		gene_list.append(line)	

#print gene_list

with open(sys.argv[2]) as fi:
	title = fi.readline()
#	print title
#	print len(title.split("\t"))
	for line in fi:
		line = line.strip()
		gene = line.split("\t")[0]
		last = line.split("\t")[1:34]
		dic_readcount[gene]=last
	fi = open(sys.argv[3],"a")
        fi.write(title)
	fi.close()

for i in gene_list:
	tmp = i+"\t"+"\t".join(dic_readcount[i])+"\n"
	#print tmp
	fi = open(sys.argv[3],"a")
	fi.write(tmp)
	fi.close()
