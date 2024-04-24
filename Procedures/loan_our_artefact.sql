-- procedure for loaning artefacts to an institute
CREATE OR REPLACE PROCEDURE loan_our_artefact(
    p_artefact_id IN UUID, -- which artefact to loan
    p_institute_id IN UUID, -- to which institute
    p_expected_arrival_date IN TIMESTAMP WITH TIME ZONE,
    p_start_date IN DATE,
    p_end_date IN DATE
)
AS $$

BEGIN
    -- check if the given artefact is our and the ID is valid
    IF NOT EXISTS(
        SELECT 1
        FROM artefacts
        WHERE id = p_artefact_id
        AND ownership = 'our'
    ) THEN
        RAISE EXCEPTION 'Artefact is not our or ID is invalid';
    END IF;

    -- check if the our the artefact wont be part of an exposition
    IF EXISTS(
        SELECT 1
        FROM artefact_exhibition
        JOIN artefacts ON artefacts.id = artefact_exhibition.artefact_id
        JOIN exhibitions ON exhibitions.id = artefact_exhibition.exhibition_id
        WHERE artefacts.id = p_artefact_id
        AND daterange(p_start_date, p_end_date, '[]') && daterange(exhibitions.start_date, exhibitions.end_date, '[]')
    )
    THEN
        RAISE EXCEPTION 'Artefact will part of an exposition at this time';
    END IF;

    INSERT INTO loans(artefact_id, institute_id, expected_arrival_date, start_date, end_date, loan_type)
    VALUES(p_artefact_id, p_institute_id, p_expected_arrival_date, p_start_date, p_end_date, 'loan_out');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;

END;
$$ LANGUAGE plpgsql;