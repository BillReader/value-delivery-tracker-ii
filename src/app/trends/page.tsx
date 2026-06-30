'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { MONTHS, CURRENT_YEAR, formatValue, calculateAggregate } from '@/lib/utils'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts'

const COLORS = [
  '#003478', '#1a5dab', '#22c55e', '#ef4444', '#eab308',
  '#8b5cf6', '#ec4899', '#06b6d4', '#f97316'
]

type ProductGroup = {
  id: string
  name: string
  abbreviation: string
}

type Initiative = {
  id: string
  name: string
  metric_type: string
  category_name: string
}

export default function TrendsPage() {
  const [productGroups, setProductGroups] = useState<ProductGroup[]>([])
  const [initiatives, setInitiatives] = useState<Initiative[]>([])
  const [selectedInitiative, setSelectedInitiative] = useState<string>('')
  const [selectedPG, setSelectedPG] = useState<string>('all')
  const [chartData, setChartData] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadInitialData() {
      const { data: pgData } = await supabase
        .from('product_groups')
        .select('*')
        .order('display_order')
      if (pgData) setProductGroups(pgData)

      const { data: initData } = await supabase
        .from('initiatives')
        .select(`
          id, name, metric_type, display_order,
          categories ( name, display_order, section )
        `)
        .order('display_order')

      if (initData) {
        const sorted = initData
          .filter((i: any) => i.categories.section === 'product_group')
          .sort((a: any, b: any) => a.categories.display_order - b.categories.display_order || a.display_order - b.display_order)
          .map((i: any) => ({
            id: i.id,
            name: i.name,
            metric_type: i.metric_type,
            category_name: i.categories.name,
          }))
        setInitiatives(sorted)
        if (sorted.length > 0) setSelectedInitiative(sorted[0].id)
      }
      setLoading(false)
    }
    loadInitialData()
  }, [])

  useEffect(() => {
    if (selectedInitiative) loadChartData()
  }, [selectedInitiative, selectedPG])

  async function loadChartData() {
    if (!selectedInitiative) return

    // Load all entries for this initiative across all months
    const { data: entries } = await supabase
      .from('monthly_entries')
      .select('product_group_id, month, year, value')
      .eq('initiative_id', selectedInitiative)
      .eq('year', CURRENT_YEAR)
      .order('month')

    // Load goals
    const { data: goals } = await supabase
      .from('initiative_goals')
      .select('month, target_value')
      .eq('initiative_id', selectedInitiative)
      .eq('year', CURRENT_YEAR)
      .order('month')

    const goalMap = new Map<number, number | null>()
    goals?.forEach((g) => goalMap.set(g.month, g.target_value))

    // Build chart data: one point per month
    const data = MONTHS.map((monthName, idx) => {
      const month = idx + 1
      const monthEntries = entries?.filter((e) => e.month === month) || []
      const point: any = { month: monthName.substring(0, 3) }

      // Add goal line
      const goalVal = goalMap.get(month)
      if (goalVal !== null && goalVal !== undefined) {
        point['Goal'] = goalVal
      }

      if (selectedPG === 'all') {
        // Show SSDA aggregate
        const values = monthEntries.map((e) => e.value).filter((v): v is number => v !== null)
        point['SSDA Aggregate'] = values.length > 0
          ? values.reduce((s, v) => s + v, 0) / values.length
          : null
      } else if (selectedPG === 'compare') {
        // Show all PGs on same chart
        productGroups.forEach((pg) => {
          const entry = monthEntries.find((e) => e.product_group_id === pg.id)
          point[pg.abbreviation] = entry?.value ?? null
        })
      } else {
        // Show single PG
        const pg = productGroups.find((p) => p.id === selectedPG)
        const entry = monthEntries.find((e) => e.product_group_id === selectedPG)
        if (pg) point[pg.abbreviation] = entry?.value ?? null
      }

      return point
    })

    setChartData(data)
  }

  const selectedInit = initiatives.find((i) => i.id === selectedInitiative)
  const isPercentage = selectedInit?.metric_type === 'percentage'

  // Group initiatives by category for the dropdown
  const groupedInits = initiatives.reduce((acc, init) => {
    if (!acc[init.category_name]) acc[init.category_name] = []
    acc[init.category_name].push(init)
    return acc
  }, {} as Record<string, Initiative[]>)

  if (loading) return <div className="text-center py-12 text-gray-500">Loading...</div>

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-ford-blue">Trend Charts</h1>
        <p className="text-gray-600 mt-1">View initiative progress over time</p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4 bg-white p-4 rounded-lg shadow-sm border">
        <div className="flex-1 min-w-[300px]">
          <label className="block text-sm font-medium text-gray-700 mb-1">Initiative</label>
          <select
            value={selectedInitiative}
            onChange={(e) => setSelectedInitiative(e.target.value)}
            className="w-full border rounded-md px-3 py-2 text-sm"
          >
            {Object.entries(groupedInits).map(([catName, inits]) => (
              <optgroup key={catName} label={catName}>
                {inits.map((init) => (
                  <option key={init.id} value={init.id}>
                    {init.name}
                  </option>
                ))}
              </optgroup>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">View</label>
          <select
            value={selectedPG}
            onChange={(e) => setSelectedPG(e.target.value)}
            className="border rounded-md px-3 py-2 text-sm min-w-[200px]"
          >
            <option value="all">SSDA Aggregate</option>
            <option value="compare">Compare All PGs</option>
            <optgroup label="Individual Product Group">
              {productGroups.map((pg) => (
                <option key={pg.id} value={pg.id}>
                  {pg.abbreviation} - {pg.name}
                </option>
              ))}
            </optgroup>
          </select>
        </div>
      </div>

      {/* Chart */}
      <div className="bg-white rounded-lg shadow-sm border p-6">
        <h3 className="font-semibold text-lg mb-4">
          {selectedInit?.name || 'Select an initiative'}
        </h3>
        <div className="h-[400px]">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis
                tickFormatter={(v) =>
                  isPercentage ? `${(v * 100).toFixed(0)}%` : v.toLocaleString()
                }
              />
              <Tooltip
                formatter={(value: any) =>
                  isPercentage ? `${(value * 100).toFixed(1)}%` : value?.toLocaleString()
                }
              />
              <Legend />
              {/* Goal line */}
              {chartData.some((d) => d['Goal'] !== undefined) && (
                <Line
                  type="monotone"
                  dataKey="Goal"
                  stroke="#9ca3af"
                  strokeDasharray="5 5"
                  strokeWidth={2}
                  dot={false}
                  connectNulls
                />
              )}
              {/* Data lines */}
              {selectedPG === 'all' && (
                <Line
                  type="monotone"
                  dataKey="SSDA Aggregate"
                  stroke={COLORS[0]}
                  strokeWidth={2}
                  dot
                  connectNulls
                />
              )}
              {selectedPG === 'compare' &&
                productGroups.map((pg, idx) => (
                  <Line
                    key={pg.id}
                    type="monotone"
                    dataKey={pg.abbreviation}
                    stroke={COLORS[idx % COLORS.length]}
                    strokeWidth={2}
                    dot
                    connectNulls
                  />
                ))}
              {selectedPG !== 'all' && selectedPG !== 'compare' && (
                <Line
                  type="monotone"
                  dataKey={productGroups.find((p) => p.id === selectedPG)?.abbreviation || ''}
                  stroke={COLORS[0]}
                  strokeWidth={2}
                  dot
                  connectNulls
                />
              )}
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  )
}
