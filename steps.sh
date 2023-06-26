#!/bin/bash

module load anaconda3/5.3.0

PROJECT=$(groups)
export SCRIPTSDIR=/home/$USER/projects/prepare_MCDS_fire_datasets
## export WORKDIR=/data/cephfs/$PROJECT/$USER/data/MCDS_fire_datasets
export WORKDIR=/data/scratch/projects/$PROJECT/MCDS_fire_datasets/
export ALUMDIR=$WORKDIR/ALUM
export DEMDIR=$WORKDIR/DEM
export VIDIR=$WORKDIR/VI
export LUCDIR=$WORKDIR/LUC
export FCDIR=$WORKDIR/FC
export hotspotDIR=$WORKDIR/hotspot
export boundariesDIR=$WORKDIR/boundaries
export population_gridDIR=$WORKDIR/population_grid
export climate_classificationDIR=$WORKDIR/climate_classification
export roadsDIR=$WORKDIR/roads
export weatherDIR=$WORKDIR/weather
export fire_historyDIR=$WORKDIR/fire_history

mkdir -p $SCRIPTSDIR
mkdir -p $WORKDIR

cd $SCRIPTSDIR

if [[ ! -e data ]] ; then
    ln -s $WORKDIR data
fi

#########################

mkdir -p $ALUMDIR
cd $ALUMDIR

## get the ALUM Land use of Australia 2015–16 raster package (GeoTIFF and supporting files) (ZIP 18 MB)
wget https://www.agriculture.gov.au/sites/default/files/documents/nlum_alumv8_250m_2015_16_alb.zip

## get the ALUM Land use of Australia 2015–16 thematic layers raster package (GeoTIFF and supporting files) (ZIP 89 MB)
wget https://www.agriculture.gov.au/sites/default/files/documents/nlum_inputs_250m_2015_16_geo.zip

## get a descriptive document
wget https://www.agriculture.gov.au/sites/default/files/documents/nlum_250m_descriptivemetadata_20220622.pdf

unzip nlum_alumv8_250m_2015_16_alb.zip

#########################

mkdir -p $DEMDIR
cd $DEMDIR

## see https://www.ga.gov.au/scientific-topics/national-location-information/digital-elevation-data

## see https://ecat.ga.gov.au/geonetwork/srv/eng/catalog.search#/metadata/66006
## get the GEODATA 9 second (~250m) DEM and D8: Digital Elevation Model Version 3 and Flow Direction Grid 2008
wget https://elevation-direct-downloads.s3-ap-southeast-2.amazonaws.com/9sec-dem/DEM-9S_ESRI.zip
## get the user guide for this product
wget https://elevation-direct-downloads.s3-ap-southeast-2.amazonaws.com/9sec-dem/UserGuide.pdf

## see https://ecat.ga.gov.au/geonetwork/srv/eng/catalog.search#/metadata/69888
## get the 3 second SRTM Derived Digital Elevation Model (DEM) Version 1.0
wget https://elevation-direct-downloads.s3-ap-southeast-2.amazonaws.com/3sec-dem/3secSRTM_DEM.zip

## unzip the 250m DEM product
unzip DEM-9S_ESRI.zip
## convert format
gdal_translate -of netCDF Data_9secDEM_D8/dem-9s.asc dem-9s.nc
## clean up
rm -r Data_9secDEM_D8/
## compress
ncks -O -4 -L4 --cnk_dmn lat,2048 --cnk_dmn lon,2048 dem-9s.nc dem-9s.nc


#########################

mkdir -p $LUCDIR
cd $LUCDIR

mkdir -p MCD12C1
cd MCD12C1


## MODIS landuse 
## see https://lpdaac.usgs.gov/products/mcd12q1v061/


source usgs_credentials.sh

