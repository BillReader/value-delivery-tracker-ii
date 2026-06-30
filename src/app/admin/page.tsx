'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

type Initiative = {
  id: string
  name: string
  metric_type: string
  frequency: string
  category_name: string
  description: string | null
  threshold: { green_min: number; yellow_min: number } | null
  assignments: string[] // PG abbreviations
}

type ProductGroup = {
  id: string
  name: string
  abbreviation: string
}

export default function AdminPage() {
  const [activeTab, setActiveTab] = useState<'initiatives' | 'thresholds' | 'assignments'>('initiatives')
  const [initiatives, setInitiatives] = useState<Initiative[]>([])
  const [productGroups, setProductGroups] = useState<ProductGroup[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    loadData()
  }, [])

  async function loadData() {
    setLoading(true)

    const { data: pgData } = await supabase
      .from('product_groups')
      .select('*')
      .order('display_order')
    if (pgData) setProductGroups(pgData)

    const { data: initData } = await supabase
      .from('initiatives')
      .select(`
        id, name, metric_type, frequency, description, display_order,
        categories ( name, display_order, section )
      `)
      .order('display_order')

    const { data: thresholdData } = await supabase
      .from('initiative_thresholds')
      .select('initiative_id, green_min, yellow_min')

    const thresholdMap = new Map<string, { green_min: number; yellow_min: number }>()
    thresholdData?.forEach((t) => thresholdMap.set(t.initiative_id, { green_min: t.green_min, yellow_min: t.yellow_min }))

    const { data: assignmentData } = await supabase
      .from('initiative_assignments')
      .select('initiative_id, product_group_id')

    const assignmentMap = new Map<string, Set<string>>()
    assignmentData?.forEach((a) => {
      if (!assignmentMap.has(a.initiative_id)) assignmentMap.set(a.initiative_id, new Set())
      assignmentMap.get(a.initiative_id)!.add(a.product_group_id)
    })

    if (initData) {
      const mapped: Initiative[] = initData
        .sort((a: any, b: any) => a.categories.display_order - b.categories.display_order || a.display_order - b.display_order)
        .map((i: any) => ({
          id: i.id,
          name: i.name,
          metric_type: i.metric_type,
          frequency: i.frequency,
          category_name: i.categories.name,
          description: i.description,
          threshold: thresholdMap.get(i.id) || null,
          assignments: pgData?.filter((pg) => assignmentMap.get(i.id)?.has(pg.id))
            .map((pg) => pg.abbreviation) || [],
        }))
      setInitiatives(mapped)
    }

    setLoading(false)
  }

  async function updateThreshold(initId: string, field: 'green_min' | 'yellow_min', value: string) {
    const numVal = parseFloat(value)
    if (isNaN(numVal)) return

    setInitiatives((prev) =>
      prev.map((i) => {
        if (i.id === initId) {
          return {
            ...i,
            threshold: {
              green_min: field === 'green_min' ? numVal : (i.threshold?.green_min ?? 0.85),
              yellow_min: field === 'yellow_min' ? numVal : (i.threshold?.yellow_min ?? 0.65),
            },
          }
        }
        return i
      })
    )
  }

  async function saveThresholds() {
    setSaving(true)
    for (const init of initiatives) {
      if (init.threshold) {
        await supabase
          .from('initiative_thresholds')
          .upsert({
            initiative_id: init.id,
            green_min: init.threshold.green_min,
            yellow_min: init.threshold.yellow_min,
          }, { onConflict: 'initiative_id' })
      }
    }
    setSaving(false)
    alert('Thresholds saved successfully!')
  }

  async function toggleAssignment(initId: string, pgId: string, currentlyAssigned: boolean) {
    if (currentlyAssigned) {
      await supabase
        .from('initiative_assignments')
        .delete()
        .eq('initiative_id', initId)
        .eq('product_group_id', pgId)
    } else {
      await supabase
        .from('initiative_assignments')
        .insert({ initiative_id: initId, product_group_id: pgId })
    }
    await loadData()
  }

  if (loading) return <div className="text-center py-12 text-gray-500">Loading...</div>

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-ford-blue">Admin Setup</h1>
        <p className="text-gray-600 mt-1">
          Manage initiatives, thresholds, and product group assignments
        </p>
      </div>

      {/* Tabs */}
      <div className="border-b">
        <div className="flex gap-4">
          {[
            { key: 'initiatives', label: 'Initiatives Overview' },
            { key: 'thresholds', label: 'Color Thresholds' },
            { key: 'assignments', label: 'PG Assignments' },
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors ${
                activeTab === tab.key
                  ? 'border-ford-blue text-ford-blue'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Initiatives Overview Tab */}
      {activeTab === 'initiatives' && (
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b bg-gray-50">
                  <th className="text-left px-4 py-2">Category</th>
                  <th className="text-left px-4 py-2">Initiative</th>
                  <th className="text-center px-3 py-2">Type</th>
                  <th className="text-center px-3 py-2">Frequency</th>
                  <th className="text-center px-3 py-2">Green</th>
                  <th className="text-center px-3 py-2">Yellow</th>
                  <th className="text-left px-3 py-2">Assigned PGs</th>
                </tr>
              </thead>
              <tbody>
                {initiatives.map((init) => (
                  <tr key={init.id} className="border-b hover:bg-gray-50">
                    <td className="px-4 py-2 text-xs text-gray-500">{init.category_name}</td>
                    <td className="px-4 py-2 font-medium">{init.name}</td>
                    <td className="text-center px-3 py-2">
                      <span className="text-xs px-1.5 py-0.5 rounded bg-gray-100">{init.metric_type}</span>
                    </td>
                    <td className="text-center px-3 py-2">
                      <span className={`text-xs px-1.5 py-0.5 rounded ${
                        init.frequency === 'quarterly' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                      }`}>
                        {init.frequency}
                      </span>
                    </td>
                    <td className="text-center px-3 py-2 text-xs">
                      {init.threshold ? `${(init.threshold.green_min * 100).toFixed(0)}%` : '-'}
                    </td>
                    <td className="text-center px-3 py-2 text-xs">
                      {init.threshold ? `${(init.threshold.yellow_min * 100).toFixed(0)}%` : '-'}
                    </td>
                    <td className="px-3 py-2 text-xs text-gray-600">
                      {init.assignments.join(', ') || 'None'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Thresholds Tab */}
      {activeTab === 'thresholds' && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <p className="text-sm text-gray-600">
              Set per-initiative thresholds for color coding. Green = value/goal &gt;= threshold. Yellow = between yellow and green. Red = below yellow.
            </p>
            <button
              onClick={saveThresholds}
              disabled={saving}
              className="px-4 py-2 bg-ford-blue text-white rounded-md text-sm hover:bg-ford-blue-light disabled:opacity-50"
            >
              {saving ? 'Saving...' : 'Save Thresholds'}
            </button>
          </div>
          <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b bg-gray-50">
                  <th className="text-left px-4 py-2">Initiative</th>
                  <th className="text-center px-3 py-2 w-[150px]">Green Min (% of goal)</th>
                  <th className="text-center px-3 py-2 w-[150px]">Yellow Min (% of goal)</th>
                </tr>
              </thead>
              <tbody>
                {initiatives.map((init) => (
                  <tr key={init.id} className="border-b hover:bg-gray-50">
                    <td className="px-4 py-2">
                      <div className="text-xs text-gray-500">{init.category_name}</div>
                      <div className="font-medium">{init.name}</div>
                    </td>
                    <td className="text-center px-3 py-2">
                      <input
                        type="number"
                        step="0.05"
                        min="0"
                        max="2"
                        value={init.threshold?.green_min ?? 0.85}
                        onChange={(e) => updateThreshold(init.id, 'green_min', e.target.value)}
                        className="w-20 border rounded px-2 py-1 text-center text-sm"
                      />
                    </td>
                    <td className="text-center px-3 py-2">
                      <input
                        type="number"
                        step="0.05"
                        min="0"
                        max="2"
                        value={init.threshold?.yellow_min ?? 0.65}
                        onChange={(e) => updateThreshold(init.id, 'yellow_min', e.target.value)}
                        className="w-20 border rounded px-2 py-1 text-center text-sm"
                      />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Assignments Tab */}
      {activeTab === 'assignments' && (
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          <p className="px-4 py-3 text-sm text-gray-600 border-b bg-gray-50">
            Click a checkbox to assign/unassign a product group from an initiative. Only assigned PGs will see the initiative in their data entry view.
          </p>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b bg-gray-50">
                  <th className="text-left px-4 py-2 sticky left-0 bg-gray-50 min-w-[250px]">Initiative</th>
                  {productGroups.map((pg) => (
                    <th key={pg.id} className="text-center px-2 py-2 w-[70px] text-xs">
                      {pg.abbreviation}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {initiatives
                  .filter((i) => i.category_name !== 'Administrative')
                  .map((init) => (
                    <tr key={init.id} className="border-b hover:bg-gray-50">
                      <td className="px-4 py-2 sticky left-0 bg-white text-xs">
                        {init.name}
                      </td>
                      {productGroups.map((pg) => {
                        const isAssigned = init.assignments.includes(pg.abbreviation)
                        return (
                          <td key={pg.id} className="text-center px-2 py-2">
                            <input
                              type="checkbox"
                              checked={isAssigned}
                              onChange={() => toggleAssignment(init.id, pg.id, isAssigned)}
                              className="rounded border-gray-300"
                            />
                          </td>
                        )
                      })}
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
