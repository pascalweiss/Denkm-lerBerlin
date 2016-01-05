--- Integrates full text search into the monument database

DROP TABLE monument_search;

CREATE VIRTUAL TABLE monument_search
USING fts3( id,
name,
obj_nr,
descr,
type_id,
super_monument_id,
link_id,
dating_id
);

INSERT INTO monument_search
SELECT  id,
name,
obj_nr,
descr,
type_id,
super_monument_id,
link_id,
dating_id
FROM monument;
