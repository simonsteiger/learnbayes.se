// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwind from '@astrojs/tailwind';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';

// https://astro.build/config
export default defineConfig({
	site: 'https://learnbayes.se',
	integrations: [
		starlight({
			title: 'Learn Bayes',
			social: {
				gitlab: 'https://gitlab.com/alping/learn-bayes',
			},
			sidebar: [
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Example Guide', slug: 'guides/example' },
					],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
			customCss: [
				'./src/tailwind.css',
				'./src/assets/katex/katex.min.css',
			]
		}),
		tailwind({ applyBaseStyles: false })
	],
	markdown: {
		remarkPlugins: [remarkMath],
		rehypePlugins: [rehypeKatex],
		// rehypePlugins: [[rehypeKatex, {trust: true}]]
	},
});
