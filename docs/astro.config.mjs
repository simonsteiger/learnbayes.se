// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwindcss from '@tailwindcss/vite';
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
        src: './src/assets/img/learn-bayes-logo.svg',
      },
      social: [
        { icon: 'gitlab', label: 'GitLab', href: 'https://gitlab.com/alping/learn-bayes' },
        { icon: 'email', label: 'Email', href: 'mailto:simon.steiger@ki.se' }
      ],
      sidebar: [
        { label: 'Home', link: '/' },
        {
          label: 'Information',
          autogenerate: { directory: 'information' },
        },
        {
          label: 'Seminar Series',
          autogenerate: { directory: 'events/seminar-series' },
          collapsed: true,
        },
        {
          label: 'Methods Week',
          autogenerate: { directory: 'events/methods-week' },
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
        './src/assets/katex/katex.min.css',
        './src/styles/global.css',
      ]
    }),
    icon()
  ],
  markdown: {
    remarkPlugins: [remarkMath],
    rehypePlugins: [rehypeKatex],
  },
  vite: {
    plugins: [tailwindcss()],
  },
});
