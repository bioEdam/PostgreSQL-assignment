-- wrong dates
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

-- artefact will be already exhibited at that time
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