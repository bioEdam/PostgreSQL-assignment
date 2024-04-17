-- check for zones "fullness" before changing zone_id in artefacts
CREATE OR REPLACE FUNCTION check_capacity()
RETURNS TRIGGER AS $$
DECLARE
    v_capacity integer;
    v_count integer;
BEGIN
    SELECT capacity INTO v_capacity FROM zones WHERE id = NEW.zone_id;
    SELECT COUNT(*) INTO v_count FROM artefacts WHERE zone_id = NEW.zone_id;
    IF v_count >= v_capacity THEN
        RAISE EXCEPTION 'Zone is full';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_capacity
BEFORE INSERT OR UPDATE OF zone_id ON artefacts
FOR EACH ROW
EXECUTE FUNCTION check_capacity();