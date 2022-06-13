# workflow spatial variable selection

source("setup.R")

modelname = "svs_spatialcv"
initModel(modelname)

# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("data/predictors/", full.name = TRUE, pattern = ".grd"))
predictor_names = readRDS("data/predictor_names.RDS")


# same folds as the reproduced spatial cv
folds = readRDS("reproduced_spatialcv/folds.RDS")


###### Modelling

hyperparameter = expand.grid(mtry = 3,
                             splitrule = "variance",
                             min.node.size = 5)


model = spatial_variable_selection(modelname, training_samples, predictors = predictor_names, response = "SLA",
                    folds = folds, hyperparameter = hyperparameter)

pre = pi_prediction(modelname, model, predictor_layers = predictors)
tdi = pi_trainDI(modelname, model)
aoa = pi_aoa(modelname, trainDI = tdi, model, predictor_layers = predictors)

# postprocessing

postmask = raster::stack("data/misc/postprocessing_mask.grd")

results = raster::stack(pre, aoa$DI, aoa$AOA)
names(results) = c("prediction", "DI", "AOA")
results = raster::mask(results, postmask, maskvalue = 1, updatevalue = NA)
results = raster::projectRaster(results, crs = crs("+proj=eqearth"), method = "ngb")
writeRaster(results, file.path(modelname, "/results/pred_di_aoa.grd"), overwrite = TRUE)
