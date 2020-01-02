### Analysis folder
https://github.com/d3b-center/d3b-research-workflows/tree/cell-proportion/cell_proportion

#### Task
Identify cell proportions of microglia and monocytes in medulloblastoma samples.
Create plots for microglia-monocyte cell proportions in  medulloblastoma subtypes from histology pbta-histology.tsv= version v12; 124 medulloblastoma samples)

#### Script  
https://github.com/d3b-center/d3b-research-workflows/blob/cell-proportion/cell_proportion/medullo_micro_mono.R

#### Packages used 
BRETIGEA; ggplot; ggpubr; reshape2;

##### Additional files/info for BRETIGEA
Marker genes dataframe for function findCells() was created using markers_df_brain + monocyte/macrophage marker genes https://actaneurocomms.biomedcentral.com/articles/10.1186/s40478-019-0665-y
plus marker genes for monocyte from xcell https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5688663/bin/13059_2017_1349_MOESM3_ESM.xlsx

Main function used in findCells() https://rdrr.io/cran/BRETIGEA/man/findCells.html
cell type proportions use all 1000 marker genes from mic (other cell types in BRETIGEA package provided file) and 317 from monocyte
cell_type_proportions = findCells(exp,markers = markers_df_brain, nMarker = 1000,method = "SVD")

#### Output
[plots/medullo_micro_mono_init_cells.pdf](https://github.com/d3b-center/d3b-research-workflows/blob/cell-proportion/cell_proportion/plots/medullo_micro_mono_init_cells.pdf) :  microglia and monocyte cell proportions in subtypes with >=6 initial tumor CNS
[plots/medullo_micro_mono_init_prog_cells.pdf](https://github.com/d3b-center/d3b-research-workflows/blob/cell-proportion/cell_proportion/plots/medullo_micro_mono_init_prog_cells.pdf) : microglia and monocyte cell proportions in subtypes with >=6 initial tumor CNS and >=6 recurrent/progressive CNS
Gray scaled plots are also available for the above 2 plots
data/analyzed/cell_proportions.tsv : cell proportions calculated for all cell types in marker gene dataframe for all medullo samples.


#### Additional outputs
medullo_all_brain_cells.png : all brain cells mean proportions using marker genes provided by BRETIGEA + monocyte marker from xCell compared for all subtypes
medullo_micro_mono.png : microglia and monocyte cell propertions in initial tumor CNS and broad histologies with recurrent/progressive tumors >=6 frequency in all subtypes
data/analyzed/marker_df_brain.tsv : marker gene dataframe used in findCells()

