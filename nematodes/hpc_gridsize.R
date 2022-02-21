# workflow hpc svs blovk size


source("setup_hpc.R")




# static input
training_samples = st_read("data/training_samples.gpkg")
global_sample = st_read("data/misc/global_sample.gpkg")
predictors = stack(list.files("/scratch/tmp/mludwig2/global_applicability/data/nematodes/predictors/",
                              full.name = TRUE, pattern = ".grd$"))
predictor_names = names(predictors)

hyperparameter = expand.grid(mtry = 3,
                             splitrule = "variance",
                             min.node.size = 5)


rm(predictors)


for(i in seq(9)){
    
    
    
    
    modelname = paste0("all_grid_", i)
    initModel(modelname)
    print(modelname)
    
    folds = create_folds_spatial(modelname, training_samples, n_folds = 10, gridsize = i, seed = 11)
    
    
    fold_gd = geodistance(modelname, training_samples,
                          modeldomain = global_sample, distance = "geo",
                          cvfolds = folds, predictors = predictor_names)
    
    fold_fd = geodistance(modelname, training_samples,
                          modeldomain = global_sample, distance = "feature",
                          cvfolds = folds, predictors = predictor_names)
    
    
    model = train_model(modelname, training_samples, predictors = predictor_names, response = "Total_Number",
                        folds = folds, hyperparameter = hyperparameter)
    
    
    tdi = pi_trainDI(modelname, model = model)
    
    
    
    modelname = paste0("svs_grid_", i)
    initModel(modelname)
    print(modelname)
    
    
    folds = create_folds_spatial(modelname, training_samples, n_folds = 10, gridsize = i, seed = 11)
    
    svs = spatial_variable_selection(modelname, training_samples,
                                     predictors = predictor_names, response = "Total_Number",
                                     folds = folds, hyperparameter = hyperparameter)
    
    tdi = pi_trainDI(modelname, model = svs)
    
    fold_fd = geodistance(modelname, training_samples,
                          modeldomain = global_sample, distance = "feature",
                          cvfolds = folds, predictors = svs$selectedvars)
    
    
}



