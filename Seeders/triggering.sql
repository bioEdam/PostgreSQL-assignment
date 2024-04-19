-- check_zone_capacity

UPDATE artefacts
SET zone_id = (SELECT id FROM zones WHERE name = 'Main Hall')
WHERE zone_id IS NULL;

