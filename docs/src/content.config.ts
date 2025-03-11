import { defineCollection, reference, z } from 'astro:content';
import { glob } from 'astro/loaders';
import { docsLoader } from '@astrojs/starlight/loaders';
import { docsSchema } from '@astrojs/starlight/schema';
import { setTime } from './utils';

const docs = defineCollection({ loader: docsLoader(), schema: docsSchema() })

const people = defineCollection({
	loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/docs/people" }),
	schema: z.object({
		title: z.string(),
		organization: z.string(),
		contact: z.string(),
		type: z.enum(['speaker', 'organizer']),
		draft: z.boolean().optional(),
	}),
});

const events = defineCollection({
	loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/docs/events" }),
	schema: z.object({
		title: z.string(),
		speaker: reference('people'),
		date: z.date(),
		start_time: z.string().time(),
		stop_time: z.string().time(),
		place: z.string(),
		type: z.string(),
		group: z.enum(['seminar-series', 'methods-week', 'networking-event', 'other']),
		url: z.string().url().optional(),
		draft: z.boolean().optional(),
	}).transform((data) => {
		return {
			...data,
			start_datetime: setTime(data.date, data.start_time),
			stop_datetime: setTime(data.date, data.stop_time),
		};
	}),
});

export const collections = { docs, people, events };
