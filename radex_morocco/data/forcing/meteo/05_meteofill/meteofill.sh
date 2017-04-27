#!/bin/bash

cd $(pwd)

meteofill=$ECHSE_TOOLS"/apps/meteofill/bin/meteofill"
idir_locs="/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/forcing/meteo/01_dbExport/out/"
idir_data="/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/forcing/meteo/04_plausibilityCheck/out/"
odir="/home/tobias/Promotion/Modellierung/Bengue/ECHSE_WASA/test_evap/data/forcing/meteo/05_meteofill/out/"

nsectors=4
norigins=4

nodata=-9999

for pattern in "wind" "temper" "apress" "sundur" "precip" "rhum" "temp_min" "temp_max"
do

  echo "Processing "$pattern

  ifile_data=$idir_data/$pattern"_data.dat"
  ifile_locs=$idir_locs/$pattern"_locs.dat"

  ofile_data=$odir/$pattern"_data.dat"
  ofile_locs=$odir/$pattern"_locs.dat"

  logfile=$odir/$pattern".log"

  resid_nmin=3
  if [ $pattern == "temper" ]; then
    resid_r2min=0.8
    resid_llim=5
    resid_ulim=45
  elif [ $pattern == "apress" ]; then
    resid_r2min=0.8
    resid_llim=850
    resid_ulim=1100
  else
    resid_r2min=1.0
    resid_llim=-9999
    resid_ulim=-9999
  fi   

  $meteofill ifile_locations=$ifile_locs ifile_data=$ifile_data chars_colsep="	" chars_comment="#" nodata=$nodata idw_power=2 nsectors=$nsectors norigins=$norigins resid_nmin=$resid_nmin resid_r2min=$resid_r2min resid_llim=$resid_llim resid_ulim=$resid_ulim ofile_data=$ofile_data ofile_locations=$ofile_locs ndigits_max=1 logfile=$logfile overwrite=true

  if [ $? -ne 0 ]; then
    echo Failed.
  else
    echo OK.
  fi

done
