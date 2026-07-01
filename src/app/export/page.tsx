'use client'
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { MONTHS, CURRENT_YEAR, formatValue } from '@/lib/utils'
export default function ExportPage() {
  const [selectedMonth, setSelectedMonth] = useState<number>(new Date().getMonth() + 1)
  const [exportType, setExportType] = useState<'monthly' | 'year' | 'notes'>('monthly')
  const [exporting, setExporting] = useState(false)
  async function handleExport() {
    setExporting(true)
    try {
      const XLSX = await import('xlsx')
      if (exportType === 'monthly' || exportType === 'year') {
        await exportData(XLSX)
      } else if (exportType === 'notes') {
        await exportNotes(XLSX)
      }
    } catch (err) {
      console.error('Export error:', err)
      alert('Export failed. Please try again.')
    }
    setExporting(false)
  }
  async function exportData(XLSX: any) {
    const { data: pgData } = await supabase
      .from('product_groups')
      .select('*')
      .order('display_order')
    const { data: initiatives } = await supabase
      .from('initiatives')
      .select(`
        id, name, metric_type, display_order,
        categories!inner ( name, section, display_order )
      `)
      .eq('categories.section', 'product_group')
    const sortedInits = (initiatives || []).sort(
      (a: any, b: any) => a.categories.display_order - b.categories.display_order || a.display_order - b.display_order
    )
    const { data: assignmentData } = await supabase
      .from('initiative_assignments')
      .select('initiative_id, product_group_id')
    const assignmentSet = new Set(
      assignmentData?.map((a) => `${a.initiative_id}|${a.product_group_id}`) || []
    )
    const { data: goalData } = await supabase
      .from('initiative_goals')
      .select('initiative_id, month, target_value')
      .eq('year', CURRENT_YEAR)
    const goalMap = new Map<string, number | null>()
    goalData?.forEach((g) => goalMap.set(`${g.initiative_id}|${g.month}`, g.target_value))
    const { data: thresholdData } = await supabase
      .from('initiative_thresholds')
      .select('initiative_id, green_min, yellow_min')
    const thresholdMap = new Map<string, { green_min: number; yellow_min: number }>()
    thresholdData?.forEach((t) => thresholdMap.set(t.initiative_id, { green_min: t.green_min, yellow_min: t.yellow_min }))
    const monthsToExport = exportType === 'year'
      ? Array.from({ length: 12 }, (_, i) => i + 1)
      : [selectedMonth]
    const wb = XLSX.utils.book_new()
    for (const month of monthsToExport) {
      const { data: entries } = await supabase
        .from('monthly_entries')
        .select('initiative_id, product_group_id, value, notes')
        .eq('month', month)
        .eq('year', CURRENT_YEAR)
      const entryMap = new Map<string, { value: number | null; notes: string | null }>()
      entries?.forEach((e) => {
        entryMap.set(`${e.initiative_id}|${e.product_group_id}`, { value: e.value, notes: e.notes })
      })
      const rows: any[] = []
      let currentCategory = ''
      for (const init of sortedInits) {
        const cat = (init as any).categories.name
        if (cat !== currentCategory) {
          rows.push({ Initiative: '', Category: cat })
          currentCategory = cat
        }
        const row: any = {
          Initiative: init.name,
          Goal: goalMap.get(`${init.id}|${month}`) ?? '',
        }
        const pgValues: number[] = []
        pgData?.forEach((pg) => {
          const isAssigned = assignmentSet.has(`${init.id}|${pg.id}`)
          if (isAssigned) {
            const entry = entryMap.get(`${init.id}|${pg.id}`)
            const val = entry?.value ?? null
            row[pg.abbreviation] = val !== null
              ? init.metric_type === 'percentage' ? val * 100 : val
              : ''
            if (val !== null) pgValues.push(val)
          } else {
            row[pg.abbreviation] = ''
          }
        })
        const aggregate = pgValues.length > 0
          ? init.metric_type === 'dollar'
            ? pgValues.reduce((s, v) => s + v, 0)
            : pgValues.reduce((s, v) => s + v, 0) / pgValues.length
          : null
        row['SSDA'] = aggregate !== null
          ? init.metric_type === 'percentage' ? aggregate * 100 : aggregate
          : ''
        rows.push(row)
      }
      const ws = XLSX.utils.json_to_sheet(rows)
      XLSX.utils.book_append_sheet(wb, ws, MONTHS[month - 1])
    }
    XLSX.writeFile(wb, `VDT2_${exportType === 'year' ? CURRENT_YEAR : MONTHS[selectedMonth - 1]}_${CURRENT_YEAR}.xlsx`)
  }
  async function exportNotes(XLSX: any) {
    const { data: entries } = await supabase
      .from('monthly_entries')
      .select(`
        month, value, notes,
        initiatives ( name, categories ( name ) ),
        product_groups ( abbreviation )
      `)
      .eq('year', CURRENT_YEAR)
      .not('notes', 'is', null)
      .neq('notes', '')
      .order('month')
    const rows = (entries || []).map((e: any) => ({
      Month: MONTHS[(e.month as number) - 1],
      Category: e.initiatives.categories.name,
      Initiative: e.initiatives.name,
      'Product Group': e.product_groups?.abbreviation || 'Admin',
      Notes: e.notes,
    }))
    const wb = XLSX.utils.book_new()
    const ws = XLSX.utils.json_to_sheet(rows)
    XLSX.utils.book_append_sheet(wb, ws, 'Notes')
    XLSX.writeFile(wb, `VDT2_Notes_${CURRENT_YEAR}.xlsx`)
  }
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-ford-blue">Export Data</h1>
        <p className="text-gray-600 mt-1">Download tracker data as Excel files</p>
      </div>
      <div className="bg-white rounded-lg shadow-sm border p-6 max-w-xl">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Export Type</label>
            <div className="space-y-2">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="exportType"
                  value="monthly"
                  checked={exportType === 'monthly'}
                  onChange={() => setExportType('monthly')}
                  className="text-ford-blue"
                />
                <span className="text-sm">Single month (with color-coded data)</span>
              </label>
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="exportType"
                  value="year"
                  checked={exportType === 'year'}
                  onChange={() => setExportType('year')}
                  className="text-ford-blue"
                />
                <span className="text-sm">Full year (12 sheets, one per month)</span>
              </label>
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="exportType"
                  value="notes"
                  checked={exportType === 'notes'}
                  onChange={() => setExportType('notes')}
                  className="text-ford-blue"
                />
                <span className="text-sm">Notes only (all months, consolidated)</span>
              </label>
            </div>
          </div>
          {exportType === 'monthly' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Month</label>
              <select
                value={selectedMonth}
                onChange={(e) => setSelectedMonth(Number(e.target.value))}
                className="border rounded-md px-3 py-2 text-sm w-full"
              >
                {MONTHS.map((name, idx) => (
                  <option key={idx} value={idx + 1}>
                    {name} {CURRENT_YEAR}
                  </option>
                ))}
              </select>
            </div>
          )}
          <button
            onClick={handleExport}
            disabled={exporting}
            className="w-full px-4 py-3 bg-ford-blue text-white rounded-md font-medium hover:bg-ford-blue-light disabled:opacity-50"
          >
            {exporting ? 'Exporting...' : 'Download Excel File'}
          </button>
        </div>
      </div>
    </div>
  )
}
