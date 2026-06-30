'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'

const navItems = [
  { href: '/', label: 'Home' },
  { href: '/entry', label: 'Data Entry' },
  { href: '/admin-entry', label: 'Admin Entry' },
  { href: '/dashboard', label: 'Dashboard' },
  { href: '/trends', label: 'Trends' },
  { href: '/reports/notes', label: 'Notes Report' },
  { href: '/export', label: 'Export' },
  { href: '/admin', label: 'Admin Setup' },
]

export default function Navigation() {
  const pathname = usePathname()

  return (
    <nav className="bg-ford-blue text-white shadow-lg">
      <div className="max-w-[1600px] mx-auto px-4">
        <div className="flex items-center h-16">
          <Link href="/" className="font-bold text-lg mr-8 whitespace-nowrap">
            VDT II
          </Link>
          <div className="flex space-x-1 overflow-x-auto">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={`px-3 py-2 rounded-md text-sm font-medium whitespace-nowrap transition-colors ${
                  pathname === item.href
                    ? 'bg-white/20 text-white'
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                {item.label}
              </Link>
            ))}
          </div>
        </div>
      </div>
    </nav>
  )
}
