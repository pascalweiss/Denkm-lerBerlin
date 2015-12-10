--- Integrates full text search into the monument database

CREATE VIRTUAL TABLE monument_search
USING fts4( id,
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