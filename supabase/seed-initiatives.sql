-- =====================================================
-- Value Delivery Tracker II - Seed Initiatives & Assignments
-- Run this AFTER schema.sql in your Supabase SQL Editor
-- =====================================================

-- Helper: Get category IDs
-- We'll use CTEs to reference categories by name

-- =====================================================
-- INITIATIVES: Product Group Section
-- =====================================================

-- Category: Direct Financial Impact (L2.4.3)
WITH cat AS (SELECT id FROM categories WHERE code = 'L2.4.3')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('ROI Dollars - Total Benefits', 'For products within your product group that have a direct financial impact, estimate your product group''s projected EOY total benefits.', 'dollar', 1),
  ('ROI Percentage', 'ROI % = (total benefits - total costs) / total costs. Minimum ROI = 160%.', 'roi', 2),
  ('Indirect Financial Impact - Hours Saved ROI', 'For products that do not have a direct financial impact, estimate hours saved ROI % = (hours saved x hourly rate - total costs) / total costs.', 'roi', 3)
) AS t(name, description, metric_type, display_order);

-- Category: AI Big Bet EBIT: Year-To-Date (L2.4.2)
WITH cat AS (SELECT id FROM categories WHERE code = 'L2.4.2')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('FCSD AI Big Bet EBIT YTD ($107M annual target)', 'Enter YTD EBIT ($) in light blue cell. In Notes, itemize that YTD total by initiative (initiative name + $ contribution).', 'dollar', 1),
  ('Pro AI Big Bet EBIT YTD ($5M annual target)', 'Enter YTD EBIT ($) in light blue cell.', 'dollar', 2),
  ('C&I AI Big Bet EBIT YTD ($10M annual target)', 'Enter YTD EBIT ($) in light blue cell.', 'dollar', 3),
  ('S&OP AI Big Bet EBIT YTD ($15M annual target)', 'Enter YTD EBIT ($) in light blue cell.', 'dollar', 4)
) AS t(name, description, metric_type, display_order);

-- Category: AI Big Bet EBIT: Annual Forecast
WITH cat AS (SELECT id FROM categories WHERE name = 'AI Big Bet EBIT: Annual Forecast')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('FCSD Annual Forecast ($107M target)', 'Enter Annual Forecast EBIT ($) in light blue cell.', 'dollar', 1),
  ('Pro Annual Forecast ($5M target)', 'Enter Annual Forecast EBIT ($) in light blue cell.', 'dollar', 2),
  ('C&I Annual Forecast ($10M target)', 'Enter Annual Forecast EBIT ($) in light blue cell.', 'dollar', 3),
  ('S&OP Annual Forecast ($15M target)', 'Enter Annual Forecast EBIT ($) in light blue cell.', 'dollar', 4)
) AS t(name, description, metric_type, display_order);

-- Category: AI Big Bets: Top-of-Funnel Projects (L2.4.5)
WITH cat AS (SELECT id FROM categories WHERE code = 'L2.4.5')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('Blue/e Top-of-Funnel AI (+$50M 2027)', 'Identify top-of-funnel AI Big Bet opportunities that can deliver incremental EBIT beyond current commitments.', 'dollar', 1),
  ('Pro Top-of-Funnel AI (+$75M 2027)', 'Identify top-of-funnel AI Big Bet opportunities that can deliver incremental EBIT beyond current commitments.', 'dollar', 2),
  ('IS Top-of-Funnel AI (+$50M 2027)', 'Identify top-of-funnel AI Big Bet opportunities that can deliver incremental EBIT beyond current commitments.', 'dollar', 3)
) AS t(name, description, metric_type, display_order);

-- Category: AI Data Readiness (L2.2.3)
WITH cat AS (SELECT id FROM categories WHERE code = 'L2.2.3')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('Achieve Data Readiness Score of 6/10', 'Achieve a Data Readiness Score of 6/10 across all data products to unlock advanced AI modeling.', 'score', 1),
  ('Deliver Unified Data Platform Framework', 'Deliver the Unified Data Platform Framework in Q1 onboarding first 2 data products Q2.', 'percentage', 2)
) AS t(name, description, metric_type, display_order);

