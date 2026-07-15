import { loadItems, type Item } from '@lib/items';

export interface BrowserConfig {
	load: () => Promise<Item[]>;
	ariaLabel: string;
	emptyText: string;
	itemLabel: string;
}

export const browserConfigs: Record<'examples' | 'resources', BrowserConfig> = {
	examples: {
		ariaLabel: 'Filter examples',
		emptyText: 'No examples match these filters.',
		itemLabel: 'example',
		load: () => loadItems('examples'),
	},
	resources: {
		ariaLabel: 'Filter resources',
		emptyText: 'No resources match these filters.',
		itemLabel: 'resource',
		load: () => loadItems('resources'),
	},
};
