--for underground stations
--from u-bahn stations to pedestrian network
ALTER TABLE switch_points DROP CONSTRAINT switch_points_pkey;
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, 1300000000+g1.nn_gid, 1200000000+g2.nn_gid, 13, 12, 94, 0, 't', g1.type_id FROM
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM underground_junctions INNER JOIN vertices ON underground_junctions.nodeid=(vertices.vertex_id % 100000000) WHERE vertices.mode_id=13)', 'true', 'nodeid', 'geom')).* FROM (SELECT * FROM underground_stations) c) AS g1,
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM osm_point INNER JOIN vertices ON osm_point.osm_id=vertices.raw_point_id WHERE vertices.mode_id=12)', 'true', 'osm_id', 'way')).* FROM (SELECT * FROM underground_stations) c) AS g2
WHERE g1.type_id=g2.type_id;
--from pedestrian network to u-bahn
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, 1200000000+g1.nn_gid, 1300000000+g2.nn_gid, 12, 13, 94, 5, 't', g1.type_id FROM
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM osm_point INNER JOIN vertices ON osm_point.osm_id=vertices.raw_point_id WHERE vertices.mode_id=12)', 'true', 'osm_id', 'way')).* FROM (SELECT * FROM underground_stations) c) AS g1,
(SELECT c.type_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM underground_junctions INNER JOIN vertices ON underground_junctions.nodeid=(vertices.vertex_id % 100000000) WHERE vertices.mode_id=13)', 'true', 'nodeid', 'geom')).* FROM (SELECT * FROM underground_stations) c) AS g2
WHERE g1.type_id=g2.type_id;
UPDATE switch_points SET switch_point_id=9400000000+id WHERE switch_point_id=0;
ALTER TABLE switch_points ADD CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id);
