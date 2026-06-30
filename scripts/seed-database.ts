/**
 * Value Delivery Tracker II - Database Seed Script
 * 
 * This script reads the existing Excel spreadsheet and imports
 * historical data (Jan-Jun 2026) into the Supabase database.
 * 
 * Prerequisites:
 *   npm install xlsx @supabase/supabase-js dotenv
 * 
 * Usage:
 *   npx ts-node scripts/seed-database.ts
 * 
 * Or with environment variables:
 *   SUPABASE_URL=... SUPABASE_KEY=... npx ts-node scripts/seed-database.ts
 */

import * as XLSX from 'xlsx';
import { createClient } from '@supabase/supabase-js';
import * as path from 'path';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../.env.local') });

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// Path to the source spreadsheet
const SPREADSHEET_PATH = path.resolve(__dirname, '../../Value Delivery Tracker.xlsx');

// =====================================================
// Column mapping per sheet (months evolved the layout)
// =====================================================

interface ColumnMap {
  ssda: string;
  c360: string;
  isda: string;
  fcsdAi: string;
  fcsdOps: string;
  fcsdCs: string;
  pro360: string;
  bspa: string;
  ymaa: string;
  notes: string;
}

// January (Sheet 1): No Instructions/YTD columns
const JAN_COLS: ColumnMap = {
  ssda: 'B', c360: 'C', isda: 'D', fcsdAi: 'E',
  fcsdOps: 'F', fcsdCs: 'G', pro360: 'H', bspa: 'I',
  ymaa: 'J', notes: 'L'
};

// February-March (Sheets 2-3): Instructions at B, SSDA at C
const FEB_MAR_COLS: ColumnMap = {
  ssda: 'C', c360: 'D', isda: 'E', fcsdAi: 'F',
  fcsdOps: 'G', fcsdCs: 'H', pro360: 'I', bspa: 'J',
  ymaa: 'K', notes: 'L'
};

// April-June (Sheets 4-6): Instructions at B, YTD at C, SSDA at D
const APR_JUN_COLS: ColumnMap = {
  ssda: 'D', c360: 'E', isda: 'F', fcsdAi: 'G',
  fcsdOps: 'H', fcsdCs: 'I', pro360: 'J', bspa: 'K',
  ymaa: 'L', notes: 'M'
};

function getColumnMap(month: number): ColumnMap {
  if (month === 1) return JAN_COLS;
  if (month <= 3) return FEB_MAR_COLS;
  return APR_JUN_COLS;
}

// PG abbreviations in column order
const PG_KEYS: (keyof ColumnMap)[] = [
  'c360', 'isda', 'fcsdAi', 'fcsdOps', 'fcsdCs', 'pro360', 'bspa', 'ymaa'
];

const PG_ABBREV_MAP: Record<string, string> = {
  c360: 'C360',
  isda: 'ISDA',
  fcsdAi: 'FCSD-AI',
  fcsdOps: 'FCSD-Ops',
  fcsdCs: 'FCSD-CS',
  pro360: 'Pro360',
  bspa: 'BSPA',
  ymaa: 'YMAA',
};

// =====================================================
// Row mapping per sheet - which rows contain which initiatives
// This varies by month as the spreadsheet evolved
// =====================================================

interface InitiativeRowMapping {
  initiativeName: string;
  row: number;
  // Which PGs have data in this row (null = use all assigned PGs)
  pgFilter?: string[];
}

