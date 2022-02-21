# project setup


palmalib = "/home/m/mludwig2/R"


library(sf)
library(tidyverse)
library(stars)
library(raster)
library(caret)
library(CAST, lib.loc = "/home/m/marvin/")


list.files("pipeline/", full.names = TRUE) %>% map(source)


