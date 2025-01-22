import { getCollection } from "astro:content";

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
