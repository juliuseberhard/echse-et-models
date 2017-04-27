rm(list=ls())

library("geostat")

setwd("/home/tobias/Promotion/Modellierung/Bengue/Preprocessing/forcing/meteo/")

for (var in c("apress","temper")) {
  residualTimeSeries(
    file_obs= paste("05_meteofill/out/",var,"_data.dat",sep=""),
    file_loc= paste("05_meteofill/out/",var,"_locs.dat",sep=""),
    colsep="\t",
    obs_colTime="end_of_interval",
    loc_colId="id",
    loc_colPred="z",
    average= FALSE,
    r2min= 0.7,
    file_resid= paste("06_residuals/out/",var,"_resid.dat",sep=""),
    file_coeff= paste("06_residuals/out/",var,"_coeff.dat",sep=""),
    nsignif=3,
    overwrite=TRUE
  )
}
