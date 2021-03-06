--for tram stations
--from tram stations to pedestrian network
ALTER TABLE switch_points DROP CONSTRAINT switch_points_pkey;
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, 1500000000 + g1.nn_gid, (12 || g2.nn_gid::text)::bigint, 15, 12, 96, 0, 't', g1.type_id FROM
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM tram_junctions INNER JOIN vertices ON tram_junctions.nodeid=(vertices.vertex_id % 100000000) WHERE vertices.mode_id=15)', 'true', 'nodeid', 'geom')).* FROM (SELECT * FROM tram_stations) c) AS g1,
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=12)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM tram_stations) c) AS g2
WHERE g1.type_id=g2.type_id;
--from pedestrian network to tram
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, (12 || g1.nn_gid::text)::bigint, 1500000000 + g2.nn_gid, 12, 15, 96, 5, 't', g1.type_id FROM
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=12)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM tram_stations) c) AS g1,
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM tram_junctions INNER JOIN vertices ON tram_junctions.nodeid=(vertices.vertex_id % 100000000) WHERE vertices.mode_id=15)', 'true', 'nodeid', 'geom')).* FROM (SELECT * FROM tram_stations) c) AS g2
WHERE g1.type_id=g2.type_id;
UPDATE switch_points SET switch_point_id=(96 || id::text)::bigint WHERE switch_point_id=0;
ALTER TABLE switch_points ADD CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id);
