FEAeval <- function(X.model = matrix(c(5,.5),nrow = 1),k=1)
{
  if (!is.matrix(X.model))
  {
    X.model = matrix(X.model, ncol = 2)
  }
  
  n = dim(X.model)[1]
  file.name = paste0('data/FEA_iter',k,'.csv')
  write.table(X.model, file = file.name, append = FALSE, quote = FALSE, sep = ',',
            row.names = FALSE, col.names = TRUE)
}
