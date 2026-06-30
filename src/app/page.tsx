import Link from 'next/link'

export default function Home() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-ford-blue">
          Value Delivery Tracker II
        </h1>
        <p className="text-gray-600 mt-2">
          Sales and Services Data &amp; Analytics (SSDA) Portfolio Progress Tracking
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <QuickLink
          href="/entry"
          title="Data Entry"
          description="Product group managers: Enter your monthly scores and notes here."
          color="bg-blue-50 border-blue-200"
        />
        <QuickLink
          href="/admin-entry"
          title="Admin Entry"
          description="Administrative initiatives: Enter quarterly/monthly admin scores."
          color="bg-purple-50 border-purple-200"
        />
        <QuickLink
          href="/dashboard"
          title="Executive Dashboard"
          description="Color-coded heatmap, submission status, and portfolio health overview."
          color="bg-green-50 border-green-200"
        />
        <QuickLink
          href="/trends"
          title="Trend Charts"
          description="View initiative progress over time with interactive charts."
          color="bg-amber-50 border-amber-200"
        />
        <QuickLink
          href="/reports/notes"
          title="Notes Report"
          description="Consolidated view of all manager notes for reporting."
          color="bg-orange-50 border-orange-200"
        />
        <QuickLink
          href="/export"
          title="Export Data"
          description="Download data as formatted Excel or CSV files."
          color="bg-gray-50 border-gray-200"
        />
      </div>
    </div>
  )
}

function QuickLink({
  href,
  title,
  description,
  color,
}: {
  href: string
  title: string
  description: string
  color: string
}) {
  return (
    <Link
      href={href}
      className={`block p-6 rounded-lg border ${color} hover:shadow-md transition-shadow`}
    >
      <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
      <p className="text-sm text-gray-600 mt-2">{description}</p>
    </Link>
  )
}
