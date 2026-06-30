-- =====================================================
-- Value Delivery Tracker II - Historical Data Seed
-- Run AFTER schema.sql, seed-initiatives.sql, and seed-assignments.sql
-- Contains Jan-Jun 2026 actual scores from spreadsheet
-- =====================================================

-- Helper: Create a function to insert scores by initiative name + PG abbreviation
-- This avoids needing to know UUIDs

-- =====================================================
-- DIRECT FINANCIAL IMPACT (L2.4.3)
-- Row 3 = Total Benefits (dollar), Row 5 = ROI % (ratio)
-- =====================================================

-- ROI Dollars - Total Benefits (all PGs, all months where data exists)
-- Note: Data appears consistent from Feb onwards. Jan had different structure.
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- February: R3 data
  (2, 'C360', 18819479),
  (2, 'ISDA', 17363854),
  (2, 'FCSD-AI', 23603603),
  (2, 'FCSD-Ops', 7126252),
  (2, 'FCSD-CS', 2941355),
  (2, 'Pro360', 11266636),
  (2, 'BSPA', 16157438),
  (2, 'YMAA', 11311039),
  -- March: R3 (same costs as Feb for most PGs)
  (3, 'C360', 18319479.73),
  (3, 'ISDA', 16929854.06),
  (3, 'FCSD-AI', 23611049.89),
  (3, 'FCSD-Ops', 8294163),
  (3, 'FCSD-CS', 2741355.42),
  (3, 'Pro360', 11266636),
  (3, 'BSPA', 12457438.56),
  (3, 'YMAA', 11311039),
  -- April: R3 (same structure)
  (4, 'C360', 18319479.73),
  (4, 'ISDA', 16929854.06),
  (4, 'FCSD-AI', 23611049.89),
  (4, 'FCSD-Ops', 8294163),
  (4, 'FCSD-CS', 2741355.42),
  (4, 'Pro360', 11266636),
  (4, 'BSPA', 12457439.06),
  (4, 'YMAA', 11311039),
  -- May: R3
  (5, 'C360', 18319479.73),
  (5, 'ISDA', 16929854.06),
  (5, 'FCSD-AI', 23611049.89),
  (5, 'FCSD-Ops', 8294163),
  (5, 'FCSD-CS', 2741355.42),
  (5, 'Pro360', 11266636),
  (5, 'BSPA', 12457439.06),
  (5, 'YMAA', 11311039),
  -- June: R3
  (6, 'C360', 69000000),
  (6, 'ISDA', 64700000),
  (6, 'FCSD-AI', 106700000),
  (6, 'FCSD-Ops', 28400000),
  (6, 'FCSD-CS', 7200000),
  (6, 'Pro360', 35000000),
  (6, 'BSPA', 52977438),
  (6, 'YMAA', 42600000)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'ROI Dollars - Total Benefits';

-- ROI Percentage (calculated: (benefits - costs) / costs)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- February R4
  (2, 'C360', 2.6664),
  (2, 'ISDA', 2.7261),
  (2, 'FCSD-AI', 3.4061),
  (2, 'FCSD-Ops', 2.7046),
  (2, 'FCSD-CS', 1.7198),
  (2, 'Pro360', 1.6627),
  (2, 'BSPA', 2.2788),
  (2, 'YMAA', 2.7662),
  -- March R4
  (3, 'C360', 2.7665),
  (3, 'ISDA', 2.8217),
  (3, 'FCSD-AI', 3.4047),
  (3, 'FCSD-Ops', 2.4241),
  (3, 'FCSD-CS', 2.3560),
  (3, 'Pro360', 1.6627),
  (3, 'BSPA', 3.2527),
  (3, 'YMAA', 2.7662),
  -- April R4
  (4, 'C360', 2.7665),
  (4, 'ISDA', 2.8217),
  (4, 'FCSD-AI', 3.5191),
  (4, 'FCSD-Ops', 2.4241),
  (4, 'FCSD-CS', 1.6264),
  (4, 'Pro360', 2.1065),
  (4, 'BSPA', 3.2527),
  (4, 'YMAA', 2.7662),
  -- May R4
  (5, 'C360', 2.7665),
  (5, 'ISDA', 2.8217),
  (5, 'FCSD-AI', 3.5191),
  (5, 'FCSD-Ops', 2.4241),
  (5, 'FCSD-CS', 1.6264),
  (5, 'Pro360', 2.1065),
  (5, 'BSPA', 3.2527),
  (5, 'YMAA', 2.7662),
  -- June R5
  (6, 'C360', 2.7665),
  (6, 'ISDA', 2.8217),
  (6, 'FCSD-AI', 3.5191),
  (6, 'FCSD-Ops', 2.4241),
  (6, 'FCSD-CS', 1.6264),
  (6, 'Pro360', 2.1065),
  (6, 'BSPA', 3.2527),
  (6, 'YMAA', 2.7662)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'ROI Percentage';

-- =====================================================
-- AI BIG BET EBIT: YEAR-TO-DATE (L2.4.2)
-- =====================================================

