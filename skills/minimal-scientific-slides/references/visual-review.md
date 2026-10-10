# Visual Review Workflow

Rendering a deck is not review. This file defines the pass that finds what source inspection cannot.

Adapted from the visual-review workflow in k-dense-ai's `scientific-slides` skill (issue checklist, distance test, cross-slide comparison) and the figure specification in the Nature Research Figure Guide.

## Why this file exists

A compliance scan answers "is anything forbidden present". It cannot answer:

- does a figure cross the caption line
- is the figure too small to read at 6 feet
- is page 9's title the same length as page 4's
- does one page have three text blocks where its siblings have one

Those are the defects that make a deck look cheap. Every one of them is only visible in a rendered image. **Export the pages and read them.** A scan that passes is not evidence the deck looks right, and treating it as such is the most common way a broken deck ships.

## Export

Use the platform's own renderer so that fonts, wrapping and image placement match what the presenter will see. On Windows, PowerPoint COM export:

```python
import win32com.client, os, tempfile, shutil
app = win32com.client.Dispatch("PowerPoint.Application")
app.Visible = True
pres = app.Presentations.Open(pptx, True, False, True)
tmp = os.path.join(tempfile.gettempdir(), "qa")
os.makedirs(tmp, exist_ok=True)
for i in range(1, pres.Slides.Count + 1):
    pres.Slides.Item(i).Export(os.path.join(tmp, "slide_%02d.png" % i), "PNG", 1800, 1013)
pres.Close(); app.Quit()
```

Export at 16:9 dimensions around 1800 × 1013 px. A sandboxed PowerPoint process may not write to a working drive; export to `%TEMP%` and copy afterwards.

Where PowerPoint is unavailable, `soffice --headless --convert-to pdf` then render pages to images. LibreOffice substitutes fonts that are not installed, so confirm the final text fit in PowerPoint before delivery.

## Four-pass review

### Pass 1 — Overview

Look at every page at once if possible (contact sheet). Judge the deck as a whole: does it look like one family, is the type size consistent, do the figures have similar visual weight, does the rhythm of pages feel even. This is where you notice that pages 4 and 9 have visibly different caption sizes even though each is internally consistent.

### Pass 2 — Page by page

Read each page individually. Work the checklist below and record defects with page numbers.

### Pass 3 — Cross-slide comparison

**This pass is what separates a professional deck from a competent one, and it is almost always skipped.** Open pairs of similar pages side by side and compare:

- caption and source line at identical y and identical point size
- title at identical y, identical size, identical left edge
- figure top edge on the same line
- identical gutter between a figure and its side column
- identical metric number size and label size
- figure optical width consistent across comparable pages

Two pages can each pass every single-page check and still look misaligned as a pair. The shared-baseline constants in `style-spec.md` §1 exist to make this pass automatic — verify they are actually holding, don't eyeball them.

### Pass 4 — Distance test

View the pages at roughly 30–40 % size, simulating projection at about 6 feet. Ask of each page:

- Is the title readable?
- Is the figure's key finding visible without hunting?
- Is any axis label illegible? If the axis needs 10 pt to fit, the figure needs redesigning, not shrinking.
- Are there two competing focal points where one would do?

Text that survives at full size and dies at distance is the single most common failure in a slide deck read from the back of a room.

## Defect checklist

**Overflow and clipping**
- text cut at the page edge or beyond its box
- captions clipped at the bottom
- a lone closing bracket, period, or single character orphaned onto a second line

**Overlap**
- text over figure, figure over figure
- caption or source line sitting on axis labels or a legend
- panel letters detached from their panel

**Alignment and spacing**
- inconsistent margins, off-centre titles, ragged multi-column gaps
- an unbalanced gutter: a figure ending far from its side column leaves a visible hole
- a figure floating in half of its allotted box, which reads as a small figure

**Figures**
- axis labels too small, legend illegible, low-resolution or stretched
- a figure with no source line
- multi-panel figures whose panels are different heights

**Typography**
- any font other than the mandated pair
- any colour other than black
- a metric label opening with a particle (`的`, `是`, `占`, `为`)
- inconsistent point sizes for the same role across pages

## Severity and logging

