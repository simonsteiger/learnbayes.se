import { getCollection, getEntries, reference, z, type CollectionEntry } from "astro:content";
import { fromZonedTime } from 'date-fns-tz';
import rmMarkdown from 'remove-markdown'
import ics from "ics"

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

export const getSpeakerList = async (event: CollectionEntry<'events'>) => {
  const speakers = await getEntries(event?.data.speaker as CollectionEntry<'people'>[])
  return new Intl.ListFormat('en').format(speakers.map(d => d.data.title))
}

export const formatTime = (time: string) => {
  return time.slice(0, -3)
}

export function setTime(date: Date, time: string, timeZone: string = 'Europe/Stockholm'): Date {
  return fromZonedTime(`${date.toISOString().split('T')[0]}T${time}`, timeZone)
}

// Functions

export const getCalendarEventLink = async (event: CollectionEntry<'events'>) => {
  const { title, startDatetime: start_datetime, stopDatetime: stop_datetime, place, type, group } = event.data
  const speaker = await getSpeakerList(event)
  const body = rmMarkdown(event.body?.replaceAll(/import .+;/g, '') || '').trim()
  const url = `https://learnbayes.se/${event.id}`

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
