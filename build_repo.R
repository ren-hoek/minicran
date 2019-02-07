library('purrr')

get_package_versions <- function(p) {
    link <- paste0("http://cran.r-project.org/src/contrib/Archive/", p)
    q <- XML::getHTMLLinks(link, xpQuery = "//@href[contains(., 'tar.gz')]")
    return(q)
}

extract_package_versions <- function(v, p) {
    gsub(paste0(p,"_"),"", gsub(".tar.gz", "", v))
}

get_packages <- function(p, v) {
    rev(map_chr(v[[p]], extract_package_versions, p))[1:min(5:length(v[[p]]))]
}

add_packages <- function(p, path, repos = c(CRAN = 'https://cran.ma.imperial.ac.uk/'), type = c('source'), deps = FALSE) {
    miniCRAN::addPackage(p, path, repos = repos, type = type, deps = deps)
} 

add_old_package <- function(v, path, p, repos = c(CRAN = 'https://cran.ma.imperial.ac.uk/'), type = "source")) {
    miniCRAN::addOldPackage(p, path = path, vers = v, repos = repos, type = type)
}

add_old_versions <-function(n, c) {
    print(paste0("Downloading previous verisons of ", n,"..."))
    c[[n]] %>% map(add_old_package, pth, n)
}

cran <- c(CRAN = 'https://cran.ma.imperial.ac.uk/')
dir.create(pth <- file.path("data", "miniCRAN"), recursive = TRUE)

miniCRAN::makeRepo(c(), path = pth, repos = cran, type = c("source"))

pi <- c("purrr", "dplyr")

pl <- miniCRAN::pkgDep(pi, repos = cran, type = "source", suggests = FALSE)

v <- map(pl, get_package_versions)
names(v) <- pl

c <- map(names(v), get_packages, v)
names(c) <- names(v)

add_packages(pl, pth)

names(c) %>% map(add_old_versions, c)

drat::archivePackages(pth)