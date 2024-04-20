-- return array of zone names where the artefact should be placed
-- if exhibition_id is null, return all zones that are not in any exhibition in CURRENT_DATE
-- if exhibition_id is not null, return all zones that are in the exhibition in CURRENT_DATE
CREATE OR REPLACE FUNCTION get_correct_artefacts_zones(p_artefact_id UUID)
RETURNS varchar(255)[] AS $$
DECLARE
    v_exhibition_id UUID;
    v_zones varchar(255)[];
BEGIN
    -- check if artefact exists
    IF NOT EXISTS (SELECT 1 FROM artefacts WHERE id = p_artefact_id) THEN
        RAISE EXCEPTION 'Artefact with id % does not exist', p_artefact_id;
    END IF;

    CALL update_current_exhibition(p_artefact_id);

    SELECT exhibition_id INTO v_exhibition_id FROM artefacts WHERE id = p_artefact_id;

    -- check if exhibition is in CURRENT_DATE start_date and end_date
    IF v_exhibition_id IS NOT NULL THEN
        SELECT array_agg(zones.name) INTO v_zones
        FROM zones
        WHERE id IN (
            SELECT zone_id
            FROM exhibition_zone
            WHERE exhibition_id = v_exhibition_id
        );
        RETURN v_zones;
    ELSE
        SELECT array_agg(zones.name) INTO v_zones
        FROM zones
        WHERE id NOT IN (
            SELECT zone_id
            FROM exhibition_zone
            JOIN exhibitions ON exhibition_zone.exhibition_id = exhibitions.id
            WHERE CURRENT_DATE BETWEEN start_date AND end_date
        );
        RETURN v_zones;
    END IF;

END;
$$ LANGUAGE plpgsql;