rm(list=ls())

# This code was used to filter the precipitation data file to the locations
# that are actually used by the model.
#
# In tests, it turned out that the saving in computation time is almost negligible (maybe 2%).

ifile_data= "/home/dkneis/progress/echse_proj/hypsoRR/neck/data/bconds/meteo/03_meteofill/out/precip_data.txt"
ifile_objects= "/home/dkneis/progress/echse_proj/hypsoRR/neck/data/topocatch/out/objDecl.KTEL.txt"
ifile_weights= "/home/dkneis/progress/echse_proj/hypsoRR/neck/data/bconds/inputs_ext_locations.txt"
varname= "precip_resid"

ofile= "/home/dkneis/progress/echse_proj/hypsoRR/neck/data/bconds/meteo/03_meteofill/out/precip_data.txt.filtered"

data= read.table(file=ifile_data, header=TRUE, sep="\t", check.names=FALSE, stringsAsFactors=FALSE)
objects= read.table(file=ifile_objects, header=TRUE, sep="\t", check.names=FALSE, stringsAsFactors=FALSE)
weights= read.table(file=ifile_weights, header=TRUE, sep="\t", check.names=FALSE, stringsAsFactors=FALSE)


locs= as.character(unique(weights$location[(weights$variable==varname) & (weights$object %in% objects$object)]))

write.table(x=data[,c(names(data)[1],locs)], file=ofile, sep="\t", col.names=TRUE, row.names=FALSE, quote=FALSE)