wget -O MCD12C1.061.nc --user=${usgs_user} --password=${usgs_password} "https://opendap.cr.usgs.gov/opendap/hyrax/MCD12C1.061/MCD12C1.061.ncml.dap.nc4?dap4.ce=/Latitude%5B2001:1:2680%5D;/Longitude%5B5852:1:6694%5D;/Majority_Land_Cover_Type_2%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D;/Majority_Land_Cover_Type_1%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D;/Num_LAI_FPAR_Classes%5B0:1:20%5D%5B0:1:10%5D;/Num_IGBP_Classes%5B0:1:20%5D%5B0:1:16%5D;/Num_UMD_Classes%5B0:1:20%5D%5B0:1:13%5D;/Majority_Land_Cover_Type_2_Assessment%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D;/Majority_Land_Cover_Type_3%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D;/Majority_Land_Cover_Type_3_Assessment%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D;/Land_Cover_Type_3_Percent%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D%5B0:1:10%5D;/Land_Cover_Type_2_Percent%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D%5B0:1:13%5D;/Majority_Land_Cover_Type_1_Assessment%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D;/Land_Cover_Type_1_Percent%5B0:1:20%5D%5B2001:1:2680%5D%5B5852:1:6694%5D%5B0:1:16%5D;/time%5B0:1:20%5D"

#  -A "*.hdf"
#  -l2

# wget -R jpg,xml -r -np -nc --no-check-certificate -e robots=off --user=${usgs_user} --password=${usgs_password} https://e4ftl01.cr.usgs.gov/MOTA/MCD12C1.061/
# mv e4ftl01.cr.usgs.gov/MOTA/MCD12C1.061/20??.01.01/*hdf .
# rm -r e4ftl01.cr.usgs.gov

# module load foss/2019b
# module load nco

## https://discover.data.vic.gov.au/dataset/native-vegetation-modelled-2005-ecological-vegetation-classes-with-bioregional-conservation-sta18

## Australia - Present Major Vegetation Groups - NVIS Version 6.0
## https://www.dcceew.gov.au/environment/land/native-vegetation/national-vegetation-information-system/data-products
## National Vegetation Information System (NVIS) Version 6.0 - AUSTRALIA - Extant Vegetation
## **Vector** dataset
## http://environment.gov.au/fed/catalog/search/resource/details.page?uuid=%7Bab942d6d-9efd-4cf2-bec7-4c1521b83803%7D
## files: {FGDB,SHP}_{ACT,NSW,NT,QLD,TAS,VIC}_EXT.zip
## Australia - Present Major Vegetation Subgroups - NVIS Version 6.0 (Albers 100m analysis product)
## **Raster** dataset
## http://environment.gov.au/fed/catalog/search/resource/details.page?uuid=%7B3F8AD12F-8300-45EC-A41A-469519A94039%7D
## {FGDB,GRID}_NVIS6_0_AUST_EXT_MVG.zip

## Interim Biogeographic Regionalisation for Australia (IBRA), Version 7 (Subregions) - States and Territories
## **Vector** dataset
## https://www.dcceew.gov.au/environment/land/nrs/science/ibra
## https://www.environment.gov.au/fed/catalog/search/resource/details.page?uuid=%7B1273FBE2-F266-4F3F-895D-C1E45D77CAF5%7D
## files: IBRA7_{regions,subregions}{,_states}.zip


######################### vegetation indices

MCD19A3CMG.A2000055.061.2022315175328.hdf  
https://e4ftl01.cr.usgs.gov/MOTA/MCD19A3CMG.061/2000.02.24/MCD19A3CMG.A2000055.061.2022315175328.hdf

wget -O MCD19A3CMG.061.nc --user=${usgs_user} --password=${usgs_password} "https://opendap.cr.usgs.gov/opendap/hyrax/MCD19A3CMG.061/MCD19A3CMG.061.ncml.dap.nc4?dap4.ce=/Latitude%5B2001:1:2680%5D;/Longitude%5B5852:1:6694%5D;/EVI%5B100:1:120%5D%5B2001:1:2680%5D%5B5852:1:6694%5D;/time%5B100:1:120%5D"

