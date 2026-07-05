import { defineCollection, reference, z } from 'astro:content';
import { glob } from 'astro/loaders';
import { docsLoader } from '@astrojs/starlight/loaders';
import { docsSchema } from '@astrojs/starlight/schema';
import { setTime } from './utils';

const docs = defineCollection({ loader: docsLoader(), schema: docsSchema() })

const speakers = defineCollection({
	loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/docs/speakers" }),
	schema: z.object({
		title: z.string(),
		organization: z.string(),
		contact: z.string(),
		draft: z.boolean().optional(),
	}),
});

const events = defineCollection({
	loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/docs/events" }),
	schema: z.object({
		title: z.string(),
		speaker: z.union([reference('speakers'), z.array(reference('speakers'))]).transform(
			speaker => Array.isArray(speaker) ? speaker : [speaker]
		),
		date: z.date(),
		start_time: z.string().time(),
		stop_time: z.string().time(),
		place: z.string(),
		type: z.string(),
		group: z.enum(['seminar-series', 'methods-week', 'networking-event', 'other']),
		url: z.string().url().optional(),
		place_url: z.string().url().optional(),
		image: z.string().optional(),
		draft: z.boolean().optional(),
	}).transform((data) => {
		return {
			...data,
			image: data.image || `speakers/${data.speaker[0].id}`,
			startDatetime: setTime(data.date, data.start_time),
			stopDatetime: setTime(data.date, data.stop_time),
		};
	}),
});

const examples = defineCollection({
	loader: glob({ pattern: "**/*.{yml,yaml}", base: "./src/content/examples" }),
	schema: z.object({
		title: z.string(),
		description: z.string(),
		topic: z.string(),
		level: z.enum(['beginner', 'advanced', 'expert']),
		tags: z.array(z.string()).default([]),
		order: z.number().optional(),
		links: z.object({
			r: z.string().nullable().optional(),
			python: z.string().nullable().optional(),
			julia: z.string().nullable().optional(),
			stan: z.string().nullable().optional(),
		}),
		draft: z.boolean().optional(),
	}),
});

const resources = defineCollection({
	loader: glob({ pattern: "**/*.{yml,yaml}", base: "./src/content/resources" }),
	schema: z.object({
		title: z.string(),
		description: z.string().optional(),
		level: z.enum(['beginner', 'advanced', 'expert']).optional(),
		tags: z.array(z.string()).default([]),
		links: z.object({
			isbn: z.string().optional(),
			doi: z.string().optional(),
			website: z.string().url().optional(),
			code: z.string().url().optional(),
		}).default({}),
		draft: z.boolean().optional(),
	}),
});

export const collections = { docs, speakers, events, examples, resources };
