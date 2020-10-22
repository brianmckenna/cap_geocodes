
CREATE EXTENSION IF NOT EXISTS "postgis";

-- setup table
CREATE TABLE "geocodes" ("gid" SERIAL, CONSTRAINT "geocodes_pk" PRIMARY KEY ("gid") );
ALTER TABLE "geocodes" ADD COLUMN "wkb_geometry" geometry(MULTIPOLYGON, 4326);
--SELECT AddGeometryColumn("geocodes", "wkb_geometry", 0, "MULTIPOLYGON", 2, TRUE);
CREATE INDEX "geocodes_wkb_geometry_geom_idx" ON "geocodes" USING GIST ("wkb_geometry");
ALTER TABLE "geocodes" ADD COLUMN "country" TEXT;
ALTER TABLE "geocodes" ADD COLUMN "valuename" TEXT;
ALTER TABLE "geocodes" ADD COLUMN "value" TEXT;
ALTER TABLE "geocodes" ADD COLUMN "name" TEXT;
ALTER TABLE "geocodes" ADD COLUMN "source" TEXT;
