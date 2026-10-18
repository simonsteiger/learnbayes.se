export interface SimpleFacet {
	key: string; // e.g. 'level', 'type'
	attr: string; // card dataset attribute name, e.g. 'level', 'type'
}

export interface CollapsibleFacet {
	key: string; // e.g. 'tag'
	attr: string; // e.g. 'tags'
}

export interface FacetedBrowserConfig {
	simple: SimpleFacet[];
	collapsible: CollapsibleFacet;
	searchAttr: string; // card dataset key holding the lowercase search blob, e.g. 'text'
	cardSelector: string; // '.lang-card' for both current browsers
	itemLabel: string; // singular noun, e.g. 'example' or 'resource'
}

const WORD_SPLIT = /[^a-z0-9]+/;

function tokenize(value: string): string[] {
	return value.toLowerCase().split(WORD_SPLIT).filter(Boolean);
}

export function initFacetedBrowser(root: HTMLElement, config: FacetedBrowserConfig): void {
	const facetKeys = [...config.simple.map((f) => f.key), config.collapsible.key];
	const simpleKeys = new Set(config.simple.map((f) => f.key));
	const facetAttr: Record<string, string> = {};
	for (const f of config.simple) facetAttr[f.key] = f.attr;
	facetAttr[config.collapsible.key] = config.collapsible.attr;

	const cards = Array.from(root.querySelectorAll<HTMLElement>(config.cardSelector));
	// Blobs are static post-load; tokenizing once here avoids redoing it twice per
	// card (matches + availFor) on every keystroke.
	const cardWords = new Map<HTMLElement, string[]>(
		cards.map((card) => [card, tokenize(card.dataset[config.searchAttr] ?? '')])
	);
	const groups = Array.from(root.querySelectorAll<HTMLElement>('[data-group]'));
	const facetButtons = Array.from(
		root.querySelectorAll<HTMLButtonElement>('button[data-facet]')
	);
	const resetButtons = Array.from(root.querySelectorAll<HTMLButtonElement>('[data-reset]'));
	const status = root.querySelector<HTMLElement>('[data-status]');
	const empty = root.querySelector<HTMLElement>('[data-empty]');

	const active = {
		facets: Object.fromEntries(facetKeys.map((key) => [key, new Set<string>()])) as Record<
			string,
			Set<string>
		>,
		query: '',
		search: [] as string[],
		expanded: false,
	};

	const searchInput = root.querySelector<HTMLInputElement>('[data-search]');
	const tagsWrap = root.querySelector<HTMLElement>('[data-tags-wrap]');
	const moreBtn = root.querySelector<HTMLElement>('[data-more]');
	const tagsToggleBtn = root.querySelector<HTMLButtonElement>('[data-tags-toggle]');
	const tagsToggleShowIcon = root.querySelector<HTMLElement>('[data-tags-toggle-icon="show"]');
	const tagsToggleHideIcon = root.querySelector<HTMLElement>('[data-tags-toggle-icon="hide"]');

	function readUrl() {
		const params = new URLSearchParams(window.location.search);
		for (const key of facetKeys) {
			active.facets[key] = new Set(params.getAll(key));
		}
		active.query = (params.get('q') ?? '').trim();
		active.search = tokenize(active.query);
		if (searchInput) searchInput.value = active.query;
	}

	// Any pending debounced write is superseded by an immediate one, so state
	// isn't written to the URL twice (once stale, once current).
	let searchUrlTimer: ReturnType<typeof setTimeout> | undefined;

	function writeUrl() {
		if (searchUrlTimer !== undefined) {
			clearTimeout(searchUrlTimer);
			searchUrlTimer = undefined;
		}
		const params = new URLSearchParams(window.location.search);
		for (const key of facetKeys) params.delete(key);
		for (const key of facetKeys) {
			active.facets[key].forEach((v) => params.append(key, v));
		}
		params.delete('q');
		if (active.query !== '') params.set('q', active.query);
		const qs = params.toString();
		history.replaceState(
			null,
			'',
			qs ? `?${qs}${window.location.hash}` : window.location.pathname + window.location.hash
		);
	}

	// Safari caps history.replaceState at ~100 calls per rolling 30s and throws
	// SecurityError past that (then keeps refusing calls for a while, even caught).
	// A deliberate typist alone can clear that limit well before 30s are up, so the
	// URL write is trailing-debounced at 500ms — worst case ~60 writes per 30s.
	// The 500ms wait is why this must be called after render(), never before it:
	// a throw in here must never be able to take card filtering down with it.
	function writeUrlDebounced() {
		if (searchUrlTimer !== undefined) clearTimeout(searchUrlTimer);
		searchUrlTimer = setTimeout(() => {
			searchUrlTimer = undefined;
			writeUrl();
		}, 500);
	}

	// A token matches a word when it equals it, or — from two characters up — prefixes
	// it, so "regress" finds "regression" mid-typing. The length floor is what stops the
	// one-letter language name "r" from matching every word that starts with an r.
	function matchesSearch(card: HTMLElement) {
		if (active.search.length === 0) return true;
		const words = cardWords.get(card) ?? [];
		return active.search.every((token) =>
			words.some((w) => w === token || (token.length >= 2 && w.startsWith(token)))
		);
	}

	function matches(card: HTMLElement) {
		if (!matchesSearch(card)) return false;
		return facetKeys.every((key) => {
			const values = (card.dataset[facetAttr[key]] ?? '').split(',').filter(Boolean);
			const set = active.facets[key];
			return set.size === 0 || values.some((v) => set.has(v));
		});
	}

	// Cards matching every active facet EXCEPT the named one, and always the search.
	// Ignoring a facet's own selection is the faceted-search rule that lets
	// multiple values in the same facet stay selectable together; the search has no
	// buttons of its own, so it is never ignored.
	function availFor(ignoreKey: string) {
		return cards.filter(
			(card) =>
				matchesSearch(card) &&
				facetKeys.every((key) => {
					if (key === ignoreKey) return true;
					const values = (card.dataset[facetAttr[key]] ?? '').split(',').filter(Boolean);
					const set = active.facets[key];
					return set.size === 0 || values.some((v) => set.has(v));
				})
		);
	}

	// Starlight renders each TOC entry as <li><a href="#slug">, desktop and mobile
	// alike, so one lookup keeps both in step with the filtered cards.
	function syncTocEntry(id: string, visible: boolean) {
		if (!id) return;
		const links = document.querySelectorAll<HTMLAnchorElement>(`a[href="#${CSS.escape(id)}"]`);
		for (const link of links) {
			const li = link.closest('li');
			if (li) li.hidden = !visible;
		}
	}

	function syncGroups() {
		for (const group of groups) {
			const groupCards = group.querySelectorAll<HTMLElement>(config.cardSelector);
			const visible = Array.from(groupCards).some((card) => !card.hidden);
			group.hidden = !visible;
			syncTocEntry(group.dataset.group ?? '', visible);
		}
	}

	function render() {
		let shown = 0;
		for (const card of cards) {
			const ok = matches(card);
			card.hidden = !ok;
			syncTocEntry(card.id, ok);
			if (ok) shown++;
		}
		syncGroups();
		const liveValues = new Set(
			availFor(config.collapsible.key).flatMap((c) =>
				(c.dataset[config.collapsible.attr] ?? '').split(',').filter(Boolean)
			)
		);
		for (const btn of facetButtons) {
			const facetKey = btn.dataset.facet ?? '';
			const value = btn.dataset.value ?? '';
			const set = active.facets[facetKey];
			const selected = set ? set.has(value) : false;
			btn.setAttribute('aria-pressed', String(selected));
			if (simpleKeys.has(facetKey)) {
				// Simple facets are global: never greyed/disabled by other facets or search.
				// Recolor unselected values once any value in this facet is chosen.
				const chosen = set ? set.size > 0 : false;
				btn.classList.toggle('is-muted', chosen && !selected);
			} else if (facetKey === config.collapsible.key) {
				const live = liveValues.has(value);
				btn.classList.toggle('is-unavailable', !live && !selected);
				btn.disabled = !live && !selected;
			}
		}
		const hasFilter = facetKeys.some((key) => active.facets[key].size > 0) || active.query !== '';
		for (const btn of resetButtons) {
			btn.disabled = !hasFilter;
			btn.setAttribute('aria-disabled', String(!hasFilter));
		}
		if (empty) empty.hidden = shown > 0;
		if (status) status.textContent = `${shown} ${config.itemLabel}${shown === 1 ? '' : 's'} shown`;
		const collapsedCount = applyCollapse();
		const canToggle = active.expanded || collapsedCount > 0;
		if (moreBtn) {
			const showMore = !active.expanded && collapsedCount > 0;
			moreBtn.hidden = !showMore;
			if (showMore) {
				const total = tagsWrap?.querySelectorAll('.fbtn').length ?? 0;
				moreBtn.textContent = `Toggle to show all ${total} tags`;
			}
		}
		if (tagsToggleBtn) {
			tagsToggleBtn.disabled = !canToggle;
			tagsToggleBtn.setAttribute('aria-disabled', String(!canToggle));
			tagsToggleBtn.setAttribute('aria-expanded', String(active.expanded));
			if (tagsToggleShowIcon) tagsToggleShowIcon.hidden = active.expanded;
			if (tagsToggleHideIcon) tagsToggleHideIcon.hidden = !active.expanded;
		}
	}

	// Measures how many buttons overflow past ~2 rows, always (even while expanded), so
	// the toggle button's enabled state stays accurate. Only actually hides the overflow
	// ('is-collapsed') when the collapsed view applies. The search never hides tag
	// buttons — unmatched tags are greyed out by render(), not pulled from the layout.
	function applyCollapse(): number {
		if (!tagsWrap) return 0;
		const tagBtns = Array.from(tagsWrap.querySelectorAll<HTMLButtonElement>('.fbtn'));
		// Clear collapse first so measurement sees the full layout.
		for (const b of tagBtns) b.classList.remove('is-collapsed');
		if (tagBtns.length === 0) return 0;
		const firstTop = tagBtns[0].offsetTop;
		let secondRowTop = Infinity;
		for (const b of tagBtns) {
			if (b.offsetTop > firstTop) {
				secondRowTop = Math.min(secondRowTop, b.offsetTop);
			}
		}
		if (secondRowTop === Infinity) return 0; // everything fits on row 1
		// Never collapse a selected tag — its active-filter chip must stay visible
		// (e.g. when reached via a shared ?tag= URL that sorts past row 2).
		const overflowing = tagBtns.filter(
			(b) => b.offsetTop > secondRowTop && b.getAttribute('aria-pressed') !== 'true'
		);
		if (!active.expanded) {
			for (const b of overflowing) b.classList.add('is-collapsed');
		}
		return overflowing.length;
	}

	function toggle(facetKey: string, value: string) {
		const set = active.facets[facetKey];
		if (!set) return;
		if (set.has(value)) set.delete(value);
		else set.add(value);
		writeUrl();
		render();
	}

	facetButtons.forEach((btn) =>
		btn.addEventListener('click', () => toggle(btn.dataset.facet ?? '', btn.dataset.value ?? ''))
	);
	searchInput?.addEventListener('input', () => {
		active.query = (searchInput.value ?? '').trim();
		active.search = tokenize(active.query);
		render();
		writeUrlDebounced();
	});
	tagsToggleBtn?.addEventListener('click', () => {
		active.expanded = !active.expanded;
		render();
	});

	resetButtons.forEach((btn) =>
		btn.addEventListener('click', () => {
			for (const key of facetKeys) active.facets[key].clear();
			active.query = '';
			active.search = [];
			active.expanded = false;
			if (searchInput) searchInput.value = '';
			writeUrl();
			render();
		})
	);

	// Clicking the "toggle to show all N tags" hint nudges the actual toggle
	// button (eye icon) with its own hover styling, without triggering it.
	moreBtn?.addEventListener('click', () => {
    if (!tagsToggleBtn) return;
    active.expanded = true;
    render();
	});

	readUrl();
	render();
	window.addEventListener('popstate', () => {
		readUrl();
		render();
	});
	window.addEventListener('resize', () => render());
}
