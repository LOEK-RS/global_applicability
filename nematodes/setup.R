# project setup


library(sf)
library(tidyverse)
library(stars)
library(raster)
library(caret)
library(CAST)
library(tmap)
library(scales)
library(kableExtra)
library(viridis)
library(tmap)
library(ggpubr)



list.files("pipeline/", full.names = TRUE) %>% map(source)


