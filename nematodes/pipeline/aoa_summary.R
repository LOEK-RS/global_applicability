

summary_aoa = function(aoa){
    aoa = as.data.frame(aoa)
    insideAOA = table(aoa)["1"]
    outsideAOA = table(aoa)["0"]
    percentageAOA = round((insideAOA / sum(insideAOA, outsideAOA))*100, 1)
    
    result = c("inside AOA" = percentageAOA, "outside AOA" = 100 - percentageAOA)
    return(result)
}