// June layout (most complete) - rows in sheet6
const JUNE_ROWS: InitiativeRowMapping[] = [
  // Direct Financial Impact
  { initiativeName: 'ROI Dollars - Total Benefits', row: 3 },
  { initiativeName: 'ROI Percentage', row: 5 },
  // AI Big Bet EBIT YTD
  { initiativeName: 'FCSD AI Big Bet EBIT YTD ($107M annual target)', row: 10, pgFilter: ['FCSD-AI', 'FCSD-Ops', 'FCSD-CS', 'BSPA'] },
  { initiativeName: 'Pro AI Big Bet EBIT YTD ($5M annual target)', row: 11, pgFilter: ['Pro360'] },
  { initiativeName: 'C&I AI Big Bet EBIT YTD ($10M annual target)', row: 12, pgFilter: ['BSPA'] },
  { initiativeName: 'S&OP AI Big Bet EBIT YTD ($15M annual target)', row: 13, pgFilter: ['YMAA'] },
  // Annual Forecast
  { initiativeName: 'FCSD Annual Forecast ($107M target)', row: 16, pgFilter: ['FCSD-AI', 'FCSD-Ops', 'FCSD-CS'] },
  { initiativeName: 'Pro Annual Forecast ($5M target)', row: 17, pgFilter: ['Pro360'] },
  { initiativeName: 'C&I Annual Forecast ($10M target)', row: 18, pgFilter: ['BSPA'] },
  { initiativeName: 'S&OP Annual Forecast ($15M target)', row: 19, pgFilter: ['YMAA'] },
  // Top-of-Funnel
  { initiativeName: 'Blue/e Top-of-Funnel AI (+$50M 2027)', row: 22, pgFilter: ['BSPA', 'YMAA'] },
  { initiativeName: 'Pro Top-of-Funnel AI (+$75M 2027)', row: 23, pgFilter: ['Pro360'] },
  { initiativeName: 'IS Top-of-Funnel AI (+$50M 2027)', row: 24, pgFilter: ['ISDA'] },
  // AI Data Readiness
  { initiativeName: 'Achieve Data Readiness Score of 6/10', row: 26 },
  { initiativeName: 'Deliver Unified Data Platform Framework', row: 27, pgFilter: ['FCSD-AI', 'FCSD-Ops'] },
  // Delivery Pace
  { initiativeName: 'Demonstrate enhanced AI effectiveness (2+ AI tools)', row: 30 },
  { initiativeName: 'Review AI KPI progress and status monthly', row: 31 },
  { initiativeName: 'Submit Efficiency Award demonstrating AI efficiency', row: 32 },
  // Personal Gemba
  { initiativeName: '1 Team improvement KPI documented/resolved per quarter', row: 35 },
  { initiativeName: 'Review GEMBA KPI and status quarterly', row: 36 },
  // Recall
  { initiativeName: 'Deliver Two (2) Recall Enterprise Capabilities', row: 39, pgFilter: ['FCSD-Ops'] },
  // Product & Services KPI Targets
  { initiativeName: '100% Products onboarded to ServiceNow', row: 42 },
  { initiativeName: '95%+ meeting Reliability, Health & SLA targets', row: 43 },
  { initiativeName: '100% met code quality SLA targets', row: 44 },
  { initiativeName: '80% deployed 2+ incremental automations', row: 45 },
  { initiativeName: 'Change Failure Rate <5% via Code Guardians', row: 46 },
  // CRM
  { initiativeName: 'CRM Segmentation and Scoring completed by Q1', row: 49, pgFilter: ['ISDA'] },
  { initiativeName: 'CRM Build tool in Q2', row: 50, pgFilter: ['ISDA'] },
  // Customer Profile
  { initiativeName: 'Retail customers with valid email opt-in', row: 53, pgFilter: ['C360'] },
  { initiativeName: 'Retail customers with complete profile', row: 54, pgFilter: ['C360'] },
  { initiativeName: 'Commercial customers with valid email opt-in', row: 55, pgFilter: ['Pro360'] },
  { initiativeName: 'Commercial customers with complete profile', row: 56, pgFilter: ['Pro360'] },
  // Corporate Reputation (NEW as of 3-30-26)
  { initiativeName: '100% Controls testing complete (BCP, SOX MCRP)', row: 60 },
  { initiativeName: 'S-Ox Comments remediated within 6 months', row: 61 },
  { initiativeName: 'Operational comments remediated within 8 months', row: 62 },
  // Transition
  { initiativeName: '60%+ products fully transitioned by EOY 2026', row: 65, pgFilter: ['C360', 'ISDA', 'FCSD-CS', 'BSPA'] },
];

// =====================================================
// Main import logic
// =====================================================

