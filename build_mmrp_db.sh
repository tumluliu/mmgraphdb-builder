#!/bin/bash

db_name=$1
db_user=$2
osm_data_file=$3

echo "============ Multimodal graph builder ============"
echo "======== Step 1 of 10: Cleanup environment... ========"
mkdir -p tmp
mkdir -p bak
rm csv/vertices.csv
rm csv/edges.csv
rm csv/car_parkings.csv
echo "======== done! ========"
# backup old database if it exists, or create a new one if not
echo "======== Step 2 of 10: Preparing database... ========"
if psql -lqt | cut -d \| -f 1 | grep -w $db_name; then
    # database exists
    pg_dump -h localhost -p 5432 -U $db_user -Fc -b -v -f "./bak/old_$db_name.backup" $db_name
else
    # ruh-roh
    createdb -O $db_user $db_name
    psql -d $db_name -U $db_user -c "CREATE EXTENSION postgis;"
fi
echo "======== done! ========"
# create initial multimodal graph tables including
# modes, switch_types, edges, vertices and switch_points, populate initial data in 
# modes and switch_types
echo "======== Step 3 of 10: Preparing multimodal graph tables in database ========"
psql -d $db_name -U $db_user -f prepare_graph_tables.sql
echo "==== Import modes data... ===="
psql -d $db_name -U $db_user -c "\COPY modes (mode_name,mode_id) FROM './csv/modes.csv' WITH CSV HEADER"
echo "==== done! ===="
echo "==== Import switch_types data... ===="
psql -d $db_name -U $db_user -c "\COPY switch_types (type_name,type_id) FROM './csv/switch_types.csv' WITH CSV HEADER"
echo "==== done! ===="
# import shapefiles with overriding the old geometry tables
echo "======== Step 4 of 10: Import OpenStreetMap data... ========"
osm2pgsql -s -l -c -d $db_name -p osm -U $db_user $osm_data_file
psql -d $db_name -U $db_user -f add_primary_key_to_osm_tables.sql
echo "======== done! ========"
echo "======== Step 5 of 10: Import UnitedMaps public transport and utilities data... ========"
for shp_file in ./shp/*.shp
do
    echo "==== Importing $shp_file... ===="
    shp2pgsql -d -s 4326 -W latin1 $shp_file | psql -h localhost -d $db_name -U $db_user 
    echo "==== done! ===="
done
echo "======== done! ========"
# generate multimodal graph edges and vertices in csv files
echo "======== Step 6 of 10: Build multimodal graph data in csv files... ========"
python build_mmgraph.py $osm_data_file
tail -n +2 ./csv/public_transit_vertices.csv >> ./csv/vertices.csv
tail -n +2 ./csv/public_transit_edges.csv >> ./csv/edges.csv
echo "======== done! ========"
echo "======== Step 7 of 10: Import multimodal graph data from csv files to database... ========"
psql -c "TRUNCATE vertices, edges;" -d $db_name -U $db_user
psql -c "\COPY vertices (out_degree,vertex_id,raw_point_id,mode_id,lon,lat) FROM './csv/vertices.csv' WITH CSV HEADER;" -d $db_name -U $db_user
psql -c "\COPY edges (length,speed_factor,mode_id,from_id,to_id,edge_id,raw_link_id) FROM './csv/edges.csv' WITH CSV HEADER;" -d $db_name -U $db_user
psql -d $db_name -U $db_user -f import_street_junctions.sql
echo "======== done! ========"
#echo "======== Import initial switch points of car_parking type... ========"
#psql -c "\COPY switch_points (cost,is_available,from_mode_id,to_mode_id,type_id,from_vertex_id,to_vertex_id,switch_point_id,ref_poi_id) FROM './csv/switch_points_car_parking.csv' WITH CSV HEADER;" -d $db_name -U $db_user
echo "======== Step 8 of 10: Generating switch points in database, could be fairly time consuming, so please be patient... ========"
echo "==== Creating nearest neighbor finding function in database... ===="
psql -d $db_name -U $db_user -f pgis_nn.sql
echo "==== done! ===="
echo "==== Generating switch points around each car parking... ===="
psql -d $db_name -U $db_user -f gen_car-parking_switch_points.sql
echo "==== done! ===="
echo "==== Generating switch points around each possible temp parking position... ===="
psql -d $db_name -U $db_user -f gen_geo-conn_switch_points.sql
echo "==== done! ===="
echo "==== Generating switch points around each P+R... ===="
psql -d $db_name -U $db_user -f gen_p+r_switch_points.sql
echo "==== done! ===="
echo "==== Generating switch points around each K+R... ===="
psql -d $db_name -U $db_user -f gen_k+r_switch_points.sql
echo "==== done! ===="
echo "==== Generating switch points around each suburban station... ===="
psql -d $db_name -U $db_user -f gen_s-bahn-station_switch_points.sql
echo "==== done! ===="
echo "==== Generating switch points around each underground station... ===="
psql -d $db_name -U $db_user -f gen_u-bahn-station_switch_points.sql
echo "==== done! ===="
echo "==== Generating switch points around each tram station... ===="
psql -d $db_name -U $db_user -f gen_tram-station_switch_points.sql
echo "==== done! ===="
# validate generated multimodal graphs
echo "======== Step 9 of : Validating multimodal graph... ========"
psql -d $db_name -U $db_user -f validate_graph.sql
echo "======== done! ========"
# clear temp files
rm tmp/*
# backup this new database
echo "======== Step 10 of 10: Backup the database just built up.. ========"
pg_dump -h localhost -p 5432 -U $db_user -Fc -b -v -f "./bak/new_$db_name.backup" $db_name
echo "======== done! ========"
echo "============ All done! ============"
