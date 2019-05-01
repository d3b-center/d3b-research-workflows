FROM ubuntu:14.04

# maintainer
MAINTAINER Krutika Gaonkar

RUN apt-get update && apt-get install -y \
	autoconf \
	automake \
	python2.7 \
	python-pip \
	make \
	g++ \
	gcc \
	build-essential \ 
	zlib1g-dev \
	libgsl0-dev \
	perl \
	curl \
	git \
	wget \
	unzip \
	tabix \
	libncurses5-dev

WORKDIR /opt
RUN git clone https://github.com/ctsa/svtools.git 
WORKDIR /opt/svtools

