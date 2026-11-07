-- GLOBUS 2027 SEO analytics draft schema for Cloudflare D1 (SQLite)
-- PROPOSAL ONLY: not deployed. Existing repair/equipment tables untouched.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS seo_sources (
  id TEXT PRIMARY KEY,
  provider TEXT NOT NULL CHECK(provider IN ('gsc')),
  property_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  last_success_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(provider, property_id)
);

CREATE TABLE IF NOT EXISTS seo_runs (
  id TEXT PRIMARY KEY,
  source_id TEXT NOT NULL REFERENCES seo_sources(id),
  period_start TEXT NOT NULL,
  period_end TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('running','complete','preliminary','failed')),
  started_at TEXT NOT NULL DEFAULT (datetime('now')),
  finished_at TEXT,
  error_message TEXT
);
CREATE INDEX IF NOT EXISTS idx_seo_runs_source_started ON seo_runs(source_id, started_at DESC);

CREATE TABLE IF NOT EXISTS seo_daily (
  source_id TEXT NOT NULL REFERENCES seo_sources(id),
  day TEXT NOT NULL,
  clicks INTEGER NOT NULL DEFAULT 0,
  impressions INTEGER NOT NULL DEFAULT 0,
  ctr REAL NOT NULL DEFAULT 0,
  position REAL,
  data_state TEXT NOT NULL DEFAULT 'preliminary' CHECK(data_state IN ('preliminary','final')),
  fetched_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY(source_id, day)
);

CREATE TABLE IF NOT EXISTS seo_dimension_daily (
  source_id TEXT NOT NULL REFERENCES seo_sources(id),
  day TEXT NOT NULL,
  dimension_type TEXT NOT NULL CHECK(dimension_type IN ('query','page','device','country')),
  dimension_value TEXT NOT NULL,
  clicks INTEGER NOT NULL DEFAULT 0,
  impressions INTEGER NOT NULL DEFAULT 0,
  ctr REAL NOT NULL DEFAULT 0,
  position REAL,
  fetched_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY(source_id, day, dimension_type, dimension_value)
);
CREATE INDEX IF NOT EXISTS idx_seo_dim_type_day ON seo_dimension_daily(source_id, dimension_type, day);

CREATE TABLE IF NOT EXISTS seo_change_log (
  id TEXT PRIMARY KEY,
  changed_on TEXT NOT NULL,
  page_url TEXT,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
-- OAuth tokens MUST NOT be stored in these tables; use encrypted server-side secrets.
-- Before production deployment: verify Workspace's actual D1 bindings, migrations,
-- authentication, scheduler and backups. No automatic migration on app startup.
