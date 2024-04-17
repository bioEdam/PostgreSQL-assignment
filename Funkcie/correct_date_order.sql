-- function to check date order while inserting and editing into exhibitions, loans
CREATE OR REPLACE FUNCTION correct_date_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.start_date > NEW.end_date THEN
        RAISE EXCEPTION 'Start date must be before end date';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_exh_correct_date_order
BEFORE INSERT OR UPDATE ON exhibitions
FOR EACH ROW EXECUTE FUNCTION correct_date_order();

CREATE OR REPLACE TRIGGER trg_loan_correct_date_order
BEFORE INSERT OR UPDATE ON loans
FOR EACH ROW EXECUTE FUNCTION correct_date_order();