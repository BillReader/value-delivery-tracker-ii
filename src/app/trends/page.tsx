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
    const selectedInit = initiatives.find((i) => i.id === selectedInitiative)
    const isDollar = selectedInit?.metric_type === 'dollar'
    const isFinancialCategory = selectedInit?.category_name === 'Direct Financial Impact'
    const isTotalBenefits = isFinancialCategory && (selectedInit?.name.includes('Total Benefits') || false)
    // Load all entries for this initiative across all months
    const { data: entries } = await supabase
      .from('monthly_entries')
      .select('product_group_id, month, year, value')
      .eq('initiative_id', selectedInitiative)
      .eq('year', CURRENT_YEAR)
      .not('product_group_id', 'is', null)
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
    // If this is Total Benefits, also load Costs (for SSDA aggregate AND individual PG views)
    let costEntries: any[] = []
    if (isTotalBenefits && selectedPG !== 'compare') {
      const costsInit = initiatives.find(i =>
        i.category_name === 'Direct Financial Impact' && i.name.includes('Projected Costs')
      )
      if (costsInit) {
        const { data: costData } = await supabase
          .from('monthly_entries')
          .select('product_group_id, month, year, value')
          .eq('initiative_id', costsInit.id)
          .eq('year', CURRENT_YEAR)
          .not('product_group_id', 'is', null)
          .order('month')
        if (costData) costEntries = costData
      }
    }
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
        // SSDA aggregate: SUM for dollar metrics, AVERAGE for others
        const values = monthEntries.map((e) => e.value).filter((v): v is number => v !== null)
        if (values.length > 0) {
          const aggValue = isDollar
            ? values.reduce((s, v) => s + v, 0)
            : values.reduce((s, v) => s + v, 0) / values.length
          // Use specific label for Total Benefits, generic for others
          if (isTotalBenefits) {
            point['SSDA Total Benefits'] = aggValue
          } else {
            point['SSDA Aggregate'] = aggValue
          }
        }
        // Add cost line for Total Benefits view
        if (isTotalBenefits && costEntries.length > 0) {
          const monthCosts = costEntries.filter((e) => e.month === month)
          const costValues = monthCosts.map((e) => e.value).filter((v): v is number => v !== null)
          if (costValues.length > 0) {
            point['SSDA Total Costs'] = costValues.reduce((s, v) => s + v, 0)
          }
        }
      } else if (selectedPG === 'compare') {
        // Show all PGs on same chart
        productGroups.forEach((pg) => {
          const entry = monthEntries.find((e) => e.product_group_id === pg.id)
          point[pg.abbreviation] = entry?.value ?? null
        })
      } else {
        // Individual PG view
        if (isTotalBenefits) {
          // For Total Benefits: show both benefits and costs for this PG
          const entry = monthEntries.find((e) => e.product_group_id === selectedPG)
          point['Total Benefits'] = entry?.value ?? null
          if (costEntries.length > 0) {
            const costEntry = costEntries.find((e) => e.product_group_id === selectedPG && e.month === month)
            if (costEntry?.value !== null && costEntry?.value !== undefined) {
              point['Total Costs'] = costEntry.value
            }
          }
        } else {
          // Non-financial: show PG abbreviation as before
          const pg = productGroups.find((p) => p.id === selectedPG)
          const entry = monthEntries.find((e) => e.product_group_id === selectedPG)
          if (pg) point[pg.abbreviation] = entry?.value ?? null
        }
      }
      return point
    })
    setChartData(data)
  }
  const selectedInit = initiatives.find((i) => i.id === selectedInitiative)
  const isPercentage = selectedInit?.metric_type === 'percentage'
  const isDollar = selectedInit?.metric_type === 'dollar'
  const isROI = selectedInit?.metric_type === 'roi'
  const isTotalBenefits = selectedInit?.category_name === 'Direct Financial Impact' && (selectedInit?.name.includes('Total Benefits') || false)
  // Determine which cost line key is in use
  const hasSSDACostLine = chartData.some((d) => d['SSDA Total Costs'] !== undefined)
  const hasPGCostLine = chartData.some((d) => d['Total Costs'] !== undefined)
  const hasCostLine = hasSSDACostLine || hasPGCostLine
  // Format Y axis ticks based on metric type
  function formatYAxis(v: number): string {
    if (isPercentage || isROI) return `${(v * 100).toFixed(0)}%`
    if (isDollar) {
      if (Math.abs(v) >= 1_000_000_000) return `$${(v / 1_000_000_000).toFixed(1)}B`
      if (Math.abs(v) >= 1_000_000) return `$${(v / 1_000_000).toFixed(0)}M`
      if (Math.abs(v) >= 1_000) return `$${(v / 1_000).toFixed(0)}K`
      return `$${v.toFixed(0)}`
    }
    return v.toLocaleString()
  }
  // Format tooltip values
  function formatTooltipValue(value: any): string {
    if (value === null || value === undefined) return '-'
    if (isPercentage || isROI) return `${(value * 100).toFixed(1)}%`
    if (isDollar) return `$${value.toLocaleString()}`
    return value.toLocaleString()
  }
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
          {hasCostLine && <span className="text-sm font-normal text-gray-500 ml-2">(with costs overlay)</span>}
        </h3>
        <div className="h-[400px]">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData} margin={{ top: 5, right: 30, left: 80, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis tickFormatter={formatYAxis} width={90} />
              <Tooltip formatter={(value: any) => formatTooltipValue(value)} />
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
              {/* === SSDA Aggregate View === */}
              {selectedPG === 'all' && isTotalBenefits && (
                <Line
                  type="monotone"
                  dataKey="SSDA Total Benefits"
                  stroke={COLORS[0]}
                  strokeWidth={2}
                  dot
                  connectNulls
                />
              )}
              {selectedPG === 'all' && !isTotalBenefits && (
                <Line
                  type="monotone"
                  dataKey="SSDA Aggregate"
                  stroke={COLORS[0]}
                  strokeWidth={2}
                  dot
                  connectNulls
                />
              )}
              {/* SSDA cost overlay */}
              {hasSSDACostLine && (
                <Line
                  type="monotone"
                  dataKey="SSDA Total Costs"
                  stroke="#ef4444"
                  strokeWidth={2}
                  dot
                  connectNulls
                />
              )}
              {/* === Compare All PGs View === */}
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
              {/* === Individual PG View === */}
              {selectedPG !== 'all' && selectedPG !== 'compare' && isTotalBenefits && (
                <Line
                  type="monotone"
                  dataKey="Total Benefits"
                  stroke={COLORS[0]}
                  strokeWidth={2}
                  dot
                  connectNulls
                />
              )}
              {/* PG cost overlay */}
              {hasPGCostLine && (
                <Line
                  type="monotone"
                  dataKey="Total Costs"
                  stroke="#ef4444"
                  strokeWidth={2}
                  dot
                  connectNulls
                />
              )}
              {selectedPG !== 'all' && selectedPG !== 'compare' && !isTotalBenefits && (
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
