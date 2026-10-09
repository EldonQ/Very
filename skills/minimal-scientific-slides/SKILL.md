---
name: minimal-scientific-slides
description: "Create or restyle editable 16:9 PowerPoint decks with a strict academic visual system: pure white canvas, black text only, SimHei for Chinese and Arial for Western scripts, generous whitespace, large evidence graphics, panel-labelled figures with formal source citations, concise text, and bilingual speaker notes. Use when the user asks for a minimal scientific or academic presentation, wants an existing deck normalized to this style, or needs layout and visual QA without decorative templates. The skill is content-agnostic and must never copy subject matter, branding, screenshots, or project-specific wording from a source deck."
---

# Minimal Scientific Slides

Apply a strict academic visual system in which evidence and spoken explanation carry the presentation. The reference benchmark is a printed journal figure plate: white ground, black ink, generous figure area, panel letters, and a formal source line. Keep every slide editable unless the user explicitly requests flattened output.

## Workflow

1. Identify the slide's single communication job before laying it out.
2. Select one layout family from `references/style-spec.md`.
3. Inventory every figure and give it two annotation lines: a caption/legend line stating what is plotted (units, category coding, sample size) and a source line stating the data or the literature citation. Source-line forms are defined in `references/style-spec.md` §6. Neither line may name the slide's authors or narrate reproduction.
4. Verify real bibliographic metadata before citing. Search the literature; never invent volume, issue, page, DOI, or licence strings.
5. Fit the content by editing and prioritizing it, not by shrinking it below the specified minimums.
6. Place figures with preserved aspect ratios and no decorative frames.
7. Attach panel letters and the source line to every figure plate.
8. Add speaker notes in the requested language format. Use the bilingual convention in the style specification when bilingual notes are requested or already present.
9. Render the complete deck and inspect every slide at normal viewing size.
10. Run available slide-overflow and element-overlap checks. Correct all unintended collisions, clipping, off-canvas elements, and unstable line wraps.

## Non-negotiable visual rules

### Typography

- Use `黑体` (SimHei) for every Chinese character and Chinese full-width punctuation.
- Use `Arial` for every Western character, Latin-script word, Arabic numeral, unit, and Western punctuation.
- This bilingual font rule is mandatory across titles, body text, metrics, labels, tables, charts, and speaker notes where font formatting is available.
- For mixed-language text, set the East Asian font to `黑体` and the Latin font to `Arial`. If the library cannot assign both font slots reliably, split the text into script-specific runs and set each run explicitly.
- Split mixed-language text into runs when necessary so Chinese and Western scripts keep their required fonts. Recheck wrapping after font assignment because the metrics differ.
- Do not substitute 宋体, Times New Roman, Calibri, Aptos, or another fallback font. Verify the final PPTX on a system where both required fonts are installed.

### Color

- All slide text is black `#000000`. There are no accent-colored titles, gray captions, or tinted labels.
- Hierarchy comes from size, weight, and whitespace — never from hue.
- The only permitted non-black ink anywhere on a slide is inside a figure, and only where it encodes data or category meaning.
- A plain, borderless shape fill behind text is permitted only to keep text legible over a busy figure. It is optional, must carry no border, no corner rounding, no shadow, and no tint that competes with the data, and it is never used as decoration or as a card.

### Canvas and decoration

- Use a 16:9 canvas with a solid white background.
- Add no background color, gradient, pattern, texture, watermark, or tinted panel.
- Add no cards, boxes, borders, rules, underlines, title bars, badges, icons, corner decorations, or ornamental shapes.
- Add no page numbers, running headers, logos, branding strips, or template elements unless the user explicitly requests them.
- Do not add a footer band, sidebar, or navigation furniture.

### Figures and text

