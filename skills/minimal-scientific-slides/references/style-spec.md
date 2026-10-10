# Minimal Scientific Slide Style Specification

Use this specification as a design system, not as a rigid template. Measurements are in inches on a 13.333 × 7.5 inch, 16:9 slide.

The visual benchmark is a printed journal figure plate: white ground, black ink, generous figure area, panel letters, and a formal source line. Nothing on the slide competes with the evidence.

## 1. Canvas and grid

- Slide size: 13.333 × 7.5 in.
- Background: solid white `#FFFFFF`, with no fill object, gradient, texture, or watermark anywhere on the slide.
- Standard left margin: 0.72 in.
- Standard right margin: 0.72 in.
- Content width: 11.893 in.

### Shared baseline anchors

Define these once and derive every position from them. Hand-tuned per-slide y values are the main cause of pages that jump when flipped.

| Anchor | y (in) | Content |
|---|---|---|
| `Y_SECTION` | 0.28 | section label |
| `Y_TITLE_TOP` | 0.56 | title box top |
| `Y_TITLE_BOT` | 1.38 | title box bottom — titles are **bottom-aligned** |
| `Y_FIG` | 1.86 | figure block top |
| `Y_NOTE` | 6.74 | caption + source line |

`NOTE_CUT = 6.58` — the hard floor. No figure may extend past it. Clamp before the contain fit; a box alone does not keep the figure inside.

**Titles are bottom-aligned to `Y_TITLE_BOT`, not top-aligned.** A top-aligned title leaves a one-line title's figure starting in a different place than a two-line title's. Bottom alignment puts every figure top on the same line regardless of title length.

`Y_CONCL` is gone. On an action-title page there is no conclusion line; the figure runs from `Y_FIG` to `NOTE_CUT` and the page ends at the caption line. Do not reserve space for a conclusion that was deleted.

Keep a clear bottom margin of at least 0.40 in. Align elements to a small number of repeated anchors; do not make each slide's geometry unique.

### Fill the canvas — aspect ratio drives the layout family

**A page that floats in the middle of its own margins reads as cramped, not minimal.** A figure occupying half its allotted box, with dead space on two sides and 2 in underneath, is a layout defect even though every content rule passes.

**Measure every asset's aspect ratio before choosing a layout family.** Contain-fit against a uniform height cap silently produces different figure widths for different aspect ratios, and the narrow ones end up marooned in white.

Measured ratios from a real deck:

| Ratio | Asset kind | Layout family |
|---|---|---|
| ≥ 2.2 | wide map, wide chart | **full content width**, height follows the ratio |
| 1.5 – 2.0 | mid chart | figure at ~7.4 in + side column |
| ≤ 1.3 | square plate | figure height-limited; side column absorbs the slack |

The trap: a 2.31-ratio map capped at 3.42 in of height becomes width-limited to 9.4 in and floats in an 11.89 in frame — 1.2 in of dead space per side plus 2.6 in underneath. Giving it the full content width instead raises it to 11.89 in wide and 5.15 in tall, which fills the page.

### Filling vertical space on text-only pages

Fixed y positions with short text leave the gaps *between* the blocks and drag the bottom margin out. Place text by where it actually ends:

- put the primary statement at optical centre, not at a fixed third;
- set the gap between a block and its follow-up from the block's **rendered line count**, not a guessed step;
- let the last block run close to the bottom margin rather than stopping a third of the way up;
- a page of three short items needs larger type and more leading, not more items.

### Two-column grid

- Left column: x 0.78, w 5.42.
- Right column: x 7.03, w 5.47.
- Gutter: about 0.83 in.
- Column heading: y 1.62, h 0.50.
- Main column content: y 2.29.

When a figure sits beside a metrics column, set the metrics column x so the gutter matches the figure's actual right edge plus the standard gutter. A metrics column placed at a fixed x leaves a 1.2 in hole beside a narrow figure, which reads as a layout error.

Small adjustments are allowed for optical alignment, but repeated slides must use the same anchors.

## 2. Typeface and hierarchy

The typeface assignment is mandatory:

- Chinese characters and Chinese full-width punctuation: `黑体` (SimHei).
- Western characters, Latin-script words, Arabic numerals, units, and Western punctuation: `Arial`.
- For mixed-language text, set the East Asian font slot to `黑体` and the Latin font slot to `Arial`. If the presentation library cannot assign both slots reliably, split the text into script-specific runs and set each run explicitly.
- Apply the rule to all editable text: titles, body text, metrics, panel headings, source lines, tables, chart labels, legends, annotations, and speaker notes where formatting is supported.
- Do not substitute 宋体, Times New Roman, Calibri, Aptos, or any other fallback. Verify the final PPTX on a system where both required fonts are installed.
- Text embedded in raster figures is not editable. Regenerate the figure with the required fonts when full-deck font compliance is requested; otherwise report the exception explicitly.

Every text role uses black. Weight and size alone create hierarchy.

| Role | Size | Weight | Color | Guidance |
|---|---:|---|---|---|
| Cover title | 52–56 pt | Bold | `#000000` | One or two lines, generous leading |
| Cover subtitle | 26–28 pt | Regular | `#000000` | Short and descriptive |
| Cover context line | 22–24 pt | Regular | `#000000` | Optional; keep visually quiet |
| Standard slide title | 36–40 pt | Bold | `#000000` | Prefer one line |
| Panel letter `(a)` | 20–24 pt | Bold | `#000000` | Inside the panel's upper-left corner |
| Panel heading inside figure | 15–18 pt | Bold | `#000000` | Names the panel content |
| Column or section heading | 24–26 pt | Bold | `#000000` | Direct label, no box |
| Large metric | 48–58 pt | Bold | `#000000` | One dominant value |
| Medium metric | 34–40 pt | Bold | `#000000` | Use only when needed |
| Primary body | 20–24 pt | Regular | `#000000` | Keep lines short |
| Dense two-column body | 18–20 pt | Regular | `#000000` | Absolute minimum 18 pt |
| Interpretation or caveat | 18–22 pt | Regular | `#000000` | One concise block; differentiate by size or wording, not color |
| Figure source line | 12–14 pt | Regular | `#000000` | Bottom of the figure plate |
| Closing reference list | 14–16 pt | Regular | `#000000` | Hanging indent, one work per line |

Line spacing should feel open but compact, typically 1.05–1.15. Use 6–12 pt paragraph spacing rather than manual blank lines. Keep text-box internal margins consistent.

Because SimHei has no light weight, do not simulate emphasis with gray. Shorten the sentence instead.

## 3. Color system

- All slide text is black `#000000`.
- There are no secondary text colors, no accent titles, no tinted captions, and no gray "quiet" labels.
- Hierarchy comes from size, weight, position, and whitespace.
- The only non-black ink on a slide lives inside a figure, and only where it encodes data, category, or published-figure semantics.
- Optional text backing: a single plain, borderless rectangle behind text sitting on a busy figure is allowed. Constraints: no border, no rounded corners, no shadow, no gradient, and a fill that does not compete with the data. It is a legibility fix, not a design element, and is never repeated as a card system.

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
- Give both columns headings at 24–26 pt.
- Limit each column to two or three text groups.
- Align corresponding groups across columns where possible.
- Do not separate columns with a rule or box.

### D. Metric left, figure right

- Use when the numerical overview precedes a dominant visual.
- Reserve roughly the left 3.0–3.5 in for one or two metric groups.
- Give the remaining space to one large figure.
- Keep metric labels short so the figure remains primary.

### E. Full-width figure

- Place one large composite figure below the standard title.
- Use nearly the full width, leaving the standard side margins unless the figure requires a deliberate optical bleed.
- Add one short interpretation below or beside the figure, never a dense caption.
- Reserve the strip under the figure for the panel letters and source line.

### F. Paired evidence figures

- Use only when the comparison is the slide's central point.
- Give both panels equal visual weight and align their plot areas, not merely their outer image bounds.
- Label the panels `(a)` and `(b)` and give them one shared source line, not two.

## 5. Figures, charts, and tables

- Prefer high-resolution raster images or vector graphics.
- Use contain placement and preserve the original aspect ratio.
- Do not add image borders, shadows, rounded masks, or background panels.
- Crop away excessive external whitespace only when no labels, legends, axes, scale bars, or annotations are lost.
- Keep legends attached to their figures. If a composite lacks a legend, rebuild or add a clear shared legend before presentation.
- Make axis labels and legends readable at slide scale; figure text should generally appear at least as large as 16–18 pt when viewed on the slide.
- Use tables sparingly. Prefer a focused comparison with few rows and columns, no outer border, light internal rules only, and the same typography.
- Preserve scientifically meaningful figure colors. Slide-owned text and annotations stay black.
- Every figure follows the plate convention in §6.

