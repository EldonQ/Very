---
name: minimal-scientific-slides
description: "Create or restyle editable 16:9 PowerPoint decks with a strict academic visual system: argument-first titles that pass the ghost deck test, pure white canvas, black text only, SimHei for Chinese and Arial for Western scripts, generous whitespace, large evidence graphics, panel-labelled figures with formal source citations, concise text, and bilingual speaker notes. Use when the user asks for a minimal scientific or academic presentation, wants an existing deck normalized to this style, or needs layout and visual QA without decorative templates. The skill is content-agnostic and must never copy subject matter, branding, screenshots, or project-specific wording from a source deck."
---

# Minimal Scientific Slides

Apply a strict academic visual system in which evidence and spoken explanation carry the presentation. The reference benchmark is a printed journal figure plate: white ground, black ink, generous figure area, panel letters, and a formal source line. Keep every slide editable unless the user explicitly requests flattened output.

A journal figure plate and a lecture slide share a look but not a job. In a figure plate the title is a caption and carries no argument. In a slide the title **is** the argument. Confusing the two produces the most common defect in academic decks: topic-label headings plus a compensating conclusion line lower down, which states the same claim twice and reads as verbose. This skill therefore governs content and argument first, and layout second.

## Workflow

**Order matters. Do not start from layout.**

1. **Choose the argument spine** (situation/complication/resolution, funnel+answer, or answer-first) and state the central question by slide 3 at the latest. See `references/argument-and-titles.md` §2.
2. **Write every slide title as a complete sentence stating the takeaway** — not a topic label. Draft all titles before building any slide. See `references/argument-and-titles.md` §1.
3. **Run the ghost deck test.** Read only the titles in sequence. They must tell the complete argument. If they read as a table of contents, repair the argument — rewrite titles, reorder, or cut slides — before building anything. Fixing this later means rebuilding the deck.
4. **Verify real bibliographic metadata before citing.** Search the literature; never invent volume, issue, page, DOI, or licence strings.
5. **Select one layout family** per slide from `references/style-spec.md`, deriving every position from the shared baseline constants in §1.
6. **Inventory every figure** and give it two annotation items: a caption stating what is plotted (units, category coding, sample size) and a source stating the data or literature citation. Source-line forms are in `references/style-spec.md` §6. Neither may name the slide's authors or narrate reproduction.
7. **Place figures at preserved aspect ratio**, top-left anchored, with the height clamped so a figure can never cross the caption line. Give the figure the largest box the grid allows.
8. **Attach panel letters** where the plate is multi-panel, at the panel's real left edge.
9. **Add speaker notes** in the requested language format. Move method detail, parameter values and provenance chains here — they are not read from the back of a room.
10. **Run the automated assertions**, then **export every page and read it** through the four visual passes in `references/visual-review.md`. Fix, re-export, re-read. A passing scan is not evidence that the deck looks right.

## Non-negotiable visual rules

### Titles are the argument, not labels

- **Every content slide's title is a complete sentence stating that slide's takeaway.** Never a topic label, never a bare section name. `受胁物种热点与多样性热点在空间上高度重叠` is a label; `中国淡水鱼适生区的受胁热点与多样性热点重合` is a finding.
- Read the title sequence alone. It must tell the whole argument — the **ghost deck test**. Repair the argument before building, not after.
- One or two lines. Three lines means the point is not sharp enough yet.
- Titles must be mutually distinguishable. If two titles could be swapped between their slides unnoticed, fix the redundancy.
- A question may open a deck; it cannot carry a results slide.

### The title–conclusion redundancy rule

When the title already states the finding, **delete the separate conclusion line.** A page carrying both an action title and a conclusion sentence says the same thing twice, which is what makes a deck read as verbose.

The two structures are mutually exclusive:

| Structure | Page contains |
|---|---|
| **Action title** (default) | conclusion-bearing title · figure · caption + source |
| **Topic title** (only when a figure needs a topic anchor, e.g. a two-panel plate or a results series) | short topic title · figure · caption + source · one conclusion sentence |

Never mix them on one page. If a slide genuinely needs a concluding sentence, its title must be a short topic label — but a topic label is a concession, not a default, and it must not be the majority of the deck.

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

