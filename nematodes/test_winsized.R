library(ggplot2)



winsizes = lapply(seq(5,25,5), function(x){
    
    print(x)
    performance = DImetric(model = scv, preds_all = comb_DIcv, window.size = x)
    errormodel = DIxMetric(performance = performance, calib = "scam", k = 6, m = 2, model = scv)
    
    performance$model = predict(errormodel, performance["DI"])
    performance$m = x
    
    return(performance)
    
    
})


ws = do.call(rbind, winsizes)

ggplot(ws, aes(x = DI, y = metric))+
    geom_hex()+
    scale_fill_gradientn(colors = viridis::viridis(50), trans = "log10", name = "Points [n]")+
    scale_y_continuous(name = "RMSE")+
    geom_line(color='red', mapping = aes(y = model, x = DI), lwd = 1)+
    ggpubr::theme_pubclean()+
    facet_wrap(.~m)+
    theme(legend.position = "bottom", legend.background = element_blank())










