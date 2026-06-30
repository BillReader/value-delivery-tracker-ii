-- =====================================================
-- Value Delivery Tracker II - Initiative Assignments
-- Run this AFTER seed-initiatives.sql
-- Maps which product groups are assigned to which initiatives
-- =====================================================

-- Helper function to insert assignments by initiative name and PG abbreviation
-- We'll do this with explicit inserts for clarity

-- Direct Financial Impact: ROI Dollars - All PGs
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'ROI Dollars - Total Benefits'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- Direct Financial Impact: ROI Percentage - All PGs
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'ROI Percentage'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- Indirect Financial Impact: Hours Saved - BSPA only (others had N/A)
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Indirect Financial Impact - Hours Saved ROI'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- AI Big Bet EBIT YTD: FCSD line -> FCSD-AI, FCSD-Ops, FCSD-CS, BSPA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'FCSD AI Big Bet EBIT YTD ($107M annual target)'
AND pg.abbreviation IN ('FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'BSPA');

-- AI Big Bet EBIT YTD: Pro line -> Pro360
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Pro AI Big Bet EBIT YTD ($5M annual target)'
AND pg.abbreviation IN ('Pro360');

-- AI Big Bet EBIT YTD: C&I line -> BSPA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'C&I AI Big Bet EBIT YTD ($10M annual target)'
AND pg.abbreviation IN ('BSPA');

-- AI Big Bet EBIT YTD: S&OP line -> YMAA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'S&OP AI Big Bet EBIT YTD ($15M annual target)'
AND pg.abbreviation IN ('YMAA');

-- AI Big Bet Annual Forecast: FCSD -> FCSD-AI, FCSD-Ops, FCSD-CS
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'FCSD Annual Forecast ($107M target)'
AND pg.abbreviation IN ('FCSD-AI', 'FCSD-Ops', 'FCSD-CS');

-- AI Big Bet Annual Forecast: Pro -> Pro360
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Pro Annual Forecast ($5M target)'
AND pg.abbreviation IN ('Pro360');

-- AI Big Bet Annual Forecast: C&I -> BSPA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'C&I Annual Forecast ($10M target)'
AND pg.abbreviation IN ('BSPA');

-- AI Big Bet Annual Forecast: S&OP -> YMAA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'S&OP Annual Forecast ($15M target)'
AND pg.abbreviation IN ('YMAA');

-- Top-of-Funnel: Blue/e -> BSPA, YMAA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Blue/e Top-of-Funnel AI (+$50M 2027)'
AND pg.abbreviation IN ('BSPA', 'YMAA');

-- Top-of-Funnel: Pro -> Pro360
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Pro Top-of-Funnel AI (+$75M 2027)'
AND pg.abbreviation IN ('Pro360');

-- Top-of-Funnel: IS -> ISDA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'IS Top-of-Funnel AI (+$50M 2027)'
AND pg.abbreviation IN ('ISDA');

-- AI Data Readiness: All PGs except YMAA (had dash = assigned per user)
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Achieve Data Readiness Score of 6/10'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- UDP Delivered: FCSD-AI, FCSD-Ops
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Deliver Unified Data Platform Framework'
AND pg.abbreviation IN ('FCSD-AI', 'FCSD-Ops');

-- Delivery Pace: All PGs (YMAA had dash = assigned)
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Demonstrate enhanced AI effectiveness (2+ AI tools)'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Review AI KPI progress and status monthly'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Submit Efficiency Award demonstrating AI efficiency'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- Personal Gemba: All PGs (YMAA had dash = assigned)
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = '1 Team improvement KPI documented/resolved per quarter'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Review GEMBA KPI and status quarterly'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- Recall Enterprise Capabilities: FCSD-Ops only
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Deliver Two (2) Recall Enterprise Capabilities'
AND pg.abbreviation IN ('FCSD-Ops');

-- Product & Services KPI Targets: All PGs (YMAA had dash = assigned)
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = '100% Products onboarded to ServiceNow'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = '95%+ meeting Reliability, Health & SLA targets'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = '100% met code quality SLA targets'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = '80% deployed 2+ incremental automations'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Change Failure Rate <5% via Code Guardians'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- CRM Messaging Impact: ISDA only
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'CRM Segmentation and Scoring completed by Q1'
AND pg.abbreviation IN ('ISDA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'CRM Build tool in Q2'
AND pg.abbreviation IN ('ISDA');

-- Customer Profile System: C360 for retail, Pro360 for commercial
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Retail customers with valid email opt-in'
AND pg.abbreviation IN ('C360');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Retail customers with complete profile'
AND pg.abbreviation IN ('C360');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Commercial customers with valid email opt-in'
AND pg.abbreviation IN ('Pro360');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Commercial customers with complete profile'
AND pg.abbreviation IN ('Pro360');

-- Improve Ford's Corporate Reputation: All PGs
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = '100% Controls testing complete (BCP, SOX MCRP)'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'S-Ox Comments remediated within 6 months'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = 'Operational comments remediated within 8 months'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'Pro360', 'BSPA', 'YMAA');

-- Transition Work EU to Chennai: C360, FCSD-CS, BSPA
INSERT INTO initiative_assignments (initiative_id, product_group_id)
SELECT i.id, pg.id
FROM initiatives i, product_groups pg
WHERE i.name = '60%+ products fully transitioned by EOY 2026'
AND pg.abbreviation IN ('C360', 'ISDA', 'FCSD-CS', 'BSPA');

-- =====================================================
-- Default Thresholds for ALL initiatives
-- Green >= 85% of goal, Yellow >= 65% of goal
-- =====================================================

INSERT INTO initiative_thresholds (initiative_id, green_min, yellow_min)
SELECT id, 0.85, 0.65
FROM initiatives;