- **The figure is the protagonist; text is the caption.** Default a content page to the figure alone on the plate at full content width, with the reading carried by the caption band and the notes. Target **75% figure / 25% text** by width. A page split evenly is a page where neither element wins. Reach for a side column only when the numbers themselves are the point of the page (a composition breakdown, a pair of headline figures), and then cap the column at a quarter of the content width.
- **Fill the canvas.** A page floating inside its own margins reads as cramped, not minimal. Measure every asset's aspect ratio first and pick the layout family from it: wide plates (ratio ≥ 2.2) take the **full content width** with height following the ratio; mid charts (1.5–2.0) go full width and centre when height-limited; square plates (≤ 1.3) are height-limited, so give them a column that carries real content rather than one lonely metric. A uniform height cap applied to mixed ratios strands the narrow figures in white space.
- **Re-draw a figure whose aspect ratio wastes the plate.** When a chart must occupy an awkward fraction of a 16:9 page, transposing it usually beats shrinking it. A vertical bar chart of 7 categories becomes a horizontal bar chart at ratio ≈ 2.8 and fills the content width instead of 55% of it.
- Let one figure, chart, or result dominate when visual evidence exists.
- Prefer one strong number plus a short explanation over dense tables of metrics.
- Use flat text and images only.
- Never stretch or distort images. Use contain-style placement by default; crop only when the crop is intentional and preserves the evidence.
- Give the figure the largest box the grid allows. A figure that floats in half of its allotted box reads as a small figure even when its pixel dimensions are adequate. Low-resolution reproduced figures may be scaled to the full box and accepted slightly soft; a slightly soft full-width plate beats a sharp one at half size.
- On text-only pages, position by where each block actually **ends**, not by a fixed step. Short text at fixed y positions leaves the gaps between blocks and drags the bottom margin out.
- Do not reduce body text below the specified minimum. Shorten or split the content instead.
- Treat any text overlap, awkward wrap, clipped glyph, or inconsistent alignment as a defect.
- **Size the title box for two lines even when most titles are one line.** A box sized for one line at 28 pt (0.82 in) cannot hold two lines at 1.18 spacing (0.92 in); the overflow runs upward and lands on the section label above it. Either give the box room for two lines or shorten every title past the one-line character budget. Verify by measuring each title length against the box width, not by looking at the rendered slide.

## A story, not a sequence of results

A deck of correct slides is not an argument. Before laying out anything, write the claim each page makes and check that the sequence creates a reason to continue.

- **Do not promote a diagnostic to the spine by default.** The tempting move is to make the most striking QC number the deck's subject. Resist it unless the deck would collapse without it. Test: *would this talk still make sense if the diagnostic turned out to be fine?* For a modelling study, the answer is usually yes — a weak correlation between two richness sources is a **constraint on method choice**, so it belongs as a paragraph in the methods slide's notes explaining why the model is fitted to habitat rather than to occurrences. Quality control produces diagnostics; the study produces findings; conflating the two is how a talk ends up answering a question the audience never asked. See `references/argument-and-titles.md` §8 for the full test and the four-beat structure to use when the diagnostic *is* the contribution.
- **Order the pages as an argument, not as a workflow.** Global context → national baseline → methods → results is a table of contents. Stakes → baseline → where the uncertainty lives → the question → the method that answers it → first result → conclusions is an argument.
- **Test an objection before a reviewer does.** Where a number invites an obvious alternative explanation, put that explanation on a slide and refute it with a test whose result is reported whichever way it falls. Reporting a test that fails to discriminate, or a stratum whose estimate is undefined, is stronger than omitting the question.
- **Make a diagnostic finding do methodological work.** The best ending for a diagnostic slide is the sentence "therefore the method must be X, because Y." A diagnostic that changes nothing downstream is trivia.
- Then run the ghost-deck test (see `references/argument-and-titles.md`): reading only the titles in order must reconstruct a defensible argument.

## Statistical claims on slides

- **Never print a correlation coefficient without its uncertainty or its test.** `ρ = 0.08` alone is unreadable. What matters is whether the value is distinguishable from zero, which takes a permutation test or a confidence interval, and the deck should say which.
- **When a distribution is zero-inflated, a single correlation understates the structure.** Split the question into "is this unit observed at all" and "how much is observed once it is", and report both slopes. A rank correlation computed over mostly-zero data is a statement about the zeros.
- **Decompose by the quality axis a reviewer would name.** If names were matched against a taxonomic backbone, the correlation restricted to exact matches is the test — and a near-identical value is the finding.
- **Report an unestimable stratum as unestimable.** When a stratum has no usable key, say so and explain why substituting an aggregate would be wrong. A fabricated estimate for a diagnostic slide is worse than a blank.
- **Check that two sample sizes agree before printing either.** Filters that differ by one covariate produce two defensible, different `n` values. Label each with its own filter instead of letting them silently disagree across pages.

