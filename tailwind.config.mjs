import starlightPlugin from '@astrojs/starlight-tailwind';

const accent = { 200: '#FFDDD6', 600: '#FF876F', 900: '#B84145', 950: '#4F0433' };

/** @type {import('tailwindcss').Config} */
export default {
	content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
	theme: {
		extend: {
			colors: { accent }
		},
		fontFamily: {
			// Your preferred text font. Starlight uses a system font stack by default.
			sans: ['"Atkinson Hyperlegible"'],
			// Your preferred code font. Starlight uses system monospace fonts by default.
			mono: ['"Fira Code"'],
		},
	},
	plugins: [starlightPlugin()],
}