async function main() {
  console.log('Reading spreadsheet:', SPREADSHEET_PATH);
  const workbook = XLSX.readFile(SPREADSHEET_PATH);
  
  console.log('Sheets found:', workbook.SheetNames);
  
  // Fetch initiative and PG lookup maps from database
  const { data: initiatives } = await supabase.from('initiatives').select('id, name');
  const { data: productGroups } = await supabase.from('product_groups').select('id, abbreviation');
  
  if (!initiatives || !productGroups) {
    console.error('Failed to fetch initiatives or product groups from database');
    console.error('Make sure you have run schema.sql, seed-initiatives.sql, and seed-assignments.sql first');
    process.exit(1);
  }
  
  const initiativeMap = new Map(initiatives.map(i => [i.name, i.id]));
  const pgMap = new Map(productGroups.map(pg => [pg.abbreviation, pg.id]));
  
  console.log(`Loaded ${initiativeMap.size} initiatives, ${pgMap.size} product groups`);
  
  const scores: Array<{
    initiative_id: string;
    product_group_id: string | null;
    year: number;
    month: number;
    value: number;
    submitted_by: string;
  }> = [];
  
  // Process months 1-6 (January-June)
  const monthNames = ['January', 'February', 'March', 'April', 'May', 'June'];
  
  for (let month = 1; month <= 6; month++) {
    const sheetName = monthNames[month - 1];
    const sheet = workbook.Sheets[sheetName];
    if (!sheet) {
      console.warn(`Sheet "${sheetName}" not found, skipping`);
      continue;
    }
    
    console.log(`\nProcessing ${sheetName}...`);
    const colMap = getColumnMap(month);
    
    // For each initiative row mapping, extract values
    for (const mapping of JUNE_ROWS) {
      const initiativeId = initiativeMap.get(mapping.initiativeName);
      if (!initiativeId) {
        console.warn(`  Initiative not found: ${mapping.initiativeName}`);
        continue;
      }
      
      // Determine which PG columns to read
      const pgsToRead = mapping.pgFilter 
        ? PG_KEYS.filter(k => mapping.pgFilter!.includes(PG_ABBREV_MAP[k]))
        : PG_KEYS;
      
      for (const pgKey of pgsToRead) {
        const col = colMap[pgKey];
        const cellRef = `${col}${mapping.row}`;
        const cell = sheet[cellRef];
        
        if (!cell) continue;
        
        const rawValue = cell.v;
        
        // Skip non-numeric values (text, dashes, N/A, etc.)
        if (typeof rawValue === 'string') {
          if (rawValue === '-' || rawValue === 'N/A' || rawValue === 'NA' || rawValue === '??') {
            continue; // Dash means assigned but no value
          }
          // Try to parse as number
          const parsed = parseFloat(rawValue.replace(/[$,]/g, ''));
          if (isNaN(parsed)) continue;
        }
        
        const value = typeof rawValue === 'number' ? rawValue : parseFloat(String(rawValue).replace(/[$,]/g, ''));
        if (isNaN(value)) continue;
        
        const pgAbbrev = PG_ABBREV_MAP[pgKey];
        const pgId = pgMap.get(pgAbbrev);
        if (!pgId) continue;
        
        scores.push({
          initiative_id: initiativeId,
          product_group_id: pgId,
          year: 2026,
          month,
          value,
          submitted_by: 'historical_import',
        });
      }
    }
    
    console.log(`  Extracted ${scores.length} total scores so far`);
  }
  
  // Insert scores in batches
  console.log(`\nInserting ${scores.length} scores into database...`);
  const BATCH_SIZE = 100;
  let inserted = 0;
  
  for (let i = 0; i < scores.length; i += BATCH_SIZE) {
    const batch = scores.slice(i, i + BATCH_SIZE);
    const { error } = await supabase.from('scores').upsert(batch, {
      onConflict: 'initiative_id,product_group_id,year,month',
    });
    
    if (error) {
      console.error(`Error inserting batch at index ${i}:`, error);
    } else {
      inserted += batch.length;
    }
  }
  
  console.log(`Successfully inserted ${inserted} scores`);
  
  // Create submission records for all PGs for months 1-6
  console.log('\nCreating submission records...');
  const submissions = [];
  for (const [abbrev, pgId] of pgMap.entries()) {
    for (let month = 1; month <= 6; month++) {
      submissions.push({
        product_group_id: pgId,
        year: 2026,
        month,
        submitted_by: 'historical_import',
        submitted_at: new Date(2026, month - 1, 28, 17, 0, 0).toISOString(),
      });
    }
  }
  
  const { error: subError } = await supabase.from('submissions').upsert(submissions, {
    onConflict: 'product_group_id,year,month',
  });
  
  if (subError) {
    console.error('Error inserting submissions:', subError);
  } else {
    console.log(`Created ${submissions.length} submission records`);
  }
  
  console.log('\nDone! Historical data import complete.');
}

main().catch(console.error);
