#!/usr/bin/Rscript


# must be in global env when using new.env
knitr::opts_chunk$set(
	dev        = 'png',
	fig.width  = 6,	fig.height = 6,
	fig.path = 'figures/',
	fig.cap="",
	collapse   = TRUE
)

do_knit <- function(option, quiet=TRUE) {

	ff <- list.files("_R", pattern='.Rmd$', ignore.case=TRUE, full.names=TRUE, recursive=TRUE)
	kf <- list.files(".", pattern='\\.rst$', recursive=TRUE)
	kf <- kf[-grep("index.rst", kf, ignore.case=TRUE)]

	dir.create('figures/', showWarnings=FALSE)
	dir.create('txt/', showWarnings=FALSE)

	
	if (option=="clean"){
		file.remove(kf)
		file.remove(list.files("txt", full=TRUE))
		file.remove(list.files("figures", full=TRUE))
	} else { 
		if (length(kf) > 0 ) {
			stime <- file.info(ff)
			fn <- gsub("_R/", "./", raster::extension((rownames(stime)), ""))
			stime <- data.frame(f=fn, stime = stime$mtime, stringsAsFactors=FALSE)

			btime <- file.info(kf)
			fn <- paste0("./", raster::extension((rownames(btime)), ""))
			btime <- data.frame(f=fn, btime = btime$mtime, stringsAsFactors=FALSE)

			m <- merge(stime, btime, by=1, all.x=TRUE)
			m[is.na(m$btime), 'btime'] <- as.POSIXct(as.Date('2000-01-01'))

			i <- which ( m$btime < m$stime ) 
			ff <- ff[i]
		}
	}
	if (length(ff) > 0) {
		outf <- gsub("_R/", "", ff)
		md <-  gsub(".rmd$", '.md', outf)
		rst <-  gsub(".rmd$", ".rst", outf)

		for (i in 1:length(ff)) {
			cat(paste("   ", tools::file_path_sans_ext(ff[i]), "\n"))
		    ks <- paste("Rscript --vanilla ../_script/knit_script.R", ff[i], quiet)
			sysfun(ks)

			pc <- paste('pandoc',  md[i], '-f markdown -t rst -o', rst[i])
			sysfun(pc)
			file.remove(md[i])		
		}
	} 
}


if (tolower(Sys.info()["sysname"])=="windows"){
	sysfun <- shell
} else {
	sysfun <- system		  
}

args <- commandArgs(TRUE)
option <- ifelse(length(args) > 0, args[1], "")

oldpath <- getwd()
path <- file.path(oldpath, 'source')
setwd(path)
do_knit(option, quiet=TRUE)
setwd(oldpath)
warnings()

