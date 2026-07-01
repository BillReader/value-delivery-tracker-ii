'use client'
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { getStatusColor, getStatusDotClass, getStatusClasses, formatValue, calculateAggregate, MONTHS, CURRENT_YEAR } from '@/lib/utils'
type ProductGroup = {
  id: string
  name: string
  abbreviation: string
}
type SubmissionStatus = {
  product_group_id: string
  submitted_at: string
  submitted_by: string | null
}
type HeatmapCell = {
  initiative_id: string
  initiative_name: string
  category_name: string
  metric_type: 'percentage' | 'dollar' | 'roi' | 'count' | 'score'
  goal: number | null
  green_min: number
  yellow_min: number
  values: Record<string, number | null> // PG id -> value
  aggregate: number | null
}
export default function DashboardPage() {
  const [selectedMonth, setSelectedMonth] = useState<number>(new Date().getMonth() + 1)
  const [productGroups, setProductGroups] = useState<ProductGroup[]>([])
  const [submissions, setSubmissions] = useState<Map<string, SubmissionStatus>>(new Map())
  const [heatmapData, setHeatmapData] = useState<HeatmapCell[]>([])
  const [loading, setLoading] = useState(true)
  useEffect(() => {
    loadDashboard()
  }, [selectedMonth])
  async function loadDashboard() {
    setLoading(true)
    // Load product groups
    const { data: pgData } = await supabase
      .from('product_groups')
      .select('*')
      .order('display_order')
    if (pgData) setProductGroups(pgData)
    // Load submissions for this month
    const { data: subData } = await supabase
      .from('submissions')
      .select('*')
      .eq('month', selectedMonth)
      .eq('year', CURRENT_YEAR)
    const subMap = new Map<string, SubmissionStatus>()
    subData?.forEach((s) => subMap.set(s.product_group_id, s))
    setSubmissions(subMap)
    // Load all initiatives with their categories (product_group section only)
    const { data: initiatives } = await supabase
      .from('initiatives')
      .select(`
        id, name, metric_type, display_order,
        categories!inner ( name, section, display_order )
      `)
      .eq('categories.section', 'product_group')
      .order('display_order')
    // Load goals for this month
    const { data: goalData } = await supabase
      .from('initiative_goals')
      .select('initiative_id, target_value')
      .eq('month', selectedMonth)
      .eq('year', CURRENT_YEAR)
    const goalMap = new Map<string, number | null>()
    goalData?.forEach((g) => goalMap.set(g.initiative_id, g.target_value))
    // Load thresholds
    const { data: thresholdData } = await supabase
      .from('initiative_thresholds')
      .select('initiative_id, green_min, yellow_min')
    const thresholdMap = new Map<string, { green_min: number; yellow_min: number }>()
    thresholdData?.forEach((t) => thresholdMap.set(t.initiative_id, { green_min: t.green_min, yellow_min: t.yellow_min }))
    // Load all entries for this month
    const { data: entryData } = await supabase
      .from('monthly_entries')
      .select('initiative_id, product_group_id, value')
      .eq('month', selectedMonth)
      .eq('year', CURRENT_YEAR)
    // Build entry lookup: initiative_id -> { pg_id -> value }
    const entryLookup = new Map<string, Map<string, number | null>>()
    entryData?.forEach((e) => {
      if (!entryLookup.has(e.initiative_id)) {
        entryLookup.set(e.initiative_id, new Map())
      }
      entryLookup.get(e.initiative_id)!.set(e.product_group_id, e.value)
    })
    // Load assignments
    const { data: assignmentData } = await supabase
      .from('initiative_assignments')
      .select('initiative_id, product_group_id')
    const assignmentLookup = new Map<string, Set<string>>()
    assignmentData?.forEach((a) => {
      if (!assignmentLookup.has(a.initiative_id)) {
        assignmentLookup.set(a.initiative_id, new Set())
      }
      assignmentLookup.get(a.initiative_id)!.add(a.product_group_id)
    })
    // Build heatmap
    const heatmap: HeatmapCell[] = (initiatives || [])
      .sort((a: any, b: any) => 
        a.categories.display_order - b.categories.display_order || a.display_order - b.display_order
      )
      .map((init: any) => {
        const values: Record<string, number | null> = {}
        const assignedPGs = assignmentLookup.get(init.id) || new Set()
        const pgEntries = entryLookup.get(init.id) || new Map()
        const threshold = thresholdMap.get(init.id) || { green_min: 0.85, yellow_min: 0.65 }
        pgData?.forEach((pg) => {
          if (assignedPGs.has(pg.id)) {
            values[pg.id] = pgEntries.get(pg.id) ?? null
          }
        })
        const validValues = Object.values(values).filter((v): v is number => v !== null)
        const aggregate = validValues.length > 0
          ? validValues.reduce((s, v) => s + v, 0) / validValues.length
          : null
        return {
          initiative_id: init.id,
          initiative_name: init.name,
          category_name: init.categories.name,
          metric_type: init.metric_type,
          goal: goalMap.get(init.id) ?? null,
          green_min: threshold.green_min,
          yellow_min: threshold.yellow_min,
          values,
          aggregate,
        }
      })
    setHeatmapData(heatmap)
    setLoading(false)
  }
  // Calculate summary stats
  const totalCells = heatmapData.reduce((count, cell) => {
    return count + Object.keys(cell.values).length
  }, 0)
  const statusCounts = { green: 0, yellow: 0, red: 0, gray: 0 }
  heatmapData.forEach((cell) => {
    Object.values(cell.values).forEach((value) => {
      const status = getStatusColor(value, cell.goal, cell.green_min, cell.yellow_min)
      statusCounts[status]++
    })
  })
  const submittedCount = submissions.size
  const totalPGs = productGroups.length
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-ford-blue">Executive Dashboard</h1>
          <p className="text-gray-600 mt-1">Portfolio health overview and submission status</p>
        </div>
        <select
          value={selectedMonth}
          onChange={(e) => setSelectedMonth(Number(e.target.value))}
          className="border rounded-md px-3 py-2 text-sm"
        >
          {MONTHS.map((name, idx) => (
            <option key={idx} value={idx + 1}>
              {name} {CURRENT_YEAR}
            </option>
          ))}
        </select>
      </div>
      {loading ? (
        <div className="text-center py-12 text-gray-500">Loading dashboard...</div>
      ) : (
        <>
          {/* Submission Status Panel */}
          <div className="bg-white rounded-lg shadow-sm border p-6">
            <h2 className="font-semibold text-lg mb-4">
              Submission Status: {MONTHS[selectedMonth - 1]} {CURRENT_YEAR}
            </h2>
            <div className="mb-4">
              <div className="flex items-center gap-2 mb-2">
                <span className="text-2xl font-bold text-ford-blue">
                  {submittedCount} of {totalPGs}
                </span>
                <span className="text-gray-600">product groups submitted</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div
                  className="bg-ford-blue rounded-full h-3 transition-all"
                  style={{ width: `${(submittedCount / totalPGs) * 100}%` }}
                />
              </div>
            </div>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {productGroups.map((pg) => {
                const sub = submissions.get(pg.id)
                return (
                  <div
                    key={pg.id}
                    className={`p-3 rounded-md border ${
                      sub
                        ? 'bg-green-50 border-green-200'
                        : 'bg-red-50 border-red-200'
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <div
                        className={`w-3 h-3 rounded-full ${
                          sub ? 'bg-status-green' : 'bg-status-red'
                        }`}
                      />
                      <span className="font-medium text-sm">{pg.abbreviation}</span>
                    </div>
                    {sub && (
                      <div className="text-xs text-gray-500 mt-1">
                        {new Date(sub.submitted_at).toLocaleDateString()}
                      </div>
                    )}
                    {!sub && (
                      <div className="text-xs text-red-600 mt-1">Not submitted</div>
                    )}
                  </div>
                )
              })}
            </div>
          </div>
          {/* Summary KPIs */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <KPICard
              label="On Track (Green)"
              value={statusCounts.green}
              total={totalCells}
              color="text-status-green"
              bgColor="bg-green-50"
            />
            <KPICard
              label="At Risk (Yellow)"
              value={statusCounts.yellow}
              total={totalCells}
              color="text-status-yellow"
              bgColor="bg-yellow-50"
            />
            <KPICard
              label="Off Track (Red)"
              value={statusCounts.red}
              total={totalCells}
              color="text-status-red"
              bgColor="bg-red-50"
            />
            <KPICard
              label="No Data (Gray)"
              value={statusCounts.gray}
              total={totalCells}
              color="text-status-gray"
              bgColor="bg-gray-50"
            />
          </div>
          {/* Heatmap Matrix */}
          <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
            <div className="px-4 py-3 border-b bg-gray-50">
              <h2 className="font-semibold">Color-Coded Heatmap: Initiatives x Product Groups</h2>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-xs">
                <thead>
                  <tr className="border-b bg-gray-50">
                    <th className="text-left px-3 py-2 sticky left-0 bg-gray-50 min-w-[250px]">Initiative</th>
                    <th className="text-center px-2 py-2 w-[60px]">SSDA</th>
                    {productGroups.map((pg) => (
                      <th key={pg.id} className="text-center px-2 py-2 w-[60px]">
                        {pg.abbreviation}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {heatmapData.map((cell, idx) => {
                    const prevCategory = idx > 0 ? heatmapData[idx - 1].category_name : null
                    const showCategoryHeader = cell.category_name !== prevCategory
                    return (
                      <>
                        {showCategoryHeader && (
                          <tr key={`cat-${cell.category_name}`} className="bg-ford-blue/5">
                            <td
                              colSpan={productGroups.length + 2}
                              className="px-3 py-2 font-semibold text-ford-blue text-xs"
                            >
                              {cell.category_name}
                            </td>
                          </tr>
                        )}
                        <tr key={cell.initiative_id} className="border-b hover:bg-gray-50">
                          <td className="px-3 py-2 sticky left-0 bg-white text-xs max-w-[250px] truncate" title={cell.initiative_name}>
                            {cell.initiative_name}
                          </td>
                          <td className="text-center px-1 py-1">
                            <div
                              className={`rounded px-1 py-0.5 text-xs font-medium ${getStatusClasses(
                                getStatusColor(cell.aggregate, cell.goal, cell.green_min, cell.yellow_min)
                              )}`}
                            >
                              {formatValue(cell.aggregate, cell.metric_type, cell.category_name === 'Customer Profile System' ? 2 : 0)}
                            </div>
                          </td>
                          {productGroups.map((pg) => {
                            const value = cell.values[pg.id]
                            const isAssigned = pg.id in cell.values
                            if (!isAssigned) {
                              return (
                                <td key={pg.id} className="text-center px-1 py-1">
                                  <div className="text-gray-300">-</div>
                                </td>
                              )
                            }
                            const status = getStatusColor(value, cell.goal, cell.green_min, cell.yellow_min)
                            return (
                              <td key={pg.id} className="text-center px-1 py-1">
                                <div className={`rounded px-1 py-0.5 text-xs font-medium ${getStatusClasses(status)}`}>
                                  {formatValue(value, cell.metric_type, cell.category_name === 'Customer Profile System' ? 2 : 0)}
                                </div>
                              </td>
                            )
                          })}
                        </tr>
                      </>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
function KPICard({
  label,
  value,
  total,
  color,
  bgColor,
}: {
  label: string
  value: number
  total: number
  color: string
  bgColor: string
}) {
  const percentage = total > 0 ? ((value / total) * 100).toFixed(0) : '0'
  return (
    <div className={`${bgColor} rounded-lg border p-4`}>
      <div className={`text-2xl font-bold ${color}`}>{value}</div>
      <div className="text-sm text-gray-600">{label}</div>
      <div className="text-xs text-gray-500 mt-1">{percentage}% of total</div>
    </div>
  )
}
