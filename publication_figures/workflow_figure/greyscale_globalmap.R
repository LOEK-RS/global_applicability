gr = grey_pal(start = 0.8, end = 0.2)


library(raster)
library(tmap)
library(scales)
treecover_rep_exp = raster("~/casestudies/global_applicability/treecover/reproduced_randomcv/prediction.grd")

treecover_rep_expmap = tm_shape(countries)+
    tm_polygons(col = "grey80")+
    tm_shape(treecover_rep_exp)+
    tm_raster(palette = gr(50), style = "cont",
              legend.is.portrait = TRUE, breaks = seq(0,100,20), title = "Expected\nRMSE")+
    tm_layout(legend.show = FALSE,
              bg.color = "white",
              frame = FALSE,
              panel.show = FALSE,
              earth.boundary = c(-180, -88, 180, 88),
              earth.boundary.color = "transparent")
treecover_rep_expmap
