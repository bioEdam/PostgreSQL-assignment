-- Function to check for overlapping exhibitions using the OVERLAPS operator
CREATE OR REPLACE FUNCTION check_artefact_exhibition_overlap()
RETURNS TRIGGER AS $$
DECLARE
    -- Variables to store the start and end dates of the new exhibition
    new_exhibition_dates DATERANGE;
BEGIN
    SELECT daterange(start_date, end_date, '[]') INTO new_exhibition_dates
    FROM exhibitions
    WHERE id = NEW.exhibition_id;

    -- Check for any existing records that overlap using the OVERLAPS operator
    IF EXISTS (
        SELECT 1
        FROM artefact_exhibition ae
        JOIN exhibitions e ON ae.exhibition_id = e.id
        WHERE ae.artefact_id = NEW.artefact_id
        AND ae.exhibition_id != NEW.exhibition_id  -- Ensure we're not comparing the exhibition to itself
        AND (daterange(e.start_date, e.end_date, '[]') && new_exhibition_dates)
    ) THEN
        RAISE EXCEPTION 'Artefact % is already part of another exhibition during the given dates.', NEW.artefact_id;
    END IF;

    -- If no overlaps, allow the insert
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to call the function before inserting or editing a new record
CREATE OR REPLACE TRIGGER trg_check_artefact_exhibition_overlap
BEFORE INSERT OR UPDATE ON artefact_exhibition
FOR EACH ROW
EXECUTE FUNCTION check_artefact_exhibition_overlap();
