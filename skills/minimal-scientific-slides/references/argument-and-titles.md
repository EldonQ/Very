# Argument and Title Governance

This file governs **what each slide says and how the deck argues**. It is content layer, not layout layer. Read it before touching layout.

Sources: Naegle KM (2021) *Ten simple rules for effective presentation slides*, PLoS Comput Biol 17(12): e1009554 (CC BY 4.0) — Rule 1 one idea per slide, Rule 3 make use of your heading, Rule 5 give credit where due, Rule 7 avoid cognitive overload, Rule 8 design for the distracted audience member. Also the Pyramid Principle (Minto) as applied in academic communication practice.

## 1. The slide title carries the argument

**A slide title is a complete sentence stating the takeaway, not a topic label.** This is the single highest-impact rule in academic slide design and the one most often violated.

| Topic label (wrong) | Action title (right) |
|---|---|
| Results | Treatment effect is significant across all three cohorts |
| Literature review | Prior work leaves the causal mechanism unexplained |
| Data | Dataset covers 40 years of county-level panel data |
| Methodology | Regression discontinuity exploits a sharp funding threshold |
| Discussion | Effect persists after controlling for selection and attrition |

### Why this matters more than any layout decision

An audience reads a new slide's heading **first**, then the body. If the heading is a topic label, the audience must wait for the presenter to discover the point — and a reader who was briefly distracted never discovers it at all (Naegle Rule 8).

A topic-label title also forces a compensating conclusion line lower on the slide. The page then states the same claim twice, in different words, which is the single most common source of the complaint that a deck is "verbose". **The fix is not to trim the sentence; it is to move the conclusion into the title and delete the duplicate.**

### Title requirements

- One or two lines. If it needs three, the point is not sharp enough yet.
- Readable at the back of the room; bold, 24–28 pt in a 10 in layout (proportionally larger on 13.333 in).
- Stated as a finding, not a question. A question may open a deck; it cannot carry a results slide.
- **Titles must be mutually distinguishable.** If two titles could be swapped between their slides without the audience noticing, the slides are redundant or one is misplaced.
- **Titles must be non-redundant.** If a title restates what the conclusion line says, delete the conclusion line.

### Ghost deck test

Read only the titles, in sequence, with the figures removed. They must tell the complete argument: what is known, what is missing, what was done, what was found, what it means.

If the title sequence reads as a table of contents rather than an argument, the deck's logic needs repair **before** any slide is built. Repair by rewriting titles, reordering slides, or cutting slides — not by adding connective text.

A fast failure signal: a title sequence containing two or more bare section names (`背景`, `数据`, `方法`, `结果`, `讨论`) means the argument was never written.

## 2. Argument spine

State the central question or claim by slide 2 or 3 at the latest. Choose one spine and apply it consistently.

- **Situation / Complication / Resolution** — what was known, what is missing, what this work contributes. The default for a research talk.
- **Funnel + Answer** — broad context → specific gap → approach → findings → implications.
- **Answer first** — conclusion, then support. For senior or time-pressured audiences.

One argument per deck. Researchers routinely try to present the whole paper; choose the claim that can be made convincingly in the available time and move the rest to appendix or notes.

### Flow test

After outlining, read the titles in order. Each should make the next feel like a natural consequence. If a slide could be moved elsewhere in the sequence without loss, it is either misplaced or dispensable.

## 3. Exhibit discipline

- **One exhibit per slide.** Two charts on a slide are either one comparison that should be a single combined exhibit, or two slides.
- **Every exhibit must earn its place.** Cover the exhibit and read the title: does the title still make sense? If yes, the exhibit is decoration. Cover the title and look at the exhibit: is the takeaway obvious without narration? If no, the exhibit needs annotation or a sharper title.
- **Rebuild figures rather than pasting from a paper or PDF.** Print-resolution figures are too small on screen and their in-figure captions do not survive projection. Regenerate charts at presentation resolution with axis labels at 16 pt or larger.
- **Do not include an exhibit you will not discuss.** Move it to the appendix.
- Prefer graphs over tables for trends, comparisons and distributions. Reserve tables for exact-value comparisons.

