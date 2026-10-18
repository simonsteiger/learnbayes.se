import { defineRouteMiddleware } from '@astrojs/starlight/route-data';
import type { Item, Kind } from '@lib/items';
import { browserConfigs, groupItems } from '@lib/browserConfigs';

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

	const config = browserConfigs[kind];
	const items = await config.load();
	const overview = starlightRoute.toc?.items[0];
	const cardEntry = (item: Item, depth: number) => ({ depth, slug: item.id, text: item.title, children: [] });
	const entries = config.groups
		? groupItems(items, config.groups).map((group) => ({
				depth: 2,
				slug: group.slug,
				text: group.label,
				children: group.items.map((item) => cardEntry(item, 3)),
			}))
		: items.map((item) => cardEntry(item, 2));

	starlightRoute.toc = {
		minHeadingLevel: 2,
		maxHeadingLevel: 3,
		items: overview ? [overview, ...entries] : entries,
	};
});