| Severity | Meaning |
|---|---|
| Critical | Slide unusable or looks unprofessional — overlap, clipping, illegible figure |
| High | Clearly visible defect — misalignment, hole in the layout, orphan wrap |
| Medium | Noticeable but not confusing — slight inconsistency |
| Low | Cosmetic |

Log as `slide | category | description | severity | status`, fix, re-export, and re-read the affected pages. A fix that shifts a shared baseline invalidates every page using that anchor — re-export the whole deck rather than the single page.

## Automated assertions worth running in the same pass

These are cheap and catch the mechanical half:

- every run: `latin == Arial`, `ea == 黑体`, `srgbClr == 000000`
- no banned authorship verb in any source line
- **every picture: `top + height <= NOTE_CUT`** — the assertion that catches the most visible defect
- caption line at the same y on every slide
- point-size audit per role, printed as a table, compared across slides
- **airiness audit**: per slide, compute the blank share of the canvas (1 − summed shape area / canvas area), the largest picture's width and height as a percentage of the canvas, and the content bounding box. Flag any slide over roughly 62 % blank, and flag any slide whose bounding box fails to reach the margins. This turns "does it look cramped?" into a number, which is the only reliable way to catch it — the eye accepts a cramped page as deliberate.

Then do the four passes by eye. The assertions are necessary and not sufficient; skipping the eye pass is how a deck with four confirmed bugs ships.

## Figure-internal standards

When generating the figures themselves, follow journal-grade conventions so they survive projection:

- axis lines and tick marks retained; both axes labelled with units in parentheses
- colour-blind-safe palette (Wong 2011, *Nat Methods* 8:441 — black, orange `#e69f00`, sky blue `#56b4e9`, bluish green `#009e73`, yellow `#f0e442`, blue `#0072b2`, vermillion `#d55e00`, reddish purple `#cc79a7`); never red/green alone, never a rainbow scale
- no background gridlines, no decorative icons, no drop shadows, no patterns
- no coloured text; use keylines and keys instead
- text embedded in figures stays legible at projection size — target 16 pt or larger for axis labels on a slide, far above the 5–7 pt minimum used in print
- multi-panel letters bold, upright, lowercase a/b/c, at the same size as the rest of the figure text

Source: Nature Research Figure Guide, *Preparing figures* and *Building and exporting figure panels*.

## Encoding honesty

A chart that encodes something the reader cannot decode is worse than no chart: it looks informative and carries noise. Audit every visual channel before delivery.

- **Test each encoding against its own range.** Point area spanning 2.5–6 units cannot convey a 33-fold difference in cell count. If the encoded quantity varies by more than about 4×, the reader cannot recover it from the mark and the channel should be dropped or replaced by an explicit annotation (`n = 22,082 to 72,296`).
- **Distinguish "less data" from "less land".** Binning by degrees rather than by area makes high-latitude bands look data-poor purely because the country narrows there (cos 53° / cos 19° = 0.64). Any spatial aggregation must hold the sampled area comparable across bins, or state the imbalance.
- **Do not let a secondary hue exist without a job.** One accent colour marks the one series the reader must act on. A second hue is a claim that the two things differ in kind.
- **Use a summary band when the interesting signal is flat.** A permutation null that spans ±0.03 against an observation at 0.084 is best shown as a histogram with the null range shaded, not as a point estimate with an error bar.
- **Put the sample size in the annotation, not in the reader's inference.** Every panel that aggregates should state its own `n` range inline.
- **Keep annotation text inside the panel.** Compute the label's position against the axis limits after expansion, not before — an annotation at `y = Inf` or beyond the last break silently disappears or overlaps a neighbour. Reserve a band for annotations (`scale_y_continuous(limits = c(0, TOP_A))`) rather than hoping the expansion leaves room.

## Legends

- Name a legend series with the quality criterion it encodes, plus its `n`: `Stratum A (perfectly matched, n = 1,359)`.
- When `scale_*_manual()` is given a named vector, the names must match the factor's levels **exactly**, including runs of spaces. A near miss returns no error — the series silently renders grey.
- An annotation layer must not inherit a `fill` mapping it has no column for. Pass `inherit.aes = FALSE` and declare only what the layer needs; if a stray key still appears, remove it with `guide_legend(override.aes = list())` — but fix the root cause first, because `fill = NA` renders as a visible legend entry, not as nothing.