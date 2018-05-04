getData <- function(n = 10, seed = sample(1:1000,1), dim = 1,
                input.dist = 'Uniform', params.dist = list(c(-1,1)), p.max = 3)
{
  X.sobol = matrix(sobol(n, dim = dim, init = TRUE, scrambling = 1, 
                  normal = FALSE, seed = seed), nrow = n, ncol = dim)
  
  X.PCE = X.model = matrix(0,nrow = n, ncol = dim)
  psi.poly = list()
  for (i in 1:dim)
  {
    if (input.dist[i]=="Uniform")
    {
      X.PCE[,i] = qunif(X.sobol[,i], min = -1, max = 1)
      X.model[,i] = qunif(X.sobol[,i], min = params.dist[[i]][1],
                          max = params.dist[[i]][2])
      psi.poly[[i]] = orthonormal.polynomials(legendre.recurrences(p.max,normalized = TRUE),
                                              polynomial(1))
      if (sum(X.model[,i]<0)>0)
      {
        warning(paste('There are negative values in input',i))
        X.model[X.model[,i]<0,i] = sum(params.dist[[i]])/2 #mean of uniform (a+b)/2
      }
    } else if (input.dist[i]=="Normal")
    {
      X.PCE[,i] = qnorm(X.sobol[,i],mean = 0, sd = 1)
      X.model[,i] = qnorm(X.sobol[,i], mean = params.dist[[i]][1],
                          sd = params.dist[[i]][2])
      psi.poly[[i]] = orthonormal.polynomials(hermite.he.recurrences(p.max,normalized = TRUE),
                                              polynomial(1))
      if (sum(X.model[,i]<0)>0)
      {
        warning(paste('There are negative values in input',i))
        X.model[X.model[,i]<0,i] = params.dist[[i]][1] #mean of normal
      }
    } else if (input.dist[i]=="Gamma")
    {
      X.model[,i] = X.PCE[,i] = qgamma(X.sobol[,i],shape = params.dist[[i]][1],
                                       scale = params.dist[[i]][2])
      psi.poly[[i]] = orthonormal.polynomials(laguerre.recurrences(p.max,normalized = TRUE),
                                              polynomial(1))
      if (sum(X.model[,i]<0)>0)
      {
        warning(paste('There are negative values in input',i))
        X.model[X.model[,i]<0,i] = prod(params.dist[[i]]) #mean of gamma (shape*scale)
      }
    } else if (input.dist[i]=="Beta")
    {
      X.model[,i] = X.PCE[,i] = qbeta(X.sobol[,i],shape1 = params.dist[[i]][1],
                                      shape2 = params.dist[[i]][2])
      psi.poly[[i]] = orthonormal.polynomials(jacobi.g.recurrences(p.max,normalized = TRUE),
                                              polynomial(1))
      if (sum(X.model[,i]<0)>0)
      {
        warning(paste('There are negative values in input',i))
        X.model[X.model[,i]<0,i] = params.dist[[i]][1]/sum(params.dist[[i]]) #mean of beta a/(a+b)
      }
    }
  }
  return(list(X.model=X.model,X.sobol=X.sobol,X.PCE=X.PCE,psi.poly=psi.poly))
}
