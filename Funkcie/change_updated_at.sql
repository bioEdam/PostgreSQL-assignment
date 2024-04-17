CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger for every table in database
DO $$
DECLARE
  r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        -- execide only if updated_at column exists
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = r.tablename AND column_name = 'updated_at') THEN
            EXECUTE 'CREATE OR REPLACE TRIGGER update_' || r.tablename || '_updated_at BEFORE UPDATE ON ' || r.tablename || ' FOR EACH ROW EXECUTE FUNCTION update_updated_at()';
        END IF;
    END LOOP;
    END;
$$;