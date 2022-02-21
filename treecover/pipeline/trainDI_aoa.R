pi_prediction = function(modelname, model, predictor_layers){
    # reduce predictor stack to model predictors
    mp = colnames(model$trainingData)[-length(model$trainingData)]
    predictor_layers = predictor_layers[[mp]]
    
    p = raster::predict(predictor_layers, model)
    writeRaster(p, file.path(modelname, "/prediction.grd"), overwrite = TRUE)
    return(p)
}


pi_trainDI = function(modelname, model){
    tdi = CAST::trainDI(model)
    saveRDS(tdi, paste0(modelname, "/trainDI.RDS"))
    return(tdi)
}



pi_aoa = function(modelname, trainDI, model, predictor_layers){
    a = CAST::aoa(newdata = predictor_layers, model = model, trainDI = trainDI)
    saveRDS(a, paste0(modelname, "/aoa.RDS"))
    return(a)
}



pi_calaoa = function(modelname, aoa, model, ...){
    ca = CAST::calibrate_aoa(AOA = aoa, model = model, ...)
    saveRDS(ca, paste0(modelname, "/calibrateaoa.RDS"))
    return(ca)
}






