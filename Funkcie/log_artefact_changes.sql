CREATE OR REPLACE FUNCTION log_artefact_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a record into artefact_history before the update
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO artefact_history (id, name, description, ownership, state, zone_id, exhibition_id, created_at)
        VALUES (OLD.id, OLD.name, OLD.description, OLD.ownership, OLD.state, OLD.zone_id, OLD.exhibition_id, OLD.created_at);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER artefact_change
BEFORE UPDATE ON artefact
FOR EACH ROW
EXECUTE FUNCTION log_artefact_change();