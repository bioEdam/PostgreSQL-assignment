-- clear all tables
DELETE FROM artefact_exhibition;
DELETE FROM artefact_category;
DELETE FROM loans;
DELETE FROM checks;
DELETE FROM artefacts_history;
DELETE FROM artefacts;
DELETE FROM exhibitions;
DELETE FROM categories;
DELETE FROM zones;
DELETE FROM institutes;

INSERT INTO categories (name, description)
VALUES
('Painting', 'All types of paintings'),
('Sculpture', 'Various forms of sculptures'),
('Rare Books', 'Collectible and antique books');

INSERT INTO artefacts (name, description, ownership, state)
VALUES
('Mona Lisa', 'A portrait by Leonardo da Vinci', 'our', 'in_exhibition'),
('David', 'Sculpture by Michelangelo', 'our', 'in_storage'),
('First Folio', 'Collection of Shakespeare plays', 'loaned', 'in_storage'),
('Hichhiker s Guide to the Galaxy', 'A great book by Douglas Adams', 'our', 'in_storage');

INSERT INTO zones (name, code, capacity)
VALUES
('Main Hall', 'MH001', 1),
('Storage Room 1', 'SR001', 100),
('Special Exhibitions Hall', 'SEH001', 30);


-- failed check_overlap
INSERT INTO artefact_exhibition (artefact_id, exhibition_id)
VALUES
((SELECT id FROM artefacts WHERE name = 'David'), (SELECT id FROM exhibitions WHERE title = 'Impressionist Treasures'));

INSERT INTO artefact_category (artefact_id, category_id)
VALUES
((SELECT id FROM artefacts WHERE name = 'Mona Lisa'), (SELECT id FROM categories WHERE name = 'Painting')),
((SELECT id FROM artefacts WHERE name = 'David'), (SELECT id FROM categories WHERE name = 'Sculpture')),
((SELECT id FROM artefacts WHERE name = 'First Folio'), (SELECT id FROM categories WHERE name = 'Rare Books'));

INSERT INTO institutes (name, country, region, town, street_address, postal_code, institute_type)
VALUES
('Louvre Museum', 'France', 'Ile-de-France', 'Paris', 'Rue de Rivoli', '75001', 'museum'),
('British Library', 'United Kingdom', 'England', 'London', '96 Euston Road', 'NW1 2DB', 'library');

INSERT INTO loans (artefact_id, loaned_from, start_date, end_date)
VALUES
((SELECT id FROM artefacts WHERE name = 'First Folio'),
(SELECT id FROM institutes WHERE name = 'British Library'),
'2023-01-01', '2023-12-31');

INSERT INTO checks (artefact_id, results, duration, check_time)
VALUES
((SELECT id FROM artefacts WHERE name = 'Mona Lisa'), 'Good condition', INTERVAL '15 minutes', '2023-04-05 10:00:00');

UPDATE checks
SET results = 'Needs restoration'
WHERE artefact_id = (SELECT id FROM artefacts WHERE name = 'Mona Lisa');

UPDATE artefacts
SET zone_id = (SELECT id FROM zones WHERE name = 'Main Hall')
WHERE name = 'Mona Lisa';

-- error for zones capacity
UPDATE artefacts
SET zone_id = (SELECT id FROM zones WHERE name = 'Main Hall')
WHERE name = 'David';

