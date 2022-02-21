# workflow random cv


source("setup.R")

modelname = "reproduced_randomcv"
initModel(modelname)

# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("data/predictors/", full.name = TRUE, pattern = ".grd"))
predictor_names = names(predictors)



folds = create_folds_random(modelname, training_samples, n_folds = 10, seed = 11)

fold_gd = geodistance(modelname, training_samples,
                      modeldomain = global_sample, distance = "geo",
                      cvfolds = folds, predictors = predictor_names)

fold_fd = geodistance(modelname, training_samples,
                      modeldomain = global_sample, distance = "feature",
                      cvfolds = folds, predictors = predictor_names)


plot_distance(fold_gd)
plot_distance(fold_fd)


###### Modelling

hyperparameter = expand.grid(mtry = 3,
                             splitrule = "variance",
                             min.node.size = 5)


model = train_model(modelname, training_samples, predictors = predictor_names, response = "Total_Number",
                    folds = folds, hyperparameter = hyperparameter)

pre = pi_prediction(modelname, model, predictor_layers = predictors)
tdi = pi_trainDI(modelname, model)
aoa = pi_aoa(modelname, trainDI = tdi, model, predictor_layers = predictors)


# postprocessing

postmask = raster("data/misc/postprocessing_mask.grd")


results = raster::stack(pre, aoa$DI, aoa$AOA)
names(results) = c("prediction", "DI", "AOA")
results = raster::mask(results, postmask, maskvalue = 1, updatevalue = NA)
results = raster::projectRaster(results, crs = crs("+proj=eqearth"), method = "ngb")
writeRaster(results, file.path(modelname, "/results/pred_di_aoa.grd"))