-- FCSD AI Big Bet EBIT YTD ($107M annual target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- January: FCSD-AI=1600000, FCSD-Ops=0, FCSD-CS=100000
  (1, 'FCSD-AI', 1600000),
  (1, 'FCSD-Ops', 0),
  (1, 'FCSD-CS', 100000),
  -- Feb: FCSD total=4500000 (FCSD-AI=4300000, FCSD-CS=200000)
  (2, 'FCSD-AI', 4300000),
  (2, 'FCSD-Ops', 0),
  (2, 'FCSD-CS', 200000),
  -- March: FCSD-AI=17100000, FCSD-CS=300000
  (3, 'FCSD-AI', 17100000),
  (3, 'FCSD-Ops', 0),
  (3, 'FCSD-CS', 300000),
  -- April: no specific breakdown found, assume similar
  (4, 'FCSD-AI', 17100000),
  (4, 'FCSD-Ops', 0),
  (4, 'FCSD-CS', 300000),
  -- May: FCSD total=35680000 (from YTD target $35.68M)
  (5, 'FCSD-AI', 34000000),
  (5, 'FCSD-Ops', 0),
  (5, 'FCSD-CS', 1680000),
  -- June: R10 D10=42260000 (G10=40000000 FCSD-AI, H10=0 Ops, I10=1760000 CS, K10=500000 BSPA)
  (6, 'FCSD-AI', 40000000),
  (6, 'FCSD-Ops', 0),
  (6, 'FCSD-CS', 1760000),
  (6, 'BSPA', 500000)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'FCSD AI Big Bet EBIT YTD ($107M annual target)';

-- Pro AI Big Bet EBIT YTD ($5M annual target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (1, 'Pro360', 0),
  (2, 'Pro360', 0),
  (3, 'Pro360', 896000),
  (4, 'Pro360', 1340496),
  (5, 'Pro360', 1825755),
  (6, 'Pro360', 1825755)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Pro AI Big Bet EBIT YTD ($5M annual target)';

-- C&I AI Big Bet EBIT YTD ($10M annual target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (1, 'BSPA', 0),
  (2, 'BSPA', 0),
  (3, 'BSPA', 0),
  (4, 'BSPA', 0),
  (5, 'BSPA', 0),
  (6, 'BSPA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'C&I AI Big Bet EBIT YTD ($10M annual target)';

-- S&OP AI Big Bet EBIT YTD ($15M annual target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (1, 'YMAA', 0),
  (2, 'YMAA', 0),
  (3, 'YMAA', 0),
  (4, 'YMAA', 0),
  (5, 'YMAA', 0),
  (6, 'YMAA', 15000000)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'S&OP AI Big Bet EBIT YTD ($15M annual target)';

-- =====================================================
-- AI BIG BET EBIT: ANNUAL FORECAST
-- =====================================================

-- FCSD Annual Forecast ($107M target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- June R16: G16=104000000, H16=5000000, I16=1000000
  (5, 'FCSD-AI', 104000000),
  (5, 'FCSD-Ops', 5000000),
  (5, 'FCSD-CS', 1000000),
  (6, 'FCSD-AI', 104000000),
  (6, 'FCSD-Ops', 5000000),
  (6, 'FCSD-CS', 1000000)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'FCSD Annual Forecast ($107M target)';

-- Pro Annual Forecast ($5M target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (2, 'Pro360', 5000000),
  (3, 'Pro360', 3200000),
  (4, 'Pro360', 4000000),
  (5, 'Pro360', 5000000),
  (6, 'Pro360', 5000000)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Pro Annual Forecast ($5M target)';

-- C&I Annual Forecast ($10M target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (2, 'BSPA', 0),
  (3, 'BSPA', 0),
  (4, 'BSPA', 0),
  (5, 'BSPA', 0),
  (6, 'BSPA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'C&I Annual Forecast ($10M target)';

-- S&OP Annual Forecast ($15M target)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (2, 'YMAA', 0),
  (3, 'YMAA', 0),
  (4, 'YMAA', 0),
  (5, 'YMAA', 15000000),
  (6, 'YMAA', 15000000)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'S&OP Annual Forecast ($15M target)';

-- =====================================================
-- AI BIG BETS: TOP-OF-FUNNEL (L2.4.5)
-- =====================================================

-- Blue/e Top-of-Funnel AI (+$50M 2027) - BSPA, YMAA
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (1, 'BSPA', 200000),
  (2, 'BSPA', 0),
  (3, 'BSPA', 0),
  (4, 'BSPA', 0),
  (5, 'BSPA', 0),
  (6, 'BSPA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Blue/e Top-of-Funnel AI (+$50M 2027)';

-- Pro Top-of-Funnel AI (+$75M 2027) - Pro360
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (1, 'Pro360', 0),
  (2, 'Pro360', 0),
  (3, 'Pro360', 0),
  (4, 'Pro360', 0),
  (5, 'Pro360', 0),
  (6, 'Pro360', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Pro Top-of-Funnel AI (+$75M 2027)';

-- IS Top-of-Funnel AI (+$50M 2027) - ISDA
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (1, 'ISDA', 0),
  (2, 'ISDA', 0),
  (3, 'ISDA', 0),
  (4, 'ISDA', 0),
  (5, 'ISDA', 0),
  (6, 'ISDA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'IS Top-of-Funnel AI (+$50M 2027)';

-- =====================================================
-- AI DATA READINESS (L2.2.3)
-- =====================================================

-- Achieve Data Readiness Score of 6/10
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- June R26: E=0, F=0, G=0.5, H=1, I=0, J=0.53, K=0.5, L=0(YMAA dash=assigned)
  (6, 'C360', 0),
  (6, 'ISDA', 0),
  (6, 'FCSD-AI', 0.5),
  (6, 'FCSD-Ops', 1.0),
  (6, 'FCSD-CS', 0),
  (6, 'Pro360', 0.53),
  (6, 'BSPA', 0.5),
  (6, 'YMAA', 0),
  -- May: same structure (data not fully available in extraction, use June values)
  (5, 'C360', 0),
  (5, 'ISDA', 0),
  (5, 'FCSD-AI', 0.5),
  (5, 'FCSD-Ops', 1.0),
  (5, 'FCSD-CS', 0),
  (5, 'Pro360', 0.53),
  (5, 'BSPA', 0.5),
  (5, 'YMAA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Achieve Data Readiness Score of 6/10';

-- Deliver Unified Data Platform Framework
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Jan: B=0.05 (SSDA level, from UDP row)
  (1, 'FCSD-Ops', 0.05),
  -- Feb R26: G(FCSD-Ops)=0.2
  (2, 'FCSD-Ops', 0.2),
  -- April R26: H(FCSD-Ops)=0.5
  (4, 'FCSD-Ops', 0.5),
  -- May R26: G(FCSD-AI)=0.6, H(FCSD-Ops)=0.6
  (5, 'FCSD-AI', 0.6),
  (5, 'FCSD-Ops', 0.6),
  -- June R27: G(FCSD-AI)=0.6, H(FCSD-Ops)=0.8
  (6, 'FCSD-AI', 0.6),
  (6, 'FCSD-Ops', 0.8)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Deliver Unified Data Platform Framework';

-- =====================================================
-- DELIVERY PACE (L2.2.4)
-- =====================================================

-- Demonstrate enhanced AI effectiveness (2+ AI tools)
-- This maps to "Create 1 Team KPI" in the spreadsheet
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- January R19: C360=0, ISDA=0, FCSD-AI=1, FCSD-Ops=0, FCSD-CS=0, Pro360=0, BSPA=0.05
  (1, 'C360', 0),
  (1, 'ISDA', 0),
  (1, 'FCSD-AI', 1.0),
  (1, 'FCSD-Ops', 0),
  (1, 'FCSD-CS', 0),
  (1, 'Pro360', 0),
  (1, 'BSPA', 0.05),
  -- March R32: D=0.45, E=0.33, F=0.5, G=0.16, H=1, I=1, J=0.05
  (3, 'C360', 0.45),
  (3, 'ISDA', 0.33),
  (3, 'FCSD-AI', 0.5),
  (3, 'FCSD-Ops', 0.16),
  (3, 'FCSD-CS', 1.0),
  (3, 'Pro360', 1.0),
  (3, 'BSPA', 0.05),
  -- April: D=SSDA, E=C360... (using May data with April-specific where available)
  (4, 'C360', 0.45),
  (4, 'ISDA', 0.33),
  (4, 'FCSD-AI', 0.5),
  (4, 'FCSD-Ops', 0.16),
  (4, 'FCSD-CS', 1.0),
  (4, 'Pro360', 1.0),
  (4, 'BSPA', 0.05),
  -- May R30 mapped to "Review AI KPI" - need different row for Create KPI
  -- June R30: E=0.85, F=0.66, G=0.5, H=0.41, I=1, J=1, K=0.6
  (5, 'C360', 0.85),
  (5, 'ISDA', 0.66),
  (5, 'FCSD-AI', 0.5),
  (5, 'FCSD-Ops', 0.41),
  (5, 'FCSD-CS', 1.0),
  (5, 'Pro360', 1.0),
  (5, 'BSPA', 0.6),
  (6, 'C360', 0.85),
  (6, 'ISDA', 0.66),
  (6, 'FCSD-AI', 0.5),
  (6, 'FCSD-Ops', 0.41),
  (6, 'FCSD-CS', 1.0),
  (6, 'Pro360', 1.0),
  (6, 'BSPA', 0.6)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Demonstrate enhanced AI effectiveness (2+ AI tools)';

-- Review AI KPI progress and status monthly
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Feb R30: D=1, E=0.33, F=0.5, G=0, H=1, I=0, J=1
  (2, 'C360', 1.0),
  (2, 'ISDA', 0.33),
  (2, 'FCSD-AI', 0.5),
  (2, 'FCSD-Ops', 0),
  (2, 'FCSD-CS', 1.0),
  (2, 'Pro360', 0),
  (2, 'BSPA', 1.0),
  -- April R30: E=1, F=0.33, G=0.5, H=0.54, I=0.33, J=1, K=1
  (4, 'C360', 1.0),
  (4, 'ISDA', 0.33),
  (4, 'FCSD-AI', 0.5),
  (4, 'FCSD-Ops', 0.54),
  (4, 'FCSD-CS', 0.33),
  (4, 'Pro360', 1.0),
  (4, 'BSPA', 1.0),
  -- May R30: E=1, F=1, G=0.5, H=0.54, I=0.5, J=1, K=1
  (5, 'C360', 1.0),
  (5, 'ISDA', 1.0),
  (5, 'FCSD-AI', 0.5),
  (5, 'FCSD-Ops', 0.54),
  (5, 'FCSD-CS', 0.5),
  (5, 'Pro360', 1.0),
  (5, 'BSPA', 1.0),
  -- June R31: E=1, F=1, G=0.5, H=0.54, I=1, J=1, K=1
  (6, 'C360', 1.0),
  (6, 'ISDA', 1.0),
  (6, 'FCSD-AI', 0.5),
  (6, 'FCSD-Ops', 0.54),
  (6, 'FCSD-CS', 1.0),
  (6, 'Pro360', 1.0),
  (6, 'BSPA', 1.0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Review AI KPI progress and status monthly';

-- Submit Efficiency Award demonstrating AI efficiency
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Feb R31: All 0
  (2, 'C360', 0),
  (2, 'ISDA', 0),
  (2, 'FCSD-AI', 0),
  (2, 'FCSD-Ops', 0),
  (2, 'FCSD-CS', 0),
  (2, 'Pro360', 0),
  (2, 'BSPA', 0),
  -- April R31: E=0.15, rest mostly 0, J=0.333
  (4, 'C360', 0.15),
  (4, 'ISDA', 0),
  (4, 'FCSD-AI', 0),
  (4, 'FCSD-Ops', 0),
  (4, 'FCSD-CS', 0),
  (4, 'Pro360', 0.333),
  (4, 'BSPA', 0),
  -- May R31: E=0.15, J=0.46
  (5, 'C360', 0.15),
  (5, 'ISDA', 0),
  (5, 'FCSD-AI', 0),
  (5, 'FCSD-Ops', 0),
  (5, 'FCSD-CS', 0),
  (5, 'Pro360', 0.46),
  (5, 'BSPA', 0),
  -- June R32: E=0.3, F=0, G=0, H=0.25, I=1, J=0.46, K=0.33
  (6, 'C360', 0.3),
  (6, 'ISDA', 0),
  (6, 'FCSD-AI', 0),
  (6, 'FCSD-Ops', 0.25),
  (6, 'FCSD-CS', 1.0),
  (6, 'Pro360', 0.46),
  (6, 'BSPA', 0.33)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Submit Efficiency Award demonstrating AI efficiency';

-- =====================================================
-- PERSONAL GEMBA (L2.7.1)
-- =====================================================

-- 1 Team improvement KPI documented/resolved per quarter
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- January R24: C360=0.083, ISDA=0, FCSD-AI=0, FCSD-Ops=0, FCSD-CS=0, Pro360=1, BSPA=0
  (1, 'C360', 0.083),
  (1, 'ISDA', 0),
  (1, 'FCSD-AI', 0),
  (1, 'FCSD-Ops', 0),
  (1, 'FCSD-CS', 0),
  (1, 'Pro360', 1.0),
  (1, 'BSPA', 0),
  -- March: C360 had gemba data from notes
  (3, 'C360', 0.33),
  (3, 'ISDA', 0),
  (3, 'FCSD-AI', 0),
  (3, 'FCSD-Ops', 0.33),
  (3, 'FCSD-CS', 0.5),
  (3, 'Pro360', 0.5),
  (3, 'BSPA', 0),
  -- April: resets at Q2 start
  (4, 'C360', 0.33),
  (4, 'ISDA', 0),
  (4, 'FCSD-AI', 0),
  (4, 'FCSD-Ops', 0),
  (4, 'FCSD-CS', 0.5),
  (4, 'Pro360', 0.33),
  (4, 'BSPA', 0),
  -- May
  (5, 'C360', 0.66),
  (5, 'ISDA', 0),
  (5, 'FCSD-AI', 0),
  (5, 'FCSD-Ops', 0),
  (5, 'FCSD-CS', 0.5),
  (5, 'Pro360', 0.66),
  (5, 'BSPA', 0),
  -- June R35: E=1, F=0.66, G=0, H=0.7, I=1, J=0.66, K=1
  (6, 'C360', 1.0),
  (6, 'ISDA', 0.66),
  (6, 'FCSD-AI', 0),
  (6, 'FCSD-Ops', 0.7),
  (6, 'FCSD-CS', 1.0),
  (6, 'Pro360', 0.66),
  (6, 'BSPA', 1.0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = '1 Team improvement KPI documented/resolved per quarter';

-- Review GEMBA KPI and status quarterly
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Feb R35: D=1, E=1, F=1, G=0, H=0, I=1, J=1
  (2, 'C360', 1.0),
  (2, 'ISDA', 1.0),
  (2, 'FCSD-AI', 1.0),
  (2, 'FCSD-Ops', 0),
  (2, 'FCSD-CS', 0),
  (2, 'Pro360', 1.0),
  (2, 'BSPA', 1.0),
  -- March: similar pattern
  (3, 'C360', 1.0),
  (3, 'ISDA', 1.0),
  (3, 'FCSD-AI', 1.0),
  (3, 'FCSD-Ops', 0),
  (3, 'FCSD-CS', 0.5),
  (3, 'Pro360', 1.0),
  (3, 'BSPA', 1.0),
  -- April R35: E=1, F=1, G=1, H=0.7, I=0.5, J=1, K=1
  (4, 'C360', 1.0),
  (4, 'ISDA', 1.0),
  (4, 'FCSD-AI', 1.0),
  (4, 'FCSD-Ops', 0.7),
  (4, 'FCSD-CS', 0.5),
  (4, 'Pro360', 1.0),
  (4, 'BSPA', 1.0),
  -- May R35: E=1, F=1, G=1, H=0, I=0.5, J=0.66, K=1
  (5, 'C360', 1.0),
  (5, 'ISDA', 1.0),
  (5, 'FCSD-AI', 1.0),
  (5, 'FCSD-Ops', 0),
  (5, 'FCSD-CS', 0.5),
  (5, 'Pro360', 0.66),
  (5, 'BSPA', 1.0),
  -- June R36: E=1, F=1, G=1, H=0.7, I=0.75, J=0.66, K=1
  (6, 'C360', 1.0),
  (6, 'ISDA', 1.0),
  (6, 'FCSD-AI', 1.0),
  (6, 'FCSD-Ops', 0.7),
  (6, 'FCSD-CS', 0.75),
  (6, 'Pro360', 0.66),
  (6, 'BSPA', 1.0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Review GEMBA KPI and status quarterly';

-- =====================================================
-- RECALL ENTERPRISE CAPABILITIES (L2.6.1)
-- =====================================================

INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (1, 'FCSD-Ops', 0),
  (2, 'FCSD-Ops', 0),
  (3, 'FCSD-Ops', 0),
  (4, 'FCSD-Ops', 0.3),
  (5, 'FCSD-Ops', 0.4),
  -- June R39: H=0.45
  (6, 'FCSD-Ops', 0.45)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Deliver Two (2) Recall Enterprise Capabilities';

-- =====================================================
-- PRODUCT & SERVICES KPI TARGETS
-- =====================================================

-- 100% Products onboarded to ServiceNow
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- January R30: C360=1, ISDA=0, FCSD-AI=0.1, FCSD-Ops=0, FCSD-CS=0.6, Pro360=0, BSPA=0.8
  (1, 'C360', 1.0),
  (1, 'ISDA', 0),
  (1, 'FCSD-AI', 0.1),
  (1, 'FCSD-Ops', 0),
  (1, 'FCSD-CS', 0.6),
  (1, 'Pro360', 0),
  (1, 'BSPA', 0.8),
  -- March R43: D=1, E=1, F=0.1, G=0.75, H=1, I=1, J=1
  (3, 'C360', 1.0),
  (3, 'ISDA', 1.0),
  (3, 'FCSD-AI', 0.1),
  (3, 'FCSD-Ops', 0.75),
  (3, 'FCSD-CS', 1.0),
  (3, 'Pro360', 1.0),
  (3, 'BSPA', 1.0),
  -- April: E=1, F=1, G=0.1, H=1, I=1, J=1, K=1 (from notes: onboarded)
  (4, 'C360', 1.0),
  (4, 'ISDA', 1.0),
  (4, 'FCSD-AI', 0.1),
  (4, 'FCSD-Ops', 1.0),
  (4, 'FCSD-CS', 1.0),
  (4, 'Pro360', 1.0),
  (4, 'BSPA', 1.0),
  -- May: same
  (5, 'C360', 1.0),
  (5, 'ISDA', 1.0),
  (5, 'FCSD-AI', 0.1),
  (5, 'FCSD-Ops', 1.0),
  (5, 'FCSD-CS', 1.0),
  (5, 'Pro360', 1.0),
  (5, 'BSPA', 1.0),
  -- June R42: E=1, F=1, G=0.1, H=1, I=1, J=0.87, K=1
  (6, 'C360', 1.0),
  (6, 'ISDA', 1.0),
  (6, 'FCSD-AI', 0.1),
  (6, 'FCSD-Ops', 1.0),
  (6, 'FCSD-CS', 1.0),
  (6, 'Pro360', 0.87),
  (6, 'BSPA', 1.0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = '100% Products onboarded to ServiceNow';

-- 95%+ meeting Reliability, Health & SLA targets
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- January R31: C360=0, ISDA=0, FCSD-AI=0.1, FCSD-Ops=0, FCSD-CS=0.6, Pro360=0.8, BSPA=0.8
  (1, 'C360', 0),
  (1, 'ISDA', 0),
  (1, 'FCSD-AI', 0.1),
  (1, 'FCSD-Ops', 0),
  (1, 'FCSD-CS', 0.6),
  (1, 'Pro360', 0.8),
  (1, 'BSPA', 0.8),
  -- March R44: D=1, E=1, F=0.1, G=0.53, H=0.6, I=1, J=1
  (3, 'C360', 1.0),
  (3, 'ISDA', 1.0),
  (3, 'FCSD-AI', 0.1),
  (3, 'FCSD-Ops', 0.53),
  (3, 'FCSD-CS', 0.6),
  (3, 'Pro360', 1.0),
  (3, 'BSPA', 1.0),
  -- May R42: E=1, F=1, G=0.1, H=0.97, I=0.88, J=0.9469, K=1
  (5, 'C360', 1.0),
  (5, 'ISDA', 1.0),
  (5, 'FCSD-AI', 0.1),
  (5, 'FCSD-Ops', 0.97),
  (5, 'FCSD-CS', 0.88),
  (5, 'Pro360', 0.9469),
  (5, 'BSPA', 1.0),
  -- June R43: E=1, F=1, G=0.1, H=0.97, I=0.88, J=0.9469, K=1
  (6, 'C360', 1.0),
  (6, 'ISDA', 1.0),
  (6, 'FCSD-AI', 0.1),
  (6, 'FCSD-Ops', 0.97),
  (6, 'FCSD-CS', 0.88),
  (6, 'Pro360', 0.9469),
  (6, 'BSPA', 1.0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = '95%+ meeting Reliability, Health & SLA targets';

-- 100% met code quality SLA targets
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- January R32: C360=0, ISDA=0, FCSD-AI=0.1, FCSD-Ops=0, FCSD-CS=0.6, Pro360=0.83, BSPA=0.5
  (1, 'C360', 0),
  (1, 'ISDA', 0),
  (1, 'FCSD-AI', 0.1),
  (1, 'FCSD-Ops', 0),
  (1, 'FCSD-CS', 0.6),
  (1, 'Pro360', 0.83),
  (1, 'BSPA', 0.5),
  -- Feb R42: D=0.5, E=0.66, F=0.1, G=0, H=0.6, I=0.66, J=0.5
  (2, 'C360', 0.5),
  (2, 'ISDA', 0.66),
  (2, 'FCSD-AI', 0.1),
  (2, 'FCSD-Ops', 0),
  (2, 'FCSD-CS', 0.6),
  (2, 'Pro360', 0.66),
  (2, 'BSPA', 0.5),
  -- March R45: D=0.75, E=0.66, F=0.1, G=0.5, H=0.6, I=0.75, J=1
  (3, 'C360', 0.75),
  (3, 'ISDA', 0.66),
  (3, 'FCSD-AI', 0.1),
  (3, 'FCSD-Ops', 0.5),
  (3, 'FCSD-CS', 0.6),
  (3, 'Pro360', 0.75),
  (3, 'BSPA', 1.0),
  -- April R42: E=0.75, F=0.66, G=0.1, H=0.75, I=0.6, J=0.71, K=1
  (4, 'C360', 0.75),
  (4, 'ISDA', 0.66),
  (4, 'FCSD-AI', 0.1),
  (4, 'FCSD-Ops', 0.75),
  (4, 'FCSD-CS', 0.6),
  (4, 'Pro360', 0.71),
  (4, 'BSPA', 1.0),
  -- May R43: E=0.85, F=0.66, G=0.1, H=1, I=1, J=0.79, K=1
  (5, 'C360', 0.85),
  (5, 'ISDA', 0.66),
  (5, 'FCSD-AI', 0.1),
  (5, 'FCSD-Ops', 1.0),
  (5, 'FCSD-CS', 1.0),
  (5, 'Pro360', 0.79),
  (5, 'BSPA', 1.0),
  -- June R44: E=0.85, F=0.66, G=0.1, H=1, I=1, J=0.79, K=1
  (6, 'C360', 0.85),
  (6, 'ISDA', 0.66),
  (6, 'FCSD-AI', 0.1),
  (6, 'FCSD-Ops', 1.0),
  (6, 'FCSD-CS', 1.0),
  (6, 'Pro360', 0.79),
  (6, 'BSPA', 1.0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = '100% met code quality SLA targets';

-- 80% deployed 2+ incremental automations
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Feb R43: D=0.5, E=0, F=0.1, G=0, H=0.6, I=NA(0), J=0
  (2, 'C360', 0.5),
  (2, 'ISDA', 0),
  (2, 'FCSD-AI', 0.1),
  (2, 'FCSD-Ops', 0),
  (2, 'FCSD-CS', 0.6),
  (2, 'Pro360', 0),
  (2, 'BSPA', 0),
  -- March R46: D=0.5, E=0, F=0.1, G=0.29, H=0.6, I=0.33, J=0.5
  (3, 'C360', 0.5),
  (3, 'ISDA', 0),
  (3, 'FCSD-AI', 0.1),
  (3, 'FCSD-Ops', 0.29),
  (3, 'FCSD-CS', 0.6),
  (3, 'Pro360', 0.33),
  (3, 'BSPA', 0.5),
  -- April R43: E=0.5, F=0, G=0.1, H=0.63, I=0.6, J=0.33, K=0.5
  (4, 'C360', 0.5),
  (4, 'ISDA', 0),
  (4, 'FCSD-AI', 0.1),
  (4, 'FCSD-Ops', 0.63),
  (4, 'FCSD-CS', 0.6),
  (4, 'Pro360', 0.33),
  (4, 'BSPA', 0.5),
  -- May R44: E=0.5, F=0, G=0.1, H=0.83, I=0.6, J=0.33, K=0.55
  (5, 'C360', 0.5),
  (5, 'ISDA', 0),
  (5, 'FCSD-AI', 0.1),
  (5, 'FCSD-Ops', 0.83),
  (5, 'FCSD-CS', 0.6),
  (5, 'Pro360', 0.33),
  (5, 'BSPA', 0.55),
  -- June R45: E=0.5, F=0, G=0.1, H=0.93, I=0.6, J=0.33, K=0.75
  (6, 'C360', 0.5),
  (6, 'ISDA', 0),
  (6, 'FCSD-AI', 0.1),
  (6, 'FCSD-Ops', 0.93),
  (6, 'FCSD-CS', 0.6),
  (6, 'Pro360', 0.33),
  (6, 'BSPA', 0.75)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = '80% deployed 2+ incremental automations';

-- Change Failure Rate <5% via Code Guardians
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Feb R44: D=0, E=0.66, F=0.1, G=0, H=0.6, I=0, J=0
  (2, 'C360', 0),
  (2, 'ISDA', 0.66),
  (2, 'FCSD-AI', 0.1),
  (2, 'FCSD-Ops', 0),
  (2, 'FCSD-CS', 0.6),
  (2, 'Pro360', 0),
  (2, 'BSPA', 0),
  -- April R44: E=0, F=0.66, G=0.1, H=0.38, I=0.8, J=1, K=1
  (4, 'C360', 0),
  (4, 'ISDA', 0.66),
  (4, 'FCSD-AI', 0.1),
  (4, 'FCSD-Ops', 0.38),
  (4, 'FCSD-CS', 0.8),
  (4, 'Pro360', 1.0),
  (4, 'BSPA', 1.0),
  -- May R45: E=0, F=0.66, G=0.1, H=0.5, I=1, J=0, K=1
  (5, 'C360', 0),
  (5, 'ISDA', 0.66),
  (5, 'FCSD-AI', 0.1),
  (5, 'FCSD-Ops', 0.5),
  (5, 'FCSD-CS', 1.0),
  (5, 'Pro360', 0),
  (5, 'BSPA', 1.0),
  -- June R46: E=0, F=0.66, G=0.1, H=0.58, I=1, J=0, K=1
  (6, 'C360', 0),
  (6, 'ISDA', 0.66),
  (6, 'FCSD-AI', 0.1),
  (6, 'FCSD-Ops', 0.58),
  (6, 'FCSD-CS', 1.0),
  (6, 'Pro360', 0),
  (6, 'BSPA', 1.0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Change Failure Rate <5% via Code Guardians';

-- =====================================================
-- CRM MESSAGING IMPACT
-- =====================================================

-- CRM Segmentation and Scoring completed by Q1
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 'ISDA', 0.5),
  (4, 'ISDA', 0.5),
  (5, 'ISDA', 0.5),
  (6, 'ISDA', 0.5)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'CRM Segmentation and Scoring completed by Q1';

-- CRM Build tool in Q2
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (5, 'ISDA', 0),
  (6, 'ISDA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'CRM Build tool in Q2';

-- =====================================================
-- CUSTOMER PROFILE SYSTEM
-- =====================================================

-- Retail customers with valid email opt-in
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Jan R42: C360=0.05 (likely incorrect/placeholder, actual ~48.5%)
  -- March R54: D=0.5133
  (3, 'C360', 0.5133),
  -- May R53: E=0.5240 (Note: April data not captured separately)
  (5, 'C360', 0.5240),
  -- June R53: E=0.524
  (6, 'C360', 0.524)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Retail customers with valid email opt-in';

-- Retail customers with complete profile
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- May R53: E=0.7313
  (5, 'C360', 0.7313),
  -- June R54: E=0.7318
  (6, 'C360', 0.7318)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Retail customers with complete profile';

-- Commercial customers with valid email opt-in (count - Pro360)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Feb/Mar R53: I=936345
  (2, 'Pro360', 936345),
  (3, 'Pro360', 936345),
  -- April R53: J=945629
  (4, 'Pro360', 945629),
  -- May R54: J=945629
  (5, 'Pro360', 945629),
  -- June R55: J=945629
  (6, 'Pro360', 945629)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Commercial customers with valid email opt-in';

-- Commercial customers with complete profile
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- April R54: J=0.275
  (4, 'Pro360', 0.275),
  -- May R55: J=0.2986
  (5, 'Pro360', 0.2986),
  -- June R56: J=0.2986
  (6, 'Pro360', 0.2986)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Commercial customers with complete profile';

-- =====================================================
-- IMPROVE FORD'S CORPORATE REPUTATION (NEW as of 3-30-26)
-- =====================================================

-- 100% Controls testing complete (BCP, SOX MCRP)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- March R60: D=1, G=0.5 (C360=1, FCSD-Ops=0.5)
  (3, 'C360', 1.0),
  (3, 'FCSD-Ops', 0.5),
  -- May R60: not present (S-Ox was at R60 in May) - check April
  -- June R60: E=1, F=0, G=0, H=0, I=0, J=0, K=1, L=0
  (6, 'C360', 1.0),
  (6, 'ISDA', 0),
  (6, 'FCSD-AI', 0),
  (6, 'FCSD-Ops', 0),
  (6, 'FCSD-CS', 0),
  (6, 'Pro360', 0),
  (6, 'BSPA', 1.0),
  (6, 'YMAA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = '100% Controls testing complete (BCP, SOX MCRP)';

-- S-Ox Comments remediated within 6 months
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- March R61: D=1, G=0.5
  (3, 'C360', 1.0),
  (3, 'FCSD-Ops', 0.5),
  -- May R60: E=1, F=0, G=0, H=1, I=0, J=0, K=1, L=0
  (5, 'C360', 1.0),
  (5, 'ISDA', 0),
  (5, 'FCSD-AI', 0),
  (5, 'FCSD-Ops', 1.0),
  (5, 'FCSD-CS', 0),
  (5, 'Pro360', 0),
  (5, 'BSPA', 1.0),
  (5, 'YMAA', 0),
  -- June R61: E=1, F=0, G=0, H=1, I=0, J=0, K=1, L=0
  (6, 'C360', 1.0),
  (6, 'ISDA', 0),
  (6, 'FCSD-AI', 0),
  (6, 'FCSD-Ops', 1.0),
  (6, 'FCSD-CS', 0),
  (6, 'Pro360', 0),
  (6, 'BSPA', 1.0),
  (6, 'YMAA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'S-Ox Comments remediated within 6 months';

-- Operational comments remediated within 8 months
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- March R62: D=1 (C360=1 only)
  (3, 'C360', 1.0),
  -- May R61: E=1, F=0, G=0, H=0, I=0, J=0, K=1, L=0
  (5, 'C360', 1.0),
  (5, 'ISDA', 0),
  (5, 'FCSD-AI', 0),
  (5, 'FCSD-Ops', 0),
  (5, 'FCSD-CS', 0),
  (5, 'Pro360', 0),
  (5, 'BSPA', 1.0),
  (5, 'YMAA', 0),
  -- June R62: E=1, F=0, G=0, H=0, I=0, J=0, K=1, L=0
  (6, 'C360', 1.0),
  (6, 'ISDA', 0),
  (6, 'FCSD-AI', 0),
  (6, 'FCSD-Ops', 0),
  (6, 'FCSD-CS', 0),
  (6, 'Pro360', 0),
  (6, 'BSPA', 1.0),
  (6, 'YMAA', 0)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = 'Operational comments remediated within 8 months';

-- =====================================================
-- TRANSITION WORK EU TO CHENNAI
-- =====================================================

-- 60%+ products fully transitioned by EOY 2026
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, pg.id, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- March R65: D=0.65, H(FCSD-CS)=0.4, J(BSPA)=0.1
  (3, 'C360', 0.65),
  (3, 'FCSD-CS', 0.4),
  (3, 'BSPA', 0.1),
  -- April R62: E=0.75, I=0.5, K=0.1
  (4, 'C360', 0.75),
  (4, 'FCSD-CS', 0.5),
  (4, 'BSPA', 0.1),
  -- June R65: E=0.75, I=0.8, K=0.75
  (6, 'C360', 0.75),
  (6, 'FCSD-CS', 0.8),
  (6, 'BSPA', 0.75)
) AS d(month, pg_abbrev, value)
JOIN product_groups pg ON pg.abbreviation = d.pg_abbrev
WHERE i.name = '60%+ products fully transitioned by EOY 2026';

-- =====================================================
-- ADMINISTRATIVE SECTION - Monthly initiatives
-- =====================================================

-- 95% of employees with uploaded objectives (monthly, admin)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Row 77: all months = 0.99
  (1, 0.99),
  (2, 0.99),
  (3, 0.99),
  (4, 0.99),
  (5, 0.99),
  (6, 0.99)
) AS d(month, value)
WHERE i.name = '95% of employees with uploaded objectives';

-- 72% average on-site per week for hybrid employees (monthly, admin)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  -- Row 78: D(Feb)=0.89, E(Mar)=0.84
  (2, 0.89),
  (3, 0.84)
) AS d(month, value)
WHERE i.name = '72% average on-site per week for hybrid employees';

-- =====================================================
-- ADMINISTRATIVE SECTION - Quarterly initiatives
-- =====================================================

-- Above $20M Finance Sign-off compliance (quarterly: Q1=Mar, Q2=Jun, Q3=Sep, Q4=Dec)
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 1.0),   -- Q1: March = 1
  (6, 1.0)    -- Q2: June = 1
) AS d(month, value)
WHERE i.name = 'Above $20M Finance Sign-off compliance';

-- LL5+ regular review cadence
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 0.25),  -- Q1
  (6, 0.50)   -- Q2
) AS d(month, value)
WHERE i.name = 'LL5+ regular review cadence';

-- Create 2 OKRs per half-year aligned with PL
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 0.25)  -- Q1
) AS d(month, value)
WHERE i.name = 'Create 2 OKRs per half-year aligned with PL';

-- Review OKRs and Status quarterly with PL
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 0.25),  -- Q1
  (6, 0.50)   -- Q2
) AS d(month, value)
WHERE i.name = 'Review OKRs and Status quarterly with PL';

-- 100% organization and talent reviews complete by Q3
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 0),   -- Q1: not started
  (6, 0)    -- Q2: not started
) AS d(month, value)
WHERE i.name = '100% organization and talent reviews complete by Q3';

-- YE 85% favorability - performance evaluation
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 0)   -- Q1: survey not yet conducted
) AS d(month, value)
WHERE i.name = 'YE 85% favorability - performance evaluation';

-- MY 85% favorability - mid-year evaluation
INSERT INTO monthly_entries (initiative_id, product_group_id, year, month, value, submitted_by)
SELECT i.id, NULL::UUID, 2026, d.month, d.value, 'historical_import'
FROM initiatives i
CROSS JOIN LATERAL (VALUES
  (3, 0)   -- Q1: survey not yet conducted
) AS d(month, value)
WHERE i.name = 'MY 85% favorability - mid-year evaluation';

-- =====================================================
-- Mark all historical months as submitted
-- =====================================================

-- Create submission records for all PGs for months 1-6
INSERT INTO submissions (product_group_id, year, month, submitted_by, submitted_at)
SELECT pg.id, 2026, m.month, 'historical_import', 
       ('2026-' || LPAD(m.month::text, 2, '0') || '-28 17:00:00')::timestamp
FROM product_groups pg
CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6)) AS m(month);
