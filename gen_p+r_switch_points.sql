--for P+R lots
--from car to s-bahn
ALTER TABLE switch_points DROP CONSTRAINT switch_points_pkey;
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, g1.vertex_id, g2.vertex_id, 11, 14, 93, 5, 't', g1.poi_id FROM
(SELECT vertex_id, poi_id, nn_gid from vertices INNER JOIN (SELECT c.poi_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=11)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM park_and_rides) c) AS foo1 ON raw_point_id=nn_gid AND mode_id=11) AS g1,
(SELECT vertex_id, poi_id, nn_gid from vertices INNER JOIN (SELECT c.poi_id, (pgis_fn_nn(c.geom, 0.003, 1, 10, '(SELECT * FROM suburban_junctions INNER JOIN vertices ON suburban_junctions.nodeid=vertices.raw_point_id WHERE vertices.mode_id=14)', 'true', 'nodeid', 'geom')).* FROM (SELECT * FROM park_and_rides) c) AS foo2 ON raw_point_id=nn_gid AND mode_id=14) AS g2
WHERE g1.poi_id=g2.poi_id;
UPDATE switch_points SET switch_point_id=(93 || id::text)::bigint WHERE switch_point_id=0;
ALTER TABLE switch_points ADD CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id);

--for P+R lots
--from car to u-bahn
ALTER TABLE switch_points DROP CONSTRAINT switch_points_pkey;
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, g1.vertex_id, g2.vertex_id, 11, 13, 93, 5, 't', g1.poi_id FROM
(SELECT vertex_id, poi_id, nn_gid from vertices INNER JOIN (SELECT c.poi_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=11)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM park_and_rides) c) AS foo1 ON raw_point_id=nn_gid AND mode_id=11) AS g1,
(SELECT vertex_id, poi_id, nn_gid from vertices INNER JOIN (SELECT c.poi_id, (pgis_fn_nn(c.geom, 0.003, 1, 10, '(SELECT * FROM underground_junctions INNER JOIN vertices ON underground_junctions.nodeid=vertices.raw_point_id WHERE vertices.mode_id=13)', 'true', 'nodeid', 'geom')).* FROM (SELECT * FROM park_and_rides) c) AS foo2 ON raw_point_id=nn_gid AND mode_id=13) AS g2
WHERE g1.poi_id=g2.poi_id;
UPDATE switch_points SET switch_point_id=(93 || id::text)::bigint WHERE switch_point_id=0;
ALTER TABLE switch_points ADD CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id);

