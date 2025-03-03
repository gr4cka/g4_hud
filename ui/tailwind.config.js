/** @type {import('tailwindcss').Config} */
import { replaceTailwindUnit, toEM } from 'tailwind-unit-replace'

const config = {
  content: [
    "./index.html",
    "./src/**/*.{svelte,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

export default replaceTailwindUnit({replacer: toEM})(config)

