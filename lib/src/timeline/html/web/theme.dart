// ignore_for_file: public_member_api_docs

/// The one stylesheet of the timeline report.
///
/// Written as CSS rather than through Jaspr's `css()` builder: this is a large
/// hand-authored stylesheet, and expressing it in Dart would roughly double its
/// length without making it easier to read. Jaspr's builder covers everything
/// used here - media queries, pseudo-classes, keyframes - so the choice is
/// about size, not capability.
///
/// It is deliberately the only stylesheet. Registering component styles through
/// `Document(styles:)` instead would mean hand-forwarding a `List<StyleRule>`
/// up through every component in between, since the `@css` annotation that
/// automates that needs `jaspr_builder`.
const timelineCSS = '''
:root {
  color-scheme: dark;
  --bg: #17181c;
  --surface: #202126;
  --surface-raised: #27292f;
  --surface-hover: #30333a;
  --border: #3d4048;
  --border-strong: #555963;
  --text: #f1f3f5;
  --text-secondary: #b9bec8;
  --text-muted: #858b96;
  --accent: #8ab4f8;
  --accent-strong: #4c8df6;
  --focus: #a8c7fa;
  --track-cell-width: 132px;
  --gap-cell-width: 24px;
  --filmstrip-height: 142px;
  --header-height: 48px;
  --timeline-height: 320px;
  font-family: Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  font-synthesis: none;
}

* {
  box-sizing: border-box;
}

html,
body {
  width: 100%;
  min-width: 320px;
  height: 100%;
  margin: 0;
  overflow: hidden;
  background: var(--bg);
  color: var(--text);
}

button,
a {
  -webkit-tap-highlight-color: transparent;
}

button {
  font: inherit;
}

button:focus-visible,
a:focus-visible {
  outline: 2px solid var(--focus);
  outline-offset: -2px;
}

.timeline-app {
  display: grid;
  grid-template-rows:
    var(--header-height)
    var(--timeline-height)
    6px
    minmax(0, 1fr);
  width: 100vw;
  height: 100vh;
  min-height: 480px;
  background: var(--bg);
}

.skip-link {
  position: fixed;
  z-index: 100;
  top: 8px;
  left: 8px;
  padding: 8px 12px;
  color: #101114;
  background: var(--focus);
  transform: translateY(-150%);
}

.skip-link:focus {
  transform: translateY(0);
}

.app-bar {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr) auto;
  align-items: center;
  min-width: 0;
  height: var(--header-height);
  border-bottom: 1px solid var(--border);
  background: #202126;
}

.brand,
.test-title,
.app-actions,
.shortcut-hint,
.range-summary,
.timeline-counts,
.code-toolbar {
  display: flex;
  align-items: center;
}

.brand {
  gap: 9px;
  height: 100%;
  padding: 0 14px;
  border-right: 1px solid var(--border);
  white-space: nowrap;
}

/* The spot magnifier, inline so the report stays a single file. */
.brand-mark {
  width: 26px;
  height: 26px;
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Cg stroke='%23222a35' stroke-linecap='round'%3E%3Cline x1='39' y1='39' x2='55' y2='55' stroke-width='15'/%3E%3Cline x1='39' y1='39' x2='55' y2='55' stroke='%233f9df5' stroke-width='9'/%3E%3Cline x1='36.5' y1='36.5' x2='39.5' y2='39.5' stroke-width='12'/%3E%3Cline x1='36.5' y1='36.5' x2='38' y2='38' stroke='%23b9bfc9' stroke-width='8'/%3E%3Cline x1='38.6' y1='38.6' x2='39.8' y2='39.8' stroke='%23ee7513' stroke-width='8'/%3E%3Ccircle cx='25' cy='25' r='19' fill='%23fff' stroke-width='3.2'/%3E%3Ccircle cx='25' cy='25' r='13.6' fill='%235cabf7' stroke-width='3'/%3E%3Cpath d='M16.4 21A9.5 9.5 0 0 1 24.2 15.5' stroke='%23fff' stroke-width='3' fill='none'/%3E%3Cpath d='M33.6 29A9.5 9.5 0 0 1 29 33.6' stroke='%23fff' stroke-width='3' fill='none'/%3E%3C/g%3E%3C/svg%3E") center / contain no-repeat;
}

.brand-name {
  font-size: 13px;
  font-weight: 600;
}

.test-title {
  min-width: 0;
  gap: 8px;
  padding: 0 14px;
  font-size: 12px;
}

.test-title__label {
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: .08em;
  font-size: 10px;
  font-weight: 600;
}

.test-title__value {
  overflow: hidden;
  color: var(--text-secondary);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.app-actions {
  gap: 12px;
  padding-right: 10px;
}

.shortcut-hint {
  gap: 5px;
  color: var(--text-muted);
  font-size: 11px;
  white-space: nowrap;
}

kbd {
  min-width: 22px;
  padding: 1px 5px 2px;
  border: 1px solid var(--border-strong);
  border-bottom-width: 2px;
  border-radius: 4px;
  color: var(--text-secondary);
  background: #292b31;
  font-family: inherit;
  line-height: 16px;
  text-align: center;
}

.toolbar-button,
.icon-button {
  border: 1px solid var(--border-strong);
  border-radius: 4px;
  color: var(--text-secondary);
  background: var(--surface-raised);
  cursor: pointer;
  transition: background-color 140ms ease, color 140ms ease;
}

.toolbar-button {
  padding: 6px 10px;
  font-size: 11px;
}

.toolbar-button:hover,
.icon-button:hover:not(:disabled) {
  color: var(--text);
  background: var(--surface-hover);
}

.timeline-panel {
  min-width: 0;
  min-height: 0;
  border-bottom: 1px solid var(--border-strong);
  background: var(--surface);
}

.timeline-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 38px;
  padding: 0 12px;
  border-bottom: 1px solid var(--border);
  font-size: 12px;
}

.range-summary,
.timeline-counts {
  gap: 9px;
}

.range-label,
.timeline-counts,
.selected-event-meta {
  color: var(--text-muted);
}

.selection-summary {
  padding-left: 9px;
  border-left: 1px solid var(--border);
  color: var(--accent);
  font-variant-numeric: tabular-nums;
}

.timeline-counts span + span::before {
  content: "·";
  margin-right: 9px;
}

.timeline-scroll {
  width: 100%;
  height: calc(var(--timeline-height) - 38px);
  overflow-x: auto;
  overflow-y: hidden;
  scrollbar-color: #5e626c #25272c;
  scrollbar-width: thin;
}

.timeline-track {
  width: max(100%, calc(
    var(--frame-count, 1) * var(--track-cell-width) +
    var(--gap-count, 0) * var(--gap-cell-width)));
  min-width: max-content;
}

.time-ruler,
.filmstrip,
.lane-events {
  display: grid;
  grid-auto-flow: column;
  grid-auto-columns: var(--track-cell-width);
  grid-template-columns: var(--track-columns);
}

.time-ruler {
  height: 40px;
  border-bottom: 1px solid var(--border);
}

/* Drawn per cell, because gap columns are narrower than frame columns. */
.ruler-cell::after {
  content: "";
  position: absolute;
  top: 0;
  right: 0;
  width: 1px;
  height: 100%;
  background: #454851;
}

.ruler-cell {
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-width: 0;
  gap: 1px;
  padding: 0 8px;
  color: var(--text-secondary);
  font-size: 10px;
  font-variant-numeric: tabular-nums;
}

.ruler-cell__row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  min-width: 0;
  gap: 6px;
  line-height: 1.4;
}

.ruler-cell__clock {
  margin-left: 3px;
  color: var(--text-muted);
  font-size: 9px;
}

.ruler-cell__spot-frame {
  overflow: hidden;
  color: var(--text-muted);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.ruler-cell__time,
.ruler-cell__frame {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.ruler-cell__frame {
  color: var(--accent);
}

.ruler-cell__frame.is-missing {
  color: var(--text-muted);
}

.ruler-cell::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 1px;
  height: 6px;
  background: var(--border-strong);
}

/* A stretch of frames the test rendered and recorded nothing in. */
.frame-gap {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  min-width: 0;
  height: 100%;
  padding: 6px 0;
  border-right: 1px solid var(--border);
  background:
    repeating-linear-gradient(
      135deg,
      transparent 0 6px,
      #22242a 6px 12px);
}

.frame-gap:hover {
  background:
    repeating-linear-gradient(
      135deg,
      transparent 0 6px,
      #2b2e36 6px 12px);
}

/* The timings, on hover, for a gap and for a frame alike. The native tooltip
   took about a second to show up and cannot be styled, so this is built here
   instead. */
.hover-card {
  position: absolute;
  z-index: 30;
  top: 50%;
  left: 50%;
  width: 192px;
  padding: 10px 12px;
  border: 1px solid var(--border-strong);
  border-radius: 7px;
  background: #2a2d34;
  box-shadow: 0 8px 24px rgba(0, 0, 0, .5);
  opacity: 0;
  visibility: hidden;
  /* Overridden per owner, see .capture .hover-card. */
  --card-x: -50%;
  transform: translate(var(--card-x), -50%) scale(.96);
  pointer-events: none;
  font-size: 11px;
  transition:
    opacity 110ms ease,
    transform 110ms ease,
    visibility 0s linear 110ms;
}

/* Nothing happens for 300ms, so dragging across the strip does not flash a
   card in every column on the way. */
.frame-gap:hover .hover-card,
.capture:hover .hover-card {
  opacity: 1;
  visibility: visible;
  transform: translate(var(--card-x), -50%) scale(1);
  transition:
    opacity 110ms ease 300ms,
    transform 110ms ease 300ms,
    visibility 0s linear 300ms;
}

/* Anchored to the left edge of the cell rather than centred on it. A card
   centred on the first frame reaches past the left edge of the strip, and a
   scroll container cannot be scrolled to reveal it. Overflow to the right just
   extends the scrollable area. Gaps never sit first, so they stay centred. */
.capture .hover-card {
  --card-x: 0;
  left: 6px;
}

.hover-card__title {
  display: block;
  color: var(--text);
  font-size: 13px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.hover-card__note {
  display: block;
  padding-bottom: 8px;
  margin-bottom: 7px;
  border-bottom: 1px solid var(--border);
  color: var(--text-muted);
  font-size: 10px;
}

.hover-card__row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  color: var(--text-secondary);
  line-height: 1.7;
}

.hover-card__row span:last-child {
  color: var(--text);
  font-variant-numeric: tabular-nums;
}

@media (prefers-reduced-motion: reduce) {
  .hover-card {
    transition: none;
  }

  .frame-gap:hover .hover-card,
  .capture:hover .hover-card {
    transition: opacity 0s linear 300ms, visibility 0s linear 300ms;
  }
}

/* Set sideways, so the column is only as wide as the text is tall. */
.frame-gap__frames {
  max-height: 100%;
  overflow: hidden;
  color: var(--text-secondary);
  font-size: 10px;
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
  text-overflow: ellipsis;
  writing-mode: vertical-rl;
}

.ruler-cell.is-gap,
.frame-events.is-gap {
  border-right: 1px solid var(--border);
  background: #1b1d22;
}

.ruler-cell.is-gap::after,
.ruler-cell.is-gap::before {
  content: none;
}

.timeline-counts__rendered {
  color: var(--text-secondary);
  font-variant-numeric: tabular-nums;
}

.filmstrip {
  height: var(--filmstrip-height);
  /* A definite row, so a capture taller than the cell letterboxes instead of
     stretching the row over the caption and the event lane below it. */
  grid-template-rows: 100%;
  border-bottom: 1px solid var(--border);
  background: #1a1b1f;
}

.capture {
  position: relative;
  display: grid;
  grid-template-rows: minmax(0, 1fr) 27px;
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  padding: 0;
  border: 0;
  border-right: 1px solid var(--border);
  border-bottom: 3px solid transparent;
  color: var(--text-secondary);
  background: transparent;
  text-align: left;
  cursor: pointer;
}

.capture:hover {
  background: #24262b;
}

.capture.is-selected {
  border-bottom-color: var(--event-color);
  background: #292b31;
}

.capture.is-selected::after {
  content: "";
  position: absolute;
  z-index: 3;
  inset: 0;
  border: 2px solid var(--accent);
  pointer-events: none;
}

.capture-image {
  position: relative;
  display: grid;
  place-items: center start;
  justify-self: start;
  width: 100%;
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  border-right: 1px solid var(--border);
}

/* Taken out of flow, so `object-fit` has a definite box to fit into. A
   percentage height against the auto-sized row resolves to the image's own
   aspect ratio instead, which crops a tall capture to its top edge. */
.capture-image img {
  position: absolute;
  display: block;
  inset: 0;
  width: 100%;
  height: 100%;
  padding: 4px;
  object-fit: contain;
  background: #101114;
}

.capture-placeholder {
  display: grid;
  place-items: center;
  align-content: center;
  gap: 4px;
  width: 100%;
  height: 100%;
  color: #717783;
  background:
    linear-gradient(135deg, transparent 49%, #27292f 49%, #27292f 51%, transparent 51%)
    0 0 / 12px 12px;
  font-size: 10px;
}

.capture-placeholder__index {
  color: #8b919d;
  font-size: 12px;
  font-variant-numeric: tabular-nums;
}

.capture-caption {
  display: flex;
  align-items: center;
  min-width: 0;
  gap: 7px;
  padding: 0 7px;
  border-top: 1px solid #30323a;
  font-size: 10px;
}

.capture-number {
  color: var(--text-muted);
  font-variant-numeric: tabular-nums;
}

.capture-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.event-lane {
  height: max(
    48px,
    calc(var(--timeline-height) - 78px - var(--filmstrip-height))
  );
  background: #1c1d21;
}

.lane-events {
  display: grid;
  grid-auto-flow: column;
  grid-auto-columns: var(--track-cell-width);
  width: 100%;
  height: 100%;
}

.frame-events {
  display: flex;
  flex-direction: column;
  min-width: 0;
  height: 100%;
  padding: 3px 0;
  overflow-x: hidden;
  overflow-y: auto;
  border-right: 1px solid #30323a;
  scrollbar-color: #5e626c #202126;
  scrollbar-width: thin;
}

.event-marker {
  position: relative;
  display: flex;
  align-items: center;
  flex: 0 0 21px;
  gap: 6px;
  min-width: 0;
  height: 21px;
  margin: 0;
  padding: 0 6px;
  overflow: hidden;
  border: 0;
  color: var(--text-secondary);
  background: transparent;
  cursor: pointer;
}

.event-marker:hover,
.event-marker.is-selected {
  color: var(--text);
  background: #2a2c32;
}

.event-marker__dot {
  flex: 0 0 auto;
  width: 7px;
  height: 7px;
  border: 2px solid var(--event-color);
  border-radius: 50%;
  background: #1c1d21;
}

.event-marker.is-selected .event-marker__dot {
  background: var(--event-color);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--event-color) 20%, transparent);
}

.event-marker__label {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 10px;
}

.empty-timeline,
.inspector-empty,
.panel-empty {
  display: grid;
  place-items: center;
  align-content: center;
  color: var(--text-muted);
}

.empty-timeline {
  height: calc(var(--timeline-height) - 38px);
  font-size: 12px;
}

.inspector {
  display: grid;
  grid-template-rows: minmax(0, 1fr);
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  background: var(--bg);
}

.inspector-empty {
  grid-row: 1 / -1;
  gap: 4px;
  padding: 24px;
  text-align: center;
}

.inspector-empty__icon {
  margin-bottom: 5px;
  color: #626874;
  font-size: 30px;
}

.inspector-empty h2,
.inspector-empty p,
.panel-empty h3,
.panel-empty p {
  margin: 0;
}

.inspector-empty h2 {
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 500;
}

.inspector-empty p,
.panel-empty p {
  max-width: 560px;
  font-size: 12px;
  line-height: 1.6;
}

.inspector-tabs {
  display: flex;
  min-width: 0;
  min-height: 36px;
  overflow-x: auto;
  overflow-y: hidden;
  padding: 0 8px;
  border-bottom: 1px solid var(--border);
  background: var(--surface);
  scrollbar-width: thin;
}

.tab-button {
  position: relative;
  flex: 0 0 auto;
  padding: 0 12px;
  border: 0;
  color: var(--text-muted);
  background: transparent;
  font-size: 11px;
  cursor: pointer;
}

.tab-button:hover {
  color: var(--text-secondary);
  background: #292b30;
}

.tab-button.is-selected {
  color: var(--text);
}

.tab-button.is-selected::after {
  content: "";
  position: absolute;
  right: 8px;
  bottom: 0;
  left: 8px;
  height: 2px;
  background: var(--accent);
}

.inspector-content {
  min-width: 0;
  min-height: 0;
  overflow: auto;
  scrollbar-color: #5e626c #202126;
  scrollbar-width: thin;
}

.interactive-inspector {
  display: grid;
  grid-template-columns:
    minmax(240px, var(--capture-pane-width, 57%))
    6px
    minmax(280px, 1fr);
  width: 100%;
  height: 100%;
  min-height: 0;
}

.inspector-sidebar {
  display: grid;
  grid-template-rows: auto minmax(0, 1fr);
  min-width: 0;
  min-height: 0;
  overflow: hidden;
}

.capture-workbench,
.widget-explorer {
  display: grid;
  min-width: 0;
  min-height: 0;
}

.capture-workbench {
  grid-template-rows: 34px minmax(0, 1fr);
}

.widget-explorer {
  grid-template-rows:
    34px
    minmax(100px, var(--tree-pane-height, 62%))
    6px
    minmax(90px, 1fr);
  width: 100%;
  height: 100%;
}

.resize-handle {
  position: relative;
  z-index: 5;
  display: grid;
  place-items: center;
  min-width: 0;
  min-height: 0;
  padding: 0;
  border: 0;
  border-radius: 0;
  color: transparent;
  background: #25272c;
  touch-action: none;
}

.resize-handle:hover,
.resize-handle:focus-visible {
  color: var(--accent);
  background: #343842;
}

.resize-handle:focus-visible {
  outline: 2px solid var(--focus);
  outline-offset: -2px;
}

.resize-handle--vertical {
  width: 6px;
  cursor: col-resize;
}

.resize-handle--horizontal {
  width: 100%;
  height: 6px;
  cursor: row-resize;
}

.resize-handle__grip {
  display: block;
  border-radius: 2px;
  background: currentColor;
}

.resize-handle--vertical .resize-handle__grip {
  width: 2px;
  height: 30px;
}

.resize-handle--horizontal .resize-handle__grip {
  width: 30px;
  height: 2px;
}

body.is-resizing-columns,
body.is-resizing-columns * {
  cursor: col-resize !important;
  user-select: none !important;
}

body.is-resizing-rows,
body.is-resizing-rows * {
  cursor: row-resize !important;
  user-select: none !important;
}

.pane-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-width: 0;
  height: 34px;
  padding: 0 9px 0 12px;
  border-bottom: 1px solid var(--border);
  color: var(--text-muted);
  background: #1d1e22;
  font-size: 10px;
}

.pane-title {
  flex: 0 0 auto;
  color: var(--text-secondary);
  font-weight: 600;
}

.selected-widget-label {
  overflow: hidden;
  color: var(--accent);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.capture-toolbar-actions {
  display: flex;
  align-items: center;
  min-width: 0;
  gap: 4px;
}

.capture-image-link {
  display: inline-flex;
  align-items: center;
  text-decoration: none;
}

.tree-actions {
  display: flex;
  gap: 3px;
}

.tree-toolbar-controls {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  min-width: 0;
  gap: 5px;
}

.widget-search {
  width: clamp(110px, 15vw, 190px);
  min-width: 0;
  height: 24px;
  padding: 3px 8px;
  border: 1px solid var(--border-strong);
  border-radius: 4px;
  outline: 0;
  color: var(--text);
  background: #141519;
  font: 10px/1.2 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
}

.widget-search::placeholder {
  color: var(--text-muted);
}

.widget-search:focus {
  border-color: var(--focus);
  box-shadow: 0 0 0 1px var(--focus);
}

.search-result-count {
  flex: 0 0 auto;
  color: var(--accent);
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
}

.text-button {
  padding: 4px 6px;
  border: 0;
  border-radius: 3px;
  color: var(--text-muted);
  background: transparent;
  font-size: 10px;
  cursor: pointer;
}

.text-button:hover {
  color: var(--text);
  background: var(--surface-hover);
}

.capture-viewport {
  position: relative;
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  background:
    linear-gradient(45deg, #1b1c20 25%, transparent 25%),
    linear-gradient(-45deg, #1b1c20 25%, transparent 25%),
    linear-gradient(45deg, transparent 75%, #1b1c20 75%),
    linear-gradient(-45deg, transparent 75%, #1b1c20 75%);
  background-position: 0 0, 0 6px, 6px -6px, -6px 0;
  background-size: 12px 12px;
}

/* Sized from the capture's own ratio, not from the image, so the canvas is
   exactly the image box however tall or wide the capture is and the outline
   percentages land on the right pixels. An image that sizes the canvas needs a
   max-height, and there is no ancestor to take a percentage of without a cycle.

   Out of flow with both offsets and auto margins, so the box fits the pane in
   whichever axis binds first. The 28px stands in for a 14px inset, which
   padding cannot provide: `inset` resolves against the padding box. */
.capture-canvas {
  position: absolute;
  inset: 0;
  display: block;
  width: auto;
  height: auto;
  max-width: calc(100% - 28px);
  max-height: calc(100% - 28px);
  margin: auto;
  aspect-ratio: var(--capture-aspect, auto);
  overflow: hidden;
  line-height: 0;
  background: #101114;
  box-shadow: 0 8px 28px rgba(0, 0, 0, .35);
}

.capture-base-image {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: contain;
}

/* Same intrinsic ratio and the same fit as the base image, so the two stay
   aligned even when the capture's dimensions are unknown and the canvas is
   wider than the image. */
.capture-event-overlay {
  position: absolute;
  z-index: 1;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
  pointer-events: none;
}

.widget-outline {
  position: absolute;
  z-index: 2;
  min-width: 2px;
  min-height: 2px;
  border: 2px solid #56b4ff;
  background: rgba(74, 168, 255, .14);
  box-shadow:
    0 0 0 1px rgba(4, 19, 31, .8),
    inset 0 0 0 1px rgba(255, 255, 255, .25);
  pointer-events: none;
}

.capture-empty,
.tree-empty {
  display: grid;
  place-items: center;
  align-content: center;
  color: var(--text-muted);
  text-align: center;
}

.capture-empty {
  gap: 6px;
  padding: 24px;
}

.capture-empty h3,
.capture-empty p {
  margin: 0;
}

.capture-empty h3 {
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 500;
}

.capture-empty p {
  max-width: 420px;
  font-size: 11px;
  line-height: 1.55;
}

.tree-empty {
  padding: 20px;
  font-size: 11px;
}

.interactive-tree {
  min-height: 0;
  padding: 4px 0 20px;
  overflow: auto;
  background: #18191d;
  scrollbar-color: #5e626c #202126;
  scrollbar-width: thin;
}

/* The tree took the arrow keys over, which is worth showing. */
.interactive-tree.has-arrow-keys {
  box-shadow: inset 0 0 0 1px var(--accent);
}

.tree-node {
  min-width: max-content;
}

.tree-node__row {
  display: flex;
  align-items: center;
  height: 25px;
  padding-left: calc(7px + var(--tree-depth) * 14px);
  color: var(--text-secondary);
  font: 11px/1.2 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
}

.tree-node__row:hover {
  background: #25272c;
}

.tree-node__row.is-selected {
  color: #fff;
  background: #24466b;
}

.tree-node__row.is-search-match:not(.is-selected) {
  color: #fff;
  background: rgba(138, 180, 248, .12);
}

.tree-node__row.is-search-match .tree-node__name {
  color: #f8d66d;
}

.tree-node__row.is-offstage {
  color: #777d88;
}

.tree-expander,
.tree-expander-spacer {
  flex: 0 0 18px;
  width: 18px;
  height: 22px;
}

.tree-expander {
  display: grid;
  place-items: center;
  padding: 0;
  border: 0;
  color: #939aa6;
  background: transparent;
  cursor: pointer;
}

.tree-expander:hover {
  color: #fff;
}

.tree-node__select {
  display: flex;
  align-items: center;
  min-width: 0;
  flex: 1 1 auto;
  gap: 7px;
  height: 25px;
  padding: 0 10px 0 1px;
  border: 0;
  color: inherit;
  background: transparent;
  text-align: left;
  cursor: pointer;
}

.tree-node__name {
  flex: 0 0 auto;
  color: inherit;
}

.tree-node__description {
  max-width: 360px;
  overflow: hidden;
  color: #848b96;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.is-selected .tree-node__description {
  color: #c1d9f3;
}

.node-badge {
  padding: 1px 4px;
  border: 1px solid #4b4f58;
  border-radius: 3px;
  color: #8c929d;
  font: 8px/1.3 Inter, ui-sans-serif, sans-serif;
}

.bounds-indicator {
  width: 6px;
  height: 6px;
  margin-left: auto;
  border: 1px solid #62b9fa;
  opacity: .65;
}

.widget-properties {
  min-width: 0;
  min-height: 0;
  border-top: 1px solid var(--border);
  background: #1d1e22;
}

.widget-properties--empty {
  display: grid;
  place-items: center;
  padding: 16px;
  color: var(--text-muted);
  font-size: 10px;
  text-align: center;
}

.properties-heading {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 42px;
  padding: 0 11px;
  border-bottom: 1px solid #30323a;
}

.properties-heading > div {
  display: grid;
  min-width: 0;
  gap: 2px;
}

.properties-heading strong {
  overflow: hidden;
  color: var(--text);
  font-size: 11px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.properties-heading span {
  color: var(--text-muted);
  font-size: 9px;
}

.bounds-summary {
  flex: 0 0 auto;
  padding-left: 8px;
  font-variant-numeric: tabular-nums;
}

.properties-scroll {
  height: calc(100% - 42px);
  overflow: auto;
  scrollbar-color: #5e626c #202126;
  scrollbar-width: thin;
}

.property-group h3 {
  position: sticky;
  top: 0;
  z-index: 1;
  margin: 0;
  padding: 6px 10px;
  border-bottom: 1px solid #2e3036;
  color: var(--text-muted);
  background: #202126;
  font-size: 9px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: .06em;
}

.property-group dl {
  margin: 0;
}

.property-row {
  display: grid;
  grid-template-columns: minmax(86px, .42fr) minmax(120px, .58fr);
  gap: 9px;
  padding: 5px 10px;
  border-bottom: 1px solid #292b30;
  font: 9px/1.4 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
}

.property-row dt {
  overflow: hidden;
  color: #8e95a1;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.property-row dd {
  min-width: 0;
  margin: 0;
  color: #c5cad2;
  overflow-wrap: anywhere;
}

.property-empty {
  margin: 0;
  padding: 8px 10px;
  color: #747a85;
  font-size: 9px;
}

.panel-empty {
  min-height: 100%;
  gap: 7px;
  padding: 24px;
  text-align: center;
}

.panel-empty h3 {
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 500;
}

.details-panel {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  height: 100%;
}

/* The event details sit on top at whatever height they need, and the source
   takes everything that is left, so dragging the inspector taller shows more
   of the file rather than more empty background. */
.details-content {
  display: flex;
  flex-direction: column;
  min-width: 0;
  height: 100%;
}

.details-primary {
  flex: 0 0 auto;
  min-width: 0;
  padding: 18px;
}

.details-primary h3 {
  margin: 0 0 12px;
  color: var(--text-secondary);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: .07em;
}

.details-copy {
  margin: 0;
  color: var(--text);
  font: 12px/1.6 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}

.source-panel {
  display: grid;
  flex: 1 1 0;
  grid-template-rows: auto minmax(0, 1fr);
  min-width: 0;
  /* Enough to read a method by, however short the inspector is dragged. What
     does not fit scrolls in the inspector, the way it did before. */
  min-height: 220px;
  border-top: 1px solid var(--border);
  background: #17181c;
}

.source-panel__header {
  display: grid;
  min-height: 36px;
  gap: 4px;
  padding: 8px 14px;
  border-bottom: 1px solid var(--border);
  background: #1d1e22;
}

.source-panel__header h3 {
  margin: 0;
  color: var(--text-secondary);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: .07em;
}

.source-panel__header a,
.source-panel__header span {
  min-width: 0;
  color: var(--text-muted);
  font: 10px/1.4 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  overflow-wrap: anywhere;
}

.source-panel__header a {
  color: var(--accent);
  text-decoration: none;
}

.source-panel__header a:hover {
  text-decoration: underline;
}

.source-code {
  min-height: 0;
  margin: 0;
  padding: 8px 0;
  overflow: auto;
  color: #cbd1db;
  font: 11px/1.55 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  tab-size: 2;
}

.source-line {
  display: grid;
  grid-template-columns: 48px max-content;
  min-width: max-content;
  border-left: 2px solid transparent;
}

.source-line.is-caller {
  border-left-color: var(--accent);
  background: rgba(103, 166, 255, .13);
}

.source-line__number {
  padding: 0 10px 0 6px;
  color: #777c86;
  text-align: right;
  user-select: none;
}

.source-line.is-caller .source-line__number {
  color: var(--accent);
}

.source-line__content {
  padding-right: 18px;
  color: inherit;
  white-space: pre;
}

.details-primary .details-heading {
  display: flex;
  gap: 8px;
  align-items: center;
  margin: 0 0 10px;
  color: var(--text);
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0;
  text-transform: none;
}

.details-heading__dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--event-color, #77808f);
  flex: none;
}

.details-heading__dot.is-failure {
  box-shadow: 0 0 0 3px rgba(244, 67, 54, .25);
}

.timings {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 22px;
  margin-top: 12px;
  padding-top: 10px;
  border-top: 1px solid var(--border);
}

.timings__item {
  display: flex;
  gap: 6px;
  align-items: baseline;
  font-size: 11px;
}

.timings__label {
  color: var(--text-muted);
}

.timings__value {
  color: var(--text-secondary);
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
}

.capture-canvas.is-zoomable {
  cursor: zoom-in;
}

.lightbox {
  position: fixed;
  inset: 0;
  z-index: 100;
  display: grid;
  grid-template-rows: minmax(0, 1fr) auto;
  gap: 12px;
  padding: 32px;
  background: rgba(9, 10, 12, .92);
  cursor: zoom-out;
}

.lightbox__stage {
  position: relative;
  min-height: 0;
  cursor: default;
}

/* Absolute rather than a centred grid item: the percentage height of a
   replaced element does not resolve against a non-stretched grid area, and the
   image overflowed the viewport. This also gives the capture and its overlays
   the exact same box, so they line up however the image letterboxes. */
.lightbox__image {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.lightbox__image--overlay {
  pointer-events: none;
}

.lightbox__position {
  display: block;
  margin-top: 3px;
  color: var(--text-muted);
  font-size: 11px;
  font-variant-numeric: tabular-nums;
}

.lightbox__caption {
  color: var(--text-secondary);
  font-size: 12px;
  text-align: center;
}

.lightbox__actions {
  position: absolute;
  z-index: 1;
  top: 12px;
  right: 16px;
  display: flex;
  gap: 8px;
  cursor: default;
}

.lightbox__action {
  padding: 6px 12px;
  border: 1px solid var(--border);
  border-radius: 6px;
  background: #1d1e22;
  color: var(--text);
  font-size: 12px;
  cursor: pointer;
}

.lightbox__action:hover {
  border-color: var(--accent);
  color: var(--accent);
}

.lightbox__action[aria-pressed="false"] {
  color: var(--text-muted);
}

.tree-spacer {
  flex: none;
}

.metadata-row {
  display: grid;
  grid-template-columns: 170px minmax(0, 1fr);
  gap: 12px;
  padding: 8px 14px;
  border-bottom: 1px solid #2b2d33;
  font-size: 11px;
}

.metadata-row dt {
  color: var(--text-muted);
}

.metadata-row dd {
  min-width: 0;
  margin: 0;
  color: var(--text-secondary);
  overflow-wrap: anywhere;
}

.metadata-row a {
  color: var(--accent);
  text-decoration: none;
}

.metadata-row a:hover {
  text-decoration: underline;
}

.tree-panel {
  display: grid;
  grid-template-rows: 32px minmax(0, 1fr);
  width: 100%;
  height: 100%;
  min-width: 0;
  min-height: 100%;
  overflow: hidden;
}

.code-toolbar {
  position: sticky;
  z-index: 2;
  top: 0;
  justify-content: space-between;
  padding: 0 12px;
  border-bottom: 1px solid var(--border);
  color: var(--text-muted);
  background: #1d1e22;
  font-size: 10px;
}

.tree-output {
  min-width: 0;
  min-height: 0;
  margin: 0;
  padding: 14px 16px 40px;
  overflow: auto;
  color: #cbd1db;
  background: #17181c;
  font: 11px/1.55 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  tab-size: 2;
  white-space: pre;
}

.tree-text-progress {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-muted);
  font-variant-numeric: tabular-nums;
}

.snackbar {
  display: none;
  position: fixed;
  bottom: 30px;
  left: 50%;
  z-index: 1;
  min-width: 250px;
  margin-left: -125px;
  padding: 16px;
  border-radius: 2px;
  color: #ffffff;
  background-color: #C97B2D;
  text-align: center;
}

.snackbar.show {
  display: block;
  animation: fadein .5s, fadeout .5s 2.5s;
}

@keyframes fadein {
  from { bottom: 0; opacity: 0; }
  to { bottom: 30px; opacity: 1; }
}

@keyframes fadeout {
  from { bottom: 30px; opacity: 1; }
  to { bottom: 0; opacity: 0; }
}

@media (max-width: 760px) {
  :root {
    --header-height: 44px;
    --filmstrip-height: 126px;
    --timeline-height: 258px;
    --track-cell-width: 112px;
  }

  .app-bar {
    grid-template-columns: auto minmax(0, 1fr);
  }

  .brand-name,
  .shortcut-hint,
  .test-title__label {
    display: none;
  }

  .app-actions {
    position: absolute;
    top: 7px;
    right: 0;
  }

  .test-title {
    padding-right: 112px;
  }

  .details-panel {
    grid-template-columns: 1fr;
  }

  .interactive-inspector {
    grid-template-columns:
      minmax(180px, var(--capture-pane-width, 48%))
      6px
      minmax(220px, 1fr);
    overflow-x: auto;
  }

  .capture-workbench {
    border-right: 1px solid var(--border);
  }

  .details-primary {
    border-right: 0;
    border-bottom: 1px solid var(--border);
  }

  .timeline-counts {
    display: none;
  }
}

@media (max-width: 480px) {
  .interactive-inspector {
    grid-template-columns:
      minmax(120px, var(--capture-pane-width, 42%))
      6px
      minmax(0, 1fr);
  }

  .tab-button {
    padding: 0 9px;
  }
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    scroll-behavior: auto !important;
    transition-duration: .01ms !important;
  }
}
''';
