import { getCollection } from 'astro:content';
import { resolveIconUrl, greyVariant } from '@lib/icons';
import removeMarkdown from 'remove-markdown';

export type Kind = 'examples' | 'resources';
export type Level = 'beginner' | 'intermediate' | 'advanced';

export interface ItemChip {
	key: string;
	label: string;
	href: string | null;
	iconUrl?: string;
	iconName?: string;
}

export interface Item {
	id: string;
	kind: Kind;
	href: string;
	title: string;
	description?: string;
	level?: Level;
	tags: string[];
	chips: ItemChip[];
	text: string;
}

// Language chips (examples): coloured svg when the link exists, grey svg when it does not.
const languages = [
	{ key: 'stan', label: 'Stan', svg: 'stan.svg' },
	{ key: 'r', label: 'R', svg: 'r.svg' },
	{ key: 'python', label: 'Python', svg: 'python.svg' },
	{ key: 'julia', label: 'Julia', svg: 'julia.svg' },
] as const;

// Media chips (resources): astro-icon names + url builders.
const media = [
	{ key: 'isbn', label: 'Book', icon: 'ph:book-duotone', href: (v: string) => `https://isbnsearch.org/isbn/${v}` },
	{ key: 'doi', label: 'Article', icon: 'ph:scroll-duotone', href: (v: string) => `https://doi.org/${v}` },
	{ key: 'website', label: 'Website', icon: 'ph:planet-duotone', href: (v: string) => v },
	{ key: 'code', label: 'Code', icon: 'ph:code', href: (v: string) => v },
] as const;

const levelRank = { beginner: 0, intermediate: 1, advanced: 2 } as const;

const isVisible = (e: { data: { draft?: boolean } }) => (import.meta.env.PROD ? !e.data.draft : true);

function byLevelThenTitle(
	a: { data: { level?: Level; title: string } },
	b: { data: { level?: Level; title: string } },
): number {
	const diff = levelRank[a.data.level ?? 'advanced'] - levelRank[b.data.level ?? 'advanced'];
	return diff !== 0 ? diff : a.data.title.localeCompare(b.data.title);
}

type ExampleLinks = { r?: string | null; python?: string | null; julia?: string | null; stan?: string | null };
type ResourceLinks = { isbn?: string; doi?: string; website?: string; code?: string };

function languageChips(links: ExampleLinks): ItemChip[] {
	return languages.map(({ key, label, svg }) => {
		const href = links[key] ?? null;
		return { key, label, href, iconUrl: resolveIconUrl(href ? svg : greyVariant(svg)) };
	});
}

function mediaChips(links: ResourceLinks): ItemChip[] {
	return media.map(({ key, label, icon, href }) => {
		const value = links[key];
		return { key, label, href: value ? href(value) : null, iconName: icon };
	});
}

// Lowercase blob backing the browser's free-text search. Only chips with a real
// href contribute, so searching "julia" or "book" narrows to items that actually
// offer it rather than to every item that has a Julia chip slot.
function searchText(item: Omit<Item, 'text'>, body: string | undefined): string {
	const available = item.chips.filter((c) => c.href).map((c) => c.label);
	const prose = removeMarkdown((body ?? '').replaceAll(/import .+;/g, ''));
	return [item.title, item.description ?? '', item.level ?? '', ...item.tags, ...available, prose]
		.join(' ')
		.toLowerCase()
		.replace(/\s+/g, ' ')
		.trim();
}

export async function loadItems(kind: Kind): Promise<Item[]> {
	if (kind === 'examples') {
		const entries = (await getCollection('examples')).filter(isVisible).sort(byLevelThenTitle);
		return entries.map((e) => {
			const base = {
				id: e.id,
				kind,
				href: `/learn/examples/${e.id}/`,
				title: e.data.title,
				description: e.data.description,
				level: e.data.level,
				tags: e.data.tags,
				chips: languageChips(e.data.links),
			} satisfies Omit<Item, 'text'>;
			return { ...base, text: searchText(base, e.body) };
		});
	}
	const entries = (await getCollection('resources')).filter(isVisible).sort(byLevelThenTitle);
	return entries.map((e) => {
		const base = {
			id: e.id,
			kind,
			href: `/learn/resources/${e.id}/`,
			title: e.data.title,
			description: e.data.description,
			level: e.data.level,
			tags: e.data.tags,
			chips: mediaChips(e.data.links),
		} satisfies Omit<Item, 'text'>;
		return { ...base, text: searchText(base, e.body) };
	});
}
