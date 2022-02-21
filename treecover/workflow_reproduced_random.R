# workflow reproduced spatial cv

source("setup_hpc.R")

modelname = "reproduced_randomcv"
initModel(modelname)

# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("data/predictors/", full.name = TRUE, pattern = ".grd"))
predictor_names = names(predictors)



folds = create_folds_random(modelname, training_samples, n_folds = 10, seed = 11)

cvfolds = data.frame(fold = folds)
cvfolds = cvfolds %>% dplyr::group_by(fold) %>%
    attr('groups') %>% dplyr::pull(.rows)



## granular distance

fold_gd_sample2sample = readRDS("data/misc/geodistance/sample_to_sample.RDS")
fold_gd_sample2sample$type = "geo"
fold_gd_sample2sample = fold_gd_sample2sample %>% rename(dist = distance)

fold_gd_sample2prediction = readRDS("data/misc/geodistance/sample_to_prediction.RDS")
fold_gd_sample2prediction$type = "geo"
fold_gd_sample2prediction = fold_gd_sample2prediction %>% rename(dist = distance)


fold_gd_between = CAST:::cvdistance(training_samples,
                                    cvfolds = cvfolds,
                                    distance = "geo",
                                    variables = predictor_names)

fold_gd = list(fold_gd_sample2sample,
               fold_gd_sample2prediction,
               fold_gd_between)

saveRDS(fold_gd, paste0(modelname, "/training_geodist.RDS"))


fold_fd = geodistance(modelname, training_samples,
                      modeldomain = global_sample, distance = "feature",
                      cvfolds = folds, predictors = predictor_names)


plot_distance(fold_gd)
plot_distance(fold_fd)


###### Modelling

hyperparameter = expand.grid(mtry = 3,
                             splitrule = "variance",
                             min.node.size = 5)


model = train_model(modelname, training_samples, predictors = predictor_names, response = "treecover2015",
                    folds = folds, hyperparameter = hyperparameter)

pre = pi_prediction(modelname, model, predictor_layers = predictors)
tdi = pi_trainDI(modelname, model)
aoa = pi_aoa(modelname, trainDI = tdi, model, predictor_layers = predictors)

# postprocessing

results = raster::stack(pre, aoa$DI, aoa$AOA)
names(results) = c("prediction", "DI", "AOA")
results = raster::projectRaster(results, crs = crs("+proj=eqearth"), method = "ngb")
writeRaster(results, file.path(modelname, "/results/pred_di_aoa.grd"), overwrite = TRUE)
