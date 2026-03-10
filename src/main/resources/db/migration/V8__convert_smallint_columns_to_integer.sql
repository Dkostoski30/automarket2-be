DO $$
DECLARE
r RECORD;
BEGIN
FOR r IN
SELECT
    table_schema,
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name <> 'flyway_schema_history'
  AND data_type = 'smallint'
    LOOP
        EXECUTE format(
            'ALTER TABLE %I.%I ALTER COLUMN %I TYPE integer',
            r.table_schema,
            r.table_name,
            r.column_name
        );
END LOOP;
END $$;