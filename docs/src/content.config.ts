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
		speaker: z.union([reference('people'), z.array(reference('people'))]).transform(
			speaker => Array.isArray(speaker) ? speaker : [speaker]
		),
		date: z.date(),
		start_time: z.string().time(),
		stop_time: z.string().time(),
		place: z.string(),
		type: z.string(),
		group: z.enum(['seminar-series', 'methods-week', 'networking-event', 'other']),
		url: z.string().url().optional(),
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

export const collections = { docs, people, events };