wget -R jpg,xml,html -r -np -nc --no-check-certificate -e robots=off --user=${usgs_user} --password=${usgs_password} https://e4ftl01.cr.usgs.gov/MOTA/MCD19A3CMG.061/2000.02.26/
wget -A hdf -r -np -nc --no-check-certificate -nv -e robots=off --user=${usgs_user} --password=${usgs_password} https://e4ftl01.cr.usgs.gov/MOTA/MCD19A3CMG.061/2000.02.28/
wget -A hdf -r -np -nc --no-check-certificate -nv -e robots=off --user=${usgs_user} --password=${usgs_password} https://e4ftl01.cr.usgs.gov/MOTA/MCD19A3CMG.061/2000.02.28/MCD19A3CMG.*.hdf


# for year in $(seq 2000 2023) ; do

module purge
module load foss/2021b gdal/3.3.2


# years=( 2000 2001 2022 2023 )
# for year in "${years[@]}" ; do

## for year in $(seq 2000 2023) ; do
for year in $(seq 2002 2021) ; do
    id1=0
    idn=22
    if [ $year -eq 2000 ] ; then
        id1=3
    fi
    if [ $year -eq 2023 ] ; then
	idn=9
    fi
    for idate in $(seq $id1 $idn) ; do
        jday=$(echo $idate*16 | bc)
	yyyymmdd=$(date -d "$year-01-01 + $jday days" +%Y.%m.%d)
	yyyymmdd_dir=e4ftl01.cr.usgs.gov/MOLT/MOD13C1.061/${yyyymmdd}/
	mkdir -p ${yyyymmdd_dir}
	if [ $(ls -1 ${yyyymmdd_dir}/*.nc | wc -l) -eq 1 ] ; then
	    echo "Date $yyyymmdd already done - skipping"
	    continue
	fi
	##
	wget -A hdf -r -np -nc --no-check-certificate -nv -e robots=off --user=${usgs_user} --password=${usgs_password} "https://e4ftl01.cr.usgs.gov/MOLT/MOD13C1.061/${yyyymmdd}/"
	if [ $(ls -1 ${yyyymmdd_dir}/*.hdf | wc -l) -eq 0 ] ; then
	    echo "Error downloading .hdf file for $yyyymmdd - skipping"
	    continue
	fi
	##
	hdffile=$(ls e4ftl01.cr.usgs.gov/MOLT/MOD13C1.061/${yyyymmdd}/*.hdf)
	ncfile=$(echo $hdffile | rev | cut -d. -f2- | rev | xargs -I@ echo @.nc)
	nc4file="${ncfile}4"
	gdal_translate -of netCDF -srcwin 5852 2001 843 680 HDF4_EOS:EOS_GRID:"${hdffile}":MODIS_Grid_16Day_VI_CMG:"CMG 0.05 Deg 16 days EVI" $ncfile
	nccopy -4 -d 4 $ncfile $nc4file
	rm $ncfile $hdffile
	mv $nc4file $ncfile
    done
done

module purge
module load foss/2019b nco/4.8.1

basedate="2000-01-01"
for year in $(seq 2000 2023) ; do
    id1=0
    idn=22
    if [ $year -eq 2000 ] ; then
        id1=3
    fi
    if [ $year -eq 2023 ] ; then
	idn=9
    fi
    for idate in $(seq $id1 $idn) ; do
        jday=$(echo $idate*16 | bc)
	yyyymmdd=$(date -d "$year-01-01 + $jday days" +%Y.%m.%d)
	thisdate=$(date -d "$year-01-01 + $jday days" +%Y-%m-%d)
	## echo $idate $yyyymmdd
	dateval=$(( ($(date --date="$thisdate" +%s) - $(date --date="$basedate" +%s) )/(60*60*24) ))
	if [ $(find e4ftl01.cr.usgs.gov/MOLT/MOD13C1.061/${yyyymmdd}/*.nc | wc -l) -ne 1 ] ; then
	    echo "Problem with date $yyyymmdd - skipping..."
	    continue
	fi
	ncfile=$(ls e4ftl01.cr.usgs.gov/MOLT/MOD13C1.061/${yyyymmdd}/*.nc)
	## rename the data variable
        ncrename -O -v Band1,EVI $ncfile $ncfile
	## update attributes
	ncatted -O -a long_name,EVI,m,c,EVI -a longname,EVI,c,c,"Daily Enhanced vegetation index at surface" -a valid_range,EVI,c,s,'0,10000'  -a add_offset,EVI,c,f,0. $ncfile $ncfile
	## add a record dimension to the data variable
	ncap2 -O -s "defdim(\"date\",1);date[date]=${dateval}.0;date@long_name=\"date\";date@units=\"days since $basedate\";" $ncfile $ncfile
	ncwa -O -a date $ncfile $ncfile
	ncecat -O -u date $ncfile $ncfile
	ncks -O --mk_rec date $ncfile $ncfile
    done
done


######################### forest cover

mkdir -p $FCDIR
cd $FCDIR

## https://www.agriculture.gov.au/abares/forestsaustralia/forest-data-maps-and-tools/spatial-data/forest-cover
wget https://www.agriculture.gov.au/sites/default/files/documents/aus_for18_geotiff.zip

######################### Rain 

## http://www.bom.gov.au/jsp/awap/rain/index.jsp
http://www.bom.gov.au/web03/ncc/www/awap/rainfall/totals/daily/grid/0.05/history/nat/2023061520230615.grid.Z?1687131883141

## recalibrated (http://www.bom.gov.au/jsp/awap/rain/archive_recal.jsp)
http://www.bom.gov.au/web03/ncc/www/awap/rainfall/totals/daily//grid/0.05/history/nat_recal/2023051020230510.grid.Z


######################## hotspot data

mkdir -p $hotspotDIR
cd $hotspotDIR

## https://hotspots.dea.ga.gov.au/files/historic

wget https://ga-sentinel.s3-ap-southeast-2.amazonaws.com/historic/ahiwfabba-all-csv.zip
wget https://ga-sentinel.s3-ap-southeast-2.amazonaws.com/historic/all-data-csv.zip
wget https://ga-sentinel.s3-ap-southeast-2.amazonaws.com/historic/avhrr-ga-all-csv.zip

# ahiwfabba-all-csv.zip -> WFABBA.csv
# all-data-csv.zip -> hotspot_historic.csv
# avhrr-ga-all-csv.zip -> GA.csv

## extract the csv files
\ls -1 *.zip | xargs -I@ unzip @

## gzip the text-formatted contents
gzip *.csv

## rename to match the original filenames
mv WFABBA.csv.gz ahiwfabba-all.csv.gz
mv hotspot_historic.csv.gz all-data.csv.gz
mv GA.csv.gz avhrr-ga-all.csv.gz

## clean up
rm *.zip

########################## Climate: rain, temp, vapor-pressure, evap, solar-rad, rel-hum, evapotransp, mslp
## https://www.longpaddock.qld.gov.au/silo/about/climate-variables/
## https://www.longpaddock.qld.gov.au/silo/gridded-data/
## https://s3-ap-southeast-2.amazonaws.com/silo-open-data/Official/annual/index.html


######################## gridded population data

## https://www.abs.gov.au/statistics/people/population/regional-population/latest-release#data-downloads

mkdir -p ${population_gridDIR}
cd ${population_gridDIR}

wget https://www.abs.gov.au/statistics/people/population/regional-population/2021-22/Australian_Population_Grid_2022_in_GEOTIFF_format.zip

unzip Australian_Population_Grid_2022_in_GEOTIFF_format.zip
rm *.zip

####################### Climate classification

mkdir -p ${climate_classificationDIR}
cd ${climate_classificationDIR}

## http://www.bom.gov.au/climate/maps/averages/climate-classification/
wget http://www.bom.gov.au/web01/ncc/www/climatology/climate-classification/tmp_zones.zip
wget http://www.bom.gov.au/web01/ncc/www/climatology/climate-classification/kpngrp.zip
wget http://www.bom.gov.au/web01/ncc/www/climatology/climate-classification/kpn.zip
wget http://www.bom.gov.au/web01/ncc/www/climatology/climate-classification/seasgrpb.zip
wget http://www.bom.gov.au/web01/ncc/www/climatology/climate-classification/seasb.zip

module load gdal
module load nco

## unzip and rename the data files
unzip kpngrp.zip kpngrp.txt
unzip kpn.zip kpnall.txt
mv kpnall.txt kpn.txt
unzip seasb.zip seasrain.txt
mv seasrain.txt seasb.txt
unzip seasgrpb.zip seasrain.txt
mv seasrain.txt seasgrpb.txt
unzip tmp_zones.zip clim-zones.txt
mv clim-zones.txt tmp_zones.txt
## convert to netcdf, then compress
\ls -1 *txt | cut -d. -f1 | xargs -I@ bash -c "gdal_translate -of netCDF @.txt @.nc ; ncks -4 -L4 -O @.nc @.nc "

## clean up
rm *.txt

## extract the README files and rename them
\ls -1 *.zip | cut -d. -f1 | xargs -I@ bash -c "unzip @.zip readme.txt ; mv -v readme.txt readme_@.txt"



####################### state boundaries

mkdir -p $boundariesDIR
cd $boundariesDIR

## https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/access-and-downloads/digital-boundary-files

wget https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/access-and-downloads/digital-boundary-files/STE_2021_AUST_SHP_GDA2020.zip

unzip *.zip 
rm *.zip

########################## road network

mkdir -p $roadsDIR
cd $roadsDIR


## https://data.aurin.org.au/dataset/osm-osm-roads-2020-na
## https://adp-access.aurin.org.au/dataset/osm-osm-roads-2020-na

########################## weather (national - prepared on NCI)

mkdir -p $weatherDIR
cd $weatherDIR

## Australian Gridded Climate Data (AGCD) v1.0.0/ Australian Water Availability Project (AWAP)
## daily
## https://geonetwork.nci.org.au/geonetwork/srv/eng/catalog.search#/metadata/f6475_9317_5747_6204

## ERA5
## 


########################## fire history

mkdir -p ${fire_historyDIR}
cd ${fire_historyDIR}

## NSW fire history
## https://datasets.seed.nsw.gov.au/dataset/fire-history-wildfires-and-prescribed-burns-1e8b6
wget https://datasets.seed.nsw.gov.au/dataset/1d05e145-80cb-4275-af9b-327a1536798d/resource/49075b91-8bcc-46e0-9cd9-2204aa61aeab/download/fire_npwsfirehistory.zip -> NSW_fire_npwsfirehistory.zip

## SA fire history
## https://data.sa.gov.au/data/dataset/fire-history
wget https://www.waterconnect.sa.gov.au/Content/Downloads/DEWNR/FIREMGT_FireHistory_shp.zip -> SA_FIREMGT_FireHistory_shp.zip

## Vic fire history
## https://discover.data.vic.gov.au/dataset/fire-history-records-of-fires-across-victoria1 -> VIC_fire-history-records-of-fires.zip
## https://discover.data.vic.gov.au/dataset/fire-history-showing-the-number-of-times-areas-have-been-burnt-based-on-mapped-fire-history-sca2 -> VIC_fire-history-showing-the-number-of-times-areas-have-been-burnt.zip
## https://discover.data.vic.gov.au/dataset/aggregated-fire-severity-classes-from-1998-onward1 -> VIC_aggregated-fire-severity-classes-from-1998-onward1.zip
## accessed through https://datashare.maps.vic.gov.au/
## terms of use: https://datashare.maps.vic.gov.au/terms-of-use
