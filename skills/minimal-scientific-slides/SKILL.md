---
name: minimal-scientific-slides
description: "Create or restyle editable 16:9 PowerPoint decks with a clean, figure-led academic visual system: white canvas, restrained navy typography, generous whitespace, large evidence graphics, concise text, consistent two-column geometry, and bilingual speaker notes. Use when the user asks for a minimal scientific or academic presentation, wants an existing deck normalized to this style, or needs layout and visual QA without decorative templates. The skill is content-agnostic and must never copy subject matter, branding, screenshots, or project-specific wording from a source deck."
---

# Minimal Scientific Slides

Apply a restrained visual system in which evidence and spoken explanation carry the presentation. Keep every slide editable unless the user explicitly requests flattened output.

## Workflow

1. Identify the slide's single communication job before laying it out.
2. Select one layout family from `references/style-spec.md`.
3. Fit the content by editing and prioritizing it, not by shrinking it below the specified minimums.
4. Place figures with preserved aspect ratios and no decorative frames.
5. Add speaker notes in the requested language format. Use the bilingual convention in the style specification when bilingual notes are requested or already present.
6. Render the complete deck and inspect every slide at normal viewing size.
7. Run available slide-overflow and element-overlap checks. Correct all unintended collisions, clipping, off-canvas elements, and unstable line wraps.

## Non-negotiable visual rules

- Use a 16:9 white canvas.
- Use `宋体` for every Chinese character and `Times New Roman` for every Western character. This bilingual font rule is mandatory across titles, body text, metrics, labels, tables, charts, and speaker notes where font formatting is available.
- Use the restrained palette, typography scale, grid, and spacing in `references/style-spec.md`.
- Keep titles plain and left aligned. Do not add title bars, underlines, badges, or decorative rules.
- Let one figure, chart, or result dominate when visual evidence exists.
- Prefer one strong number plus a short explanation over dense tables of metrics.
- Use flat text and images only. Do not add cards, boxes, borders, shadows, gradients, patterned backgrounds, ornamental icons, or corner decorations.
- Do not add page numbers, running headers, logos, branding strips, project labels, or template watermarks unless the user explicitly requests them.
- Never stretch or distort images. Use contain-style placement by default; crop only when the crop is intentional and preserves the evidence.
- Do not reduce body text below 18 pt. Shorten or split the content instead.
- Treat any text overlap, awkward wrap, clipped glyph, or inconsistent alignment as a defect.
- Split mixed-language text into runs when necessary so Chinese and Western scripts keep their required fonts. Recheck wrapping after font assignment because the metrics differ.

## Content independence

This skill defines presentation form only. It must not embed or distribute a source presentation, source images, screenshots, data, research claims, institution names, person names, project names, or topic-specific examples. When demonstrating a layout, use neutral placeholders such as `[Title]`, `[Figure]`, `[Key result]`, and `[Interpretation]`.

## Quality bar

Deliver only after the rendered deck is visually stable:

- repeated elements align to the same anchors;
- text remains legible from a meeting-room screen;
- figures are large enough to read without zooming;
- captions and notes explain rather than duplicate the slide;
- no slide looks like a dashboard or a collection of unrelated cards;
- the visual hierarchy is obvious within two seconds.
