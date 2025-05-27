
############################################
## Begin: Install required packages
############################################

install.packages('TGS')

## Install minet package version 3.4.0
install.packages('devtools')
library(devtools)
devtools::install_version("minet", version = "3.4.0", repos = "http://cran.us.r-project.org")

############################################
## End: Install required packages
############################################

library(TGS)

## Assign absolute path to the input directory.
input_dir <- 'C:\\Users\\sapta\\Documents\\GitHub\\TestTGS\\assets'
  
## Assign the name of the desired output directory.
## The output directory will be created automatically.
output_dir <- 'C:\\Users\\sapta\\Documents\\GitHub\\TestTGS\\assets\\Output_Ds10n_TGS_plus'

## Run algorithm 'TGS+'
TGS::LearnTgs(
  isfile = 0,
  json.file = '',
  input.dirname = input_dir,
  input.data.filename = 'InSilicoSize10-Yeast1-trajectories.tsv',
  num.timepts = 21,
  true.net.filename = '',
  input.wt.data.filename = '',
  is.discrete = FALSE,
  num.discr.levels = 2,
  discr.algo = 'discretizeData.2L.Tesla',
  mi.estimator = 'mi.pca.cmi',
  apply.aracne = TRUE,
  clr.algo = 'CLR',
  max.fanin = 14,
  allow.self.loop = TRUE,
  scoring.func = 'BIC',
  output.dirname = output_dir
)


## Load the list of unrolled adjacency matrices.
## It will load a list named 'unrolled.DBN.adj.matrix.list'.
load(paste(output_dir, 'unrolled.DBN.adj.matrix.list.RData', sep = '\\'))

## Print the reconstructed GRN of the 7th time interval
print(unrolled.DBN.adj.matrix.list[[7]])

## Roll up the unrolled adjacency matrices into a single
## rolled adjacency matrix.
adj.mx <- unrolled.DBN.adj.matrix.list[[1]]
for (i in 2:20){
  adj.mx <- (adj.mx + unrolled.DBN.adj.matrix.list[[i]])
}

## Print the rolled adjacency matrix
print(adj.mx)



