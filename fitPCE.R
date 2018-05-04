### gPCE on Kubra's FEA SLM model
# Start new sample
rm(list = ls())
cat(paste('Start time',Sys.time()),'\n')
#package.lib = paste0(Sys.getenv('SCRATCH'),'/.Rlib')
#.libPaths(package.lib)
setwd('~/FEA_PCE/')
data.settings = 'FEA_PCE.RData'
load(data.settings)

packages.need = c('randtoolbox','gtools','orthopolynom','glmnet')
sapply(packages.need, require, character.only = TRUE)
source('getPSI.R')
source('fit.glmnet.R')

cat('Starting new PCE model fitting\n')

# Calculate basis functions indices
alpha = permutations(p.max+1,m,0:p.max,repeats.allowed=TRUE)
alpha = alpha[rowSums(alpha^q)^(1/q)<=p.max,]

# Read evaluated data
data.csv = read.table('data/FEA_all_data.csv', header = TRUE, sep = ',')
Y = as.matrix(data.csv['depth'])
Ynan = !is.nan(Y)
Y = as.matrix(Y[Ynan])

# standardize the data
Y.mean = mean(Y)
Y.sd = sd(Y)
Y.norm = (Y-Y.mean)/Y.sd

# calculate data matrix
PSI = getPSI(alpha=alpha, X=X, Ynan=Ynan)

# Fit the elastic net model
fit = fit.glmnet(PSI=PSI, Y=Y.norm, nfolds = 10)

# update errors
cvm.last = cvm.min
cvm.min = min(fit$cvm)
cvm.hist = c(cvm.hist,cvm.min)
cat('CV error:',cvm.min*Y.sd*1e6,'um')

if (cvm.min > cvm.target & (cvm.last-cvm.min) > cvm.diff)
{
  cat('\n\nAfter iteration ',k,', another iteration is needed.\n\n', sep = '')
} else {
  cat('\n\nAfter iteration ',k,', the targets have been met.\nNo more iterations needed',
      sep = '')}

# update for next iteration
n.actual = n.actual + delta.n
k = k+1

save(list = setdiff(ls(),lsf.str()),file = data.settings)
