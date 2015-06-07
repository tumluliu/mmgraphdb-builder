--for underground stations
--from u-bahn stations to pedestrian network
ALTER TABLE switch_points DROP CONSTRAINT switch_points_pkey;
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, g1.vertex_id, (12 || g2.nn_gid::text)::bigint, 13, 12, 94, 0, 't', g1.platformid FROM
(SELECT underground_platforms.platformid, vertices.vertex_id FROM vertices JOIN underground_platforms ON (vertices.vertex_id % 10000000::bigint - vertices.vertex_id % 1000000::bigint + vertices.vertex_id % 10000::bigint) = underground_platforms.junctionid AND (vertices.vertex_id % 1000000::bigint / 100000) = underground_platforms.direction AND ('U'::text || ((vertices.vertex_id % 100000000::bigint / 10000000)::text)) = underground_platforms.line_name::text WHERE vertices.mode_id = 13) AS g1,
(SELECT c.platformid, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=12)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM underground_platforms) c) AS g2
WHERE g1.platformid=g2.platformid;
--from pedestrian network to u-bahn
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, (12 || g1.nn_gid::text)::bigint, g2.vertex_id, 12, 13, 94, 5, 't', g1.platformid FROM
(SELECT c.platformid, (pgis_fn_nn(c.geom, 0.002, 1, 10, '(SELECT * FROM street_junctions INNER JOIN vertices ON street_junctions.osm_id=vertices.raw_point_id WHERE vertices.mode_id=12)', 'true', 'osm_id', 'geom')).* FROM (SELECT * FROM underground_platforms) c) AS g1,
(SELECT underground_platforms.platformid, vertices.vertex_id FROM vertices JOIN underground_platforms ON (vertices.vertex_id % 10000000::bigint - vertices.vertex_id % 1000000::bigint + vertices.vertex_id % 10000::bigint) = underground_platforms.junctionid AND (vertices.vertex_id % 1000000::bigint / 100000) = underground_platforms.direction AND ('U'::text || ((vertices.vertex_id % 100000000::bigint / 10000000)::text)) = underground_platforms.line_name::text WHERE vertices.mode_id = 13) AS g2
WHERE g1.platformid=g2.platformid;
UPDATE switch_points SET switch_point_id=(94 || id::text)::bigint WHERE switch_point_id=0;
ALTER TABLE switch_points ADD CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id);
