# fold distances


geodistance = function(modelname, training_samples, modeldomain, cvfolds, distance, predictors){
    
    cvfolds = data.frame(fold = cvfolds)
    
    cvfolds = cvfolds %>% dplyr::group_by(fold) %>%
        attr('groups') %>% dplyr::pull(.rows)
    
    sample_to_sample = CAST:::sample2sample(training_samples,
                                            distance,
                                            variables = predictors)
    
    sample_to_prediction = CAST:::sample2prediction(training_samples,
                                                    modeldomain,
                                                    distance,
                                                    variables = predictors)
    
    between_folds = CAST:::cvdistance(training_samples,
                                      cvfolds,
                                      distance,
                                      variables = predictors)
    
    result = list(sample_to_sample = sample_to_sample,
                  sample_to_prediction = sample_to_prediction,
                  between_folds = between_folds)
    
    saveRDS(result, paste0(modelname, "/training_", distance, "dist.RDS"))
    return(result)
}


