--for physical connections
ALTER TABLE switch_points DROP CONSTRAINT switch_points_pkey;
INSERT INTO switch_points (switch_point_id, from_vertex_id, to_vertex_id, from_mode_id, to_mode_id, type_id, cost, is_available, ref_poi_id)
SELECT 0, g1.vertex_id, g2.vertex_id, 11, 12, 92, 0.5, 't', NULL FROM
(SELECT raw_point_id, vertex_id FROM vertices WHERE mode_id=11) AS g1,
(SELECT raw_point_id, vertex_id FROM vertices WHERE mode_id=12) AS g2
WHERE g1.raw_point_id=g2.raw_point_id;
UPDATE switch_points SET switch_point_id=9200000000+id WHERE switch_point_id=0;
ALTER TABLE switch_points ADD CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id);

