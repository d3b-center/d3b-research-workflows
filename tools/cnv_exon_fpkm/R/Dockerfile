FROM r-base:latest
WORKDIR /opt

#add scripts
ADD collate.R /opt/collate.R
CMD ["Rscript", "collate.R"]