-- Category: Delivery Pace (L2.2.4)
WITH cat AS (SELECT id FROM categories WHERE code = 'L2.2.4')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('Demonstrate enhanced AI effectiveness (2+ AI tools)', 'Each Product Team/Line within your product group should define one measurable KPI that addresses a key delivery impediment. Scoring is based solely on percentage of teams with a documented KPI.', 'percentage', 1),
  ('Review AI KPI progress and status monthly', 'Score this initiative at 100% if your product group''s People Leaders are conducting monthly reviews of the Delivery Pace KPIs.', 'percentage', 2),
  ('Submit Efficiency Award demonstrating AI efficiency', 'Score this initiative based on the percentage of product teams within your group that have submitted for a GDIA Efficiency Award. 25% per quarter.', 'percentage', 3)
) AS t(name, description, metric_type, display_order);

-- Category: Personal Gemba (L2.7.1)
WITH cat AS (SELECT id FROM categories WHERE code = 'L2.7.1')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('1 Team improvement KPI documented/resolved per quarter', 'Each Product Team/Line within your product group should document and resolve one measurable improvement KPI per quarter based on a Gemba. Scoring is based on percentage of teams. 33% per month, resetting to 0% at beginning of each quarter.', 'percentage', 1),
  ('Review GEMBA KPI and status quarterly', 'Review the Improvement KPI and its status with your PL at least once per quarter. 33% per month, resetting to 0% at beginning of each quarter.', 'percentage', 2)
) AS t(name, description, metric_type, display_order);

-- Category: Recall Enterprise Capabilities (L2.6.1)
WITH cat AS (SELECT id FROM categories WHERE code = 'L2.6.1')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('Deliver Two (2) Recall Enterprise Capabilities', 'Increment the score each time a NHTSA Consent Order obligation is completed (e.g., 1, 2, 3, etc.). Use the Notes column to document the specific obligation met and any relevant details.', 'count', 1)
) AS t(name, description, metric_type, display_order);

-- Category: Product & Services KPI Targets
WITH cat AS (SELECT id FROM categories WHERE name = 'Product & Services KPI Targets')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('100% Products onboarded to ServiceNow', '100% of Products and Services onboarded to ServiceNow for Incident Management and meeting MTTD, MTTA, MTTN, and MTTR targets.', 'percentage', 1),
  ('95%+ meeting Reliability, Health & SLA targets', '95%+ of in-scope Products and Services meeting Reliability, Health & Relevancy and SLA targets (KPIs may include API Response time, Data Completeness, Freshness, etc.).', 'percentage', 2),
  ('100% met code quality SLA targets', '100% of in-scope Products and Services met organization code quality SLA targets and quality gates are integrated in CI/CD pipelines.', 'percentage', 3),
  ('80% deployed 2+ incremental automations', '80% of Products and Services deployed at least 2 incremental automations per product/Service, achieving efficiency and toil reduction in operations.', 'percentage', 4),
  ('Change Failure Rate <5% via Code Guardians', 'Achieve a Change Failure Rate (CFR) of less than 5% by enforcing Code Guardians as the mandatory quality gate for 100% of code merges.', 'percentage', 5)
) AS t(name, description, metric_type, display_order);

-- Category: CRM Messaging Impact
WITH cat AS (SELECT id FROM categories WHERE name = 'CRM Messaging Impact')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('CRM Segmentation and Scoring completed by Q1', 'Report percentage complete based on actual progress toward full delivery (0-99% until complete). Reflect 100% only once the initiative is fully complete. 33% per month starting in January.', 'percentage', 1),
  ('CRM Build tool in Q2', 'Report percentage complete based on actual progress. 33% per month starting in April, culminating to 100% by end of Q2.', 'percentage', 2)
) AS t(name, description, metric_type, display_order);

