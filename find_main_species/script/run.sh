#! /usr/bin/bash

if [ $# -eq 0 ];then
        echo "Usage: bash RUN.sh -m metadata -s sample_data(all.tpm.txt) -b blastn_data(stander.blastn.out) -n health_findout_table -y sick_findout_table"

	exit 1
fi

while getopts ":m:s:b:n:y:h" arg
do
        case $arg in
                m )
                        metadata=$OPTARG;;
                s )
                        sample_data=$OPTARG;;
		b )
			blastn_data=$OPTARG;;
		n )
			health_findout_table=$OPTARG;;
		y )
			sick_findout_table=$OPTARG;;
                h )
                        echo "Usage: bash Gnerate_Dna_data_frame.sh -d(blastn_out) -i(cu_file) -a(assembly.id.txt) -g(4904MG.info.txt) -o(gene_cu_tax_data_frame)"
                        exit 0;;
                ? )
	esac
done

echo "#############################Now beginning##############################"
date +"%Y-%m-%d %H:%M:%S"
if [ ! -f ./diff_sick_gene ];then
Rscript Input_sample_data_find_diff_gene.R ${sample_data} ${metadata}
fi
date +"%Y-%m-%d %H:%M:%S"
echo "#############################Found_gene_done#############################"
echo "######The different_gene file: diff_sick_gene/diff_health_gene"

if [ ! -f ./sick_gene_sample ];then
python find_gene.py ./diff_sick_gene ${sample_data} sick_gene_sample
fi

if [ ! -f ./health_gene_sample ];then
python find_gene.py ./diff_health_gene ${sample_data} health_gene_sample
fi

echo "#############################Found_gene_table_done#############################"
echo "###The different gene's abundance smaple data is : sick_gene_sample / healh_gene_sample"
date +"%Y-%m-%d %H:%M:%S"
echo "#############################Generating Cluster#############################"
echo "#############################分割线#############################"
echo "#############################分割线#############################"
if [ ! -f ./ASD_sick_cluster ];then
/home/yejunbin/software/mls/cc.bin -n 10 -i sick_gene_sample -o ASD_sick_cluster -c ASD.sick_profile -p CAG --max_canopy_dist 0.1 --max_close_dist 0.4 --max_merge_dist 0.1 --min_step_dist 0.005 --stop_fraction 1 --canopy_size_stats_file ASD.sick_progress_stat_file
fi

if [ ! -f ./ASD_health_cluster ];then
/home/yejunbin/software/mls/cc.bin -n 10 -i health_gene_sample -o ASD_health_cluster -c ASD.health_profile -p CAG --max_canopy_dist 0.1 --max_close_dist 0.4 --max_merge_dist 0.1 --min_step_dist 0.005 --stop_fraction 1 --canopy_size_stats_file ASD.health_progress_stat_file
fi
echo "#############################分割线#############################"
echo "#############################分割线#############################"
echo "#############################Generate cluster with health/sick Done!#############################"
echo "###The Cluster file is : ASD_sick_cluster  /  ASD_health_cluster"
echo "###The profiles file is : ASD.sick_profile / ASD.health_profile"
date +"%Y-%m-%d %H:%M:%S"

echo "#############################match BLastn out with TAX_id #############################"
if [ ! -f health_findout_table ];then
python Gnerate_Dna_data_frame.py ${blastn_data} ASD_sick_cluster assembly.id.txt taxid_4904_info.txt ${sick_findout_table}
python Gnerate_Dna_data_frame.py ${blastn_data} ASD_health_cluster assembly.id.txt taxid_4904_info.txt  ${health_findout_table}
fi
echo "###match BLastn out with TAX_id Done!###"
date +"%Y-%m-%d %H:%M:%S"

echo "#############################Finding the MGS of the health and sick#############################"
if [ ! -f plot_tab ];then
Rscript plot_data.R ${health_findout_tab} ${sick_findout_table} ${sample_data} health_gene_sample sick_gene_sample
fi
date +"%Y-%m-%d %H:%M:%S"


echo "Done!"