### Annotation inside figures

Where the key finding is not immediately obvious from the exhibit alone, mark it **inside the figure** — a call-out, a highlighted series, a labelled peak. An annotation outside the figure is a caption and does not perform this job.

Do this in the figure source (the plotting script), not as a slide overlay, so it scales and exports cleanly.

## 4. Slide-level economy

- **Body text: about 40 words maximum per slide.** Above that, either split the slide or move the material to notes or appendix.
- **Method detail belongs in the notes.** Parameter values, provenance chains, sample-size derivations, and algorithm lists are not read from the back of a room. Keep them in speaker notes unless the slide's single job is to state the method.
- Telegraphic phrasing is fine where meaning survives: `1,525 known freshwater species`, not `Our study found that there were 1,525 species`.
- Bold and italic for signal only — key terms, statistical notation, taxon names. Never decoration.

## 5. Two independent tests per slide

| Test | Question | Failure response |
|---|---|---|
| Self-sufficient | Could a reader get the key point from this slide without hearing the narration? | Sharpen the title, annotate the figure, or cut a second claim |
| Mute | If they heard nothing, is the main point obvious within two seconds? | Make the figure larger, raise the title's contrast in size, delete competing numbers |

The deck will be read as a PDF handout. A slide that only works while someone is talking is a broken slide.

## 6. Closing structure

- The conclusions slide is the last non-appendix slide and **stays on screen during Q&A**. Never end on "Thank you", a blank slide, or an appendix slide.
- Conclusions restate the argument, not the section headings. Each item pairs the finding with its implication.
- A references slide is required whenever any borrowed figure, dataset, or claim appears.
- For decks over 15 slides, orient the audience with a section label on each content slide.

## 7. Planning checklist

Run before building any slide:

```
□ Spine chosen (SCR / funnel / answer-first) and applied consistently
□ Central question stated by slide 3 at the latest
□ Titles drafted for every slide, not just labels
□ Ghost deck test passes: titles alone tell the argument
□ No title restates its own conclusion line, and no conclusion line restates its title
□ One exhibit per slide, each directly supporting its title
□ Every borrowed exhibit has a verified source line
□ Conclusions slide is last non-appendix slide
```

## 8. The diagnostic spine

A dataset that looks broken is often the deck's best material. When a number looks wrong — a near-zero correlation, an unexpectedly flat trend, a gap between two sources that should agree — do not footnote it. Build the deck around it.

The four-beat structure:

| Beat | Page type | Content |
|---|---|---|
| 1. Contradiction | topic title | Two sources describe the same object and disagree. Show the disagreement. |
| 2. Test | action title | One page per competing explanation, each with the test that discriminates between them |
| 3. Verdict | action title | What survives the tests, stated with the failing test reported as fully as the passing one |
| 4. Constraint | action title | "Therefore the method must be X, because Y" — the diagnostic changes a decision |

**Ordering the tests.** Put the test a reviewer will ask for first. A reviewer who suspects name mismatching wants the name-matching test first; a reviewer who suspects sampling bias wants the permutation test first. Getting this wrong reads as either evasive or confused.

**Reporting the failures.** A stratum whose estimate is undefined, a test whose result is the same either way, a null result you expected to be significant — all of it belongs on the slide, with the reason. The credibility of the passing result depends on the failing ones being shown.

**The constraint page is mandatory.** Without beat 4 the diagnostic is a curiosity; with it, it is the reason the method looks the way it does. This is also where a deferral belongs: "this quantity cannot be repaired, therefore we measure a different one."

**Guard against over-reading the diagnosis.** "The data are too sparse to model directly" is a statement about occurrence records. It is not a statement that the species are poorly known — a second, independent line of evidence (an expert range map) can show the opposite, and stating both is stronger than either alone.