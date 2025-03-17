// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwind from '@astrojs/tailwind';
import icon from 'astro-icon';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';

// https://astro.build/config
export default defineConfig({
  site: 'https://learnbayes.se',
  integrations: [
    starlight({
      title: 'Learn Bayes',
      logo: {
        src: './src/assets/learn-bayes-logo.svg',
      },
      social: {
        gitlab: 'https://gitlab.com/alping/learn-bayes',
        email: 'mailto:simon.steiger@ki.se',
      },
      sidebar: [
        { label: 'Home', link: '/' },
        {
          label: 'Information',
          autogenerate: { directory: 'information' },
        },
        {
          label: 'Events',
          autogenerate: { directory: 'events' },
          collapsed: false,
        },
        {
          label: 'Guides',
          autogenerate: { directory: 'guides' },
        },
        {
          label: 'Programming',
          autogenerate: { directory: 'programming' },
        },
        {
          label: 'Reading',
          autogenerate: { directory: 'reading' },
        },
      ],
      head: [
        // Add Plausible Analytics script (GDPR compliant analytics)
        {
          tag: 'script',
          attrs: {
            defer: true,
            'data-domain': 'learnbayes.se',
            src: 'https://plausible.io/js/script.outbound-links.js',
          },
        },
      ],
      customCss: [
        './src/tailwind.css',
        './src/assets/katex/katex.min.css',
        './src/styles/custom.css',
      ]
    }),
    tailwind({ applyBaseStyles: false }),
    icon()
  ],
  markdown: {
    remarkPlugins: [remarkMath],
    rehypePlugins: [rehypeKatex],
  },
});
