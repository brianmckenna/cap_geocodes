#!/bin/bash
cd "$(dirname "$0")"

apt-get update && apt-get install -y jq

DATE=`date +"%Y%m%d%H%M"`

for x in $(jq -c -r '.[] | @base64' shapefiles.json); do

  # create associative array key=value
  declare -A obj
  while IFS="=" read -r k v
  do
    obj[$k]="$v"
  done < <(echo ${x} | base64 --decode | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]')

  SHP_URL=${obj[shp]}
  FILENAME=`basename $SHP_URL`
  FILENAME="${FILENAME%.*}" # strip extension

  if test ! -f "$FILENAME.sql"; then

    # download Shapefile
    echo -e "\t>> downloading $SHP_URL"
    curl -O -s $SHP_URL >/dev/null

    # unzip shapefile
    echo -e "\t>> extracting $FILENAME.zip"
    unzip $FILENAME.zip >/dev/null

    # GDAL SHP -> PGDump
    echo -e "\t>> converting $FILENAME.shp to $FILENAME.sql"
    # https://gdal.org/drivers/vector/pgdump.html
    ogr2ogr -progress -f PGDump -s_srs crs:84 -t_srs crs:84 $FILENAME.sql $FILENAME.shp -lco SRID=4326 -nlt PROMOTE_TO_MULTI

  fi

  # SQL commands to load data
  SQL=${obj[sql]}
  echo -e "\t>> writing to SQL load script (geocodes.$DATE.sql)"
  echo "\i $FILENAME.sql" >> geocodes.$DATE.sql
  echo "INSERT INTO geocodes (wkb_geometry, country, valuename, value, name, source) SELECT $SQL, $FILENAME FROM $FILENAME;" >> geocodes.$DATE.sql
  echo "DROP TABLE IF EXISTS $FILENAME CASCADE;" >> geocodes.$DATE.sql

  # cleanup
  rm -f "$FILENAME.dbf" "$FILENAME.prj" "$FILENAME.shp" "$FILENAME.shx" "$FILENAME.zip"

done
