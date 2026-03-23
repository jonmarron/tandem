/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,jsx,ts,tsx}',
    './components/**/*.{js,jsx,ts,tsx}',
  ],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        primary: '#4F7FFA',
        'primary-dark': '#3563D4',
        secondary: '#FF6B6B',
        accent: '#FFD166',
        background: '#F8F9FE',
        surface: '#FFFFFF',
        'text-primary': '#1A1D2E',
        'text-secondary': '#6B7280',
        border: '#E5E7EB',
        success: '#22C55E',
        error: '#EF4444',
      },
    },
  },
  plugins: [],
};
