

library(RMySQL)
library(spgrass6)
library(rgeos)


# MySQL settings #
user <- "tobias"
password <- "tobias"
dbname <- "jaguaribe_gages" # name of the empty database, should be created beforehand
host <- "localhost"

# open MySQL connection (needs to be created beforehand and should be empty)
con <- dbConnect(MySQL(), user=user, password=password,
                 dbname=dbname, host=host, client.flag = CLIENT_MULTI_STATEMENTS)


# start GRASS session
initGRASS( gisBase="/opt/grass",
           home=tempdir(),
           location="Bengue",
           mapset="PERMANENT",
           gisDbase="/home/tobias/Promotion/Modellierung/Bengue/grassdata/",
           override=TRUE)

# vector file with station locations
gages_vect <- "cli_gages"

# vector of catchment in GRASS
catch_vect <- "catch"

# gages have to be within that distance around the catchment (in GRASS region units)
dist_lim <- 100000

# no data value in output
nodata= -9999

# variables
pars= data.frame(stringsAsFactors=FALSE,
                 id_db=     c("evap_pot", "evap_act"),
                 id_export= c("etp", "eta")
)

# define time period for time series extraction
start_date <- "2000-01-01 00:00:00"
end_date <- "2013-12-31 00:00:00"

# temporal resolution of data (flag in db)
resol <- 3

# maximum fraction of NA data allowed in time period
na_frac <- .5

# output directory
odir= "/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/forcing/meteo/01_dbExport/"





### CALCULATIONS ###

# helper function
stat_identify <- function(x,gag=gages,cat=catch,dist=dist_lim) { 
  index <- which(gag@data$code == x)
  return(gWithinDistance(gag[index,], cat, dist=dist))
}



# load gages and catchment from GRASS
gages <- readVECT6(gages_vect)
catch <- readVECT6(catch_vect)

# Loop over variables
for (k in 1:nrow(pars)) {
  
  # get data filtered by resolution flag and defined time period
  q= paste0("SELECT gage_code,date,",pars$id_db[k], " FROM clim_ts WHERE ",
            "resolution=", resol, " AND ",
            "(date BETWEEN '",start_date,"' AND '",end_date, "')")
  db_dat <- dbGetQuery(con, q)
  

  # re-order data
  dat_mat <- tapply(db_dat[[3]], list(date=db_dat$date, station=db_dat$gage_code), function(x) x)
  
  # keep only data for station within defined distance around catchment
  stat <- colnames(dat_mat)
  stat_keep <- lapply(stat, stat_identify)
  dat_mat <- dat_mat[,unlist(stat_keep)]
  
  # keep only those stations and data which have enough non-NA data
  stat_keep <- apply(dat_mat, 2, function(x, na_f=na_frac) return(length(which(is.na(x))) < na_f * length(x)))
  dat_mat <- dat_mat[, stat_keep]
  
  print(paste0("Found ",ncol(dat_mat)," stations within given distance around the catchment with sufficient non-NA data for variable '",
               pars$id_export[k],"'"))
  
  # replace NA value by specified value
  dat_mat[which(is.na(dat_mat))] <- nodata
  
  # set up station data.frame for export
  rows <- gages@data$code %in% as.integer(colnames(dat_mat))
  locs_out <- data.frame(id=gages@data$code[rows],
                         x=coordinates(gages[rows,])[,1],
                         y=coordinates(gages[rows,])[,2],
                         z=gages@data$alt[rows],
                         name=gages@data$name[rows])
  
  locs_out$z[which(is.na(locs_out$z))] <- nodata
  
  write.table(locs_out, paste0(odir,"/",pars$id_export[k],"_locs.dat"), quote=F, sep="\t", row.names=F)
  
  
  # data output
  ofile <- paste0(odir,"/",pars$id_export[k],"_data.dat")
  write(c("end_of_interval", colnames(dat_mat)), ofile, sep="\t", ncolumns=ncol(dat_mat)+1)
  write.table(dat_mat, ofile, col.names=F, sep="\t", quote=F, append=T)
 
} # loop over variables
