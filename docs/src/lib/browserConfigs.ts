import { loadItems, type Item } from '@lib/items';

export interface GroupSpec {
	slug: string;
	label: string;
	matches: (item: Item) => boolean;
}

export interface ItemGroup {
	slug: string;
	label: string;
	items: Item[];
}

export interface BrowserConfig {
	load: () => Promise<Item[]>;
	ariaLabel: string;
	emptyText: string;
	itemLabel: string;
	groups?: GroupSpec[];
}

// Each item goes to the first group whose `matches` accepts it. Throws if an
// item matches no group, so a spec list without a catch-all fails loudly.
export function groupItems(items: Item[], specs: GroupSpec[]): ItemGroup[] {
	const groups = specs.map((spec) => ({ slug: spec.slug, label: spec.label, items: [] as Item[] }));
	for (const item of items) {
		const index = specs.findIndex((spec) => spec.matches(item));
		if (index === -1) throw new Error(`Item "${item.id}" matches no browser group`);
		groups[index].items.push(item);
	}
	return groups.filter((group) => group.items.length > 0);
}

export const browserConfigs: Record<'examples' | 'resources', BrowserConfig> = {
	examples: {
		ariaLabel: 'Filter examples',
		emptyText: 'No examples match these filters.',
		itemLabel: 'example',
		load: () => loadItems('examples'),
		groups: [
			{
				slug: 'statistical-rethinking-2026',
				label: 'Statistical Rethinking 2026',
				matches: (item) => item.id.startsWith('sr2026-'),
			},
			{
				slug: 'statistical-rethinking-2024',
				label: 'Statistical Rethinking 2024',
				matches: (item) => item.id.startsWith('sr2024-'),
			},
			{ slug: 'other-tutorials', label: 'Other tutorials', matches: () => true },
		],
	},
	resources: {
		ariaLabel: 'Filter resources',
		emptyText: 'No resources match these filters.',
		itemLabel: 'resource',
		load: () => loadItems('resources'),
	},
};
