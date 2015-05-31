--for parking places
ALTER TABLE switch_points DROP CONSTRAINT switch_points_pkey;
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, (11 || g1.nn_gid::text)::bigint, (12 || g2.nn_gid::text)::bigint, 11, 12, 91, 3, 't', g1.osm_id FROM
(SELECT c.osm_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=11)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM car_parkings) c) AS g1,
(SELECT c.osm_id, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=12)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM car_parkings) c) AS g2
WHERE g1.osm_id=g2.osm_id;
UPDATE switch_points SET switch_point_id=(91 || id::text)::bigint WHERE switch_point_id=0;
ALTER TABLE switch_points ADD CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id);

