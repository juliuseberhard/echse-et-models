
library(xts)

wasa_file <- "/home/tobias/Promotion/Modellierung/Bengue/WASA/runs/test/input/Time_series/extraterrestrial_radiation.dat"

echse_radex_ofile <- "/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/forcing/radex_wasa.dat"

dat <- read.table(wasa_file, skip=1)

date <- seq.Date(as.Date("1970-01-01"), as.Date("2099-12-31"), by="month")
dat_xts <- xts(matrix(NA, ncol=1, nrow=length(date)), date)

for(m in 1:12)
  dat_xts[.indexmon(dat_xts)==(m-1),1] <- dat[m,]

write(c("end_of_interval", colnames(dat_xts)), echse_radex_ofile, sep="\t", ncolumns=ncol(dat_xts)+1) 
write.table(dat_xts, echse_radex_ofile,
            sep="\t", quote=F, col.names=F, row.names=format(index(dat_xts), '%Y-%m-%d %H:%M:%S'), append=T)
