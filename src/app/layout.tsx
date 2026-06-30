import type { Metadata } from 'next'
import './globals.css'
import Navigation from '@/components/Navigation'

export const metadata: Metadata = {
  title: 'Value Delivery Tracker II',
  description: 'SSDA Portfolio Progress Tracking',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="min-h-screen">
        <Navigation />
        <main className="max-w-[1600px] mx-auto px-4 py-6">
          {children}
        </main>
      </body>
    </html>
  )
}
