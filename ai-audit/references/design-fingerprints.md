# Design / Visual AI Fingerprints

Reference file for the design-audit mode of the AI Audit skill. Contains the detectable visual patterns that mark a page as
AI-generated. Derived from research on impeccable (pbakaus/impeccable) and analysis of common AI-generated UIs.

## Overused Fonts

AI models converge on the same handful of fonts because they're the most frequently paired in training data. Using one of these
as the primary heading or body font is a strong visual tell.

**Detected fonts:**
- **Inter** — the single most common AI UI font
- **Roboto**
- **Fraunces** — especially italic for hero headlines
- **Geist** — Vercel's font, heavily represented in training data
- **Space Grotesk**
- **Plus Jakarta Sans**
- **Playfair Display**
- **Recoleta** — especially italic
- **DM Sans**
- **Cabinet Grotesk**
- **Satoshi**
- **Instrument Sans**

**Severity**: P0 for Inter or Fraunces italic as primary font. P1 for any other overused font. P2 for using one of these alongside a more distinctive companion font.  
**Fix**: Choose a less common font family. Pair a distinctive display font with a neutral but uncommon body font. Avoid the AI hall-of-fame list above.

## Single Font for Everything

Using exactly one font family for all headings, body, captions, and UI labels flattens the typographic hierarchy.

**Severity**: P0 if that font is also overused (Inter, etc.). P1 otherwise.  
**Fix**: Use at least 2 fonts — one for display/headings and one for body text — or create strong hierarchy through weight/size within a flexible family.

## Flat Type Hierarchy

Font sizes are too close together to create a clear visual hierarchy. Common AI pattern: heading at 18px, subheading at 16px, body at 14px.

**Severity**: P1 if the ratio between successive levels is under 1.25. P2 if under 1.15.  
**Fix**: Create distinct size tiers. Aim for at least 1.25× ratio between steps (e.g., 16 → 20 → 28 → 36).

## AI Color Palette

Purple/violet gradients and cyan-on-dark are the most recognizable color tells of AI-generated UIs. This palette emerged because models were trained on startup landing pages that followed the same design trends.

**Patterns to detect:**
- Purple-to-blue or purple-to-cyan gradients on headings, backgrounds, buttons
- Cyan or teal accent colors on dark backgrounds
- Electric violet (#7C3AED, #8B5CF6 and similar)
- Vibrant cyan (#06B6D4, #22D3EE and similar)
- Neon pink/magenta paired with deep indigo

**Severity**: P0 for purple/violet gradients as a primary accent. P1 for cyan-on-dark. P2 for a single AI-color accent element in an otherwise unique palette.  
**Fix**: Choose colors from a deliberate, brand-driven palette. Avoid the purple/cyan/indigo triad.

## Cream / Beige Background

Warm cream (#FAFAF0, #FFF8F0, #F5F0EB and similar) has become the default "tasteful" AI surface color — reached for by reflex instead of from a palette.

**Severity**: P1 for pure cream/beige backgrounds on a full page. P2 if used as a section accent.  
**Fix**: Choose a background that comes from a deliberate palette, not the safe warm off-white.

## Gradient Text

Gradient text on headings and hero metrics — especially purple-to-blue — is one of the most universal AI tells.

**Severity**: P0 if gradient text appears on headings or hero metrics.  
**Fix**: Use solid colors for text. Reserve gradients for decorative elements if at all.

## Side-Tab Accent Borders

A thick colored border (2-6px) on the left (or top) side of a card. The single most recognizable tell of AI-generated UI.

**Severity**: P0 for any occurrence.  
**Fix**: Remove the side stripe. Use a subtler accent — or nothing — to distinguish the card.

## Icon Tile Stacked Above Heading

A small rounded-square icon container above a heading — this universal AI feature-card template appears in practically every generated landing page. Look for an icon in a rounded box (often with a tinted background) sitting above or to the top-left of a heading.

**Severity**: P0 for 3+ instances on the same page. P1 for 1-2.  
**Fix**: Put icons beside headings (side-by-side) or let them sit in line without their own container.

## Hero Eyebrow / Pill Chip

Tiny uppercase letter-spaced text sitting immediately above an oversized hero headline. Often rendered as a pill/chip shape. Every AI SaaS hero has one.

**Severity**: P0 if combined with overused fonts or AI color palette. P1 standalone.  
**Fix**: Drop the eyebrow. Integrate the kicker into the headline, or skip it entirely.

## Repeated Section Kickers

Repeating the same eyebrow/kicker/label pattern above every section heading. "The AI editorial scaffold" — it signals structure over substance.

**Severity**: P2 (advisory — some sites legitimately use section labels).  
**Fix**: Vary section introductions, or remove the kickers and let headings stand alone.

## Numbered Section Markers

Using "01", "02", "03" (or 01, 02, 03) as display markers above section headings. Another AI editorial scaffold.

**Severity**: P2 (advisory — can be intentional).  
**Fix**: Choose a different section cadence. Remove the numbers or integrate them into the heading.

## Card Grid / Nested Cards

AI models put everything in cards — feature cards, pricing cards, testimonial cards — and then nest cards inside cards.

**Patterns to detect:**
- Three or more cards in a row (the 3-column card grid)
- Cards with rounded corners, white backgrounds, subtle shadows
- Cards inside cards (e.g., individual features in cards inside a parent card section)
- All cards identical in structure (same icon position, same padding, same layout)

**Severity**: P0 for nested cards or 3-column card grid with overused fonts. P1 for standard card grid. P2 for a single card section.  
**Fix**: Flatten the hierarchy. Use spacing, dividers, and typographic contrast instead of containers.

## Monotonous Spacing

Every element uses the same spacing value — no variation in rhythm between grouped vs separated items. AI models tend to use one spacing scale everywhere.

**Severity**: P1 if spacing is visibly uniform across unrelated element groups. P2 at the edges.  
**Fix**: Use tight groupings for related items and generous separations between sections. A proper spacing scale (4, 8, 16, 24, 48, 80) creates rhythm.

## Bounce / Elastic Easing

Bounce and elastic easings on interactions feel dated and are an AI default. Real objects decelerate smoothly.

**Severity**: P1 for bounce/elastic on primary interactions. P2 on decorative elements.  
**Fix**: Use exponential easing (ease-out-quart/quint/expo) for most motion.

## Dark Mode with Glowing Accents

Dark backgrounds paired with colored box-shadow glows. The default "cool" look that AI models reach for on dark themes.

**Severity**: P0 if combined with AI color palette. P1 standalone.  
**Fix**: Use subtle, purposeful lighting — or drop the dark theme entirely if it's there just for effect.

## Italic Serif Display Headline

Oversized italic serif (Fraunces, Recoleta, Playfair Display, Newsreader italic) as the primary hero headline. Reads as tasteful in isolation but has become the universal AI-startup landing page hero.

**Severity**: P1 for italic serif hero combined with other patterns. P2 as standalone.  
**Fix**: Set roman, or move to a serif sans display face. Only use italic serif in editorial/magazine contexts where it's intentional.

## Oversized Hero Headline

A full-sentence headline set at display size that dominates the viewport and leaves no room for anything else above the fold.

**Severity**: P1 if the headline is over 8 words AND set at display size (4rem+).  
**Fix**: Tighten the headline to 1-3 words if set large, or lower the font size if it needs the word count.
