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
    p_artefact_id UUID;
    p_zone_id UUID;
BEGIN
     -- check if the artefacts and zones exist
    IF NOT EXISTS (
        SELECT 1
        FROM artefacts
        WHERE id = ANY(p_artefacts)
    ) THEN
        RAISE EXCEPTION 'Artefact does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM zones
        WHERE id = ANY(p_zones)
    ) THEN
        RAISE EXCEPTION 'Zone does not exist';
    END IF;

    -- Check if all loaned artefacts are available for the exhibition
    FOREACH p_artefact_id IN ARRAY p_artefacts
    LOOP
        IF EXISTS (
            -- check for only the newest loan of there are multiple loans
            WITH newest_loan AS (
                SELECT *
                FROM loans
                WHERE artefact_id = p_artefact_id
                ORDER BY start_date DESC
                LIMIT 1
            )
            SELECT 1
            FROM newest_loan
            JOIN artefacts ON artefacts.id = p_artefact_id
            WHERE artefacts.ownership = 'loaned'
            AND (newest_loan.start_date > p_start_date
            OR newest_loan.end_date < p_end_date)

        ) THEN
            RAISE EXCEPTION 'Loaned artefact is not available for the exhibition';
        END IF;
    END LOOP;

    -- Create the new exhibition
    INSERT INTO exhibitions (title, start_date, end_date, description)
    VALUES (p_exhibition_title, p_start_date, p_end_date, p_description)
    RETURNING id INTO new_exhibition_id; -- get the new exhibition id


    -- Insert artefacts and zones into the relationship tables
    FOREACH p_artefact_id IN ARRAY p_artefacts
    LOOP
        -- check_artefact_exhibition_overlap trigger will check for overlapping exhibitions
        INSERT INTO artefact_exhibition (artefact_id, exhibition_id)
        VALUES (p_artefact_id, new_exhibition_id);
    END LOOP;


    FOREACH p_zone_id IN ARRAY p_zones
    LOOP
        -- check_zone_exhibition_overlap trigger will check for overlapping exhibitions
        INSERT INTO exhibition_zone (zone_id, exhibition_id)
        VALUES (p_zone_id, new_exhibition_id);
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