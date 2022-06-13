# Area of Applicability of global spatial prediction models

This repository contains code and data to reproduce the results from XXX.




## Repository structure

The reproduction of the three studies are in the three directories `nematodes`, `sla` and `treecover`.
Each directory follows the same logic:

* `data`: static input data for the modelling process
	* `predictors`: raster layers of the predictors
	* `misc`:
		* `global_sample.gpkg` globally distributed points - needed for sample-to-prediction distance
		* `postprocessing_mask` raster layer of valid pixels
	* `training_samples.gpkg`: response with extracted predictor values at reference sample locations

* `pipeline`: functions and scripts for the modelling (see below)
* `reproduced_random`, `reproduced_spatial`, `svs_random`, `svs_spatial`: models with results and metadata
	* `rfmodel.RDS`: the actual model
	* `folds.RDS`: row indices of the cross-validation folds
	* `prediction.grd`: global raster of the predicted response
	* `trainDI.RDS`: dissimilarity index between the reference samples and CV folds (intermediate result of the aoa)
	* `aoa.RDS`: area of applicability of the models CV performance
	* `training_featuredist.RDS`: feature space distance between training samples / training samples to global domain / between CV folds
	* `training_geodist.RDS`: geographic distance between training samples / training samples to global domain / between CV folds
	* `results`: prediction, DI and AOA with applied postprocessing mask
* `setup.R`: load packages, functions and static data
* `workflow_XX.R`: Script to execute the modelling pipeline and create the results


## Modelling pipeline

### Find senseful spatial folds

The aim is to find spatial blocks such that prediction scenarios during CV resemble the final prediction conditions on the whole globe. For this, we divide observations into spatial blocks based on their geographic location (`create_folds.R`) and compute the distance for each observation to the closest observation in a different fold (`fold_distances.R`). We tried different block sizes and compared the between-fold-distance with the sample-to-prediction difference. The resulting distances and folds can be displayed with `plot_folddistance.R`.


### Model training and spatial feature selection

`train_model.R` reproduces the models from the original studies. It trains a random forest model on all available predictors evaluated by CV using the specified folds.  We compared to strategies: random folds and spatial folds as described above.

`feature_selection.R` uses the spatial folds for a Forward Feature Selection in order to identify predictors that are most suitable to predict beyond the training locations. For better comparability, these simplified, predictor-reduced models are again evaluated with random CV.


### Analysing Model Transferability

We use the Area of Applicability to assess model transferability - i.e. the area for which the model CV error applies and no extrapolations in the multivariate predictor space occur. The functions itself are from the `CAST` package. `trainDI_aoa.R` contains function to also write the output automatically. The computations can be quite long, so a high performance cluster might be useful.















