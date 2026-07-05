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
	cardSelector: string; // '.lang-card' for both current browsers
	itemLabel: string; // singular noun, e.g. 'example' or 'resource'
}

export function initFacetedBrowser(root: HTMLElement, config: FacetedBrowserConfig): void {
	const facetKeys = [...config.simple.map((f) => f.key), config.collapsible.key];
	const simpleKeys = new Set(config.simple.map((f) => f.key));
	const facetAttr: Record<string, string> = {};
	for (const f of config.simple) facetAttr[f.key] = f.attr;
	facetAttr[config.collapsible.key] = config.collapsible.attr;

	const cards = Array.from(root.querySelectorAll<HTMLElement>(config.cardSelector));
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
		search: '',
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
	}

	function writeUrl() {
		const params = new URLSearchParams(window.location.search);
		for (const key of facetKeys) params.delete(key);
		for (const key of facetKeys) {
			active.facets[key].forEach((v) => params.append(key, v));
		}
		const qs = params.toString();
		history.replaceState(
			null,
			'',
			qs ? `?${qs}${window.location.hash}` : window.location.pathname + window.location.hash
		);
	}

	function matches(card: HTMLElement) {
		return facetKeys.every((key) => {
			const values = (card.dataset[facetAttr[key]] ?? '').split(',').filter(Boolean);
			const set = active.facets[key];
			return set.size === 0 || values.some((v) => set.has(v));
		});
	}

	// Cards matching every active facet EXCEPT the named one.
	// Ignoring a facet's own selection is the faceted-search rule that lets
	// multiple values in the same facet stay selectable together.
	function availFor(ignoreKey: string) {
		return cards.filter((card) =>
			facetKeys.every((key) => {
				if (key === ignoreKey) return true;
				const values = (card.dataset[facetAttr[key]] ?? '').split(',').filter(Boolean);
				const set = active.facets[key];
				return set.size === 0 || values.some((v) => set.has(v));
			})
		);
	}

	function render() {
		let shown = 0;
		for (const card of cards) {
			const ok = matches(card);
			card.hidden = !ok;
			if (ok) shown++;
		}
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
				const matchesSearch = active.search === '' || value.toLowerCase().includes(active.search);
				btn.classList.toggle('is-hidden', !matchesSearch);
			}
		}
		const hasFilter = facetKeys.some((key) => active.facets[key].size > 0) || active.search !== '';
		for (const btn of resetButtons) {
			btn.disabled = !hasFilter;
			btn.setAttribute('aria-disabled', String(!hasFilter));
		}
		if (empty) empty.hidden = shown > 0;
		if (status) status.textContent = `${shown} ${config.itemLabel}${shown === 1 ? '' : 's'} shown`;
		const collapsedCount = applyCollapse();
		const canToggle = active.search === '' && (active.expanded || collapsedCount > 0);
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

	// Measures how many buttons overflow past ~2 rows, always (even while expanded
	// or mid-search), so the toggle button's enabled state stays accurate. Only
	// actually hides the overflow (adds 'is-collapsed') when collapsed view applies.
	function applyCollapse(): number {
		if (!tagsWrap) return 0;
		const tagBtns = Array.from(tagsWrap.querySelectorAll<HTMLButtonElement>('.fbtn'));
		// Clear collapse first so measurement sees the full search-filtered layout.
		for (const b of tagBtns) b.classList.remove('is-collapsed');
		if (active.search !== '') return 0;
		const visible = tagBtns.filter((b) => !b.classList.contains('is-hidden'));
		if (visible.length === 0) return 0;
		const firstTop = visible[0].offsetTop;
		let secondRowTop = Infinity;
		for (const b of visible) {
			if (b.offsetTop > firstTop) {
				secondRowTop = Math.min(secondRowTop, b.offsetTop);
			}
		}
		if (secondRowTop === Infinity) return 0; // everything fits on row 1
		// Never collapse a selected tag — its active-filter chip must stay visible
		// (e.g. when reached via a shared ?tag= URL that sorts past row 2).
		const overflowing = visible.filter(
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
		active.search = (searchInput.value ?? '').trim().toLowerCase();
		render();
	});
	tagsToggleBtn?.addEventListener('click', () => {
		active.expanded = !active.expanded;
		render();
	});

	resetButtons.forEach((btn) =>
		btn.addEventListener('click', () => {
			for (const key of facetKeys) active.facets[key].clear();
			active.search = '';
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
		tagsToggleBtn.classList.add('console__tags-toggle--nudge');
		window.setTimeout(() => tagsToggleBtn.classList.remove('console__tags-toggle--nudge'), 600);
	});

	// Clicking a card outside its outbound links (.lang-chip) or tag buttons
	// nudges the clickable links with their own hover styling, so users who
	// click the card body notice where the actual links are.
	for (const card of cards) {
		card.addEventListener('click', (e) => {
			const target = e.target as HTMLElement;
			if (target.closest('.lang-chip, .tag')) return;
			const chips = card.querySelectorAll<HTMLElement>('.lang-chip:not(.lang-chip--disabled)');
			chips.forEach((chip) => chip.classList.add('lang-chip--nudge'));
			window.setTimeout(() => {
				chips.forEach((chip) => chip.classList.remove('lang-chip--nudge'));
			}, 600);
		});
	}

	readUrl();
	render();
	window.addEventListener('popstate', () => {
		readUrl();
		render();
	});
	window.addEventListener('resize', () => render());
}
