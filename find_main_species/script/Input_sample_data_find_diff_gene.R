
Args = commandArgs(TRUE)

sample_data = Args[1]
meta = Args[2]
paste("sample_data:",sample_data)
paste("metadata:",meta)
###输入metadata
metadata = read.csv(meta,header=T,sep = " ",stringsAsFactors=F)
metadata = metadata[order(metadata$group),]

###输入整理sample_data
data1 = read.csv(sample_data,header=F,sep = "\t",stringsAsFactors = F)
colnames(data1)=data1[1,]
rownames(data1)=data1[,1]
data1 = data1[-1,]
data1 = data1[,-1]
data2 = apply(data1,2,function(x)as.numeric(x))
rownames(data2)=rownames(data1)
colnames(data2) = sub("_.*$","",colnames(data2))
data = data2[,intersect(colnames(data2),rownames(metadata))]
data = data[apply(data,1,sum)>0,]
rm(data1,data2)

idx = which(rownames(metadata) %in% colnames(data))
metadata = metadata[idx,]

idx = match(rownames(metadata),colnames(data))
data = data[,idx]

group = metadata$group
means = as.data.frame(t(apply(data,1,function(x)tapply(x,group,mean))))
res_g = apply(data,1,function(x)wilcox.test(x ~ group,alternative = "g"))
res_l = apply(data,1,function(x)wilcox.test(x ~ group,alternative = "l"))
p.values_g = sapply(res_g,function(x)x$p.value)
p.values_l = sapply(res_l,function(x)x$p.value)
statistics = data.frame(W = sapply(res_g,function(x)x$statistic))
p.adj_g = p.adjust(p.values_g,method = 'BH')
p.adj_l = p.adjust(p.values_l,method = 'BH')
test_df = cbind(means,statistics,data.frame(p.values_g=p.values_g,p.adj_g=p.adj_g,p.values_l=p.values_l,p.adj_l=p.adj_l))

rownames(test_df) = rownames(data)

diff_health_gene = rownames(test_df[test_df$p.values_g< 0.05,])
diff_sick_gene = rownames(test_df[test_df$p.values_l< 0.05,])

write.table(diff_health_gene,file = "./diff_health_gene", row.names = F, quote = F,col.names = F)
write.table(diff_sick_gene,file = "./diff_sick_gene", row.names = F, quote = F,col.names = F)


