### gPCE on Kubra's FEA SLM model
# Start new sample
rm(list = ls())
cat(paste('Start time',Sys.time()),'\n')
#package.lib = paste0(Sys.getenv('SCRATCH'),'/.Rlib')
#.libPaths(package.lib)
setwd('~/FEA_PCE/')
data.settings = 'FEA_PCE.RData'
iter.file = 'iterations.csv'

packages.need = c('randtoolbox','gtools','orthopolynom','glmnet')
sapply(packages.need, require, character.only = TRUE)

source('getData.R')
source('FEAeval.R')

# Set up of code ----------------------------------------------------------

# check if first time running or continuation of adaptive algorithm
if (file.exists(data.settings))
{
  cat('Continuing from previous adaptive PCE model iteration\n')
  load(data.settings)
} else {
  cat('Starting new adaptive PCE model\n')
  
  # parameters to change: twoSigma and Absorptivity
  # fourSigma ~ N(70um, (15um)^2)
  # A ~ U(0.3,0.8) or Beta(.,.)
  m = 3
  input.vars = c('P','v','D4')
  input.dist = c('Normal','Uniform','Uniform')
  params.dist = list(c(49,0.5),
                     c(0.1,0.2),
                     c(70e-6,100e-6))
  p.max = 4
  q = 1
  delta.n = 10
  SeedSob = sample(1:1000,1)
  cvm.target = 1e-2
  cvm.diff = 5e-4
  cvm.last = 2
  cvm.min = 1
  n.actual = 0
  cvm.hist = c()
  k = 1
}

# get the design
X <- getData(n = (n.actual + delta.n), seed = SeedSob, dim = m,
             input.dist = input.dist, params.dist = params.dist, p.max = p.max)
colnames(X$X.model) = input.vars

# create new points
cat('\nCreating new sample points. Iteration',k,'\n')
FEAeval(X.model=X$X.model[(n.actual+1):(n.actual+delta.n),],k=k)

if (file.exists(iter.file))
{
  write.table(cbind(k,n.actual,delta.n), file = iter.file, append = TRUE,
              quote = FALSE, sep = ',', row.names = FALSE, col.names = FALSE)
} else
{
  write.table(cbind(k,n.actual,delta.n), file = iter.file, append = FALSE,
              quote = FALSE, sep = ',', row.names = FALSE,
              col.names = c('k','n.actual','delta.n'))
}

save(list = setdiff(ls(),lsf.str()),file = data.settings)
cat('\nSuccesfully finished creating new points for iteration',k,'\n\n')
