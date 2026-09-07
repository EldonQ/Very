# Minimal Scientific Slide Style Specification

Use this specification as a design system, not as a rigid template. Measurements are in inches on a 13.333 × 7.5 inch, 16:9 slide.

## 1. Canvas and grid

- Slide size: 13.333 × 7.5 in.
- Background: solid white, `#FFFFFF`.
- Standard left margin: 0.75 in.
- Standard right margin: 0.75 in.
- Standard title box: x 0.75, y 0.44, w 11.83, h 0.79.
- Main content begins around y 1.35–1.65.
- Keep a clear bottom margin of at least 0.45 in.
- Align elements to a small number of repeated anchors. Do not make each slide's geometry unique.

### Two-column grid

- Left column: x 0.78, w 5.42.
- Right column: x 7.03, w 5.47.
- Gutter: about 0.83 in.
- Column heading: y 1.62, h 0.50.
- Main column content: y 2.29.

Small adjustments are allowed for optical alignment, but repeated slides must use the same anchors.

## 2. Typeface and hierarchy

The typeface assignment is mandatory:

- Chinese characters and Chinese full-width punctuation: `宋体`.
- Western characters, Latin-script words, Arabic numerals, units, and Western punctuation: `Times New Roman`.
- For mixed-language text, set the East Asian font to `宋体` and the Latin font to `Times New Roman`. If the presentation library cannot assign both font slots reliably, split the text into script-specific runs and set each run explicitly.
- Apply the rule to all editable text, including titles, body text, metrics, tables, chart labels, legends, annotations, and speaker notes where formatting is supported.
- Do not substitute Calibri, Arial, Aptos, or another fallback font. Verify the final PPTX on a system where both required fonts are installed.
- Text embedded in raster figures is not editable. Regenerate the figure with the required fonts when full-deck font compliance is requested; otherwise report the exception explicitly.

| Role | Size | Weight | Color | Guidance |
|---|---:|---|---|---|
| Cover title | 52–56 pt | Bold | `#173B5F` | One or two lines, generous leading |
| Cover subtitle | 26–28 pt | Regular | `#4B5B68` | Short and descriptive |
| Cover context line | 22–24 pt | Regular | `#70808D` | Optional; keep visually quiet |
| Standard slide title | 40–42 pt | Bold | `#173B5F` | Prefer one line |
| Column or section heading | 26–28 pt | Bold | `#2D5D89` | Direct label, no box |
| Large metric | 48–58 pt | Bold | `#173B5F` | One dominant value |
| Medium metric | 36–44 pt | Bold | `#173B5F` or accent | Use only when needed |
| Primary body | 20–24 pt | Regular | `#15212B` | Keep lines short |
| Dense two-column body | 18–20 pt | Regular | `#15212B` | Absolute minimum 18 pt |
| Interpretation or caveat | 18–22 pt | Regular | `#4B5B68` | One concise block |

Line spacing should feel open but compact, typically 1.05–1.15. Use 6–12 pt paragraph spacing rather than manual blank lines. Keep text-box internal margins consistent.

## 3. Color system

Use color for hierarchy, not decoration.

- Primary navy: `#173B5F` — titles, key numbers, selected primary text.
- Section blue: `#2D5D89` — column headings and restrained labels.
- Body ink: `#15212B` — normal body text.
- Secondary blue-gray: `#4B5B68` — explanations and caveats.
- Tertiary blue-gray: `#70808D` — low-priority context.
- Optional warm accent: `#B97821` — at most one comparison or warning on a slide.

Do not introduce near-duplicate navy shades. If restyling an existing deck, normalize them to this palette unless a figure has its own scientifically meaningful color scale.

## 4. Layout families

### A. Cover

- Place the title at x 0.75, y about 0.60, w about 11.15, h up to 1.80.
- Place a short subtitle near y 3.55–3.75.
- Place optional context near y 6.25–6.40.
- Use no hero image unless the user explicitly wants one.

### B. Figure left, evidence right

