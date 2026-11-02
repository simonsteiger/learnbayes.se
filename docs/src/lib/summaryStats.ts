import type { CollectionEntry } from 'astro:content';

export interface LevelCounts { beginner: number; intermediate: number; advanced: number }
export interface ChipCount { key: string; count: number }

export interface ExampleStats {
	total: number;
	langs: ChipCount[];
	levels: LevelCounts;
	tagCount: number;
}

export interface ResourceStats {
	total: number;
	types: ChipCount[];
	levels: LevelCounts;
	tagCount: number;
}

const LANG_KEYS = ['stan', 'r', 'python', 'julia'] as const;
const TYPE_KEYS = ['website', 'article', 'book', 'code'] as const;

// Resource type is derived from which link is present — the link field carries the type.
const TYPE_LINK = { website: 'website', article: 'doi', book: 'isbn', code: 'code' } as const;

function emptyLevels(): LevelCounts {
	return { beginner: 0, intermediate: 0, advanced: 0 };
}

function countLevels<T extends { data: { level?: 'beginner' | 'intermediate' | 'advanced' } }>(
	entries: T[],
): LevelCounts {
	const levels = emptyLevels();
	for (const e of entries) {
		if (e.data.level) levels[e.data.level] += 1;
	}
	return levels;
}

function uniqueTagCount(entries: { data: { tags: string[] } }[]): number {
	return new Set(entries.flatMap((e) => e.data.tags)).size;
}

export function exampleStats(entries: CollectionEntry<'examples'>[]): ExampleStats {
	const langs = LANG_KEYS.map((key) => ({
		key,
		count: entries.filter((e) => e.data.links[key] != null).length,
	}));
	return {
		total: entries.length,
		langs,
		levels: countLevels(entries),
		tagCount: uniqueTagCount(entries),
	};
}

export function resourceStats(entries: CollectionEntry<'resources'>[]): ResourceStats {
	const types = TYPE_KEYS.map((key) => ({
		key,
		count: entries.filter((e) => e.data.links[TYPE_LINK[key]] != null).length,
	}));
	return {
		total: entries.length,
		types,
		levels: countLevels(entries),
		tagCount: uniqueTagCount(entries),
	};
}