- Let one figure, chart, or result dominate when visual evidence exists.
- Prefer one strong number plus a short explanation over dense tables of metrics.
- Use flat text and images only.
- Never stretch or distort images. Use contain-style placement by default; crop only when the crop is intentional and preserves the evidence.
- Give the figure the largest box the grid allows. A figure that floats in half of its allotted box reads as a small figure even when its pixel dimensions are adequate. Low-resolution reproduced figures may be scaled to the full box and accepted slightly soft; a slightly soft full-width plate beats a sharp one at half size.
- Do not reduce body text below the specified minimum. Shorten or split the content instead.
- Treat any text overlap, awkward wrap, clipped glyph, or inconsistent alignment as a defect.

## Copy discipline

- **One conclusion per slide.** State the finding as a single declarative sentence; do not add a closing sentence that restates numbers already printed beside the figure.
- A conclusion line must not break so that a closing bracket or a single trailing character falls onto a second line. Shorten the sentence until it fits.
- **Metric labels are self-contained noun phrases.** When a large number is printed above a label, the label must read as a standalone phrase and must never begin with a particle such as `的`, `是`, or `占`. Write `全球已评估淡水鱼类的受威胁比例`, not `的已知淡水鱼类物种在全球受威胁`.
- Delete any sentence that only re-encodes a number sitting two centimetres away on the same slide.
- Move method detail, parameter values, and provenance chains into the speaker notes unless the slide's single job is to state the method.

## Shared baseline grid

Repeated elements must land on the same anchor on every slide, so nothing jumps when pages are flipped. Define the anchors once as constants and derive positions from them; never hand-tune a y value per slide.

A working set for a 13.333 x 7.5 in canvas:

| Anchor | y (in) | Content |
|---|---|---|
| `Y_SECTION` | 0.34 | section label |
| `Y_TITLE` | 0.70 | slide title |
| `Y_FIG` | 1.50 | figure block top |
| `Y_NOTE` | 5.62 | caption + source line |
| `Y_CONCL` | 6.06 | conclusion sentence |

Two hard floors follow from the grid and must be enforced in code, not by eye:

- `NOTE_CUT = Y_NOTE - 0.14` — **no figure may extend past this line.** Clamp the drawn height inside the placement function. A contain-fit box only stays inside when the figure is width-limited; an explicitly tall box (a low-resolution plate being enlarged) silently crosses the line and the caption lands on the x-axis labels.
- `CONCL_CUT = 6.86` — no conclusion may extend past this line.

### Why `valign="middle"` is a bug

A picture inserted with vertical centring sits lower than its frame by roughly half the leftover space, and figure plates rarely fill their box exactly. Any caption positioned against the *frame* bottom therefore lands on the figure. Top-left anchor every figure, return the real placed rectangle from the placement function, and derive what follows from that rectangle rather than from the box you asked for. Patching the collision per slide hides the defect instead of removing it.

## Reference and citation discipline

- Every figure plate carries a visible source line. A figure without a traceable source is a defect, not a style choice.
- **Source lines state data and citation only — never authorship or reproduction verbs.** Banned on slides: `作者自绘`, `作者制图`, `自制`, `引自`, `改编自`, `摘自`, `本文绘制`, `Our figure`, `Adapted from`, `Courtesy of`. These are production commentary and they read as self-announcement in an academic talk. Write `数据：IUCN Red List（2025）` or `Barbarossa et al. (2021), Nat Commun 12: 1701, Fig. 1（CC BY 4.0）` instead.
- Label multi-panel figures with bold panel letters `(a)`, `(b)`, `(c)` at a fixed offset inside each panel's upper-left corner. Skip panel letters on single-panel figures.
- Separate the two jobs of figure annotation: a **caption line** explains what is plotted (units, category coding, colour meaning), and a **source line** states the data or the literature citation. They are two distinct items; neither may name the authors nor narrate reproduction.
- Put the caption and the source on **ONE horizontal line** — caption flush to the left margin, source flush to the right margin, both on the same baseline. Never stack them as two paragraphs; a stacked pair reads as an accidental wrap and doubles the vertical footprint.
- Because the source column is right-flushed, its right edge becomes a straight vertical rule down the deck. Keep source strings short enough to stay on one line at the specified size; move a licence or a long method note into the caption or the speaker notes rather than letting the source line wrap.
- Record the licence for reproduced literature figures.
- When the deck cites literature in text, use author–year form in parentheses and spell out the same reference in the closing reference slide.
- Resolve every citation against a real source before delivery. If a bibliographic detail cannot be verified, mark it explicitly rather than guessing.

