--- Integrates full text search into the monument database

DROP TABLE monument_search;
DROP TABLE monument_search_content;
DROP TABLE monument_search_segdir;
DROP TABLE monument_search_segments;

DROP TABLE address_search;
DROP TABLE address_search_content;
DROP TABLE address_search__segdir;
DROP TABLE address_search_segments;

DROP TABLE participant_search;
DROP TABLE participant_search_content;
DROP TABLE participant_search__segdir;
DROP TABLE participant_search_segments;

DROP TABLE monument_notion_search;
DROP TABLE monument_notion_search_content;
DROP TABLE monument_notion_search__segdir;
DROP TABLE monument_notion_search_segments;


CREATE VIRTUAL TABLE monument_search
USING fts4( 
	id,
	name,
	obj_nr,
	descr,
	type_id,
	super_monument_id,
	link_id,
	dating_id
);

INSERT INTO monument_search
SELECT  
	id,
	name,
	obj_nr,
	descr,
	type_id,
	super_monument_id,
	link_id,
	dating_id
FROM monument;


CREATE VIRTUAL TABLE address_search
USING fts4( 
	id,
	lat,
	long,
	street,
	nr
);

INSERT INTO address_search
SELECT  
	id,
	lat,
	long,
	street,
	nr
FROM address;

CREATE VIRTUAL TABLE participant_search
USING fts4(
	id,
	name);

INSERT INTO participant_search
SELECT 
	id,
	name
FROM participant;

CREATE VIRTUAL TABLE monument_notion_search
USING fts4(
	id,
	name
);

INSERT INTO monument_notion_search
SELECT
	id,
	name
FROM monument_notion;