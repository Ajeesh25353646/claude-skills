# Copy / Text AI Fingerprints

Reference file for the copy-audit mode of the AI Audit skill. Contains the detectable patterns of AI-generated prose.
Load this file when auditing text content.

## Em Dash Overuse

AI models default to em dashes (— or `--`) as a way to create dramatic pauses and asides. Human writers use them sparingly.

- **Rule**: More than 2 em dashes in body copy (headings are less suspicious) is a strong AI tell.
- **Severity**: P0 if 3+ in body text. P1 if exactly 2. P2 if 1.
- **Fix**: Replace with commas, colons, periods, or parentheses — most em dashes can simply be removed or turned into separate sentences.

## Forced Transitional Phrases

These phrases are AI filler that pad word count without adding substance. They're almost never used in human-written web copy or documentation.

- "Let's dive in"
- "Delve into"
- "In today's fast-paced world"
- "In today's digital landscape"
- "In an era where"
- "It's worth noting that"
- "It is important to note that"
- "Navigate the landscape"
- "At [company/product], we believe"
- "Questions? [Contact us / Reach out]" (when used as a section header)
- "Without further ado"
- "Let's take a closer look"
- "A closer look reveals"
- "Have you ever wondered"
- "The truth is that"
- "The fact of the matter is"

**Severity**: P0 for 2+ occurrences, P1 for 1.  
**Fix**: Delete the filler phrase. Start the sentence at the substantive part.

## Marketing / Sales Buzzwords

Certain words cluster in AI-generated marketing copy because models were trained on SaaS landing pages.

- "Streamline"
- "Empower" / "Empowering"
- "Supercharge"
- "Revolutionize" / "Revolutionary"
- "Cutting-edge"
- "Game-changer" / "Game changing"
- "World-class"
- "Next-generation"
- "Enterprise-grade"
- "Seamless" / "Seamlessly"
- "Robust"
- "Unlock" (as in "unlock potential")
- "Harness" (as in "harness the power of")
- "Leverage" (as in "leverage our platform")
- "Best-in-class"
- "Industry-leading"

**Severity**: P0 for 3+ in a page, P1 for 1-2, P2 for single occurrence in otherwise clean copy.  
**Fix**: Replace with specific, concrete language. Say what the product *actually does* instead of what it *claims to do*.

## Aphoristic Cadence

Short punchy sentences that contrast two things or use a "X. Not Y." or "X. Just Y." pattern. One is fine. When multiple sections land on this structure, it's a clear AI cadence pattern.

Patterns to detect:
- "X. Not Y." / "X. No Y." — "Build. Not plan." "Create. Not configure."
- "X. Just Y." — "A tool. Just a tool."
- "Not a [noun]. A [noun]." — "Not a platform. A paradigm." "Not a feature. A framework."
- Sequential one-word imperatives: "Build. Ship. Iterate." "Design. Develop. Deploy."
- Parallel sentence openings where every paragraph starts identically

**Severity**: P0 for 3+ instances, P1 for 2, P2 for 1.  
**Fix**: Rewrite for variety. Mix sentence structures. Let one or two land for emphasis; don't make it the page's voice.

## Fluff / Padding

These phrases add no information and bulk text to meet length. They're markers of a model that was prompted to "write a detailed page."

- "It should come as no surprise that"
- "It goes without saying that"
- "It is important to emphasize that"
- "In conclusion"
- "To sum it up"
- "As previously mentioned"
- "As we have seen"
- "Needless to say"
- "That being said"

**Severity**: P1 for any occurrence (these are almost never in human web copy).  
**Fix**: Delete the phrase entirely. The surrounding text is stronger without it.

## Overly Complex Sentence Structure

AI models produce sentences that are grammatically correct but unnaturally dense:
- Sentences over 30 words that pack multiple clauses
- Three or more commas in a single sentence
- Stacked prepositional phrases ("of the X in the Y for the Z")
- Nominalizations turning verbs into nouns ("make an optimization" → "optimize")

**Severity**: P1 for 3+ dense sentences in a page, P2 for 1-2.  
**Fix**: Split long sentences. Cut the prepositional chain. Use active verbs.

## Structured Repetition

When every paragraph or section opens with the same grammatical structure, it reads like AI output from a template prompt. Common pattern: every section starts with "[Subject] is [adjective] and [adjective]. It [verb]..."

Another variant: every section heading follows the same formula ("Why X?" / "How X Works" / "Benefits of X") as a repeating section pattern.

**Severity**: P1 for 4+ consecutive same-structure openings, P2 for 2-3.  
**Fix**: Vary the openings. Mix statements, questions, and commands.