- Use for maps, charts, diagrams, or composite figures.
- Give the figure roughly two-thirds of the width: x 0.15–0.50, y 1.25–1.90, w 8.0–8.8, h 4.4–5.8.
- Place the evidence block around x 8.4–9.1 with w 3.8–4.4.
- Use one large metric, a short unit/descriptor, two to four concise lines, and one interpretation.
- Visually center the figure in its region; preserve aspect ratio.

### C. Balanced two-column discussion

- Use the standard two-column grid.
- Give both columns headings at 26–28 pt.
- Limit each column to two or three text groups.
- Align corresponding groups across columns where possible.
- Do not separate columns with a rule or box.

### D. Metric left, figure right

- Use when the numerical overview precedes a dominant visual.
- Reserve roughly the left 3.0–3.5 in for one or two metric groups.
- Give the remaining space to one large figure.
- Keep metric labels quiet so the figure remains primary.

### E. Full-width figure

- Place one large composite figure below the standard title.
- Use nearly the full width, leaving the standard side margins unless the figure requires a deliberate optical bleed.
- Add one short interpretation below or beside the figure, never a dense caption.

### F. Paired evidence figures

- Use only when the comparison is the slide's central point.
- Give both panels equal visual weight and align their plot areas, not merely their outer image bounds.
- Use one shared explanation rather than repeating labels under both panels.

## 5. Figures, charts, and tables

- Prefer high-resolution raster images or vector graphics.
- Use contain placement and preserve the original aspect ratio.
- Do not add image borders, shadows, rounded masks, or background panels.
- Crop away excessive external whitespace only when no labels, legends, axes, scale bars, or annotations are lost.
- Keep legends attached to their figures. If a composite lacks a legend, rebuild or add a clear shared legend before presentation.
- Make axis labels and legends readable at slide scale; figure text should generally appear at least as large as 16–18 pt when viewed on the slide.
- Use tables sparingly. Prefer a focused comparison with few rows and columns, no outer border, light internal rules only, and the same typography palette.
- Preserve scientifically meaningful figure colors. Apply the slide palette only to surrounding text and newly created annotations.

## 6. Text and editorial presentation

- Give each slide one clear point.
- Prefer short declarative titles and compact noun phrases.
- Keep body groups to approximately three to five lines where possible.
- Avoid slogans, production commentary, template language, and labels that do not help the audience interpret the slide.
- Avoid excessive all-caps text, arrows, semicolons, and nested bullet levels.
- Use bullets only when the items are genuinely parallel. Otherwise use short separated text groups.
- Edit copy before reducing type size or tightening spacing.

## 7. Speaker notes

Notes should sound like a presenter speaking to an audience. They should add context, transitions, limitations, and interpretation instead of reading the slide verbatim.

When bilingual English–Chinese notes are requested, use exactly this structure:

```text
English
[Natural spoken English]

中文
[自然、口语化的中文讲稿]

[Sources]
- [Source or provenance note]
```

Keep `[Sources]` even when there are no formal citations if provenance or figure attribution needs to be recorded. Do not place production instructions or hidden project commentary in notes.

## 8. Visual QA checklist

Render every slide before delivery and inspect at normal size.

- No text overlaps, clipped text, cropped glyphs, or off-slide objects.
- No unintended image distortion or cropping.
- Standard titles share the same x, y, width, height, font size, and color.
- Repeated column headings and content blocks align exactly.
- Chinese text uses `宋体`; Western text uses `Times New Roman`. Mixed-language runs retain both assignments after saving and reopening the PPTX.
- Body text is at least 18 pt and figure labels remain readable.
- Long titles are shortened before they wrap; if a wrap is essential, enlarge the title box without colliding with content.
- Text does not sit on top of visually busy evidence.
- Whitespace is balanced; no corner is crowded merely to fill the canvas.
- No page numbers, brand strips, cards, borders, decorative backgrounds, or ornamental shapes appear unless explicitly requested.
- Speaker notes are present, ordered correctly, and free of placeholder text.
