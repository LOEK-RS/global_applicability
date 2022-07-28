# workflow svs featurespace


# workflow reproduced feature cv

source("setup.R")

modelname = "svs_featurecv03"
initModel(modelname)

# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("data/predictors/", full.name = TRUE, pattern = ".grd"))


# predictors from spatial cv model
model_spatial = readRDS("svs_spatialcv/rfmodel.RDS")
predictor_names = model_spatial$selectedvars



folds = create_folds_featurespace(modelname, training_samples, n_folds = 3, predictor_names = predictor_names)

fold_gd = geodistance(modelname, training_samples,
                      modeldomain = global_sample, distance = "geo",
                      cvfolds = folds, predictors = predictor_names)

fold_fd = geodistance(modelname, training_samples,
                      modeldomain = global_sample, distance = "feature",
                      cvfolds = folds, predictors = predictor_names)





###### Modelling

hyperparameter = expand.grid(mtry = 3,
                             splitrule = "variance",
                             min.node.size = 5)


model = train_model(modelname, training_samples, predictors = predictor_names, response = "SLA",
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

