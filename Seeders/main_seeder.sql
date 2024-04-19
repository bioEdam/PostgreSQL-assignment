-- clear all tables
DELETE FROM artefact_exhibition;
DELETE FROM exhibition_zone;
DELETE FROM artefact_category;
DELETE FROM loans;
DELETE FROM checks;
DELETE FROM artefacts_history;
DELETE FROM artefacts CASCADE;
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
('Hitchhikers Guide to the Galaxy', 'A great book by Douglas Adams', 'our', 'in_storage');

INSERT INTO zones (name, code, capacity)
VALUES
('Main Hall', 'MH001', 1),
('Storage Room 1', 'SR001', 100),
('Back Rooms', 'SEH001', 30);

INSERT INTO artefact_category (artefact_id, category_id)
VALUES
((SELECT id FROM artefacts WHERE name = 'Mona Lisa'), (SELECT id FROM categories WHERE name = 'Painting')),
((SELECT id FROM artefacts WHERE name = 'David'), (SELECT id FROM categories WHERE name = 'Sculpture')),
((SELECT id FROM artefacts WHERE name = 'First Folio'), (SELECT id FROM categories WHERE name = 'Rare Books')),
((SELECT id FROM artefacts WHERE name = 'Hitchhikers Guide to the Galaxy'), (SELECT id FROM categories WHERE name = 'Rare Books'));

INSERT INTO institutes (name, country, region, town, street_address, postal_code, institute_type)
VALUES
('Louvre Museum', 'France', 'Ile-de-France', 'Paris', 'Rue de Rivoli', '75001', 'museum'),
('British Library', 'United Kingdom', 'England', 'London', '96 Euston Road', 'NW1 2DB', 'library');

INSERT INTO loans (artefact_id, institute_id, start_date, end_date, loan_type)
VALUES
((SELECT id FROM artefacts WHERE name = 'First Folio'),
(SELECT id FROM institutes WHERE name = 'British Library'),
'2023-01-01', '2026-12-31', 'loan_in');
-- rewrite with loan_for_artefact procedure

INSERT INTO checks (artefact_id, results, duration, check_time)
VALUES
((SELECT id FROM artefacts WHERE name = 'Mona Lisa'), 'Good condition', INTERVAL '15 minutes', '2023-04-05 10:00:00');

-- premiestnenie artefaktu do inej zony
UPDATE artefacts
SET zone_id = (SELECT id FROM zones WHERE name = 'Main Hall')
WHERE name = 'Mona Lisa';

DO $$
DECLARE
    v_artefact_ids UUID[];
    v_zone_ids UUID[];
BEGIN
    SELECT ARRAY_AGG(id) INTO v_artefact_ids
    FROM artefacts
    WHERE name IN ('Mona Lisa', 'David');

    SELECT ARRAY_AGG(id) INTO v_zone_ids
    FROM zones
    WHERE name IN ('Main Hall');

    CALL create_exhibition('The Great Exhibition'::VARCHAR(255), '2023-05-01'::DATE, '2024-10-15'::DATE, 'This assignment is fun'::TEXT, v_artefact_ids, v_zone_ids);
END $$;

-- use function update_current_exhibition on all artefacts
DO $$
DECLARE
    v_artefact_id UUID;
BEGIN
    FOR v_artefact_id IN SELECT id FROM artefacts
    LOOP
        CALL update_current_exhibition(v_artefact_id);
    END LOOP;
END $$;
