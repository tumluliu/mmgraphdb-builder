ALTER TABLE "osm_line" ADD COLUMN "gid" INTEGER;
CREATE SEQUENCE "osm_line_gid_seq";
UPDATE osm_line SET gid = nextval('"osm_line_gid_seq"');
ALTER TABLE "osm_line"
  ALTER COLUMN "gid" SET DEFAULT nextval('"osm_line_gid_seq"');
ALTER TABLE "osm_line"
  ALTER COLUMN "gid" SET NOT NULL;
ALTER TABLE "osm_line" ADD UNIQUE ("gid");
ALTER TABLE "osm_line" ADD PRIMARY KEY ("gid");
 
ALTER TABLE "osm_point" ADD COLUMN "gid" INTEGER;
CREATE SEQUENCE "osm_point_gid_seq";
UPDATE osm_point SET gid = nextval('"osm_point_gid_seq"');
ALTER TABLE "osm_point"
  ALTER COLUMN "gid" SET DEFAULT nextval('"osm_point_gid_seq"');
ALTER TABLE "osm_point"
  ALTER COLUMN "gid" SET NOT NULL;
ALTER TABLE "osm_point" ADD UNIQUE ("gid");
ALTER TABLE "osm_point" ADD PRIMARY KEY ("gid");
 
ALTER TABLE "osm_polygon" ADD COLUMN "gid" INTEGER;
CREATE SEQUENCE "osm_polygon_gid_seq";
UPDATE osm_polygon SET gid = nextval('"osm_polygon_gid_seq"');
ALTER TABLE "osm_polygon"
  ALTER COLUMN "gid" SET DEFAULT nextval('"osm_polygon_gid_seq"');
ALTER TABLE "osm_polygon"
  ALTER COLUMN "gid" SET NOT NULL;
ALTER TABLE "osm_polygon" ADD UNIQUE ("gid");
ALTER TABLE "osm_polygon" ADD PRIMARY KEY ("gid");
