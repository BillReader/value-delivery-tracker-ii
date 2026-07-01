// Default thresholds: Green >= 85% of goal, Yellow >= 65% of goal, Red < 65%
export const DEFAULT_GREEN_MIN = 0.85
export const DEFAULT_YELLOW_MIN = 0.65
export type StatusColor = 'green' | 'yellow' | 'red' | 'gray'
/**
 * Calculate the status color for a value against a goal.
 * Uses per-initiative thresholds if available, otherwise defaults.
 */
export function getStatusColor(
  value: number | null,
  goal: number | null,
  greenMin: number = DEFAULT_GREEN_MIN,
  yellowMin: number = DEFAULT_YELLOW_MIN
): StatusColor {
  if (value === null || goal === null || goal === 0) return 'gray'
  const ratio = value / goal
  if (ratio >= greenMin) return 'green'
  if (ratio >= yellowMin) return 'yellow'
  return 'red'
}
/**
 * Calculate SSDA aggregate (simple average) from product group values.
 * Only includes non-null values from assigned product groups.
 */
export function calculateAggregate(values: (number | null)[]): number | null {
  const validValues = values.filter((v): v is number => v !== null)
  if (validValues.length === 0) return null
  return validValues.reduce((sum, v) => sum + v, 0) / validValues.length
}
/**
 * Format a value based on its metric type for display.
 */
export function formatValue(
  value: number | null,
  metricType: 'percentage' | 'dollar' | 'roi' | 'count' | 'score'
): string {
  if (value === null) return '-'
  switch (metricType) {
    case 'percentage':
      return `${(value * 100).toFixed(0)}%`
    case 'dollar':
      if (value >= 1_000_000) return `$${(value / 1_000_000).toFixed(2)}M`
      if (value >= 1_000) return `$${(value / 1_000).toFixed(0)}K`
      return `$${value.toFixed(0)}`
    case 'roi':
      return `${(value * 100).toFixed(0)}%`
    case 'count':
      return value.toLocaleString()
    case 'score':
      return value.toFixed(1)
    default:
      return value.toString()
  }
}
/**
 * Get the CSS classes for a status color.
 */
export function getStatusClasses(status: StatusColor): string {
  switch (status) {
    case 'green':
      return 'bg-status-green text-white'
    case 'yellow':
      return 'bg-status-yellow text-black'
    case 'red':
      return 'bg-status-red text-white'
    case 'gray':
      return 'bg-status-gray text-white'
  }
}
/**
 * Get a dot/badge for inline status display.
 */
export function getStatusDotClass(status: StatusColor): string {
  switch (status) {
    case 'green':
      return 'bg-status-green'
    case 'yellow':
      return 'bg-status-yellow'
    case 'red':
      return 'bg-status-red'
    case 'gray':
      return 'bg-status-gray'
  }
}
