-- =====================================================
-- Value Delivery Tracker II - Database Schema
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)
-- =====================================================

-- 1. Product Groups
CREATE TABLE product_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  abbreviation TEXT NOT NULL UNIQUE,
  display_order INT NOT NULL DEFAULT 0
);

-- 2. Categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT,
  section TEXT NOT NULL CHECK (section IN ('product_group', 'admin')),
  display_order INT NOT NULL DEFAULT 0
);

-- 3. Initiatives
CREATE TABLE initiatives (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  metric_type TEXT NOT NULL CHECK (metric_type IN ('percentage', 'dollar', 'roi', 'count', 'score')),
  frequency TEXT NOT NULL DEFAULT 'monthly' CHECK (frequency IN ('monthly', 'quarterly')),
  display_order INT NOT NULL DEFAULT 0
);

-- 4. Initiative Assignments (which PGs are responsible for which initiatives)
CREATE TABLE initiative_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  initiative_id UUID NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  product_group_id UUID NOT NULL REFERENCES product_groups(id) ON DELETE CASCADE,
  UNIQUE(initiative_id, product_group_id)
);

-- 5. Initiative Goals (SSDA-level targets per month)
CREATE TABLE initiative_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  initiative_id UUID NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INT NOT NULL,
  target_value NUMERIC,
  UNIQUE(initiative_id, month, year)
);

-- 6. Initiative Thresholds (per-initiative color coding cutoffs)
CREATE TABLE initiative_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  initiative_id UUID NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  green_min NUMERIC NOT NULL DEFAULT 0.85,
  yellow_min NUMERIC NOT NULL DEFAULT 0.65,
  UNIQUE(initiative_id)
);

-- 7. Monthly Entries (actual values + notes per PG per initiative per month)
CREATE TABLE monthly_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  initiative_id UUID NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  product_group_id UUID REFERENCES product_groups(id) ON DELETE CASCADE,
  month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INT NOT NULL,
  value NUMERIC,
  notes TEXT,
  submitted_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Unique constraint for PG entries (product_group_id is NOT NULL)
CREATE UNIQUE INDEX idx_entries_unique_with_pg
ON monthly_entries (initiative_id, product_group_id, month, year)
WHERE product_group_id IS NOT NULL;

-- Unique constraint for admin entries (product_group_id IS NULL)
CREATE UNIQUE INDEX idx_entries_unique_without_pg
ON monthly_entries (initiative_id, month, year)
WHERE product_group_id IS NULL;

-- 8. Submissions (tracks which PGs have officially submitted for a month)
CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_group_id UUID NOT NULL REFERENCES product_groups(id) ON DELETE CASCADE,
  month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INT NOT NULL,
  submitted_at TIMESTAMPTZ DEFAULT now(),
  submitted_by TEXT,
  UNIQUE(product_group_id, month, year)
);

-- =====================================================
-- Indexes for performance
-- =====================================================

CREATE INDEX idx_initiatives_category ON initiatives(category_id);
CREATE INDEX idx_assignments_initiative ON initiative_assignments(initiative_id);
CREATE INDEX idx_assignments_pg ON initiative_assignments(product_group_id);
CREATE INDEX idx_goals_initiative_period ON initiative_goals(initiative_id, year, month);
CREATE INDEX idx_entries_initiative_period ON monthly_entries(initiative_id, year, month);
CREATE INDEX idx_entries_pg_period ON monthly_entries(product_group_id, year, month);
CREATE INDEX idx_submissions_period ON submissions(year, month);

-- =====================================================
-- Row Level Security (disabled for now since no auth)
-- =====================================================

ALTER TABLE product_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE initiatives ENABLE ROW LEVEL SECURITY;
ALTER TABLE initiative_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE initiative_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE initiative_thresholds ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- Allow all operations for anon (no auth required)
CREATE POLICY "Allow all access" ON product_groups FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON initiatives FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON initiative_assignments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON initiative_goals FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON initiative_thresholds FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON monthly_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON submissions FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- Seed: Product Groups
-- =====================================================

INSERT INTO product_groups (name, abbreviation, display_order) VALUES
  ('Customer 360', 'C360', 1),
  ('IS Data & Analytics', 'ISDA', 2),
  ('FCSD AI', 'FCSD-AI', 3),
  ('FCSD Operations / Service 360', 'FCSD-Ops', 4),
  ('FCSD Customer Service', 'FCSD-CS', 5),
  ('Pro 360', 'Pro360', 6),
  ('BSPA', 'BSPA', 7),
  ('YMAA', 'YMAA', 8);

-- =====================================================
-- Seed: Categories
-- =====================================================

INSERT INTO categories (name, code, section, display_order) VALUES
  ('Direct Financial Impact', 'L2.4.3', 'product_group', 1),
  ('AI Big Bet EBIT: Year-To-Date', 'L2.4.2', 'product_group', 2),
  ('AI Big Bet EBIT: Annual Forecast', NULL, 'product_group', 3),
  ('AI Big Bets: Top-of-Funnel Projects', 'L2.4.5', 'product_group', 4),
  ('AI Data Readiness', 'L2.2.3', 'product_group', 5),
  ('Delivery Pace', 'L2.2.4', 'product_group', 6),
  ('Personal Gemba', 'L2.7.1', 'product_group', 7),
  ('Recall Enterprise Capabilities', 'L2.6.1', 'product_group', 8),
  ('Product & Services KPI Targets', NULL, 'product_group', 9),
  ('CRM Messaging Impact', NULL, 'product_group', 10),
  ('Customer Profile System', NULL, 'product_group', 11),
  ('Improve Ford''s Corporate Reputation', NULL, 'product_group', 12),
  ('Transition Work EU to Chennai', NULL, 'product_group', 13),
  ('Administrative', NULL, 'admin', 14);
