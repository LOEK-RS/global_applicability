# divide training data into folds




create_folds_random = function(modelname, training_samples, n_folds, seed){
    random_folds = seq(nrow(training_samples)) %% n_folds
    set.seed(seed)
    random_folds = sample(random_folds)
    saveRDS(random_folds, paste0(modelname, "/folds.RDS"))
    return(random_folds)
}



create_folds_spatial = function(modelname, training_samples, n_folds, gridsize, seed){
    # create grid
    grid = world_grid(cellsize = gridsize)
    
    
    # spatially match points
    # remove grid cells without points
    grid = grid[lengths(st_intersects(grid, training_samples)) > 0,]
    
    # randomly create groups
    grid$fold = seq(nrow(grid)) %% n_folds
    set.seed(seed)
    grid$fold = sample(grid$fold)
    
    st_write(grid, paste0(modelname, "/spatial_folds_grid.gpkg"), append = FALSE)
    
    spatial_folds = st_join(training_samples, grid, left = TRUE) %>% pull(fold)
    
    saveRDS(spatial_folds, paste0(modelname, "/folds.RDS"))
    return(spatial_folds)
}


world_grid = function(extent = c(-180, -90, 180, 90), cellsize = 15, crs = 4326){
    world = sf::st_multipoint(x = matrix(extent, ncol = 2, byrow = TRUE)) %>%
        sf::st_sfc(crs = crs)
    world_grid = sf::st_make_grid(world, cellsize = cellsize)
    world_grid = sf::st_sf(fold = seq(length(world_grid)), world_grid)
    
    return(world_grid)
}

