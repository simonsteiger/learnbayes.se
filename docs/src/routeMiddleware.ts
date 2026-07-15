import { defineRouteMiddleware } from '@astrojs/starlight/route-data';
import { loadItems, type Kind } from '@lib/items';

// The two faceted-browser pages have no headings of their own, so their TOC is
// free real estate: fill it with the cards on the page.
const browserRoutes: Record<string, Kind> = {
	'learn/examples': 'examples',
	'learn/resources': 'resources',
};

export const onRequest = defineRouteMiddleware(async (context) => {
	const { starlightRoute } = context.locals;
	const id = starlightRoute.id.replace(/\.mdx?$/, '');
	const kind = browserRoutes[id];
	if (!kind) return;

	const items = await loadItems(kind);
	const overview = starlightRoute.toc?.items[0];
	const cardItems = items.map((item) => ({
		depth: 2,
		slug: item.id,
		text: item.title,
		children: [],
	}));

	starlightRoute.toc = {
		minHeadingLevel: 2,
		maxHeadingLevel: 3,
		items: overview ? [overview, ...cardItems] : cardItems,
	};
});
