'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { MONTHS, CURRENT_YEAR } from '@/lib/utils'

type NoteEntry = {
  initiative_name: string
  category_name: string
  product_group_abbr: string
  notes: string
  value: number | null
}

export default function NotesReportPage() {
  const [selectedMonth, setSelectedMonth] = useState<number>(new Date().getMonth() + 1)
  const [selectedPG, setSelectedPG] = useState<string>('all')
  const [selectedCategory, setSelectedCategory] = useState<string>('all')
  const [productGroups, setProductGroups] = useState<any[]>([])
  const [categories, setCategories] = useState<any[]>([])
  const [notes, setNotes] = useState<NoteEntry[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadFilters() {
      const { data: pgData } = await supabase
        .from('product_groups')
        .select('*')
        .order('display_order')
      if (pgData) setProductGroups(pgData)

      const { data: catData } = await supabase
        .from('categories')
        .select('*')
        .eq('section', 'product_group')
        .order('display_order')
      if (catData) setCategories(catData)
    }
    loadFilters()
  }, [])

  useEffect(() => {
    loadNotes()
  }, [selectedMonth, selectedPG, selectedCategory])

  async function loadNotes() {
    setLoading(true)

    let query = supabase
      .from('monthly_entries')
      .select(`
        value, notes,
        initiatives!inner ( name, category_id, categories ( name, section ) ),
        product_groups ( abbreviation, name )
      `)
      .eq('month', selectedMonth)
      .eq('year', CURRENT_YEAR)
      .not('notes', 'is', null)
      .neq('notes', '')

    if (selectedPG !== 'all') {
      query = query.eq('product_group_id', selectedPG)
    }

    const { data } = await query

    let filtered = (data || [])
      .map((entry: any) => ({
        initiative_name: entry.initiatives.name,
        category_name: entry.initiatives.categories.name,
        product_group_abbr: entry.product_groups?.abbreviation || 'Admin',
        notes: entry.notes,
        value: entry.value,
      }))
      .filter((n: NoteEntry) => {
        if (selectedCategory !== 'all') {
          return n.category_name === categories.find((c: any) => c.id === selectedCategory)?.name
        }
        return true
      })

    // Sort by category then initiative
    filtered.sort((a: NoteEntry, b: NoteEntry) => {
      if (a.category_name !== b.category_name) return a.category_name.localeCompare(b.category_name)
      if (a.initiative_name !== b.initiative_name) return a.initiative_name.localeCompare(b.initiative_name)
      return a.product_group_abbr.localeCompare(b.product_group_abbr)
    })

    setNotes(filtered)
    setLoading(false)
  }

  // Group notes by initiative for the consolidated view
  const groupedNotes = notes.reduce((acc, note) => {
    const key = `${note.category_name}|||${note.initiative_name}`
    if (!acc[key]) acc[key] = []
    acc[key].push(note)
    return acc
  }, {} as Record<string, NoteEntry[]>)

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-ford-blue">Notes Report</h1>
        <p className="text-gray-600 mt-1">
          Consolidated view of all manager notes for reporting
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4 bg-white p-4 rounded-lg shadow-sm border">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Month</label>
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
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Product Group</label>
          <select
            value={selectedPG}
            onChange={(e) => setSelectedPG(e.target.value)}
            className="border rounded-md px-3 py-2 text-sm"
          >
            <option value="all">All Product Groups</option>
            {productGroups.map((pg: any) => (
              <option key={pg.id} value={pg.id}>
                {pg.abbreviation}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="border rounded-md px-3 py-2 text-sm"
          >
            <option value="all">All Categories</option>
            {categories.map((cat: any) => (
              <option key={cat.id} value={cat.id}>
                {cat.name}
              </option>
            ))}
          </select>
        </div>
        <div className="ml-auto self-end">
          <button
            onClick={() => {
              // Copy all notes to clipboard in the consolidated format
              const text = Object.entries(groupedNotes)
                .map(([key, entries]) => {
                  const [category, initiative] = key.split('|||')
                  const noteLines = entries.map(
                    (e) => `${e.product_group_abbr}: ${e.notes}`
                  ).join('\n')
                  return `[${category}] ${initiative}\n${noteLines}`
                })
                .join('\n\n')
              navigator.clipboard.writeText(text)
            }}
            className="px-4 py-2 bg-ford-blue text-white rounded-md text-sm hover:bg-ford-blue-light"
          >
            Copy All Notes
          </button>
        </div>
      </div>

      {/* Notes Display */}
      {loading ? (
        <div className="text-center py-12 text-gray-500">Loading notes...</div>
      ) : notes.length === 0 ? (
        <div className="text-center py-12 text-gray-500 bg-white rounded-lg border">
          No notes found for the selected filters.
        </div>
      ) : (
        <div className="space-y-4">
          {Object.entries(groupedNotes).map(([key, entries]) => {
            const [category, initiative] = key.split('|||')
            return (
              <div key={key} className="bg-white rounded-lg shadow-sm border">
                <div className="px-4 py-3 border-b bg-gray-50">
                  <div className="text-xs text-gray-500 uppercase tracking-wide">{category}</div>
                  <div className="font-semibold text-gray-900">{initiative}</div>
                </div>
                <div className="divide-y">
                  {entries.map((entry, idx) => (
                    <div key={idx} className="px-4 py-3">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-medium text-sm text-ford-blue">
                          {entry.product_group_abbr}:
                        </span>
                      </div>
                      <p className="text-sm text-gray-700 whitespace-pre-wrap">
                        {entry.notes}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            )
          })}
        </div>
      )}

      <div className="text-sm text-gray-500">
        Total notes: {notes.length} across {Object.keys(groupedNotes).length} initiatives
      </div>
    </div>
  )
}
