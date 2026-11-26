#!/usr/bin/env bash
set -Eeuo pipefail

# NextOps PostgreSQL initialization
# Database name is prompted; schema is fixed to public.
DB_HOST="nextops-dev-psql-db.postgres.database.azure.com"
DB_PORT="5432"
DB_SCHEMA="public"

command -v psql >/dev/null 2>&1 || {
  echo "ERROR: psql is required. On macOS install it with: brew install libpq"
  exit 1
}

read -rp "PostgreSQL administrator username: " DB_USER
read -rsp "PostgreSQL administrator password: " DB_PASSWORD
echo
read -rp "Database name [nextops]: " DB_NAME
DB_NAME="${DB_NAME:-nextops}"

if [[ ! "$DB_NAME" =~ ^[A-Za-z_][A-Za-z0-9_]{0,62}$ ]]; then
  echo "ERROR: Invalid database name. Use letters, numbers and underscores; max 63 characters."
  exit 1
fi

export PGPASSWORD="$DB_PASSWORD"
export PGSSLMODE="require"

echo "[1/2] Ensure database '$DB_NAME' exists..."
psql -X -v ON_ERROR_STOP=1 \
  -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
  -v db_name="$DB_NAME" <<'SQL'
SELECT format('CREATE DATABASE %I', :'db_name')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'db_name')
\gexec
SQL

echo "[2/2] Create public schema objects and seed data if the table is empty..."
psql -X -v ON_ERROR_STOP=1 \
  -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<'SQL'
CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE IF NOT EXISTS public.telemetry (
  id BIGSERIAL PRIMARY KEY,
  device_id TEXT NOT NULL,
  device_type TEXT NOT NULL,
  refinery_region TEXT NOT NULL,
  temperature NUMERIC(10,2) NOT NULL,
  pressure NUMERIC(10,2) NOT NULL,
  flow_rate NUMERIC(10,2) NOT NULL,
  "timestamp" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  component_metrics JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_telemetry_device_timestamp
  ON public.telemetry (device_id, "timestamp" DESC);

INSERT INTO public.telemetry
  (device_id, device_type, refinery_region, temperature, pressure,
   flow_rate, "timestamp", component_metrics)
SELECT
  'DEV-' || lpad(d::text, 3, '0'),
  CASE WHEN d % 3 = 0 THEN 'Pump'
       WHEN d % 3 = 1 THEN 'Compressor'
       ELSE 'Valve' END,
  CASE WHEN d % 3 = 0 THEN 'North'
       WHEN d % 3 = 1 THEN 'South'
       ELSE 'West' END,
  round((65 + random() * 35)::numeric, 2),
  round((20 + random() * 80)::numeric, 2),
  round((100 + random() * 400)::numeric, 2),
  NOW() - (r * INTERVAL '1 hour'),
  jsonb_build_object(
    'vibration', round((random() * 10)::numeric, 2),
    'efficiency', round((70 + random() * 30)::numeric, 2)
  )
FROM generate_series(1, 12) AS d
CROSS JOIN generate_series(0, 11) AS r
WHERE NOT EXISTS (SELECT 1 FROM public.telemetry);

SELECT count(*) AS telemetry_records FROM public.telemetry;
SQL

unset PGPASSWORD DB_PASSWORD
echo "Database initialization completed: ${DB_NAME}.${DB_SCHEMA}"
