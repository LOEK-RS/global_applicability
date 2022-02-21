# project setup


palmalib = "/home/m/mludwig2/R"


library(sf)
library(tidyverse)
library(stars)
library(raster)
library(caret)
library(s2, lib.loc = palmalib)
library(CAST, lib.loc = palmalib)


list.files("pipeline/", full.names = TRUE) %>% map(source)


