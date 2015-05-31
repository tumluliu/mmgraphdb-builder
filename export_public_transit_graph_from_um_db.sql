\copy (select length,speed_factor,mode_id,from_id,to_id,edge_id, null as osm_id from edges where mode_id != 1001 and mode_id != 1002) to 'public_transit_edges.csv' with csv header;
\copy (select out_degree as outdegree,vertex_id,null as osm_id,mode_id,x as lon,y as lat from vertices where mode_id != 1001 and mode_id != 1002) to 'public_transit_vertices.csv' with csv header;