## 6. Figure plate convention: panel letters and source lines

A figure plate is the unit of evidence on a slide. It has four parts: the figure, its panel letters (multi-panel only), a caption/legend line, and a source line.

### Panel letters

- Label every panel of a multi-panel figure with a bold `(a)`, `(b)`, `(c)` at a fixed offset inside the panel's upper-left corner, or immediately left of the panel title when the panel has its own heading.
- Place the letter on the figure itself, not in the slide body text, so the plate stays self-describing.
- Use the same size, weight, and offset in every panel of a deck.
- Never number panels inconsistently with the slide's own `(a)`/`(b)` text references.

### Panel headings

- Name each panel's content directly under or above it, e.g. `Environmental gradient`, `Microscopy`, `Metabarcoding`.
- Use bold for the heading and italic for taxon names, gene markers, or parameter symbols inside it, mirroring journal figure practice.

### Source line

Every figure carries exactly one source line below the plate, in 12–14 pt black.

**The source line states data and citation only.** It must never name the authors of the slide, nor narrate the act of reproducing a figure. Banned: `作者自绘`, `作者制图`, `自制`, `引自`, `改编自`, `摘自`, `本文绘制`, `Our figure`, `Adapted from`, `Courtesy of`, `Source: author`. In an academic talk these read as self-announcement or as production commentary, and they crowd out the evidence.

| Content | Source-line form | Example |
|---|---|---|
| Original analysis on a public dataset | `数据：<来源>（<版本/年份>）` | `数据：IUCN Red List（2025）` |
| Original analysis combining datasets | `数据：<来源 A>；<来源 B>` | `数据：IUCN Red List（2025）、GBIF 发生记录` |
| Reproduced literature figure | `<作者> et al. (<年>), <期刊缩写> <卷>: <页>, Fig. <n>（<许可>）` | `Barbarossa et al. (2021), Nat Commun 12: 1701, Fig. 1（CC BY 4.0）` |
| Author's own model output | `数据：<记录来源>；<情景来源>；模型：<算法>` | `数据：GBIF（DOI 10.15468/dl.kmmt73）；模型：RF 与 MaxEnt 集成` |

- Reproduced figures record the licence and the exact figure number.
- Journal, year, volume, and pages use the standard abbreviated form: `Nature 638: 138–145`.
- Keep the source line in the same position and size on every plate.

### Caption and source share one line

The caption and the source sit on **one horizontal line at `Y_NOTE`**, as two separate text boxes on the same baseline:

- caption flush to the left margin `x = 0.75`, width ≈ 6.7 in, left-aligned;
- source flush to the right margin, right-aligned, in the remaining width.

Stacking them as two paragraphs is a defect, not a variant: it doubles the vertical footprint, reads as an accidental wrap, and pushes the conclusion line down on that slide only. Because the source is right-flushed its right edge forms a straight vertical rule down the deck — that alignment is the point, so keep source strings short enough to hold one line. Move a licence string or a long method qualifier into the caption or the speaker notes rather than letting the source wrap.

A caption explains what is plotted, not where it came from: units, category coding, colour meaning, sample size. Example: `受威胁（CR/EN/VU）物种丰富度，0.05° 网格统计（种/格网）`. Never concatenate the caption and the source into one long string.

### In-text citation

- Cite literature in the slide body as `（<作者> <年>）` or `(<Author> <year>)` matching the surrounding script.
- Spell out the full reference on the closing reference slide, one work per line, with a hanging indent.

## 7. Text and editorial presentation

