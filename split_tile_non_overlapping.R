# load library
library(raster)
library(terra)
library(sf)

split_size = 128 #size of image patches that you want to split

rst <- raster("raster file that you want to split")
#name of the raster files
nm <- strsplit(basename("raster file that you want to split", ".tif")[[1]][1]
               
rst.grd <- aggregate(rst, fact = split_size)
values(rst.grd) <- seq(1, raster::ncol(rst.grd)*raster::nrow(rst.grd), 1)
rst.shp <- as.polygons(rast(rst.grd))

#save the grid file as the vector layer (do not need this if you dont
writeVector(rst.shp, filename = paste0("grid_128_", nm, ".gpkg"), overwrite = T)

#loop using the resulted grid to crop image into tiles
for(j in 1:length(rst.shp)){
  print(paste0("start ", j, "/", length(rst.shp)))
  exta <- rast(rst.shp[j])
  rst.cr <- raster::crop(rst, raster::extent(raster(exta)))
  print(paste0("ncols ", ncol(rst.cr), " x nrows ", nrow(rst.cr)))
  if (any(is.na(values((rst.cr))))){ # skip all raster image with NA values
    print(paste0("skip"))
    } else if ((ncol(rst.cr) != 128)|(nrow(rst.cr) != 128)){
      print(paste0("skip"))
    } else {
      raster::writeRaster(rst.cr, paste0("grid_", j, "_", nm, ".tif"), format = "GTiff", datatype = "FLT4S")
    }
  }
