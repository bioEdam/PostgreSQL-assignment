-- after loaned_in exemplar arrives set the arrival date to the current date and set artefacts status to in_storage
CREATE OR REPLACE FUNCTION artefact_arrival(
    p_artefact_id UUID
)
RETURNS VOID AS $$
BEGIN
    -- check if the exemplar is loaned in'
    IF NOT EXISTS (
        SELECT 1
        FROM loans
        WHERE artefact_id = p_artefact_id
        AND loan_type = 'loan_in'
    ) THEN
        RAISE EXCEPTION 'Exemplar is not loaned in';
    END IF;

    UPDATE loans
    SET arrival_date = CURRENT_DATE
    WHERE artefact_id = p_artefact_id;

    UPDATE artefacts
    SET state = 'in_storage'
    WHERE id = p_artefact_id;
END;
$$ LANGUAGE plpgsql;
-- I feel like this should have been a procedure