--- relation-table drops
DROP TABLE route_rel;
DROP TABLE district_rel;
DROP TABLE sub_district_rel;
DROP TABLE monument_notion_rel;
DROP TABLE participant_rel;


--- entity-table drops
DROP TABLE history;
DROP TABLE route;
DROP TABLE district;
DROP TABLE sub_district;
DROP TABLE monument_notion;
DROP TABLE dating;
DROP TABLE picture;
DROP TABLE participant_type;
DROP TABLE participant;
DROP TABLE address;
DROP TABLE monument;
DROP TABLE type;


--- entity-table creation
CREATE TABLE route (
	id		SERIAL PRIMARY KEY,
	name	VARCHAR(40),
	length	NUMERIC, 
	descr	TEXT 
);
CREATE TABLE type (
	id		SERIAL PRIMARY KEY,
	name	VARCHAR(18)
);
CREATE TABLE district(
	id 		SERIAL PRIMARY KEY,
	name	VARCHAR(30)
);
CREATE TABLE sub_district (
	id 		SERIAL PRIMARY KEY,
	name	VARCHAR(30)
);
CREATE TABLE monument_notion(
	id 		SERIAL PRIMARY KEY,
	name	VARCHAR(50)
);
CREATE TABLE participant_type(
	id 			SERIAL PRIMARY KEY,
	name		VARCHAR(100)
);
CREATE TABLE participant(
	id 			SERIAL PRIMARY KEY,
	name		VARCHAR(100)
);
CREATE TABlE monument (
	id                  SERIAL PRIMARY KEY,
	name                VARCHAR(300),
	obj_nr              VARCHAR(8),
	descr               TEXT,
	type_id             INTEGER REFERENCES type(id),
	super_monument_id	INTEGER REFERENCES monument(id),
	link_id             INTEGER REFERENCES monument(id)
);
CREATE TABLE address(
id              SERIAL PRIMARY KEY,
lat				NUMERIC,
long			NUMERIC,
street			VARCHAR(100),
nr 				VARCHAR(8),
monument_id 	INTEGER REFERENCES monument(id)
);
CREATE TABLE picture(
	id 			SERIAL PRIMARY KEY,
	url			VARCHAR(200),
	monument_id INTEGER REFERENCES monument(id)
);
CREATE TABLE dating(
	id 			SERIAL PRIMARY KEY,
	beginning	DATE,
	ending 		DATE,
	monument_id INTEGER REFERENCES monument(id)
);

--- relation-table creation
CREATE TABLE route_rel(
	id 			SERIAL PRIMARY KEY,
	route_id	INTEGER REFERENCES route(id),
	monument_id	INTEGER REFERENCES monument(id),
	stage		INTEGER
);
CREATE TABLE district_rel(
	id 			SERIAL PRIMARY KEY,
	district_id	INTEGER REFERENCES district(id),	
	monument_id INTEGER REFERENCES monument(id)
);
CREATE TABLE sub_district_rel(
	id 				SERIAL PRIMARY KEY,
	sub_district_id	INTEGER REFERENCES sub_district(id),
	monument_id		INTEGER REFERENCES monument(id)
);
CREATE TABLE monument_notion_rel(
	id 					SERIAL PRIMARY KEY,
	monument_notion_id	INTEGER REFERENCES monument_notion(id),
	monument_id 		INTEGER REFERENCES monument(id)
);
CREATE TABLE participant_rel(
	id 					SERIAL PRIMARY KEY, 
	monument_id 		INTEGER REFERENCES monument(id),
	participant_id		INTEGER REFERENCES participant(id), 
	participant_type_id	INTEGER REFERENCES participant_type(id)
);
CREATE TABLE history(
	search_string		TEXT,
	time_int_since_1970	NUMERIC
);


commit;







