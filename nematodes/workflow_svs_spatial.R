# workflow svs

source("setup.R")

modelname = "svs10"

initModel(modelname)


# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("data/predictors/", full.name = TRUE, pattern = ".grd"))
predictor_names = names(predictors)
folds = readRDS("reproduced10/folds.RDS")


##### Modelling

hyperparameter = expand.grid(mtry = 3,
                             splitrule = "variance",
                             min.node.size = 5)


svs = spatial_variable_selection(modelname, training_samples,
                                 predictors = predictor_names, response = "Total_Number",
                                 folds = folds, hyperparameter = hyperparameter)


pre = pi_prediction(modelname, model = svs, predictor_layers = predictors)
tdi = pi_trainDI(modelname, svs)
aoa = pi_aoa(modelname, trainDI = tdi, predictor_layers = predictors, model = svs)


# feature distances after the variable selection

fold_fd = geodistance(modelname, training_samples,
                      modeldomain = global_sample, distance = "feature",
                      cvfolds = folds, predictors = svs$selectedvars)

plot_distance(fold_fd)

# postprocessing

postmask = raster("data/misc/postprocessing_mask.grd")
results = raster::stack(pre, aoa$DI, aoa$AOA)
names(results) = c("prediction", "DI", "AOA")
results = raster::mask(results, postmask, maskvalue = 1, updatevalue = NA)
results = raster::projectRaster(results, crs = crs("+proj=eqearth"), method = "ngb")
writeRaster(results, file.path(modelname, "/results/pred_di_aoa.grd"), overwrite = TRUE)


