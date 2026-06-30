export type Database = {
  public: {
    Tables: {
      product_groups: {
        Row: {
          id: string
          name: string
          abbreviation: string
          display_order: number
        }
        Insert: {
          id?: string
          name: string
          abbreviation: string
          display_order: number
        }
        Update: {
          id?: string
          name?: string
          abbreviation?: string
          display_order?: number
        }
      }
      categories: {
        Row: {
          id: string
          name: string
          code: string | null
          section: 'product_group' | 'admin'
          display_order: number
        }
        Insert: {
          id?: string
          name: string
          code?: string | null
          section: 'product_group' | 'admin'
          display_order: number
        }
        Update: {
          id?: string
          name?: string
          code?: string | null
          section?: 'product_group' | 'admin'
          display_order?: number
        }
      }
      initiatives: {
        Row: {
          id: string
          category_id: string
          name: string
          description: string | null
          metric_type: 'percentage' | 'dollar' | 'roi' | 'count' | 'score'
          frequency: 'monthly' | 'quarterly'
          display_order: number
        }
        Insert: {
          id?: string
          category_id: string
          name: string
          description?: string | null
          metric_type: 'percentage' | 'dollar' | 'roi' | 'count' | 'score'
          frequency?: 'monthly' | 'quarterly'
          display_order: number
        }
        Update: {
          id?: string
          category_id?: string
          name?: string
          description?: string | null
          metric_type?: 'percentage' | 'dollar' | 'roi' | 'count' | 'score'
          frequency?: 'monthly' | 'quarterly'
          display_order?: number
        }
      }
      initiative_assignments: {
        Row: {
          id: string
          initiative_id: string
          product_group_id: string
        }
        Insert: {
          id?: string
          initiative_id: string
          product_group_id: string
        }
        Update: {
          id?: string
          initiative_id?: string
          product_group_id?: string
        }
      }
      initiative_goals: {
        Row: {
          id: string
          initiative_id: string
          month: number
          year: number
          target_value: number | null
        }
        Insert: {
          id?: string
          initiative_id: string
          month: number
          year: number
          target_value?: number | null
        }
        Update: {
          id?: string
          initiative_id?: string
          month?: number
          year?: number
          target_value?: number | null
        }
      }
      initiative_thresholds: {
        Row: {
          id: string
          initiative_id: string
          green_min: number
          yellow_min: number
        }
        Insert: {
          id?: string
          initiative_id: string
          green_min: number
          yellow_min: number
        }
        Update: {
          id?: string
          initiative_id?: string
          green_min?: number
          yellow_min?: number
        }
      }
      monthly_entries: {
        Row: {
          id: string
          initiative_id: string
          product_group_id: string | null
          month: number
          year: number
          value: number | null
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          initiative_id: string
          product_group_id?: string | null
          month: number
          year: number
          value?: number | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          initiative_id?: string
          product_group_id?: string | null
          month?: number
          year?: number
          value?: number | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      submissions: {
        Row: {
          id: string
          product_group_id: string
          month: number
          year: number
          submitted_at: string
          submitted_by: string | null
        }
        Insert: {
          id?: string
          product_group_id: string
          month: number
          year: number
          submitted_at?: string
          submitted_by?: string | null
        }
        Update: {
          id?: string
          product_group_id?: string
          month?: number
          year?: number
          submitted_at?: string
          submitted_by?: string | null
        }
      }
    }
  }
}
