'use client'

import { useState, useEffect, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import { getStatusColor, getStatusDotClass, formatValue, MONTHS, CURRENT_YEAR } from '@/lib/utils'

type Initiative = {
  id: string
  name: string
  description: string | null
  metric_type: 'percentage' | 'dollar' | 'roi' | 'count' | 'score'
  frequency: 'monthly' | 'quarterly'
}

type EntryData = {
  value: number | null
  notes: string | null
}

export default function AdminEntryPage() {
  const [initiatives, setInitiatives] = useState<Initiative[]>([])
  const [entries, setEntries] = useState<Map<string, EntryData>>(new Map()) // key: initId|month
  const [goals, setGoals] = useState<Map<string, number | null>>(new Map()) // key: initId|month
  const [thresholds, setThresholds] = useState<Map<string, { green_min: number; yellow_min: number }>>(new Map())
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [lastSaved, setLastSaved] = useState<string | null>(null)

  useEffect(() => {
    loadData()
  }, [])

  async function loadData() {
    setLoading(true)

    // Load admin initiatives
    const { data: initData } = await supabase
      .from('initiatives')
      .select(`
        id, name, description, metric_type, frequency, display_order,
        categories!inner ( section )
      `)
      .eq('categories.section', 'admin')
      .order('display_order')

    if (initData) {
      setInitiatives(initData.map((i: any) => ({
        id: i.id,
        name: i.name,
        description: i.description,
        metric_type: i.metric_type,
        frequency: i.frequency,
      })))
    }

    // Load all entries for admin initiatives (no product_group_id)
    const { data: entryData } = await supabase
      .from('monthly_entries')
      .select('initiative_id, month, value, notes')
      .is('product_group_id', null)
      .eq('year', CURRENT_YEAR)

    const entryMap = new Map<string, EntryData>()
    entryData?.forEach((e) => {
      entryMap.set(`${e.initiative_id}|${e.month}`, { value: e.value, notes: e.notes })
    })
    setEntries(entryMap)

    // Load goals
    const { data: goalData } = await supabase
      .from('initiative_goals')
      .select('initiative_id, month, target_value')
      .eq('year', CURRENT_YEAR)

    const goalMap = new Map<string, number | null>()
    goalData?.forEach((g) => {
      goalMap.set(`${g.initiative_id}|${g.month}`, g.target_value)
    })
    setGoals(goalMap)

    // Load thresholds
    const { data: thresholdData } = await supabase
      .from('initiative_thresholds')
      .select('initiative_id, green_min, yellow_min')

    const thresholdMap = new Map<string, { green_min: number; yellow_min: number }>()
    thresholdData?.forEach((t) => {
      thresholdMap.set(t.initiative_id, { green_min: t.green_min, yellow_min: t.yellow_min })
    })
    setThresholds(thresholdMap)

    setLoading(false)
  }

  function updateValue(initId: string, month: number, rawValue: string, metricType: string) {
    const key = `${initId}|${month}`
    const entry = entries.get(key) || { value: null, notes: null }

    let numValue: number | null = null
    if (rawValue.trim() !== '') {
      const cleaned = rawValue.replace(/[$,%]/g, '').trim()
      numValue = parseFloat(cleaned)
      if (isNaN(numValue)) numValue = null
      if (numValue !== null && metricType === 'percentage' && numValue > 1) {
        numValue = numValue / 100
      }
    }

    const updated = new Map(entries)
    updated.set(key, { ...entry, value: numValue })
    setEntries(updated)
  }

  function updateNotes(initId: string, month: number, notes: string) {
    const key = `${initId}|${month}`
    const entry = entries.get(key) || { value: null, notes: null }
    const updated = new Map(entries)
    updated.set(key, { ...entry, notes: notes || null })
    setEntries(updated)
  }

  async function saveAll() {
    setSaving(true)

    const entriesToSave = Array.from(entries.entries())
      .filter(([, data]) => data.value !== null || data.notes !== null)
      .map(([key, data]) => {
        const [initId, month] = key.split('|')
        return {
          initiative_id: initId,
          product_group_id: null,
          month: parseInt(month),
          year: CURRENT_YEAR,
          value: data.value,
          notes: data.notes,
          updated_at: new Date().toISOString(),
        }
      })

    for (const entry of entriesToSave) {
      await supabase
        .from('monthly_entries')
        .upsert(entry, {
          onConflict: 'initiative_id,product_group_id,month,year'
        })
    }

    setLastSaved(new Date().toLocaleTimeString())
    setSaving(false)
  }

  // For quarterly initiatives, determine which months to show
  function getDisplayMonths(frequency: 'monthly' | 'quarterly'): number[] {
    if (frequency === 'monthly') return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    // Quarterly: show end-of-quarter months
    return [3, 6, 9, 12]
  }

  if (loading) return <div className="text-center py-12 text-gray-500">Loading...</div>

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-ford-blue">Administrative Initiatives</h1>
          <p className="text-gray-600 mt-1">
            Enter your administrative initiative scores (quarterly and monthly)
          </p>
        </div>
        <div className="flex items-center gap-4">
          {lastSaved && <span className="text-xs text-gray-500">Last saved: {lastSaved}</span>}
          <button
            onClick={saveAll}
            disabled={saving}
            className="px-4 py-2 bg-ford-blue text-white rounded-md text-sm hover:bg-ford-blue-light disabled:opacity-50"
          >
            {saving ? 'Saving...' : 'Save All'}
          </button>
        </div>
      </div>

      {/* Admin Initiatives Table */}
      <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-gray-50">
                <th className="text-left px-4 py-2 sticky left-0 bg-gray-50 min-w-[250px]">Initiative</th>
                <th className="text-center px-2 py-2 w-[60px]">Freq</th>
                {MONTHS.map((m, idx) => (
                  <th key={idx} className="text-center px-2 py-2 w-[80px] text-xs">
                    {m.substring(0, 3)}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {initiatives.map((init) => {
                const displayMonths = getDisplayMonths(init.frequency)
                return (
                  <tr key={init.id} className="border-b hover:bg-gray-50">
                    <td className="px-4 py-3 sticky left-0 bg-white">
                      <div className="font-medium text-gray-900 text-xs">{init.name}</div>
                      {init.description && (
                        <div className="text-xs text-gray-500 mt-0.5 line-clamp-1">{init.description}</div>
                      )}
                    </td>
                    <td className="text-center px-2 py-3">
                      <span className={`text-xs px-1.5 py-0.5 rounded ${
                        init.frequency === 'quarterly' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                      }`}>
                        {init.frequency === 'quarterly' ? 'Q' : 'M'}
                      </span>
                    </td>
                    {MONTHS.map((_, monthIdx) => {
                      const month = monthIdx + 1
                      const isActive = displayMonths.includes(month)
                      const key = `${init.id}|${month}`
                      const entry = entries.get(key)
                      const goal = goals.get(key)
                      const threshold = thresholds.get(init.id)
                      const status = getStatusColor(
                        entry?.value ?? null,
                        goal ?? null,
                        threshold?.green_min,
                        threshold?.yellow_min
                      )

                      if (!isActive) {
                        return <td key={month} className="text-center px-1 py-2 bg-gray-50" />
                      }

                      return (
                        <td key={month} className="text-center px-1 py-2">
                          <div className="flex items-center gap-0.5">
                            <input
                              type="text"
                              value={
                                entry?.value !== null && entry?.value !== undefined
                                  ? init.metric_type === 'percentage'
                                    ? (entry.value * 100).toString()
                                    : entry.value.toString()
                                  : ''
                              }
                              onChange={(e) => updateValue(init.id, month, e.target.value, init.metric_type)}
                              className="w-14 border rounded px-1 py-0.5 text-center text-xs"
                              placeholder="-"
                            />
                            <div className={`w-2 h-2 rounded-full flex-shrink-0 ${getStatusDotClass(status)}`} />
                          </div>
                        </td>
                      )
                    })}
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Notes Section */}
      <div className="bg-white rounded-lg shadow-sm border p-4">
        <h2 className="font-semibold mb-4">Notes by Initiative</h2>
        <div className="space-y-4">
          {initiatives.map((init) => {
            const currentMonth = new Date().getMonth() + 1
            const key = `${init.id}|${currentMonth}`
            const entry = entries.get(key)
            return (
              <div key={init.id} className="border-b pb-3 last:border-b-0">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  {init.name} - {MONTHS[currentMonth - 1]}
                </label>
                <textarea
                  value={entry?.notes || ''}
                  onChange={(e) => updateNotes(init.id, currentMonth, e.target.value)}
                  className="w-full border rounded px-3 py-2 text-sm resize-y min-h-[60px]"
                  placeholder="Add notes for this month..."
                />
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
