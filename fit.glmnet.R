fit.glmnet <- function(PSI=NULL, Y=NULL, nfolds = 10)
{
  n.a.net = 20
  a.net = seq(0,1, length.out = n.a.net)
  cv.err = rep(0,n.a.net)
  for (i in 1:n.a.net)
  {
    fit = cv.glmnet(PSI, Y, type.measure = 'mae', nfolds = nfolds, family = "gaussian",
                    alpha = a.net[i], nlambda = 100, standardize = TRUE, intercept=TRUE,
                    grouped=FALSE)
    cv.err[i] = min(fit$cvm)
  }
  
  a.net.star = a.net[which.min(cv.err)]
  fit = cv.glmnet(PSI, Y, type.measure = 'mae', nfolds = dim(PSI)[1], family = "gaussian",
                  alpha = a.net.star, nlambda = 100, standardize = TRUE, intercept=TRUE,
                  grouped=FALSE)
  
  return(fit)
}