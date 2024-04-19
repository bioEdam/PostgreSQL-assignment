-- function made for easy of editing artefact data for the curators
-- checks CURRENT TIME sets the exhibition_id in the artefact table to the exhibition_id of the exhibition that is currently active
CREATE OR REPLACE PROCEDURE update_current_exhibition(p_artefact_id UUID)
AS $$
BEGIN
    UPDATE artefacts AS art
    SET exhibition_id = (SELECT id FROM exhibitions WHERE CURRENT_TIMESTAMP BETWEEN start_date AND end_date)
    WHERE id = p_artefact_id;
END;
$$ LANGUAGE plpgsql;