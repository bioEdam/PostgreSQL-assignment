-- check if the artefact is at the correct zone if it is part of an exhibition
-- if it is not part of an exhibition, then it cannot be at a zone that is part of an exhibition

CREATE OR REPLACE FUNCTION check_artefact_zone(p_artefact_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_zone_id UUID;
    v_exhibition_id UUID;
    v_exhibition_zones_id UUID[];
BEGIN
    -- check if the artefact exists
    IF NOT EXISTS (SELECT 1 FROM artefacts WHERE id = p_artefact_id) THEN
        RAISE EXCEPTION 'Artefact does not exist';
    END IF;

    CALL update_current_exhibition(p_artefact_id);

    -- get the zone of the artefact
    SELECT zone_id INTO v_zone_id
    FROM artefacts
    WHERE id = p_artefact_id;

    -- get the exhibition of the artefact
    SELECT exhibition_id INTO v_exhibition_id
    FROM artefacts
    WHERE id = p_artefact_id;

    IF v_exhibition_id IS NOT NULL THEN
        -- get all the zones that are part of the exhibition
        SELECT ARRAY(SELECT zone_id
                     FROM exhibition_zone
                     WHERE exhibition_id = v_exhibition_id) INTO v_exhibition_zones_id;

        IF v_zone_id = ANY(v_exhibition_zones_id) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    ELSE
        -- if the artefact is not part of an exhibition, then it cannot be at a zone that is part of an exhibition
        IF EXISTS (SELECT 1
                   FROM exhibition_zone
                   WHERE zone_id = v_zone_id) THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;