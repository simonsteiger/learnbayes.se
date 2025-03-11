import { getCollection, reference, z, type CollectionEntry } from "astro:content";
import { fromZonedTime } from 'date-fns-tz';
import rmMarkdown from 'remove-markdown'
import ics from "ics"

// Zod Schemas

export const personSchema = z.object({
  title: z.string(),
  organization: z.string(),
  contact: z.string(),
  type: z.enum(['speaker', 'organizer']),
  draft: z.boolean().optional(),
})

export const eventSchema = z.object({
  title: z.string(),
  speaker: reference('people'),
  date: z.date(),
  start_time: z.string().time().optional(),
  stop_time: z.string().time().optional(),
  place: z.string().optional(),
  type: z.string(),
  group: z.enum(['seminar-series', 'methods-week', 'networking-event', 'other']),
  draft: z.boolean().optional(),
})

// Collections

export const allEvents = await getCollection("events", ({ data }) => {
  return import.meta.env.PROD ? data.draft !== true : true;
});

export const allPeople = await getCollection("people", ({ data }) => {
  return import.meta.env.PROD ? data.draft !== true : true;
});

export const allSpeakers = allPeople.filter(({ data }) => {
  return data.type == "speaker";
});

export const getSpeaker = (speakerID: string) => {
  return allSpeakers.find((speaker) => speaker.id == speakerID);
};

export const formatTime = (time: string) => {
  return time.slice(0, -3)
}

export function setTime(date: Date, time: string, timeZone: string = 'Europe/Stockholm'): Date {
  return fromZonedTime(`${date.toISOString().split('T')[0]}T${time}`, timeZone)
}

// Functions

export const getCalendarEventLink = async (event: CollectionEntry<'events'>) => {
  const { title, start_datetime, stop_datetime, place, type, group } = event.data

  const speaker = getSpeaker(event.data.speaker.id)?.data.title

  const body = rmMarkdown(event.body?.replaceAll(/import .+;/g, '') || '').trim()

  const url = `https://learnbayes.se/events/${event.id}`

  const eventData = {
    start: start_datetime.getTime(),
    end: stop_datetime.getTime(),
    title: `Learn Bayes: ${title} with ${speaker}`,
    description: `${type} with ${speaker}\n\n${body}\n\n${url}`,
    location: place,
    url: url,
    categories: [
      'Learn Bayes',
      group.replace("-", " ").replace(/(^|\s)\S/g, s => s.toUpperCase()),
      type
    ],
  }

  const { error, value } = ics.createEvent(eventData);

  if (error || value === undefined) {
    console.log(error);
    throw new Error('Failed to create ICS event');
  }

  const utf8Encoder = new TextEncoder();
  const utf8Bytes = utf8Encoder.encode(value);

  // Convert UTF-8 bytes to base64
  const base64 = btoa(
    Array.from(utf8Bytes)
      .map(byte => String.fromCharCode(byte))
      .join('')
  );

  return `data:text/calendar;charset=utf8;base64,${base64}`;
}
