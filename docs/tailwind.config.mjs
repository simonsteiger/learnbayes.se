import starlightPlugin from '@astrojs/starlight-tailwind';

import starlightPlugin from '@astrojs/starlight-tailwind';

// Generated color palettes
const accent = { 200: '#b1cfd1', 600: '#00787d', 900: '#0b393c', 950: '#0e292a' };
const gray = { 100: '#f6f6f6', 200: '#eeeeee', 300: '#c2c2c2', 400: '#8b8b8b', 500: '#585858', 700: '#383838', 800: '#272727', 900: '#181818' };

// const accent = { 200: '#FFDDD6', 600: '#FF876F', 900: '#B84145', 950: '#4F0433' };

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
			colors: { accent, gray },
    },
    fontFamily: {
      // Your preferred text font. Starlight uses a system font stack by default.
      sans: ['"Atkinson Hyperlegible"'],
      // Your preferred code font. Starlight uses system monospace fonts by default.
      mono: ['"Fira Code"', 'monospace'],
    },
  },
  plugins: [starlightPlugin()],
}
