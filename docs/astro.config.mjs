// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightSidebarTopics from 'starlight-sidebar-topics';
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
      components: {
        SocialIcons: './src/components/SocialIcons.astro',
        ThemeProvider: './src/components/ThemeProvider.astro',
      },
      plugins: [
        starlightSidebarTopics([
          {
            label: 'Learning',
            link: '/learn/',
            icon: 'open-book',
            items: [
              { label: 'Examples', slug: 'learn/examples' },
              { label: 'Resources', slug: 'learn/resources' },
            ],
          },
          {
            label: 'Book Club',
            link: '/book-club/',
            icon: 'comment',
            items: [
              { label: 'About the Book Club', slug: 'book-club' },
            ],
          },
          {
            label: 'Events',
            link: '/information/information',
            icon: 'information',
            items: [
              { label: 'About Learn Bayes', slug: 'information/information' },
              { label: 'Seminar Series', autogenerate: { directory: 'events/seminar-series' } },
              { label: 'Methods Week', autogenerate: { directory: 'events/methods-week' } },
              { label: 'Networking Event', slug: 'information/networking-event' },
              { label: 'Speakers', slug: 'information/speakers' },
            ],
          },
        ], {
          exclude: [
            '/index',
            '/guides/**',
            '/programming/**',
            '/speakers/**',
            '/information/methods-week',
            '/information/seminar-series',
          ],
        }),
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
