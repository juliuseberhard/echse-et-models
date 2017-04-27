# interpolate et observations based on weights as for forcing (only works if locations are the same as for forcing) 

library(xts)

setwd("/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/observations/02_interpol/")

# file of forcing weights
wgt_file <- "../../forcing/inputs_ext_locations.dat"

# time series files to be interpolated
ts_file <- c("../../forcing/meteo/05_meteofill/out/rhum_data.dat", "../../forcing/meteo/05_meteofill/out/glorad_data.dat",
             "../../forcing/meteo/05_meteofill/out/sundur_data.dat", "../../forcing/meteo/05_meteofill/out/wind_data.dat")


# read wgt file
wgt <- read.table(wgt_file, header=T)

# get weights (based on temperature variable)
r_wgt <- grep("temper", wgt$variable)
wgt_locs <- as.character(unique(wgt$location[r_wgt]))
wgt_weights <- wgt$weight[r_wgt]

# loop over ts
for (t in ts_file) {
  
  # read data
  dat <- read.table(t, header=T, sep="\t", na.strings = "-9999")
  
  dat_xts <- xts(dat[,-1], as.POSIXct(dat$end_of_interval, tz='UTC'))
  colnames(dat_xts) <- gsub("X", "", colnames(dat_xts))
  
  # calculate interpolated time series
  dat_interpol <- apply(dat_xts[,wgt_locs], 1, function(x) weighted.mean(x, wgt_weights))
  dat_int_xts <- xts(dat_interpol, as.POSIXct(names(dat_interpol), tz='UTC'))
  
  # write output
  write(c("end_of_interval", colnames(dat_int_xts)), tail(unlist(strsplit(t, "/")), n=1), sep="\t", ncolumns=ncol(dat_int_xts)+1) 
  write.table(dat_int_xts, tail(unlist(strsplit(t, "/")), n=1),
              sep="\t", quote=F, col.names=F, row.names=format(index(dat_int_xts), '%Y-%m-%d %H:%M:%S'), append=T)
}
