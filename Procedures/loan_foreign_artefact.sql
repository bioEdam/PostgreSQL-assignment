-- procedure for loaning artefacts from an institute
-- creates a new artefact for the system and sets the loaned status to true
-- returns the artefact id
-- adds a new loan to the system
-- all parameters are start with p_

-- helper for variables

-- CREATE TABLE artefacts (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     name VARCHAR(255) NOT NULL,
--     description TEXT,
--     ownership ownership NOT NULL DEFAULT 'our',
--     state states NOT NULL,

-- CREATE TABLE loans (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     artefact_id UUID,
--     institute_id UUID,
--     loan_type loan_directions NOT NULL,
--     expected_arrival_date TIMESTAMP WITH TIME ZONE,
--     arrival_date TIMESTAMP WITH TIME ZONE,
--     start_date DATE NOT NULL,
--     end_date DATE,

CREATE OR REPLACE PROCEDURE loan_foreign_artefact(
    p_artefact_name VARCHAR(255),
    p_artefact_description TEXT,
    p_institute_id UUID,
    -- loan type is always 'loan_in'
    p_expected_arrival_date TIMESTAMP WITH TIME ZONE,
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_artefact_id UUID;
    v_loan_id UUID;
BEGIN
    -- check if the artefact name is already exists
    SELECT id INTO v_artefact_id
    FROM artefacts
    WHERE name = p_artefact_name;

    -- check if institute exists
    IF NOT EXISTS (SELECT 1 FROM institutes WHERE id = p_institute_id) THEN
        RAISE EXCEPTION 'Institute with id % does not exist', p_institute_id;
    END IF;

    -- create a new artefact
    IF v_artefact_id IS NULL THEN
        INSERT INTO artefacts (name, description, ownership, state)
        VALUES (p_artefact_name, p_artefact_description, 'loaned', 'in_transit')
        RETURNING id INTO v_artefact_id;
    END IF;

    -- create a new loan
    INSERT INTO loans (artefact_id, institute_id, loan_type, expected_arrival_date, start_date, end_date)
    VALUES (v_artefact_id, p_institute_id, 'loan_in', p_expected_arrival_date, p_start_date, p_end_date)
    RETURNING id INTO v_loan_id;

END;
$$;