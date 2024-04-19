-- function made for editing artefact's exhibition_id for the curators

-- pick exhibitions that the artefact is in
-- and checks CURRENT TIME sets the exhibition_id in the artefact table to the exhibition_id
-- of the exhibition that is currently active
CREATE OR REPLACE PROCEDURE update_current_exhibition(p_artefact_id UUID)
AS $$
DECLARE
    v_exhibition_id UUID;
BEGIN
    -- get exhibition_id that is currently active and artefact is in
    SELECT ax.exhibition_id INTO v_exhibition_id
    FROM artefact_exhibition AS ax
    JOIN exhibitions x on ax.exhibition_id = x.id
    WHERE ax.artefact_id = p_artefact_id
        AND CURRENT_DATE BETWEEN x.start_date AND x.end_date;

    -- update artefact table
    UPDATE artefacts
    SET exhibition_id = v_exhibition_id -- luckily null if is not part of any exhibition, just like we like it
    WHERE id = p_artefact_id;
END;
$$ LANGUAGE plpgsql;