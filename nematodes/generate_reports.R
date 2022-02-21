# generate reports


library(rmarkdown)


modelnames = c("reproduced_randomcv", "reproduced_spatialcv", "svs_spatialcv", "svs_randomcv")


for(i in modelnames){
    render(input = "report_template.Rmd", params = list(model = i), output_file = paste0("docs/report_", i, ".html"))
}






