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

export const collections = { docs, speakers, events };
