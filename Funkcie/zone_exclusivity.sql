CREATE OR REPLACE FUNCTION check_zone_exhibition_overlap()
RETURNS TRIGGER AS $$
DECLARE
    -- Variables to store the start and end dates of the new exhibition
    new_exhibition_dates DATERANGE;
BEGIN
    SELECT daterange(start_date, end_date, '[]') INTO new_exhibition_dates
    FROM exhibitions
    WHERE id = NEW.exhibition_id;

    IF EXISTS (
        SELECT 1
        FROM exhibition_zone
        JOIN exhibitions ON exhibition_zone.exhibition_id = exhibitions.id
        WHERE exhibition_zone.zone_id = NEW.zone_id
        AND daterange(exhibitions.start_date, exhibitions.end_date, '[]') && new_exhibition_dates
        AND exhibitions.id != NEW.exhibition_id -- Exclude the current exhibition
    ) THEN
        RAISE EXCEPTION 'Exhibition overlaps with another exhibition in the same zone';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_zone_exhibition_overlap
BEFORE INSERT OR UPDATE ON exhibition_zone
FOR EACH ROW
EXECUTE FUNCTION check_zone_exhibition_overlap();