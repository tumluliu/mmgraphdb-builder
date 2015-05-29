#!/bin/bash

db_name=$1
db_user=$2
osm_data_file=$3

mkdir -p tmp
mkdir -p bak
rm csv/vertices.csv
rm csv/edges.csv
rm csv/car_parkings.csv
# backup old database if it exists, or create a new one if not
if psql -lqt | cut -d \| -f 1 | grep -w $db_name; then
    # database exists
    pg_dump -h localhost -p 5432 -U $db_user -Fc -b -v -f "./bak/old_$db_name.backup" $db_name
else
    # ruh-roh
    createdb -O $db_user $db_name
    psql -d $db_name -U $db_user -c "CREATE EXTENSION postgis;"
fi
# create initial multimodal graph tables including
# modes, switch_types, edges, vertices and switch_points, populate initial data in 
# modes and switch_types
echo "======== Preparing multimodal graph tables in database ========"
psql -d $db_name -U $db_user -f prepare_graph_tables.sql
echo "======== Import modes data... ========"
psql -d $db_name -U $db_user -c "\COPY modes (mode_name,mode_id) FROM './csv/modes.csv' WITH CSV HEADER"
echo "done!"
echo "======== Import switch_types data... ========"
psql -d $db_name -U $db_user -c "\COPY switch_types (type_name,type_id) FROM './csv/switch_types.csv' WITH CSV HEADER"
echo "done!"
# import shapefiles with overriding the old geometry tables
echo "======== Import OpenStreetMap data... ========"
osm2pgsql -s -l -c -d $db_name -p osm -U $db_user $osm_data_file
echo "done!"
echo "======== Import UnitedMaps public transport and utilities data... ========"
for shp_file in ./shp/*.shp
do
    echo "Importing $shp_file... "
    shp2pgsql -c -s 4326 -W latin1 $shp_file | psql -h localhost -d $db_name -U $db_user 
    echo "done!"
done
echo "done!"
# generate multimodal graph edges and vertices in csv files
echo "======== Build multimodal graph data... ========"
python build_mmgraph.py $osm_data_file
psql -c "TRUNCATE vertices, edges;" -d $db_name -U $db_user
tail -n +2 ./csv/public_transit_vertices.csv >> ./csv/vertices.csv
tail -n +2 ./csv/public_transit_edges.csv >> ./csv/edges.csv
psql -c "\COPY vertices (outdegree,vertex_id,osm_id,mode_id,lon,lat) FROM './csv/vertices.csv' WITH CSV HEADER;" -d $db_name -U $db_user
psql -c "\COPY edges (length,speed_factor,mode_id,from_id,to_id,edge_id,osm_id) FROM './csv/edges.csv' WITH CSV HEADER;" -d $db_name -U $db_user
# import initial switch points of car_parking type
psql -c "\COPY switch_points (cost,is_available,from_mode_id,to_mode_id,type_id,from_vertex_id,to_vertex_id,switch_point_id,ref_poi_id) FROM './csv/switch_points_car_parking.csv' WITH CSV HEADER;" -d $db_name -U $db_user
# generate switch points in database
#psql -d $db_name -U $db_user -f switch_points_generator.sql
# validate generated multimodal graphs
echo "done!"
echo "======== Validating multimodal graph... ========"
psql -d $db_name -U $db_user -f validate_graph.sql
# clear temp files
rm tmp/*
# backup this new database
pg_dump -h localhost -p 5432 -U $db_user -Fc -b -v -f "./bak/new_$db_name.backup" $db_name
