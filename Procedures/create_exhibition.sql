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
    -- Check if the start date is before the end date
    IF p_start_date >= p_end_date THEN
        RAISE EXCEPTION 'Start date must be before the end date';
    END IF;


    -- Check if all loaned artefacts are available for the exhibition
        FOREACH p_artefact_id IN ARRAY p_artefacts
        LOOP
            -- do this only if the artefact is loaned
            IF EXISTS (SELECT 1 FROM artefacts WHERE id = p_artefact_id AND ownership = 'loaned')
             THEN
                IF NOT EXISTS (
                    -- check for only the newest loan of there are multiple loans
                    SELECT 1
                    FROM loans
                    JOIN artefacts ON loans.artefact_id = artefacts.id
                    WHERE artefacts.id = p_artefact_id
                    -- check if the loaned artefact is available for the exhibition (contained by)
                    AND tstzrange(COALESCE(loans.arrival_date, loans.expected_arrival_date), loans.end_date, '[]')
                            <@
                        tstzrange(p_start_date::TIMESTAMP WITH TIME ZONE, p_end_date::TIMESTAMP WITH TIME ZONE, '[]')
                ) THEN
                    RAISE EXCEPTION 'Loaned artefact is not available for the exhibition';
                END IF;
            END IF;
        END LOOP;
    -- Check if all our artefacts are available for the exhibition
    FOREACH p_artefact_id IN ARRAY p_artefacts
    LOOP
        IF EXISTS (
            SELECT 1
            FROM loans
            JOIN artefacts ON artefacts.id = loans.artefact_id
            WHERE artefacts.ownership = 'our' AND artefacts.id = p_artefact_id
            AND daterange(loans.start_date, loans.end_date, '[]') && daterange(p_start_date, p_end_date, '[]')
        ) THEN
            RAISE EXCEPTION 'Our artefact is loaned during the exhibition';
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


    -- No need for COMMIT DataGrip will automatically "wrap" the procedure in a transaction
    -- I HOPE THIS WONT BITE ME IN THE BUTT
EXCEPTION
    WHEN OTHERS THEN
        -- catch failed overlap and other checks
        ROLLBACK;
        RAISE;
END;
$$;
