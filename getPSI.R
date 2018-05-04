getPSI <- function(alpha = matrix(0, nrow = 1, ncol = 2), X=NULL, Ynan=NULL)
{
  XPCE = X$X.PCE[Ynan,]
  n.alpha = dim(alpha)[1]
  n = dim(XPCE)[1]
  m = dim(XPCE)[2]
  
  PSI = matrix(0,nrow=n,ncol=(n.alpha-1))
  for (j in 2:n.alpha)
  {
    X.poly = 0*XPCE
    for (i in 1:m)
    {
      X.poly[,i] = unlist(polynomial.values(X$psi.poly[[i]][alpha[j,i]+1],XPCE[,i]))
    }
    PSI[,j-1] = apply(X.poly,1,prod)
  }
  return(PSI)
}
