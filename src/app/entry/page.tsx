'use client'
import { useState, useEffect, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import { formatValue, MONTHS, CURRENT_YEAR } from '@/lib/utils'
type ProductGroup = {
  id: string
  name: string
  abbreviation: string
}
type Initiative = {
  id: string
  name: string
  description: string | null
  metric_type: 'percentage' | 'dollar' | 'roi' | 'count' | 'score'
  category_name: string
  category_id: string
}
type EntryData = {
  initiative_id: string
  value: number | null
  notes: string | null
}
export default function DataEntryPage() {
  const [productGroups, setProductGroups] = useState<ProductGroup[]>([])
  const [selectedPG, setSelectedPG] = useState<string>('')
  const [selectedMonth, setSelectedMonth] = useState<number>(new Date().getMonth() + 1)
  const [initiatives, setInitiatives] = useState<Initiative[]>([])
  const [currentEntries, setCurrentEntries] = useState<Map<string, EntryData>>(new Map())
  const [priorEntries, setPriorEntries] = useState<Map<string, EntryData>>(new Map())
  const [confirmedNotes, setConfirmedNotes] = useState<Set<string>>(new Set())
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [isSubmitted, setIsSubmitted] = useState(false)
  const [lastSaved, setLastSaved] = useState<string | null>(null)
  // Load product groups
  useEffect(() => {
    async function loadPGs() {
      const { data } = await supabase
        .from('product_groups')
        .select('*')
        .order('display_order')
      if (data) setProductGroups(data)
      setLoading(false)
    }
    loadPGs()
  }, [])
  // Load initiatives and data when PG or month changes
  const loadData = useCallback(async () => {
    if (!selectedPG || !selectedMonth) return
    setLoading(true)
    setConfirmedNotes(new Set())
    // Get assigned initiatives for this PG
    const { data: assignments } = await supabase
      .from('initiative_assignments')
      .select(`
        initiative_id,
        initiatives (
          id, name, description, metric_type, display_order,
          categories ( id, name, display_order )
        )
      `)
      .eq('product_group_id', selectedPG)
    if (assignments) {
      const mapped: Initiative[] = assignments
        .map((a: any) => ({
          id: a.initiatives.id,
          name: a.initiatives.name,
          description: a.initiatives.description,
          metric_type: a.initiatives.metric_type,
          category_name: a.initiatives.categories.name,
          category_id: a.initiatives.categories.id,
          display_order: a.initiatives.display_order,
          category_order: a.initiatives.categories.display_order,
        }))
        .sort((a: any, b: any) =>
          a.category_order - b.category_order || a.display_order - b.display_order
        )
      setInitiatives(mapped)
    }
    // Get current month entries
    const { data: entries } = await supabase
      .from('monthly_entries')
      .select('initiative_id, value, notes')
      .eq('product_group_id', selectedPG)
      .eq('month', selectedMonth)
      .eq('year', CURRENT_YEAR)
    const entryMap = new Map<string, EntryData>()
    entries?.forEach((e: any) => {
      entryMap.set(e.initiative_id, e)
    })
    setCurrentEntries(entryMap)
    // Get prior month entries
    const priorMonth = selectedMonth === 1 ? 12 : selectedMonth - 1
    const priorYear = selectedMonth === 1 ? CURRENT_YEAR - 1 : CURRENT_YEAR
    const { data: prior } = await supabase
      .from('monthly_entries')
      .select('initiative_id, value, notes')
      .eq('product_group_id', selectedPG)
      .eq('month', priorMonth)
      .eq('year', priorYear)
    const priorMap = new Map<string, EntryData>()
    prior?.forEach((e: any) => {
      priorMap.set(e.initiative_id, e)
    })
    setPriorEntries(priorMap)
    // Check submission status
    const { data: submission } = await supabase
      .from('submissions')
      .select('submitted_at')
      .eq('product_group_id', selectedPG)
      .eq('month', selectedMonth)
      .eq('year', CURRENT_YEAR)
      .maybeSingle()
    setIsSubmitted(!!submission)
    setLoading(false)
  }, [selectedPG, selectedMonth])
  useEffect(() => {
    loadData()
  }, [loadData])
  // Update entry value
  function updateValue(initiativeId: string, rawValue: string, metricType: string) {
    const entry = currentEntries.get(initiativeId) || { initiative_id: initiativeId, value: null, notes: null }
    let numValue: number | null = null
    if (rawValue.trim() !== '') {
      const cleaned = rawValue.replace(/[$,%]/g, '').trim()
      numValue = parseFloat(cleaned)
      if (isNaN(numValue)) numValue = null
      // Convert percentage/roi input (entered as whole numbers) to decimal for storage
      if (numValue !== null && (metricType === 'percentage' || metricType === 'roi') && numValue > 1) {
        numValue = numValue / 100
      }
    }
    const updated = new Map(currentEntries)
    updated.set(initiativeId, { ...entry, value: numValue })
    setCurrentEntries(updated)
    // Auto-calculate ROI when costs or benefits change
    autoCalculateROI(initiativeId, updated)
  }
  // Auto-calculate ROI when costs or benefits change
  function autoCalculateROI(changedId: string, entries: Map<string, EntryData>) {
    const changedInit = initiatives.find(i => i.id === changedId)
    if (!changedInit || changedInit.category_name !== 'Direct Financial Impact') return
    // Find the three related initiatives
    const benefitsInit = initiatives.find(i =>
      i.category_name === 'Direct Financial Impact' && i.name.includes('Total Benefits')
    )
    const costsInit = initiatives.find(i =>
      i.category_name === 'Direct Financial Impact' && i.name.includes('Projected Costs')
    )
    const roiInit = initiatives.find(i =>
      i.category_name === 'Direct Financial Impact' && i.name === 'ROI Percentage'
    )
    if (!benefitsInit || !costsInit || !roiInit) return
    const benefits = entries.get(benefitsInit.id)?.value
    const costs = entries.get(costsInit.id)?.value
    if (benefits !== null && benefits !== undefined && costs !== null && costs !== undefined && costs > 0) {
      const roi = (benefits - costs) / costs
      const updated = new Map(entries)
      const roiEntry = updated.get(roiInit.id) || { initiative_id: roiInit.id, value: null, notes: null }
      updated.set(roiInit.id, { ...roiEntry, value: roi })
      setCurrentEntries(updated)
    }
  }
  // Update entry notes
  function updateNotes(initiativeId: string, notes: string) {
    const entry = currentEntries.get(initiativeId) || { initiative_id: initiativeId, value: null, notes: null }
    const updated = new Map(currentEntries)
    updated.set(initiativeId, { ...entry, notes: notes || null })
    setCurrentEntries(updated)
  }
  // Adopt prior note on focus
  function adoptPriorNote(initiativeId: string) {
    const currentNote = currentEntries.get(initiativeId)?.notes
    const priorNote = priorEntries.get(initiativeId)?.notes
    if (!currentNote && priorNote && !confirmedNotes.has(initiativeId)) {
      updateNotes(initiativeId, priorNote)
      setConfirmedNotes(prev => new Set(prev).add(initiativeId))
    }
  }
  // Check if an initiative row is incomplete (missing value or note)
  function isIncomplete(init: Initiative): 'missing-value' | 'missing-note' | 'complete' {
    const entry = currentEntries.get(init.id)
    const hasValue = entry?.value !== null && entry?.value !== undefined
    const hasNote = !!(entry?.notes)
    // For ROI Percentage (calculated), only need the value present
    if (init.name === 'ROI Percentage') {
      return hasValue ? 'complete' : 'missing-value'
    }
    if (!hasValue) return 'missing-value'
    if (!hasNote) return 'missing-note'
    return 'complete'
  }
  // Save all entries
  async function saveEntries() {
    setSaving(true)
    const entries = Array.from(currentEntries.values()).filter(
      (e) => e.value !== null || e.notes !== null
    )
    for (const entry of entries) {
      await supabase
        .from('monthly_entries')
        .upsert({
          initiative_id: entry.initiative_id,
          product_group_id: selectedPG,
          month: selectedMonth,
          year: CURRENT_YEAR,
          value: entry.value,
          notes: entry.notes,
          updated_at: new Date().toISOString(),
        }, {
          onConflict: 'initiative_id,product_group_id,month,year'
        })
    }
    setLastSaved(new Date().toLocaleTimeString())
    setSaving(false)
  }
  // Submit for the month
  async function submitForMonth() {
    setSubmitting(true)
    await saveEntries()
    await supabase
      .from('submissions')
      .upsert({
        product_group_id: selectedPG,
        month: selectedMonth,
        year: CURRENT_YEAR,
        submitted_at: new Date().toISOString(),
        submitted_by: productGroups.find(pg => pg.id === selectedPG)?.name || 'Unknown',
      }, {
        onConflict: 'product_group_id,month,year'
      })
    setIsSubmitted(true)
    setSubmitting(false)
  }
  // Group initiatives by category, filter out deleted ones
  const groupedInitiatives = initiatives
    .filter(i => i.name !== 'Indirect Financial Impact - Hours Saved ROI')
    .reduce((acc, init) => {
      if (!acc[init.category_name]) acc[init.category_name] = []
      acc[init.category_name].push(init)
      return acc
    }, {} as Record<string, Initiative[]>)
  // Count incomplete items
  const incompleteCount = initiatives
    .filter(i => i.name !== 'Indirect Financial Impact - Hours Saved ROI')
    .filter(i => isIncomplete(i) !== 'complete').length
  if (loading && !selectedPG) {
    return <div className="text-center py-12 text-gray-500">Loading...</div>
  }
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-ford-blue">Monthly Data Entry</h1>
        <p className="text-gray-600 mt-1">
          Select your product group and month to enter values and notes.
        </p>
      </div>
      {/* Selectors */}
      <div className="flex flex-wrap gap-4 items-end bg-white p-4 rounded-lg shadow-sm border">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Product Group
          </label>
          <select
            value={selectedPG}
            onChange={(e) => setSelectedPG(e.target.value)}
            className="border rounded-md px-3 py-2 text-sm min-w-[200px]"
          >
            <option value="">-- Select --</option>
            {productGroups.map((pg) => (
              <option key={pg.id} value={pg.id}>
                {pg.abbreviation} - {pg.name}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Month
          </label>
          <select
            value={selectedMonth}
            onChange={(e) => setSelectedMonth(Number(e.target.value))}
            className="border rounded-md px-3 py-2 text-sm min-w-[150px]"
          >
            {MONTHS.map((name, idx) => (
              <option key={idx} value={idx + 1}>
                {name} {CURRENT_YEAR}
              </option>
            ))}
          </select>
        </div>
        {selectedPG && (
          <div className="flex items-center gap-4 ml-auto">
            {incompleteCount > 0 && (
              <span className="text-sm text-amber-700 bg-amber-50 px-3 py-1 rounded-full border border-amber-200">
                {incompleteCount} incomplete
              </span>
            )}
            {isSubmitted && (
              <span className="text-sm text-green-700 bg-green-50 px-3 py-1 rounded-full border border-green-200">
                Submitted
              </span>
            )}
            {lastSaved && (
              <span className="text-xs text-gray-500">Last saved: {lastSaved}</span>
            )}
            <button
              onClick={saveEntries}
              disabled={saving}
              className="px-4 py-2 bg-gray-600 text-white rounded-md text-sm hover:bg-gray-700 disabled:opacity-50"
            >
              {saving ? 'Saving...' : 'Save Draft'}
            </button>
            <button
              onClick={submitForMonth}
              disabled={submitting}
              className="px-4 py-2 bg-ford-blue text-white rounded-md text-sm hover:bg-ford-blue-light disabled:opacity-50"
            >
              {submitting ? 'Submitting...' : `Submit for ${MONTHS[selectedMonth - 1]}`}
            </button>
          </div>
        )}
      </div>
      {/* Completion Legend */}
      {selectedPG && !loading && incompleteCount > 0 && (
        <div className="flex items-center gap-4 text-xs text-gray-500 bg-white px-4 py-2 rounded border">
          <span className="flex items-center gap-1">
            <span className="w-3 h-3 rounded-sm bg-red-100 border border-red-300 inline-block"></span>
            Missing value
          </span>
          <span className="flex items-center gap-1">
            <span className="w-3 h-3 rounded-sm bg-amber-100 border border-amber-300 inline-block"></span>
            Missing note
          </span>
          <span className="text-gray-400">|</span>
          <span>Prior month notes appear in grey. Click to adopt them for this month.</span>
        </div>
      )}
      {/* Data Entry Table */}
      {selectedPG && !loading && (
        <div className="space-y-8">
          {Object.entries(groupedInitiatives).map(([categoryName, inits]) => (
            <div key={categoryName} className="bg-white rounded-lg shadow-sm border overflow-hidden">
              <div className="bg-ford-blue/5 px-4 py-3 border-b">
                <h2 className="font-semibold text-ford-blue">{categoryName}</h2>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b bg-gray-50">
                      <th className="text-left px-4 py-2 w-[280px]">Initiative</th>
                      <th className="text-center px-3 py-2 w-[100px]">Prior Month</th>
                      <th className="text-center px-3 py-2 w-[120px]">Current Value</th>
                      <th className="text-left px-3 py-2">Notes</th>
                    </tr>
                  </thead>
                  <tbody>
                    {inits.map((init) => {
                      const currentEntry = currentEntries.get(init.id)
                      const priorEntry = priorEntries.get(init.id)
                      const completionStatus = isIncomplete(init)
                      const isROI = init.name === 'ROI Percentage'
                      // Determine row highlight for incomplete items
                      const rowBg = completionStatus === 'missing-value'
                        ? 'bg-red-50'
                        : completionStatus === 'missing-note'
                        ? 'bg-amber-50'
                        : 'hover:bg-gray-50'
                      // Determine note display state
                      const currentNote = currentEntry?.notes || ''
                      const priorNote = priorEntry?.notes || ''
                      const showPriorAsGrey = !currentNote && priorNote && !confirmedNotes.has(init.id)
                      return (
                        <tr key={init.id} className={`border-b ${rowBg}`}>
                          <td className="px-4 py-3">
                            <div className="font-medium text-gray-900">{init.name}</div>
                            {init.description && (
                              <div className="text-xs text-gray-500 mt-1">
                                {init.description}
                              </div>
                            )}
                          </td>
                          <td className="text-center px-3 py-3 text-gray-500">
                            {formatValue(priorEntry?.value ?? null, init.metric_type)}
                          </td>
                          <td className="text-center px-3 py-3">
                            {isROI ? (
                              // ROI is calculated, read-only
                              <div className="text-gray-700 font-medium">
                                {currentEntry?.value !== null && currentEntry?.value !== undefined
                                  ? `${(currentEntry.value * 100).toFixed(0)}%`
                                  : '-'
                                }
                                <div className="text-xs text-gray-400 mt-0.5">auto-calculated</div>
                              </div>
                            ) : (
                              <>
                                <input
                                  type="text"
                                  value={
                                    currentEntry?.value !== null && currentEntry?.value !== undefined
                                      ? init.metric_type === 'percentage' || init.metric_type === 'roi'
                                        ? (currentEntry.value * 100).toFixed(0)
                                        : init.metric_type === 'dollar'
                                          ? currentEntry.value.toString()
                                          : currentEntry.value.toString()
                                      : ''
                                  }
                                  onChange={(e) => updateValue(init.id, e.target.value, init.metric_type)}
                                  placeholder={
                                    init.metric_type === 'dollar' ? '$0'
                                    : init.metric_type === 'percentage' || init.metric_type === 'roi' ? '0-100'
                                    : '0'
                                  }
                                  className="w-full border rounded px-2 py-1 text-center text-sm"
                                />
                                {(init.metric_type === 'percentage' || init.metric_type === 'roi') && (
                                  <span className="text-xs text-gray-400">%</span>
                                )}
                              </>
                            )}
                          </td>
                          <td className="px-3 py-3">
                            {isROI ? (
                              <span className="text-xs text-gray-400 italic">
                                ROI = (Benefits - Costs) / Costs
                              </span>
                            ) : (
                              <textarea
                                value={showPriorAsGrey ? priorNote : currentNote}
                                onFocus={() => {
                                  if (showPriorAsGrey) adoptPriorNote(init.id)
                                }}
                                onChange={(e) => updateNotes(init.id, e.target.value)}
                                placeholder="Add notes..."
                                rows={2}
                                className={`w-full border rounded px-2 py-1 text-sm resize-y min-h-[36px] ${
                                  showPriorAsGrey ? 'text-gray-400 italic' : 'text-gray-900'
                                }`}
                              />
                            )}
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          ))}
        </div>
      )}
      {selectedPG && loading && (
        <div className="text-center py-12 text-gray-500">Loading initiatives...</div>
      )}
      {!selectedPG && (
        <div className="text-center py-12 text-gray-500 bg-white rounded-lg border">
          Select a product group to begin entering data.
        </div>
      )}
    </div>
  )
}
