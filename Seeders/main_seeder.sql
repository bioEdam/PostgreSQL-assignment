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
('Hitchhikers Guide to the Galaxy', 'A great book by Douglas Adams', 'our', 'in_storage'),
('The Hound of the Baskervilles', 'A classic Sherlock Holmes novel', 'our', 'in_storage');

INSERT INTO zones (name, code, capacity)
VALUES
('Main Hall', 'MH001', 1),
('Storage Room 1', 'SR001', 100),
('Back Rooms', 'SEH001', 30);

INSERT INTO artefact_category (artefact_id, category_id)
VALUES
((SELECT id FROM artefacts WHERE name = 'Mona Lisa'), (SELECT id FROM categories WHERE name = 'Painting')),
((SELECT id FROM artefacts WHERE name = 'David'), (SELECT id FROM categories WHERE name = 'Sculpture')),
((SELECT id FROM artefacts WHERE name = 'Hitchhikers Guide to the Galaxy'), (SELECT id FROM categories WHERE name = 'Rare Books')),
((SELECT id FROM artefacts WHERE name = 'The Hound of the Baskervilles'), (SELECT id FROM categories WHERE name = 'Rare Books'));

INSERT INTO institutes (name, country, region, town, street_address, postal_code, institute_type)
VALUES
('Louvre Museum', 'France', 'Ile-de-France', 'Paris', 'Rue de Rivoli', '75001', 'museum'),
('British Library', 'United Kingdom', 'England', 'London', '96 Euston Road', 'NW1 2DB', 'library');


-- p_artefact_name VARCHAR(255),
-- p_artefact_description TEXT,
-- p_institute_id UUID,
-- p_expected_arrival_date TIMESTAMP WITH TIME ZONE,
-- p_start_date DATE,
-- p_end_date DATE
DO $$
    DECLARE
        v_institute_id UUID;
    BEGIN
        SELECT id INTO v_institute_id FROM institutes WHERE name = 'British Library';
        CALL loan_foreign_artefact('First Folio', 'Collection of Shakespeare plays'::TEXT,
                                   v_institute_id, '2023-01-01 10:00:00', '2023-01-01', '2026-12-31');
    END
$$;

DO $$
    DECLARE
        v_institute_id UUID;
        v_artefact_id UUID;
    BEGIN
        -- use of loan_our_artefact function
        SELECT id INTO v_institute_id FROM institutes WHERE name = 'British Library';
        SELECT id INTO v_artefact_id FROM artefacts WHERE name = 'The Hound of the Baskervilles';
        CALL loan_our_artefact(v_artefact_id, v_institute_id, '2026-1-15', '2025-12-31', '2026-12-31');
    END;
    $$;

-- set category for First Folio
INSERT INTO artefact_category (artefact_id, category_id)
VALUES
((SELECT id FROM artefacts WHERE name = 'First Folio'), (SELECT id FROM categories WHERE name = 'Rare Books'));

INSERT INTO checks (artefact_id, results, duration, check_time)
VALUES
((SELECT id FROM artefacts WHERE name = 'Mona Lisa'), 'Good condition', INTERVAL '15 minutes', '2023-04-05 10:00:00');

-- update zone for Mona Lisa
UPDATE artefacts
SET zone_id = (SELECT id FROM zones WHERE name = 'Main Hall')
WHERE name = 'Mona Lisa';

-- create exhibition
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

    CALL create_exhibition('The Great Exhibition'::VARCHAR(255), '2024-04-1'::DATE, '2024-10-15'::DATE, 'This assignment is fun'::TEXT, v_artefact_ids, v_zone_ids);
END $$;

-- create exhibition in da future
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
    WHERE name IN ('Back Rooms');

    CALL create_exhibition('The Future Exhibition'::VARCHAR(255), '2027-03-01'::DATE, '2028-10-15'::DATE, 'Actually good stuff'::TEXT, v_artefact_ids, v_zone_ids);
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

-- use of artefact_arrival function
SELECT * FROM artefact_arrival((SELECT id FROM artefacts where name = ('First Folio')));

-- do check_zone function for all artefacts
SELECT name, check_artefact_zone(id) FROM artefacts;

-- do get_correct_artefacts_zones function for all artefacts
SELECT artefacts.name, get_correct_artefacts_zones(artefacts.id), zones.name as curr_zones_name, check_artefact_zone(artefacts.id) FROM artefacts
LEFT JOIN zones ON artefacts.zone_id = zones.id;