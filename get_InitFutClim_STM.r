#### Future climat
#### By Steve Vissault
#### December first, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")

# Database connection
source('./con_quicc_db.r')
#source('./con_quicc_db_local.r')

#Load librairies
library('reshape2')

GCM_df <- read.csv("./list_GCMs.csv")
GCM_df <- subset(GCM_df, scenario == 'rcp85')

out_folder <- "./out_files/fut_Initclim_STM/"

for (x in 1:dim(GCM_df)[1]){

    system(paste("mkdir -p ",out_folder,"GCM_id_",rownames(GCM_df)[x],sep=""))

    query_fut_climData <- paste("SELECT ST_X(geom) as lon, ST_Y(geom) as lat, x , y, var, ", 1970 ," as min_yr,",2000," as max_yr, val, clim_center, mod, run, scenario FROM (
    SELECT var,clim_center, mod, run, scenario, (ST_PixelAsCentroids(ST_Union(ST_Clip(ST_Transform(raster,4269),1,env_plots,true),'MEAN'),1,false)).*
    FROM clim_rs.fut_clim_biovars,
    (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) as envelope
    WHERE (var='bio1' OR var='bio12') AND (yr >= 1970 AND yr <=  2000) AND clim_center='",GCM_df[x,1],"' AND mod='",GCM_df[x,2],"' AND run='",GCM_df[x,3],"' AND scenario='",GCM_df[x,4],"' AND ST_Intersects(ST_Transform(raster,4269),env_plots)
    GROUP BY var,clim_center, mod, run, scenario
    ) as pixels;",sep="")

    cat("Querying id: ",rownames(GCM_df)[x],"; processing window:", windows[i]-15, "-", windows[i], "\n")

    fut_climData <- dbGetQuery(con, query_fut_climData)

    write.table(fut_climData, file=paste(out_folder,"GCM_id_",rownames(GCM_df)[x],"/GCM_id_",rownames(GCM_df)[x],"_win_1970-2000.csv",sep=""), sep=',', row.names=FALSE)

}
