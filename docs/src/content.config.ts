import { defineCollection, reference, z } from 'astro:content';
import { glob } from 'astro/loaders';
import { docsLoader } from '@astrojs/starlight/loaders';
import { docsSchema } from '@astrojs/starlight/schema';

const docs = defineCollection({ loader: docsLoader(), schema: docsSchema() })

const people = defineCollection({
	loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/people" }),
	schema: z.object({
		name: z.string(),
		organization: z.string(),
		contact: z.string(),
		type: z.enum(['speaker', 'organizer']),
		draft: z.boolean().optional(),
	}),
});

const events = defineCollection({
	loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/events" }),
	schema: z.object({
		title: z.string(),
		speaker: reference('people'),
		date: z.date(),
		start_time: z.string().time().optional(),
		stop_time: z.string().time().optional(),
		place: z.string().optional(),
		type: z.string(),
		group: z.enum(['seminar-series', 'methods-week', 'networking-event', 'other']),
		draft: z.boolean().optional(),
	}),
});

export const collections = { docs, people, events};