## Copy discipline

- **Body text: about 40 words maximum per slide.** Above that, split the slide or move the material to the notes.
- **Method detail belongs in speaker notes.** Parameter values, provenance chains, sample-size derivations and algorithm lists are not read from the back of a room. Keep them in notes unless the slide's single job is to state the method.
- A conclusion line, where the structure calls for one, must not break so that a closing bracket or a single trailing character falls onto a second line. Shorten the sentence until it fits.
- **Metric labels are self-contained noun phrases.** When a large number is printed above a label, the label must read as a standalone phrase and must never begin with a particle such as `的`, `是`, or `占`. Write `全球已评估淡水鱼类的受威胁比例`, not `的已知淡水鱼类物种在全球受威胁`.
- Delete any sentence that only re-encodes a number sitting two centimetres away on the same slide.
- Telegraphic phrasing is fine where meaning survives: `1,525 known freshwater species`, not `Our study found that there were 1,525 species`.

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
- **Source lines state data and citation only — never authorship or reproduction verbs, and never a label prefix.** Banned on slides: `作者自绘`, `作者制图`, `自制`, `引自`, `改编自`, `摘自`, `本文绘制`, `Our figure`, `Adapted from`, `Courtesy of`. These are production commentary and they read as self-announcement in an academic talk. Also banned: a category label in front of the source, such as `数据：`, `来源：`, `Source:`. The label adds nothing the citation does not already say, and it is a tic that reads as machine-generated.
- **Write the bare citation.** `IUCN Red List (2025)` or `Barbarossa et al. (2021), Nat Commun 12: 1701, Fig. 1` — not `数据：IUCN Red List（2025）`. The line should read as it would in a journal figure legend.
- Set the licence in the caption or the notes, not in the source line.
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

- titles alone tell the argument (ghost deck test passes);
- no page carries both an action title and a conclusion sentence stating the same claim;
- repeated elements align to the same anchors, verified by cross-slide comparison;
- the caption line sits at the same y on every slide, so flipping pages produces no vertical jump;
- no figure crosses the note line — assert `picture top + height <= NOTE_CUT`;
- every exhibit is legible at distance and its key finding is visible without hunting;
- figures are large enough to read without zooming;
- every figure plate has panel letters where applicable, and a caption and source sharing one line, with the source free of authorship verbs;
- captions and notes explain rather than duplicate the slide;
- all text is black and renders in 黑体/Arial;
- no slide looks like a dashboard or a collection of unrelated cards;
- the visual hierarchy is obvious within two seconds, including from the back of the room.

The final review must be done by **looking at the exported slide images**, through all four passes in `references/visual-review.md`: overview, page by page, cross-slide comparison, and distance test. A programmatic compliance scan proves nothing forbidden is present; it cannot see a figure crossing the caption line, an orphan wrap, a label opening with a dangling particle, or two pages that each pass alone but do not match as a pair.

## Provenance of these rules

The content-layer rules are drawn from sources that may be cited alongside them:

- Naegle KM (2021). Ten simple rules for effective presentation slides. *PLoS Computational Biology* 17(12): e1009554. CC BY 4.0. — one idea per slide, one minute per slide, **title as takeaway**, cite what is borrowed, avoid cognitive overload, design for the distracted listener.
- Gabberflast `academic-pptx-skill` (MIT) — action titles, ghost deck test, exhibit discipline, argument-first outline before building.
- k-dense-ai `scientific-slides` — the four-pass visual review, issue checklist, distance test, cross-slide comparison, common-pitfalls taxonomy.
- Nature Research Figure Guide — axis and tick requirements, colour-blind-safe palette, panel-letter form, text-size floors.

The layout layer remains this skill's own design system: pure black text, 黑体/Arial, no decoration, shared baseline grid, one-line caption and source. Content rules were adopted from the sources above; the visual system was not copied from them.