-- Category: Customer Profile System
WITH cat AS (SELECT id FROM categories WHERE name = 'Customer Profile System')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('Retail customers with valid email opt-in', 'Increase % of NA and EU retail customers who have at least 1 contact opted in to communications with a valid email.', 'percentage', 1),
  ('Retail customers with complete profile', 'Increase % of NA and EU retail customers with a complete customer profile from ~73% to ~75%.', 'percentage', 2),
  ('Commercial customers with valid email opt-in', 'Increase the number of NA and EU commercial customers who have at least 1 contact opted in to communications with a valid email from 926k to 1.02m.', 'count', 3),
  ('Commercial customers with complete profile', 'Increase % of NA and EU commercial customers with a complete customer profile from ~26% to ~54%.', 'percentage', 4)
) AS t(name, description, metric_type, display_order);

-- Category: Improve Ford's Corporate Reputation
WITH cat AS (SELECT id FROM categories WHERE name LIKE 'Improve Ford%')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('100% Controls testing complete (BCP, SOX MCRP)', '100% Controls testing complete and approved (BCP, SOX MCRP) and on time.', 'percentage', 1),
  ('S-Ox Comments remediated within 6 months', 'S-Ox Comments remediated within 6 months.', 'percentage', 2),
  ('Operational comments remediated within 8 months', 'Operational comments remediated within 8 months.', 'percentage', 3)
) AS t(name, description, metric_type, display_order);

-- Category: Transition Work EU to Chennai
WITH cat AS (SELECT id FROM categories WHERE name = 'Transition Work EU to Chennai')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, 'monthly', display_order FROM cat,
(VALUES
  ('60%+ products fully transitioned by EOY 2026', 'Score based on the actual percentage of in-scope products fully transitioned. 60% or greater represents full achievement for 2026. 95% by end of 2027.', 'percentage', 1)
) AS t(name, description, metric_type, display_order);

-- =====================================================
-- INITIATIVES: Administrative Section
-- =====================================================

WITH cat AS (SELECT id FROM categories WHERE name = 'Administrative')
INSERT INTO initiatives (category_id, name, description, metric_type, frequency, display_order)
SELECT cat.id, name, description, metric_type, frequency, display_order FROM cat,
(VALUES
  ('Above $20M Finance Sign-off compliance', 'Ensure LL5+ do this with their teams. We will monitor and ensure compliance with the Finance sign-off requirement for all initiatives above $20M.', 'percentage', 'quarterly', 1),
  ('LL5+ regular review cadence', 'Established a regular review process with the Portfolio Leader to assess GDIA objectives alignment.', 'percentage', 'quarterly', 2),
  ('GDIA objectives contributing to Business Leader L3+ objectives', 'Percentage of GDIA objectives directly contributing to a Business Leader''s L3+ objectives reviewed by PL.', 'percentage', 'quarterly', 3),
  ('Net Promoter Score (NPS) - How helpful was GDIA', 'NPS based on the question: "How helpful was GDIA achieving their Objectives?", conducted quarterly, score of 50 and trending upward.', 'score', 'quarterly', 4),
  ('Create 2 OKRs per half-year aligned with PL', 'Create 2 OKRs for each half of the year based on the Dev Plan aligned with PL. Leverage GDIA''s "Driving Value Together" learning program.', 'percentage', 'quarterly', 5),
  ('Review OKRs and Status quarterly with PL', 'Reviewing OKRs and status monthly with the Portfolio Leader and Product Group Managers.', 'percentage', 'quarterly', 6),
  ('100% organization and talent reviews complete by Q3', 'Completing organization and talent reviews by Q3 to strengthen the talent pipeline and support effective succession planning.', 'percentage', 'quarterly', 7),
  ('YE 85% favorability - performance evaluation', 'Targeting 85% favorability on year-end performance evaluation feedback.', 'percentage', 'quarterly', 8),
  ('MY 85% favorability - mid-year evaluation', 'Targeting 85% favorability on mid-year performance evaluation feedback.', 'percentage', 'quarterly', 9),
  ('95% of employees with uploaded objectives', 'Driving high-quality objective cascading and review, with a target of at least 95% of employees having approved objectives uploaded.', 'percentage', 'monthly', 10),
  ('72% average on-site per week for hybrid employees', 'Supporting hybrid work expectations, with on-site attendance tracking toward an average of four days per week globally.', 'percentage', 'monthly', 11)
) AS t(name, description, metric_type, frequency, display_order);
