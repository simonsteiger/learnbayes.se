// Build-time resolver for local SVG icon URLs. Vite resolves the glob at build.
// Keys look like ".../src/assets/img/icons/julia.svg" -> string URL.
const iconUrls = import.meta.glob<string>('@assets/img/icons/*.svg', {
	eager: true,
	query: '?url',
	import: 'default',
});

export function resolveIconUrl(name: string): string {
	const hit = Object.entries(iconUrls).find(([p]) => p.endsWith(`/${name}`));
	if (!hit) throw new Error(`resolveIconUrl: icon not found: ${name}`);
	return hit[1];
}

export function greyVariant(name: string): string {
	return name.replace(/\.svg$/, '_grey.svg');
}
