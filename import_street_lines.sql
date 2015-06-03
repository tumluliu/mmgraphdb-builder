DROP TABLE IF EXISTS street_lines;

CREATE TABLE street_lines(
    link_id bigint,
    osm_id bigint,
    from_node bigint,
    to_node bigint,
    geojson text
);

-- The & sign in QUOTE argument here is to use a symbol does not appear in file
-- to ensure the double-quotes can be correctly imported in database fields
\COPY street_lines (link_id, osm_id, from_node, to_node, geojson) FROM './csv/street_lines.csv' WITH CSV HEADER DELIMITER ';' QUOTE '&';

SELECT AddGeometryColumn('public', 'street_lines', 'geom', 4326, 'LINESTRING', 2);

UPDATE street_lines SET geom = ST_SetSRID(ST_GeomFromGeoJSON(geojson), 4326);

CREATE INDEX street_lines_geom ON street_lines USING GIST (geom);

CREATE INDEX link_id_idx ON street_lines USING btree (link_id);
