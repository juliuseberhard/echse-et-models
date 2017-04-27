# take data from db export and adjust temporal resolution

library(xts)

# data file from db export
path_in <- "/home/tobias/Promotion/Modellierung/Bengue/Preprocessing/forcing/meteo/01_dbExport/out/"
dat_ifile <- "apress_data.dat"


# output
odir <- "/home/tobias/Promotion/Modellierung/Bengue/Preprocessing/forcing/meteo/02_adjust_timesteps/out/"

nadata <- -9999


# read data
dat <- read.table(paste(path_in, dat_ifile, sep="/"), header=F, sep="\t", skip=1, na.string=nadata)
header_dat <- readLines(paste(path_in, dat_ifile, sep="/"), n=1)

# create xts object
dat_xts <- xts(dat[,-1], as.POSIXct(dat[,1], tz="Fortaleza/Brazil"))

# calculate simple mean value from sub-daily values
dat_daily <- apply.daily(dat_xts, mean, na.rm=T)

# time set to 18:00:00 as it alway was the last time for every in dat_xts -> set back to 00:00:00
index(dat_daily) <- as.POSIXct(format(index(dat_daily), "%Y-%m-%d 00:00:00"), tz="Fortaleza/Brazil")

# write output
writeLines(text=header_dat, con=paste(odir, dat_ifile, sep="/"))
write.table(dat_daily, paste(odir, dat_ifile, sep="/"), sep="\t", quote=F, col.names=F, row.names=format(index(dat_daily), '%Y-%m-%d %H:%M:%S'), append=T, na=as.character(nadata))
