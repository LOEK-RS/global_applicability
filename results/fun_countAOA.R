# count AOA

countAOA = function(a){
    a = as.data.frame(a)
    a = na.omit(a)
    a = a$AOA
    insideAOA = table(a)["1"]
    outsideAOA = table(a)["0"]
    
    percentageAOA = round((insideAOA / sum(insideAOA, outsideAOA))*100, 1)
    return(percentageAOA)
}




