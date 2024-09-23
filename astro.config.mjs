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
          label: 'Information',
          autogenerate: { directory: 'information' },
        },
        {
          label: 'Examples',
          autogenerate: {directory: 'examples'},
        },
        {
          label: 'Guides',
          autogenerate: {directory: 'guides'},
        },
        {
          label: 'Further reading',
          autogenerate: {directory: 'resources'},
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
  },
});
