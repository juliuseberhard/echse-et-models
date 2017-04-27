rm(list=ls())

library("geostat")

setwd("/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/")

# Table of target locations
file_catAttribs= "../../../Preprocessing/LUMP/sub_stats.txt"

# external location table from vegetation parameter time series (estimated by LUMP::db_echse_input)
file_wgt_veg <- "./vegPar_time_series/input_ext_locs.dat"

# get objDecl
objDecl_file <- "catchment/objDecl.dat"

# Source location files for actually interpolated meteo variables
files_sources= c(
  temper= "forcing/meteo/05_meteofill/out/temper_locs.dat",
  apress= "forcing/meteo/05_meteofill/out/apress_locs.dat",
  sundur= "forcing/meteo/05_meteofill/out/sundur_locs.dat",
  wind= "forcing/meteo/05_meteofill/out/wind_locs.dat",
  rhum= "forcing/meteo/05_meteofill/out/rhum_locs.dat",
  glorad= "forcing/meteo/dummy_locs.dat",
  glorad_max= "forcing/meteo/dummy_locs.dat",
  cloud= "forcing/meteo/dummy_locs.dat",
  radex= "forcing/meteo/dummy_locs.dat"
)

# Output file
file_result= "forcing/inputs_ext_locations.dat"

################################################################################


# Weights for actually interpolated meteovars
f= tempfile()
externalInputLocationsTable(file_targets= file_catAttribs, files_sources= files_sources,
  idField_targets="pid", idField_sources="id",
  colsep = "\t", nsectors = 10, norigins = 10, power = 2,
  file_result= f, ndigits = 3, overwrite = FALSE)

# read weights file
wgt= read.table(file=f, header=TRUE, sep="\t")
invisible(file.remove(f))

# Read obj declaration
objDecl_dat <- read.table(objDecl_file, header=T)

# get SVCs for each subbasin (name scheme: svc_{id_subbasin}_{id_lu}_{id_tc}_{id_svc})
#svc <- objDecl_dat$object[grep("WASA_svc", objDecl_dat$objectGroup)]

# put SVCs into weights table replacing corresponding subbasin
#sub <- unlist(strsplit(as.character(svc), "_"))
#sub <- sub[seq(2, length(sub), 5)]
# wgt_out <- NULL
# for(s in unique(sub)) {
#   r_decl <- which(sub == s)
#   r_wgt <- which(wgt$object == s)
#   
#   wgt_out <- rbind(wgt_out, merge(wgt[r_wgt,], svc[r_decl]))
# }
# 
# wgt_out <- wgt_out[,c("y", "variable", "location", "weight")]
# names(wgt_out)[1] <- "object"

# read weights file of vegetation parameter time series
wgt_veg <- read.table(file_wgt_veg, header=T)

# combine wgt data
wgt_out <- rbind(wgt, wgt_veg)

# Create result
write.table(x=wgt_out, file=file_result, sep="\t", col.names=TRUE, row.names=FALSE, quote=FALSE)
