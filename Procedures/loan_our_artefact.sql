-- procedure for loaning artefacts to an institute
CREATE OR REPLACE PROCEDURE loan_foreign_artefact(
    p_artefact_id IN UUID, -- which artefact to loan
    p_institute_id IN UUID, -- to which institute
    p_expected_arrival_date IN TIMESTAMP WITH TIME ZONE,
    p_start_date IN DATE,
    p_end_date IN DATE
)
AS $$

BEGIN
    -- check if the given artefact is our
    IF NOT EXISTS(
        SELECT 1
        FROM artefacts
        WHERE id = p_institute_id
        AND ownership = 'our'
    ) THEN
        RAISE EXCEPTION 'Artefact is not our';
    END IF;

    INSERT INTO loans(artefact_id, institute_id, expected_arrival_date, start_date, end_date, loan_type)
    VALUES(p_artefact_id, p_institute_id, p_expected_arrival_date, p_start_date, p_end_date, 'loaned_out');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;

END;
$$ LANGUAGE plpgsql;