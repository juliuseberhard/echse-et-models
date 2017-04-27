rm(list=ls())

idir= "/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/forcing/meteo/"
odir= "/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/forcing/meteo/04_plausibilityCheck/out/"

show_bad_values= TRUE

# Limits of plausible range for data
ranges= data.frame(stringsAsFactors=FALSE,
  sub_path=c("01_dbExport/out/", "01_dbExport/out/", "02_adjust_timesteps/out/", "01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/"),
  name=c("precip","temper","apress","rhum","wind", "sundur", "temp_min", "temp_max"),
  miss=c(     -9999,     -9999,     -9999,     -9999,     -9999,    -9999, -9999, -9999),
  llim=c(       0,     5,     800,       0,       0,       0, 0, 0),
  ulim=c(     300,      45,    1100,     100,      60,   13, 45, 45)
)

for (k in 1:nrow(ranges)) {
  ifile=paste0(idir,"/",ranges$sub_path[k],"/",ranges$name[k],"_data.dat")
  d= read.table(ifile,header=TRUE, sep="\t", stringsAsFactors=FALSE, check.names=FALSE)
  for (col in 2:ncol(d)) {
    rows= which((d[,col] != ranges$miss[k]) & ((d[,col] < ranges$llim[k]) | (d[,col] > ranges$ulim[k])))
    if (length(rows) > 0) {
      print(paste(ranges$name[k]," @ ",names(d)[col],": ",length(rows)," implausible values.",sep=""))
      if (show_bad_values) {
        for (row in rows) {
          print(paste(ranges$name[k]," @ ",names(d)[col]," on ",d[row,1],": ",d[row,col],sep=""))
        }
      }
      d[rows,col]= ranges$miss[k]
    }
  }
  
  # check if there is a row with NA values (many of them in a row might cause unreasonable results by meteofill)
  na_rows <- apply(as.matrix(d[,-1]), 1, function(x) !any(!(x == ranges$miss[k])))
  if (any(na_rows) & (length(which(na_rows))<=100)) print(paste0(ranges$name[k], " @ ", d[na_rows, 1], " is NA at all stations! Consider the method described in echse tools 3.6.1 for meteofill!"))
  if (any(na_rows) & (length(which(na_rows))>100)) print(paste0(ranges$name[k], " contains many timesteps with NA values at all stations! Use method described in echse tools 3.6.1 for meteofill!"))
  
  ofile=paste(odir,"/",ranges$name[k],"_data.dat",sep="")
  write.table(x=d,file=ofile,sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)
}




### OPTIONAL ###
# in case of many timesteps where all station values are NA introduce a virtual station (see sec 3.6.1 of echse tools manual)

library(xts)

# specify variables and paths to files where a virtual station shall be introduces
variables= data.frame(stringsAsFactors=FALSE,
                   sub_path=c("01_dbExport/out/", "01_dbExport/out/", "02_adjust_timesteps/out/", "01_dbExport/out/", "01_dbExport/out/", "03_sun2globrad/out/", "01_dbExport/out/"),
                   name=c("precip","temper","apress","rhumid","windsp","glorad", "sunshine"),
                   stat_path=c("01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/", "01_dbExport/out/"),
                   miss=c(     -9999,     -9999,     -9999,     -9999,     -9999,     -9999, -9999)
)

# loop over variables
for (k in 1:nrow(variables)) {
  ifile=paste0(idir,"/",variables$sub_path[k],"/",variables$name[k],"_data.dat")
  d= as.xts(read.zoo(ifile,header=TRUE, sep="\t", stringsAsFactors=FALSE, check.names=FALSE, na.strings=variables$miss[k]))

  ### PRECIPITATION ###
  # calculate means of monthly sums over all years and station and distribute rainfall equally over month
  if (variables$name[k] == "precip") {
    monthly_means <- apply.monthly(d, sum)
    means_stations <- apply(monthly_means, 1, mean, na.rm=T)
  }

  ### TEMPERATURE ###
  # calculate means for every day of year over all years and stations
  if (variables$name[k] == "temper") {
    daily_means <- aggregate(d, by=list(days=format(index(d), "%j")), mean, na.rm=T)
    daily_means <- apply(daily_means, 1, mean)
    
    # 
    doy_start <- as.numeric(format(index(d), "%j"))[1]
    doy_end <- tail(as.numeric(format(index(d), "%j")), n=1)
    dat <- merge(index_doy, daily_means, sort=F)
  }
  
  

}
