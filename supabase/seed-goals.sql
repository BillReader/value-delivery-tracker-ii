-- =====================================================
-- Value Delivery Tracker II - Initiative Goals (2026)
-- Run this AFTER seed-assignments.sql
-- Goals are at the SSDA level (monthly targets)
-- =====================================================

-- Helper: For initiatives with fixed monthly targets, we insert all 12 months.
-- For ramping targets, we calculate per-month values.

-- =====================================================
-- AI Big Bet EBIT YTD - Ramping targets (cumulative monthly)
-- FCSD: $107M annual = $8.92M/month cumulative
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, m.month * 8920000
FROM initiatives i, 
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'FCSD AI Big Bet EBIT YTD ($107M annual target)';

-- Pro: $5M annual = $420K/month cumulative
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, m.month * 420000
FROM initiatives i, 
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Pro AI Big Bet EBIT YTD ($5M annual target)';

-- C&I: $10M annual = $833K/month cumulative
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, m.month * 833000
FROM initiatives i, 
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'C&I AI Big Bet EBIT YTD ($10M annual target)';

-- S&OP: $15M annual = $1.25M/month cumulative
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, m.month * 1250000
FROM initiatives i, 
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'S&OP AI Big Bet EBIT YTD ($15M annual target)';

-- =====================================================
-- AI Big Bet Annual Forecast - Fixed full-year targets
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 107000000
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'FCSD Annual Forecast ($107M target)';

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 5000000
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Pro Annual Forecast ($5M target)';

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 10000000
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'C&I Annual Forecast ($10M target)';

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 15000000
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'S&OP Annual Forecast ($15M target)';

-- =====================================================
-- Top-of-Funnel: No numeric goal (N/A in spreadsheet)
-- We'll store NULL to indicate no target comparison
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, NULL
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name IN (
  'Blue/e Top-of-Funnel AI (+$50M 2027)',
  'Pro Top-of-Funnel AI (+$75M 2027)',
  'IS Top-of-Funnel AI (+$50M 2027)'
);

-- =====================================================
-- Data Readiness: Score target = 0.6 (6 out of 10)
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.6
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Achieve Data Readiness Score of 6/10';

-- UDP: N/A target
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, NULL
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Deliver Unified Data Platform Framework';

-- =====================================================
-- Delivery Pace: Percentage targets
-- =====================================================

-- Enhanced AI effectiveness: 75% target
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.75
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Demonstrate enhanced AI effectiveness (2+ AI tools)';

-- Review AI KPI: 100% target
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 1.0
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Review AI KPI progress and status monthly';

-- Submit Efficiency Award: 25% per quarter ramping (25%, 50%, 75%, 100%)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026,
  CASE WHEN m.month <= 3 THEN 0.25
       WHEN m.month <= 6 THEN 0.50
       WHEN m.month <= 9 THEN 0.75
       ELSE 1.0 END
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Submit Efficiency Award demonstrating AI efficiency';

-- =====================================================
-- Personal Gemba: Resets quarterly (33% per mo within quarter)
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026,
  CASE WHEN m.month % 3 = 1 THEN 0.33
       WHEN m.month % 3 = 2 THEN 0.66
       ELSE 1.0 END
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '1 Team improvement KPI documented/resolved per quarter';

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026,
  CASE WHEN m.month % 3 = 1 THEN 0.33
       WHEN m.month % 3 = 2 THEN 0.66
       ELSE 1.0 END
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Review GEMBA KPI and status quarterly';

-- =====================================================
-- Recall Enterprise Capabilities: N/A target (count-based)
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, NULL
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Deliver Two (2) Recall Enterprise Capabilities';

-- =====================================================
-- Product & Services KPI Targets
-- =====================================================

-- ServiceNow: 100%
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 1.0
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '100% Products onboarded to ServiceNow';

-- Reliability/SLA: 95%
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.95
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '95%+ meeting Reliability, Health & SLA targets';

