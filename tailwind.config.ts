import type { Config } from 'tailwindcss'
const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
    './src/lib/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'status-green': '#22c55e',
        'status-yellow': '#eab308',
        'status-red': '#ef4444',
        'status-gray': '#9ca3af',
        'ford-blue': '#003478',
        'ford-blue-light': '#1a5dab',
      },
    },
  },
  plugins: [],
}
export default config
