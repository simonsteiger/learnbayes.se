import { getCollection, getEntries, type CollectionEntry } from "astro:content";
import { fromZonedTime } from 'date-fns-tz';
import rmMarkdown from 'remove-markdown'
import ics from "ics"

// Collections

export const allEvents = await getCollection("events", ({ data }) => {
  return import.meta.env.PROD ? data.draft !== true : true;
});

export const allSpeakers = await getCollection("speakers", ({ data }) => {
  return import.meta.env.PROD ? data.draft !== true : true;
});

export const getSpeakerList = async (event: CollectionEntry<'events'>) => {
  const speakers = await getEntries(event?.data.speaker as CollectionEntry<'speakers'>[])
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

  return toCalendarDataUrl(eventData)
}

export interface Lecture {
  /** Lecture label, e.g. `A01`. */
  label: string;
  url: string;
}

interface BookClubSessionDetails {
  start: Date;
  end: Date;
  place: string;
  chapters: number[];
  lectures: Lecture[];
}

export const formatList = (items: (string | number)[]) => new Intl.ListFormat('en').format(items.map(String))

export const pluralise = (noun: string, count: number) => (count === 1 ? noun : `${noun}s`)

export const getBookClubCalendarEventLink = (session: BookClubSessionDetails) => {
  const { start, end, place, chapters, lectures } = session
  const url = 'https://learnbayes.se/book-club/sessions'
  const lectureList = formatList(lectures.map(({ label, url }) => `${label} (${url})`))
  const preparation = `We recommend watching video ${pluralise('lecture', lectures.length)} ${lectureList} and reading ${pluralise('chapter', chapters.length)} ${formatList(chapters)}.`

  return toCalendarDataUrl({
    start: start.getTime(),
    end: end.getTime(),
    title: 'Learn Bayes: Book Club',
    description: `Book club on Statistical Rethinking by Richard McElreath\n\n${preparation}\n\n${url}`,
    location: place,
    url: url,
    categories: ['Learn Bayes', 'Book Club'],
  })
}

interface WorkshopModuleDetails {
  start: Date;
  end: Date;
  place: string;
  module: string;
}

export const getWorkflowWorkshopCalendarEventLink = (session: WorkshopModuleDetails) => {
  const { start, end, place, module } = session
  const url = 'https://learnbayes.se/information/workflow-workshop'

  return toCalendarDataUrl({
    start: start.getTime(),
    end: end.getTime(),
    title: `Learn Bayes: Bayesian Workflow workshop – ${module}`,
    description: `Bayesian Workflow workshop, module: ${module}\n\n${url}`,
    location: place,
    url: url,
    categories: ['Learn Bayes', 'Workshop'],
  })
}

const toCalendarDataUrl =(eventData: ics.EventAttributes) => {
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
