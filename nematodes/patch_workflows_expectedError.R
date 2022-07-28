# calibrate AOA


library(CAST)
source("~/development/CAST/R/expectedError.R")


# reproduced
rcv = readRDS("reproduced_randomcv/rfmodel.RDS")
scv = readRDS("reproduced_spatialcv/rfmodel.RDS")
fcv = readRDS("reproduced_featurecv03/rfmodel.RDS")

raoa = readRDS("reproduced_randomcv/aoa.RDS")
saoa = readRDS("reproduced_spatialcv/aoa.RDS")
faoa = readRDS("reproduced_featurecv03/aoa.RDS")

# calibrate DI as implemented currently in CAST
rcalib = calibrate_aoa(AOA = raoa, model = rcv, multiCV = FALSE, showPlot = FALSE, window.size = 25)
scalib = calibrate_aoa(AOA = saoa, model = scv, multiCV = FALSE, showPlot = FALSE, window.size = 25)
fcalib = calibrate_aoa(AOA = faoa, model = fcv, multiCV = FALSE, showPlot = FALSE, window.size = 25)


saveRDS(rcalib, "reproduced_randomcv/calibratedDI.RDS")
saveRDS(scalib, "reproduced_spatialcv/calibratedDI.RDS")
saveRDS(fcalib, "reproduced_featurecv03/calibratedDI.RDS")

# combine both cv strategies
r_DIcv = DIcv(model=rcv, AOA = raoa)
s_DIcv = DIcv(model=scv, AOA = saoa)
f_DIcv = DIcv(model=fcv, AOA = faoa)

comb_DIcv = rbind(r_DIcv, s_DIcv, f_DIcv)

performance = DImetric(model = scv, preds_all = comb_DIcv, window.size = 25)
errormodel = DIxMetric(performance = performance, calib = "scam", k = 6, m = 2, model = scv)



# create new AOA mask that combined all three strategies

aoa_comb = list(AOA = raoa$AOA | saoa$AOA | faoa$AOA)


expected_error = predictExpectedError(errormodel,
                                      DI = saoa$DI,
                                      minDI = min(performance$DI, na.rm = TRUE),
                                      maskAOA = TRUE,
                                      AOA = faoa$AOA)


# mask expected error with postmask like the prediction
postmask = raster("data/misc/postprocessing_mask.grd")


expected_error = raster::mask(expected_error, postmask, maskvalue = 1, updatevalue = NA)
expected_error = raster::projectRaster(expected_error, crs = crs("+proj=eqearth"), method = "ngb")


saveRDS(performance, "reproduced_combinedcv/performance.RDS")
saveRDS(errormodel, "reproduced_combinedcv/errormodel.RDS")
writeRaster(expected_error, file.path("reproduced_combinedcv/expected_error.grd"), overwrite = TRUE)


# svs ------------





rcv = readRDS("svs_randomcv/rfmodel.RDS")
scv = readRDS("svs_spatialcv/rfmodel.RDS")
fcv = readRDS("svs_featurecv03/rfmodel.RDS")

raoa = readRDS("svs_randomcv/aoa.RDS")
saoa = readRDS("svs_spatialcv/aoa.RDS")
faoa = readRDS("svs_featurecv03/aoa.RDS")


# calibrate DI as implemented currently in CAST
rcalib = calibrate_aoa(AOA = raoa, model = rcv, multiCV = FALSE, showPlot = FALSE, window.size = 25)
scalib = calibrate_aoa(AOA = saoa, model = scv, multiCV = FALSE, showPlot = FALSE, window.size = 25)
fcalib = calibrate_aoa(AOA = faoa, model = fcv, multiCV = FALSE, showPlot = FALSE, window.size = 25)

saveRDS(rcalib, "svs_randomcv/calibratedDI.RDS")
saveRDS(scalib, "svs_spatialcv/calibratedDI.RDS")
saveRDS(fcalib, "svs_featurecv03/calibratedDI.RDS")


# combine both cv strategies
r_DIcv = DIcv(model=rcv, AOA = raoa)
s_DIcv = DIcv(model=scv, AOA = saoa)
f_DIcv = DIcv(model=fcv, AOA = faoa)


comb_DIcv = rbind(r_DIcv, s_DIcv, f_DIcv)

performance = DImetric(model = scv, preds_all = comb_DIcv, window.size = 25)
errormodel = DIxMetric(performance = performance, calib = "scam", k = 6, m = 2, model = scv)


aoa_comb = list(AOA = raoa$AOA | saoa$AOA | faoa$AOA)


expected_error = predictExpectedError(errormodel,
                                       DI = saoa$DI,
                                       minDI = min(performance$DI, na.rm = TRUE),
                                       maskAOA = TRUE,
                                       AOA = faoa$AOA)


postmask = raster("data/misc/postprocessing_mask.grd")


expected_error = raster::mask(expected_error, postmask, maskvalue = 1, updatevalue = NA)
expected_error = raster::projectRaster(expected_error, crs = crs("+proj=eqearth"), method = "ngb")


saveRDS(performance, "svs_combinedcv/performance.RDS")
saveRDS(errormodel, "svs_combinedcv/errormodel.RDS")
writeRaster(expected_error, file.path("svs_combinedcv/expected_error.grd"), overwrite = TRUE)
