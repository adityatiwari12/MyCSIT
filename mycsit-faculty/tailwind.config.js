/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#FF6B35',
          light: '#FFF3EE',
          dark: '#E85520',
        },
        accent: '#FF9F1C',
        success: '#22C55E',
        warning: '#F59E0B',
        error: '#EF4444',
        surface: '#FFFFFF',
        background: '#F8F8F8',
        border: '#EEEEEE',
        'text-primary': '#1A1A2E',
        'text-secondary': '#6B7280',
        'text-muted': '#9CA3AF',
      },
      fontFamily: {
        display: ['Poppins', 'sans-serif'],
        body: ['DM Sans', 'sans-serif'],
      },
      borderRadius: {
        card: '16px',
        pill: '9999px',
      },
      boxShadow: {
        card: '0 2px 12px rgba(0,0,0,0.06)',
        elevated: '0 4px 24px rgba(0,0,0,0.10)',
        'accent-glow': '0 4px 16px rgba(255,107,53,0.25)',
      },
    },
  },
  plugins: [],
};