- Give each slide one clear point.
- **The title states that point.** See `argument-and-titles.md` §1. A topic-label title is only acceptable where a figure needs a topic anchor — a two-panel plate, or a page in a results series — and such pages are a minority.
- **Never carry both an action title and a conclusion sentence on the same page.** If the title is the finding, there is no conclusion line. If a conclusion line is needed, the title is short and topical.
- Where a conclusion line is used, it must not wrap so that a closing bracket, a period, or a single trailing character falls onto a second line. Shorten the sentence until it fits one line at 20 pt across 11.83 in, or accept two balanced lines.
- **Metric labels are self-contained noun phrases.** Printed under a large number, the label must stand alone and must never open with a particle. Write `全球已评估淡水鱼类的受威胁比例`, never `26%` over `的已知淡水鱼类物种在全球受威胁`. The same ban covers labels opening with `是`, `占`, `为`, or a bare `的`.
- Body text stays at about 40 words maximum per slide.
- Put method detail, parameter values, and provenance chains in the speaker notes unless the slide's single job is to state the method.
- Prefer short declarative titles and compact noun phrases.
- Keep body groups to approximately three to five lines where possible.
- Avoid slogans, production commentary, template language, and labels that do not help the audience interpret the slide.
- Avoid excessive all-caps text, arrows, semicolons, and nested bullet levels.
- Use bullets only when the items are genuinely parallel. Otherwise use short separated text groups.
- Edit copy before reducing type size or tightening spacing.

## 8. Speaker notes

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

## 9. Closing reference slide

- Use a plain closing slide titled with the section label plus `参考文献` / `References`.
- List one work per line as: `<作者> (<年>). <标题>. <期刊缩写> <卷>: <页>.`
- Left-align with a hanging indent so author names align.
- Build the list as **one text frame with one paragraph per entry and a uniform `space_after`**. Advancing y by a fixed step per entry leaves a visible hole wherever an entry runs one line instead of two.
- Keep every entry in 14–16 pt black, no numbering decoration, no dividers, and no background.
- Include every work cited on any slide or figure plate, so the deck is self-contained.

## 10. Visual QA checklist

Run the full procedure in `visual-review.md`: automated assertions, then four visual passes (overview, page by page, cross-slide comparison, distance test).

Automated assertions worth running:

- every run: `latin == Arial`, `ea == 黑体`, `srgbClr == 000000`;
- no source line matches a banned authorship verb;
- **every picture: `top + height <= NOTE_CUT`** — this one assertion catches the most common and most visible defect;
- caption line at the same y on every slide;
- point-size audit per role, compared across slides.

Content layer (see `argument-and-titles.md`):

- every content slide's title is a complete sentence stating the takeaway, not a topic label;
- ghost deck test passes: the title sequence alone tells the complete argument;
- no page carries both an action title and a conclusion sentence stating the same claim;
- one exhibit per slide, directly supporting its title;
- conclusions slide is last non-appendix slide; no "thank you" ending.

Then confirm by eye:

- No text overlaps, clipped text, cropped glyphs, or off-slide objects.
- No unintended image distortion or cropping.
- Standard titles share the same x, y, width, height, font size, and color.
- Repeated column headings and content blocks align exactly — verified by **opening pairs of similar slides side by side**, not one at a time.
- Chinese text renders in `黑体`; Western text renders in `Arial`. Mixed-language runs retain both assignments after saving and reopening the PPTX.
- Every text run is black `#000000`.
- No background object, card, border, rule, badge, page number, or brand strip appears anywhere.
- Body text is at least 18 pt and figure labels remain readable.
- Every figure plate has panel letters where applicable (single-panel figures carry none), and a caption and source **sharing one line** with the source right-flushed.
- Panel letters sit at each panel's real left edge, not at the requested box edge.
- No source line contains authorship or reproduction verbs (`作者自绘`, `作者制图`, `自制`, `引自`, `改编自`, `Adapted from`, `Courtesy of`, or similar).
- Figures fill the space the grid allows. A plate floating in half of its box reads as a small figure.
- **Distance test**: viewed at 30–40 % size, the title is readable and the figure's key finding is visible without hunting. Axis labels that need to shrink to fit indicate a figure that needs redesigning.
- No metric label opens with `的`, `是`, `占`, or `为`.
- Metric columns beside a figure leave a gutter matching the standard gutter, not a 1.2 in hole.
- Long titles are shortened before they wrap; if a wrap is essential, enlarge the title box without colliding with content.
- Text does not sit on top of visually busy evidence; a plain text-backing rectangle is used only where needed for legibility.
- Whitespace is balanced; no corner is crowded merely to fill the canvas.
- Speaker notes are present, ordered correctly, and free of placeholder text.
- Every cited reference is verified against a real publication and appears on the closing reference slide.