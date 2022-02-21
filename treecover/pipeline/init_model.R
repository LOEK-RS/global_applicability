initModel = function(modelname){
    
    if(!dir.exists(modelname)){
        dir.create(modelname)
        dir.create(file.path(modelname, "results"))   
    }
    
    
    
}