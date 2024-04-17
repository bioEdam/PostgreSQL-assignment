SELECT id, name FROM artefacts;
SELECT id, name FROM zones;
-- create_exhibition(
--     p_exhibition_title VARCHAR(255),
--     p_start_date DATE,
--     p_end_date DATE,
--     p_description TEXT,
--     p_artefacts UUID[],
--     p_zones UUID[])
CALL create_exhibition('The Great Exhibition'::VARCHAR(255), '1851-05-01'::DATE, '1851-10-15'::DATE, 'This assignment is fun'::TEXT,
                       ARRAY['d9d6e0f3-e65e-4109-a6a6-b6333b5e686b', '00719cb5-e757-40c9-babd-81d995372f35']::UUID[],
                       ARRAY['2bbdf4ac-1061-47b0-b685-17b3998e94e6', '8feca945-da3a-4f4e-bf66-7228afb8c1e7']::UUID[]);