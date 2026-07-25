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
      routeMiddleware: './src/routeMiddleware.ts',
      plugins: [
        starlightSidebarTopics([
          {
            label: 'Learning',
            id: 'learn',
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
          topics: {
            learn: ['/learn/examples/**', '/learn/resources/**'],
          },
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
        {
          tag: 'script',
          attrs: {
            defer: true,
            src: 'https://cloud.umami.is/script.js',
            'data-website-id': '3c1fdd32-4199-4ac2-a805-d6d46ea99cb1',
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
