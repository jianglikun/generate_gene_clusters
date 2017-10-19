FROM debian:jessie

MAINTAINER jianglikun@ds.quantibio.com

RUN apt-get update && apt-get install -yq --no-install-recommends \
    git \
    wget \
    make \
    build-essential \
    ca-certificates \
    libboost-dev \
    libboost-program-options-dev 
RUN git clone https://github.com/jianglikun/generate_gene_clusters.git && cd /generate_gene_clusters && make && cd / && cp /generate_gene_clusters/cc.bin /bin
ADD ./all.tpm.txt /








