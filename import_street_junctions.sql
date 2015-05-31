DROP TABLE IF EXISTS street_junctions;

CREATE TABLE street_junctions(
    osm_id bigint,
    lon float,
    lat float
);

\COPY street_junctions (osm_id, lon, lat) FROM './csv/street_junctions.csv' WITH CSV HEADER;

SELECT AddGeometryColumn('public', 'street_junctions', 'geom', 4326, 'POINT', 2);

UPDATE street_junctions SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);

CREATE INDEX street_junctions_geom ON street_junctions USING GIST (geom);

CREATE INDEX osm_id_idx ON street_junctions USING btree (osm_id);
