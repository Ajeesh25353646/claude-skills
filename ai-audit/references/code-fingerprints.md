# Code AI Fingerprints

Reference file for the code-audit mode of the AI Audit skill. Contains the detectable patterns of AI-generated code.
Load this file when auditing source code files.

## Verbose Comments Explaining Obvious Code

AI models comment everything by default, producing comments that narrate what the code does rather than *why* it does it.
Human developers write comments for non-obvious reasoning, caveats, and context.

**Patterns to detect:**

- A comment above every single function, even trivial getters/setters
- Comments that restate the obvious: `// Add item to list` above `list.append(item)`
- Comments that explain what a language construct does: `// Loop through array` above `for item in items:`
- `// Initialize [variable]` above a variable declaration
- `// Define a class for...` above a class definition
- `// Main function` above the entry point
- ASCII art comment banners separating sections (`// ===== Section =====`)
- Docstrings that repeat what the function signature already says:
  ```python
  def get_user(id: int) -> User:
      """Get user by id. Returns User object."""
  ```

**Severity**: P0 if 5+ obvious comments across the file. P1 for 2-4. P2 for a single one.  
**Fix**: Delete comments that explain what, keep only comments that explain *why not* or *why this way*.

## Generic / AI-Style Naming

AI models default to certain variable, function, and file names. These are the `data` of AI-generated code.

**Patterns to detect:**
- `data`, `items`, `result`, `temp`, `tmp`, `obj`, `thing`, `stuff`, `helper`, `utils`
- `process_data()`, `handle_item()`, `do_something()`, `perform_action()`
- `MyComponent`, `AppComponent`, `MainPage`, `HomePage`, `AboutPage` (when the project has more specific names available)
- Type names like `ItemType`, `DataModel`, `BaseModel`, `GenericHandler`
- File names: `utils.py`, `helpers.py`, `common.py`, `types.py`, `index.ts` (when they lump unrelated things)

**Severity**: P0 if 3+ generic names appear as main constructs. P1 for 1-2.  
**Fix**: Name things for what they specifically are. A list of users is `users`, not `data`. A function that sends email is `send_email()`, not `process_item()`.

## Over-Engineering / Unnecessary Abstraction

AI models over-compensate for "write good code" prompts by adding abstraction layers that small projects don't need.

**Patterns to detect:**
- Factory pattern for a single-product project (no actual polymorphism in sight)
- Strategy/Visitor/Observer patterns where a simple if/else or callback would work
- Abstract base classes with exactly one concrete implementation
- Dependency injection containers in a 200-line script
- Interface/implementation split when there's one implementation and no planned alternative
- `BaseX` class with exactly one subclass `X(BaseX)`
- A separate interface/type file for every component in a small project

**Severity**: P0 for truly gratuitous over-engineering (factory for one product, DI container in a script). P1 for premature abstraction (abstract base with one impl). P2 for mild over-structuring.  
**Fix**: YAGNI — only abstract when you have 2+ concrete cases. For single implementations, write the concrete code directly.

## Hallucinated / Wrong Imports

AI models sometimes import packages that don't exist, are for different languages, or are the wrong version.

**Patterns to detect:**
- Packages that don't exist on PyPI/npm (models invent plausible names)
- import that's correct but from the wrong subpackage
- Import exists but the imported symbol doesn't exist in that package
- Import from a package that is in requirements but never actually used
- Using a library that exists for a different language's ecosystem

**Severity**: P0 for any hallucinated import (code won't run).  
**Fix**: Use the correct package/symbol or implement natively.

## Missing Edge Cases in Complete-Looking Code

AI-generated functions often look complete but silently skip edge case handling. This is a subtle tell because the code *looks* right on first read.

**Patterns to detect:**
- Functions with no null/None checks on required parameters
- Empty collection handling missing (what happens if the list is empty?)
- Input validation absent (string is assumed valid format)
- No try/except around IO or network calls
- No rate limit, pagination, or retry handling where obviously needed
- Error messages that are generic or absent
- No handling for edge values (negative numbers, zero, max int, Unicode)

**Severity**: P0 for missing error handling on critical paths. P1 for missing edge cases on regular paths.  
**Fix**: Add null checks, empty-handling, input validation, and error recovery to all exposed functions.

## Dead Code / Unreachable Paths

AI models sometimes generate code that contains branches that can never execute or variables that are assigned but never read.

**Patterns to detect:**
- Variables assigned but never referenced again
- `if` conditions that are always true or always false
- `else` blocks after `return` or `raise`
- Functions defined in a module but never called within and not exported
- Imports that are never used

**Severity**: P1 for unreachable branches. P2 for unused variables/imports.  
**Fix**: Remove dead code. Use linters (pyright, ESLint, ruff) to catch these automatically.

## Uniform but Unnatural Code "Voice"

Human-written code has more variation in style than AI-generated code. AI output is uniformly formatted, uniformly commented, and uniformly structured in a way that feels like one person wrote every line at once.

**Patterns to detect:**
- Every function follows the exact same structure (docstring → type annotations → guard clause → body → return)
- Identical spacing patterns in every block (no allowances for different logical complexity)
- All error messages use the same grammatical form
- Every comment is exactly "// [verb] [noun]" — no variation
- The entire file reads like one author wrote it in one sitting without iteration

This is the hardest to detect programmatically and the easiest to feel on read. Trust your sense of "this is too uniform."

**Severity**: P2 (advisory) — flag it but let the developer decide.  
**Fix**: Vary code structure to match the complexity of each specific problem. A 3-line function doesn't need the same scaffolding as a 50-line one.
