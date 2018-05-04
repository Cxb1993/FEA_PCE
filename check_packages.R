### script to be run before sending batch job to ensure
### that packages are installed in the custom folder

rm(list = ls())
package.lib = paste0(Sys.getenv('SCRATCH'),'/.Rlib')
#.libPaths(package.lib)

packages.need = c('randtoolbox','gtools','orthopolynom','glmnet')
for (i in packages.need)
{
  if (i %in% installed.packages()[, "Package"])
  {
    message("Package ",i," is installed")
  } else {
    install.packages(i, lib=package.lib, dependencies=TRUE, repos = 'https://cran.revolutionanalytics.com/')
    message("Package ",i," has been installed")
  }
}