-- Code quality: 100%
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 1.0
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '100% met code quality SLA targets';

-- Automation: 80%
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.80
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '80% deployed 2+ incremental automations';

-- Change Failure Rate: 100% (goal is 100% compliance with Code Guardians)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 1.0
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Change Failure Rate <5% via Code Guardians';

-- =====================================================
-- CRM Messaging Impact: Ramping targets
-- =====================================================

-- Segmentation: 33% per month in Q1 (Jan=33%, Feb=66%, Mar=100%, then stays 100%)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026,
  CASE WHEN m.month = 1 THEN 0.33
       WHEN m.month = 2 THEN 0.66
       ELSE 1.0 END
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'CRM Segmentation and Scoring completed by Q1';

-- Build tool: 33% per month in Q2 (Apr=33%, May=66%, Jun=100%, then stays 100%)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026,
  CASE WHEN m.month <= 3 THEN 0.0
       WHEN m.month = 4 THEN 0.33
       WHEN m.month = 5 THEN 0.66
       ELSE 1.0 END
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'CRM Build tool in Q2';

-- =====================================================
-- Customer Profile System
-- =====================================================

-- Retail email opt-in: ~50.7% target (from June C column)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.507
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Retail customers with valid email opt-in';

-- Retail complete profile: ~75.29% target
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.7529
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Retail customers with complete profile';

-- Commercial email opt-in: 1,020,000 target (count)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 1020000
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Commercial customers with valid email opt-in';

-- Commercial complete profile: 54.2% target
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.542
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Commercial customers with complete profile';

-- =====================================================
-- Improve Ford's Corporate Reputation: 100% targets
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 1.0
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name IN (
  '100% Controls testing complete (BCP, SOX MCRP)',
  'S-Ox Comments remediated within 6 months',
  'Operational comments remediated within 8 months'
);

-- =====================================================
-- Transition Work: Ramping to 60% by EOY (8% per month)
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, m.month * 0.05
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '60%+ products fully transitioned by EOY 2026';

-- =====================================================
-- Direct Financial Impact: ROI target = 1.6 (160%)
-- =====================================================

INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 1.6
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'ROI Percentage';

-- ROI Dollars and Hours Saved: No fixed target (varies by PG)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, NULL
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name IN (
  'ROI Dollars - Total Benefits',
  'Indirect Financial Impact - Hours Saved ROI'
);

-- =====================================================
-- Administrative Initiatives Goals
-- =====================================================

-- 95% employees with uploaded objectives (monthly, target = 0.95)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.95
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '95% of employees with uploaded objectives';

-- 72% on-site (monthly, target = 0.72)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.72
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = '72% average on-site per week for hybrid employees';

-- Quarterly admin initiatives: quarterly targets (Q1=0.25, Q2=0.5, Q3=0.75, Q4=1.0)
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026,
  CASE WHEN m.month <= 3 THEN 0.25
       WHEN m.month <= 6 THEN 0.50
       WHEN m.month <= 9 THEN 0.75
       ELSE 1.0 END
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name IN (
  'Above $20M Finance Sign-off compliance',
  'LL5+ regular review cadence',
  'Create 2 OKRs per half-year aligned with PL',
  'Review OKRs and Status quarterly with PL',
  '100% organization and talent reviews complete by Q3'
);

-- GDIA objectives: No fixed numeric target
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, NULL
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'GDIA objectives contributing to Business Leader L3+ objectives';

-- NPS: target score of 50
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 50
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name = 'Net Promoter Score (NPS) - How helpful was GDIA';

-- Performance eval favorability: 85%
INSERT INTO initiative_goals (initiative_id, month, year, target_value)
SELECT i.id, m.month, 2026, 0.85
FROM initiatives i,
  (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(month)
WHERE i.name IN (
  'YE 85% favorability - performance evaluation',
  'MY 85% favorability - mid-year evaluation'
);
