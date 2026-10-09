---
name: minimal-scientific-slides
description: "Create or restyle editable 16:9 PowerPoint decks with a strict academic visual system: pure white canvas, black text only, SimHei for Chinese and Arial for Western scripts, generous whitespace, large evidence graphics, panel-labelled figures with formal source citations, concise text, and bilingual speaker notes. Use when the user asks for a minimal scientific or academic presentation, wants an existing deck normalized to this style, or needs layout and visual QA without decorative templates. The skill is content-agnostic and must never copy subject matter, branding, screenshots, or project-specific wording from a source deck."
---

# Minimal Scientific Slides

Apply a strict academic visual system in which evidence and spoken explanation carry the presentation. The reference benchmark is a printed journal figure plate: white ground, black ink, generous figure area, panel letters, and a formal source line. Keep every slide editable unless the user explicitly requests flattened output.

## Workflow

1. Identify the slide's single communication job before laying it out.
2. Select one layout family from `references/style-spec.md`.
3. Inventory every figure and classify it as **self-produced**, **literature-derived**, or **data-derived from a cited source**. Each class has a mandatory citation form defined in `references/style-spec.md` §6.
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
- Do not reduce body text below the specified minimum. Shorten or split the content instead.
- Treat any text overlap, awkward wrap, clipped glyph, or inconsistent alignment as a defect.

## Reference and citation discipline

- Every figure plate carries a visible source line. A figure without a traceable source is a defect, not a style choice.
- Label multi-panel figures with bold panel letters `(a)`, `(b)`, `(c)` at a fixed offset inside each panel's upper-left corner.
- Distinguish provenance explicitly in the source line: self-drawn work, literature reproduction, and third-party data reuse each use a different, standard phrasing defined in `references/style-spec.md` §6.
- Record the licence for reproduced literature figures.
- When the deck cites literature in text, use author–year form in parentheses and spell out the same reference in the closing reference slide.
- Resolve every citation against a real source before delivery. If a bibliographic detail cannot be verified, mark it explicitly rather than guessing.

## Content independence

This skill defines presentation form only. It must not embed or distribute a source presentation, source images, screenshots, data, research claims, institution names, person names, project names, or topic-specific examples. When demonstrating a layout, use neutral placeholders such as `[Title]`, `[Figure]`, `[Panel a]`, `[Key result]`, `[Interpretation]`, and `[Source line]`.

## Implementation notes (python-pptx path)

- `run.font.name` writes **only** the `a:latin` slot. To satisfy the bilingual font rule, append `a:ea` and `a:cs` elements to the run's `a:rPr` right after `a:latin`. Appending preserves schema order (`solidFill` → `latin` → `ea` → `cs`), so PowerPoint opens the file without repair.
- Verify compliance programmatically before delivery: walk every run, assert `latin == Arial`, `ea == 黑体`, and `srgbClr == 000000`. Report the violation count; do not eyeball it.
- Rendered map/chart PNGs often carry large white margins. Contain-fit placement then makes the figure look small. Trim white borders (PIL `ImageChops.difference` + `getbbox`) before placing, and recompute every box from the trimmed aspect ratio — a near-square 1.13:1 map can become 2.3:1 after trimming, which changes the correct layout family.
- Never add a slide-level panel letter if the figure already draws `(a)`/`(b)` inside itself. Duplicated letters render as overlapping text. Panel letters belong only on multi-panel plates.
- For hanging-indent reference lists, set `marL` and a negative `indent` on the paragraph properties; there is no high-level API.

## Quality bar

Deliver only after the rendered deck is visually stable:

- repeated elements align to the same anchors;
- text remains legible from a meeting-room screen;
- figures are large enough to read without zooming;
- every figure plate has panel letters where applicable and a correct source line;
- captions and notes explain rather than duplicate the slide;
- all text is black and renders in 黑体/Arial;
- no slide looks like a dashboard or a collection of unrelated cards;
- the visual hierarchy is obvious within two seconds.