## Content independence

This skill defines presentation form only. It must not embed or distribute a source presentation, source images, screenshots, data, research claims, institution names, person names, project names, or topic-specific examples. When demonstrating a layout, use neutral placeholders such as `[Title]`, `[Figure]`, `[Panel a]`, `[Key result]`, `[Interpretation]`, and `[Source line]`.

## Implementation notes (python-pptx path)

- `run.font.name` writes **only** the `a:latin` slot. To satisfy the bilingual font rule, append `a:ea` and `a:cs` elements to the run's `a:rPr` right after `a:latin`. Appending preserves schema order (`solidFill` → `latin` → `ea` → `cs`), so PowerPoint opens the file without repair.
- Verify compliance programmatically before delivery: walk every run, assert `latin == Arial`, `ea == 黑体`, and `srgbClr == 000000`. Report the violation count; do not eyeball it.
- Rendered map/chart PNGs often carry large white margins. Contain-fit placement then makes the figure look small. Trim white borders (PIL `ImageChops.difference` + `getbbox`) before placing, and recompute every box from the trimmed aspect ratio — a near-square 1.13:1 map can become 2.3:1 after trimming, which changes the correct layout family.
- Give `figure()` a `bottom=` parameter and clamp `h` to `bottom - y` **before** computing the contain fit. Return the real `(x, y, w, h)` placed so panel letters, panel titles, and captions can be aligned to the figure itself rather than to the requested box.
- Place multi-panel letters at the real left edge each panel ended up at. A height-limited panel is narrower than its box, so the box edge is not the panel edge and the letter floats in the gap.
- Never add a slide-level panel letter if the figure already draws `(a)`/`(b)` inside itself. Duplicated letters render as overlapping text. Panel letters belong only on multi-panel plates.
- For hanging-indent reference lists, set `marL` and a negative `indent` on the paragraph properties; there is no high-level API.
- Build a reference list as **one text frame with one paragraph per entry and a uniform `space_after`**. Advancing y by a fixed step per entry leaves a visible hole wherever an entry runs one line instead of two.
- Font compliance and banned-verb scans are necessary but not sufficient. They cannot see a figure crossing the note line, a one-character orphan wrap, or a label opening with a dangling particle. Export every slide to PNG and read the images.
- Verify picture bottoms programmatically in the same pass: assert `top + height <= NOTE_CUT` on every slide. This single assertion catches the most common and most visible defect.

## Quality bar

Deliver only after the rendered deck is visually stable:

- repeated elements align to the same anchors;
- the caption line and the conclusion line sit at the same y on every slide, so flipping pages produces no vertical jump;
- no figure crosses the note line — assert `picture top + height <= NOTE_CUT`;
- text remains legible from a meeting-room screen;
- figures are large enough to read without zooming;
- every figure plate has panel letters where applicable, and a caption and source sharing one line, with the source free of authorship verbs;
- each slide carries at most one conclusion sentence, and no line ends on a lone trailing character;
- captions and notes explain rather than duplicate the slide;
- all text is black and renders in 黑体/Arial;
- no slide looks like a dashboard or a collection of unrelated cards;
- the visual hierarchy is obvious within two seconds.

The last round of review must be done by **looking at the exported slide images**, page by page, at full size. A clean compliance scan is evidence that nothing is forbidden; it is not evidence that the deck looks right. Reading the renders is what catches the defects a scanner cannot see.