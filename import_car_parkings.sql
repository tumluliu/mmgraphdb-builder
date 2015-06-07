DROP TABLE IF EXISTS car_parkings;

CREATE TABLE car_parkings(
    osm_id bigint,
    name text,
    lon float,
    lat float
);

\COPY car_parkings (osm_id, name, lon, lat) FROM './csv/car_parkings.csv' WITH CSV HEADER;

SELECT AddGeometryColumn('public', 'car_parkings', 'geom', 4326, 'POINT', 2);

UPDATE car_parkings SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);

CREATE INDEX car_parking_geom ON car_parkings USING GIST (geom);

CREATE INDEX osm_id_idx ON car_parkings USING btree (osm_id);
