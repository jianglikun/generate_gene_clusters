suppressWarnings(library(tidyr))
suppressWarnings(library(dplyr))


find_CAG = function(tax_CAG_tab){
  ASD_health_findout = read.csv(tax_CAG_tab,sep = "\t",header = F,stringsAsFactors = F)
  colnames(ASD_health_findout) = c("Cluster","gene","identity","taxid","V6")
  ASD_health_findout$V6 = as.character(ASD_health_findout$V6)
  cluster_healthgene_species = separate(ASD_health_findout,col = V6,into =  c("K","Phylum","Class","Order","Family","Genus","Species"),sep = ";",remove = FALSE)
  health_cluster = sort(unique(cluster_healthgene_species$Cluster))
  clu_health_list = lapply(health_cluster,function(x){tmp = subset(cluster_healthgene_species,Cluster ==x);tapply(as.character(tmp$gene),as.character(tmp$Cluster),function(y)length(unique(y)))})
  names(clu_health_list) = health_cluster
  health_data = t(data.frame(clu_health_list))
  colnames(health_data) = "cul_num"
  species_list = lapply(as.character(health_cluster),function(x){tmp = subset(cluster_healthgene_species,Cluster ==x);tapply(as.character(tmp$gene),as.character(tmp$Species),function(y)length(unique(y)))})
  names(species_list) = health_cluster
  species_list = lapply(species_list,function(x)sort(x,decreasing = T))
  
  genus_list = lapply(as.character(health_cluster),function(x){tmp = subset(cluster_healthgene_species,Cluster ==x);tapply(as.character(tmp$gene),as.character(tmp$Genus),function(y)length(unique(y)))})
  names(genus_list) = health_cluster
  genus_list = lapply(genus_list,function(x)sort(x,decreasing = T))
  
  phylum_list = lapply(as.character(health_cluster),function(x){tmp = subset(cluster_healthgene_species,Cluster ==x);tapply(as.character(tmp$gene),as.character(tmp$Phylum),function(y)length(unique(y)))})
  names(phylum_list) = health_cluster
  phylum_list = lapply(phylum_list,function(x)sort(x,decreasing = T))
  
  health_data = as.data.frame(health_data)
  
  for(i in 1:length(health_cluster)){
    max_species=names(species_list[[i]])[1]
    max_species_num=species_list[[i]][1]
    health_data$max_species[i]=max_species
    health_data$max_species_gene_num[i]=max_species_num
    health_data$Tax_id[i]=cluster_healthgene_species$taxid[match(max_species,cluster_healthgene_species$Species)]
    max_genus=names(genus_list[[i]])[1]
    max_genus_num=genus_list[[i]][1]
    health_data$max_genus[i]=max_genus
    health_data$max_genus_gene_num[i]=max_genus_num
    max_phy=names(phylum_list[[i]])[1]
    max_phy_num=phylum_list[[i]][1]
    health_data$max_phy[i]=max_phy
    health_data$max_phy_gene_num[i]=max_phy_num}
  
  species_per = health_data$max_species_gene_num/health_data$cul_num
  genus_per = health_data$max_genus_gene_num/health_data$cul_num
  findout_table = cbind(clu_nu = health_data$cul_num,Tax_id=health_data$Tax_id,species_per = species_per,health_data[,c(2,3,5,6,7,8)])

 # findout_table = cbind(clu_nu=health_data$cul_num,health_data[,2:3],species_per,health_data[,4:5],genus_per,health_data[,6:7] )
  id= findout_table$clu_nu>500 & findout_table$species_per >0.5
  findout_table = findout_table[id,]
  return(findout_table)}

fun_plot_tab =function(health_data,sick_data,health_tab = health_tab,sick_tab = sick_tab,sample_health = sample_health,sample_sick=sample_sick,plot_tab){
  cluster_healthgene_species = read.csv(health_tab,sep = "\t",header = F,stringsAsFactors = F)
  colnames(cluster_healthgene_species) = c("Cluster","gene","identity","taxid","V6")
  
  cluster_sickgene_species = read.csv(sick_tab,sep = "\t",header = F,stringsAsFactors = F)
  colnames(cluster_sickgene_species) = c("Cluster","gene","identity","taxid","V6")
  
  sample_health_gene=lapply(rownames(health_data),function(x){tmp = subset(cluster_healthgene_species,Cluster ==x);sample(tmp$gene,50)})
  names(sample_health_gene) = rownames(health_data)
  health_heat_data = lapply(sample_health_gene,function(x){id=match(x,rownames(sample_health));sample_health[id,]})
  health_heat_data = do.call("rbind",health_heat_data)
  
  sample_sick_gene = lapply(rownames(sick_data),function(x){tmp = subset(cluster_sickgene_species,Cluster ==x);sample(tmp$gene,50)})
  names(sample_sick_gene)= rownames(sick_data)
  sick_heat_data = lapply(sample_sick_gene,function(x){id = match(x,rownames(sample_sick));sample_sick[id,]})
  sick_heat_data = do.call("rbind",sick_heat_data)
  
  plot_table = rbind(sick_heat_data,health_heat_data)
  plot_tab = t(apply(plot_table,1,scale))
  colnames(plot_tab) = colnames(plot_table)
  #plot_tab = cbind(plot_tab,split)
  return(plot_tab)}

get_sample_data = function(sample_data){
  data1 = read.csv(sample_data,header = F,sep = "\t",stringsAsFactors = F)
  colnames(data1)=data1[1,]
  rownames(data1)=data1[,1]
  data1 = data1[-1,]
  data1 = data1[,-1]
  data2 = apply(data1,2,function(x)as.numeric(x))
  rownames(data2)=rownames(data1)
  colnames(data2) = sub("_.*$","",colnames(data2))
  return(data2)
}

Args = commandArgs(TRUE)

health_tab=Args[1]
sick_tab=Args[2]
sample_health = Args[4]
sample_sick = Args[5]
sample_data = Args[3]


health_data = suppressWarnings(find_CAG(health_tab))
sick_data = suppressWarnings(find_CAG(sick_tab))
print("find ok")
write.csv(health_data,file="./health_CAG.csv")
write.csv(sick_data,file="./sick_CAG.csv")

print("The health and sick CAG has found")
sample_health=get_sample_data(sample_health)
sample_sick = get_sample_data(sample_sick)
plot_tab =fun_plot_tab(health_data,sick_data,health_tab = health_tab,sick_tab = sick_tab,sample_health=sample_health,sample_sick=sample_sick,plot_tab)


#split = c(sort(paste("S",rep(1:nrow(sick_data),50),sep = "")),sort(paste("H",rep(1:nrow(health_data),50),sep = "")))
#Heatmap(ll,cluster_rows = FALSE,cluster_columns =FALSE,split = split ,show_row_names = F,col=colorRamp2(c(-1, 0,1.5,2.5, 4.5), c("white","#90CDDF","#30A698","#D2C33F","red")))

write.csv(plot_tab,file = "./plot_tab")

print("The Heatmap data has ready")
