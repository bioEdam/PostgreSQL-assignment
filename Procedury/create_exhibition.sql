CREATE OR REPLACE PROCEDURE create_exhibition(
    p_exhibition_title VARCHAR(255),
    p_start_date DATE,
    p_end_date DATE,
    p_description TEXT,
    p_artefacts UUID[],
    p_zones UUID[])
LANGUAGE plpgsql
AS $$
DECLARE
    new_exhibition_id UUID;
    artefact_id UUID;
    zone_id UUID;
BEGIN

    -- Create the new exhibition
    INSERT INTO exhibitions (title, start_date, end_date, description)
    VALUES (p_exhibition_title, p_start_date, p_end_date, p_description)
    RETURNING id INTO new_exhibition_id; -- get the new exhibition id

    FOREACH artefact_id IN ARRAY p_artefacts
    LOOP
        -- check_artefact_exhibition_overlap trigger will check for overlapping exhibitions
        INSERT INTO artefact_exhibition (artefact_id, exhibition_id)
        VALUES (artefact_id, new_exhibition_id);
    END LOOP;

    FOREACH zone_id IN ARRAY p_zones
    LOOP
        -- check_zone_exhibition_overlap trigger will check for overlapping exhibitions
        INSERT INTO exhibition_zone (zone_id, exhibition_id)
        VALUES (zone_id, new_exhibition_id);
    END LOOP;

    -- No need for COMMIT DataGrip will automatically commit the transaction
    -- I HOPE THIS WONT BE A MASSIVE PAIN IN THE BUTT
EXCEPTION
    WHEN OTHERS THEN
        -- catch failed overlap and other checks
        ROLLBACK;
        RAISE;
END;
$$;
