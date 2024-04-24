-- wrong dates (correct_date_order.sql)
DO $$
DECLARE
    v_artefact_ids UUID[];
    v_zone_ids UUID[];
BEGIN
    SELECT ARRAY_AGG(id) INTO v_artefact_ids
    FROM artefacts
    WHERE name IN ('Hitchhikers Guide to the Galaxy');

    SELECT ARRAY_AGG(id) INTO v_zone_ids
    FROM zones
    WHERE name IN ('Main Hall');

                                                                -- dates are reversed
    CALL create_exhibition('The Great Exhibition'::VARCHAR(255), '2025-11-01'::DATE, '2025-10-15'::DATE, 'This assignment is fun'::TEXT,
                           v_artefact_ids, v_zone_ids);
END $$;

-- artefact will be already exhibited at that time (artefact_exclusivity.sql)
DO $$
DECLARE
    v_artefact_ids UUID[];
    v_zone_ids UUID[];
BEGIN
    SELECT ARRAY_AGG(id) INTO v_artefact_ids
    FROM artefacts
    WHERE name IN ('Mona Lisa');

    SELECT ARRAY_AGG(id) INTO v_zone_ids
    FROM zones
    WHERE name IN ('Main Hall');


    CALL create_exhibition('Da Vinki?'::VARCHAR(255), '2024-06-01'::DATE, '2024-9-15'::DATE, 'This should give an error'::TEXT,
                           v_artefact_ids, v_zone_ids);
END $$;

-- zone is already occupied (zone_exclusivity.sql)
DO $$
DECLARE
    v_artefact_ids UUID[];
    v_zone_ids UUID[];
BEGIN
    SELECT ARRAY_AGG(id) INTO v_artefact_ids
    FROM artefacts
    WHERE name IN ('Hitchhikers Guide to the Galaxy');

    SELECT ARRAY_AGG(id) INTO v_zone_ids
    FROM zones
    WHERE name IN ('Main Hall');

    CALL create_exhibition('Arthurove dobrodruzstva'::VARCHAR(255), '2024-05-01'::DATE, '2024-09-10'::DATE, 'This should give an error'::TEXT,
                           v_artefact_ids, v_zone_ids);
END $$;

-- the loaned artefact will no longer be available (create_exhibition.sql)
DO $$
DECLARE
    v_artefact_ids UUID[];
    v_zone_ids UUID[];
BEGIN
    SELECT ARRAY_AGG(id) INTO v_artefact_ids
    FROM artefacts
    WHERE name IN ('First Folio', 'Mona Lisa');

    SELECT ARRAY_AGG(id) INTO v_zone_ids
    FROM zones
    WHERE name IN ('Main Hall');

    CALL create_exhibition('Da Vinki?'::VARCHAR(255), '2026-06-01'::DATE, '2027-09-15'::DATE, 'This should give an error'::TEXT,
                           v_artefact_ids, v_zone_ids);
END $$;

-- our artefact will be loaned
DO $$
DECLARE
    v_artefact_ids UUID[];
    v_zone_ids UUID[];
BEGIN
    SELECT ARRAY_AGG(id) INTO v_artefact_ids
    FROM artefacts
    WHERE name IN ('The Hound of the Baskervilles');

    SELECT ARRAY_AGG(id) INTO v_zone_ids
    FROM zones
    WHERE name IN ('Main Hall');

    CALL create_exhibition('Da Vinki?'::VARCHAR(255), '2026-06-01'::DATE, '2026-09-15'::DATE, 'This should give an error'::TEXT,
                           v_artefact_ids, v_zone_ids);
END $$;