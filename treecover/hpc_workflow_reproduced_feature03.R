# workflow reproduced spatial cv

source("setup_hpc.R")

modelname = "reproduced_feature03"
initModel(modelname)

# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("/scratch/tmp/mludwig2/global_applicability/data/treecover/predictors/", full.name = TRUE, pattern = ".grd$"))
predictor_names = names(predictors)

create_folds_featurespace = function(modelname, training_samples, predictor_names, n_folds){
    
    # create feature space cluster
    feature_folds = stats::kmeans(training_samples[predictor_names] %>% st_drop_geometry(), n_folds)$cluster
    saveRDS(feature_folds, paste0(modelname, "/folds.RDS"))
    return(feature_folds)
}

folds = create_folds_featurespace(modelname, training_samples, n_folds = 3, predictor_names = predictor_names)



###### Modelling

hyperparameter = expand.grid(mtry = 3,
                             splitrule = "variance",
                             min.node.size = 5)


model = train_model(modelname, training_samples, predictors = predictor_names, response = "treecover2015",
                    folds = folds, hyperparameter = hyperparameter)

pre = pi_prediction(modelname, model, predictor_layers = predictors)
tdi = pi_trainDI(modelname, model)
aoa = pi_aoa(modelname, trainDI = tdi, model, predictor_layers = predictors)




