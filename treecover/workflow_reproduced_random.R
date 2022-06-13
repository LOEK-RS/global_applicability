# workflow reproduced spatial cv

# use this after hpc processing



source("setup.R")

modelname = "reproduced_randomcv"
initModel(modelname)

# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("data/predictors/", full.name = TRUE, pattern = ".grd"))
predictor_names = names(predictors)


pre = raster(paste0(modelname, "/prediction.grd"))
aoa = readRDS(paste0(modelname, "/aoa.RDS"))


# postprocessing

results = raster::stack(pre, aoa$DI, aoa$AOA)
names(results) = c("prediction", "DI", "AOA")
results = raster::projectRaster(results, crs = crs("+proj=eqearth"), method = "ngb")
writeRaster(results, file.path(modelname, "/results/pred_di_aoa.grd"), overwrite = TRUE)
