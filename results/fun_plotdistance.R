

plot_distance = function(distance){
    
    df = do.call(rbind, distance)
    
    p = ggplot(df, aes(x = dist, fill = what))+
        scale_x_log10(name = paste0("Distance [m]"),
                      breaks = trans_breaks("log10", function(x) 10^x),
                      labels = trans_format("log10", math_format(10^.x)))+
        geom_density(alpha = .6)+
        ggpubr::theme_pubclean()
    
    p
    return(p)
    
    
}
