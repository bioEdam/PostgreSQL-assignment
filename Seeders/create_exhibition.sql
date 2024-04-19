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
    WHERE name IN ('Back Rooms');

    CALL create_exhibition('The Less Great Exhibition'::VARCHAR(255), '2023-01-01'::DATE, '2026-12-31'::DATE, 'This assignment is fun'::TEXT, v_artefact_ids, v_zone_ids);
END $$;