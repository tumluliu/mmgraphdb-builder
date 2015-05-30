-- Table: modes

DROP TABLE IF EXISTS modes;

CREATE TABLE modes
(
    mode_name character varying(255),
    mode_id integer NOT NULL,
    CONSTRAINT modes_pkey PRIMARY KEY (mode_id)
)
WITH (
    OIDS=FALSE
);

-- Table: switch_types

DROP TABLE IF EXISTS switch_types;

CREATE TABLE switch_types
(
    type_name character varying(255),
    type_id integer NOT NULL,
    CONSTRAINT switch_types_pkey PRIMARY KEY (type_id)
)
WITH (
    OIDS=FALSE
);

-- Table: edges

DROP TABLE IF EXISTS edges;

CREATE TABLE edges
(
    id serial NOT NULL,
    length double precision,
    speed_factor double precision,
    mode_id integer NOT NULL,
    from_id bigint NOT NULL,
    to_id bigint NOT NULL,
    edge_id bigint NOT NULL,
    raw_link_id bigint,
    CONSTRAINT edges_pkey PRIMARY KEY (edge_id)
)
WITH (
    OIDS=FALSE
);

-- Index: edge_id_idx

DROP INDEX IF EXISTS edge_id_idx;

CREATE INDEX edge_id_idx
ON edges
USING btree
(edge_id);

-- Index: edge_mode_idx

DROP INDEX IF EXISTS edge_mode_idx;

CREATE INDEX edge_mode_idx
ON edges
USING btree
(mode_id);
ALTER TABLE edges CLUSTER ON edge_mode_idx;

-- Index: from_idx

DROP INDEX IF EXISTS from_idx;

CREATE INDEX from_idx
ON edges
USING btree
(from_id);

-- Index: to_idx

DROP INDEX IF EXISTS to_idx;

CREATE INDEX to_idx
ON edges
USING btree
(to_id);

-- Table: vertices

DROP TABLE IF EXISTS vertices;

CREATE TABLE vertices
(
    id serial NOT NULL,
    out_degree integer,
    vertex_id bigint NOT NULL,
    raw_point_id bigint,
    mode_id integer NOT NULL,
    lon double precision,
    lat double precision,
    CONSTRAINT vertices_pkey PRIMARY KEY (vertex_id)
)
WITH (
    OIDS=FALSE
);

-- Index: vertex_id_idx

DROP INDEX IF EXISTS vertex_id_idx;

CREATE UNIQUE INDEX vertex_id_idx
ON vertices
USING btree
(vertex_id);

-- Index: vertex_mode_idx

DROP INDEX IF EXISTS vertex_mode_idx;

CREATE INDEX vertex_mode_idx
ON vertices
USING btree
(mode_id);
ALTER TABLE vertices CLUSTER ON vertex_mode_idx;

-- Table: switch_points

DROP TABLE IF EXISTS switch_points;

CREATE TABLE switch_points
(
    id serial NOT NULL,
    cost double precision,
    is_available boolean,
    from_mode_id integer NOT NULL,
    to_mode_id integer NOT NULL,
    type_id integer NOT NULL,
    from_vertex_id bigint NOT NULL,
    to_vertex_id bigint NOT NULL,
    switch_point_id bigint NOT NULL,
    ref_poi_id bigint,
    CONSTRAINT switch_points_pkey PRIMARY KEY (switch_point_id)
)
WITH (
    OIDS=FALSE
);

-- Index: mode_id_pair_idx

DROP INDEX IF EXISTS mode_id_pair_idx;

CREATE INDEX mode_id_pair_idx
ON switch_points
USING btree
(from_mode_id, to_mode_id);
ALTER TABLE switch_points CLUSTER ON mode_id_pair_idx;

-- Index: type_id_idx

DROP INDEX IF EXISTS type_id_idx;

CREATE INDEX type_id_idx
ON switch_points
USING btree
(type_id);
