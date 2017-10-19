sudo docker build -t images.k11e.org/jlk/generate_clust_file:v1.1.0 .

sudo docker run --rm  -v /home/jianglikun/MGS/zhenghe/docker_test/:/home/jianglikun/MGS/zhenghe/docker_test images.k11e.org/jlk/generate_clust_file:v1.1.0 /mgs-canopy-algorithm/src/cc.bin  -n 10 -i /home/jianglikun/MGS/zhenghe/docker_test/all.tpm.txt -o /home/jianglikun/MGS/zhenghe/docker_test/ASD.40samples_clusters -c /home/jianglikun/MGS/zhenghe/docker_test/ASD.40samples_profile -p CAG --max_canopy_dist 0.1 --max_close_dist 0.4 --max_merge_dist 0.1 --min_step_dist 0.005 --stop_fraction 1 --canopy_size_stats_file /home/jianglikun/MGS/zhenghe/docker_test/ASD.40sampes_progress_stat_file



