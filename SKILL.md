---
name: pr-reviewer
description: Review a GitHub pull request or the local branch diff against Steve's code-review checklist (naming, lint, CI, PR description, tests, style, comments, spelling, security, error handling, PR size, dead code, DRY). Use when asked to review a PR, review branch changes, or give a pre-merge opinion. Given a PR number or URL, review that PR via gh; otherwise review the local branch diff.
---

# PR Reviewer — Steve style

Review code changes the way Steve would: pragmatic, idiom-aware, and focused on
things that actually matter. Tests and correctness are non-negotiable; style
dogma is not.

## 1. Pick the target

- **A PR number or URL was given** → PR mode. First confirm `gh auth status`
  succeeds — if not, stop and tell the human to run `gh auth login` instead of
  attempting the review. Then use `gh pr view <n>` for the description,
  `gh pr diff <n>` for the diff, `gh pr checks <n>` for CI. If the PR is a
  draft (`gh pr view <n> --json isDraft`), still review it but note the draft
  status up front so expectations are set.
- **No PR referenced** → local mode. Diff the current branch against the merge
  base with the default branch. Resolve the base explicitly — do **not** trust
  a bare `origin/HEAD`, which is often unset and fails silently inside command
  substitution:

  ```bash
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD \
    || git rev-parse --verify --quiet origin/main \
    || git rev-parse --verify --quiet origin/master \
    || git rev-parse --verify --quiet main \
    || git rev-parse --verify --quiet master)
  ```

  Confirm `$base` is non-empty and `git merge-base HEAD "$base"` succeeds
  before diffing; if either fails, say so rather than reviewing a wrong or
  empty diff. Include uncommitted changes in the review.
- In local mode, skip the CI and PR-description checks — note that they were
  skipped so the human knows they still apply before merging.

## 2. Gather context

Before judging anything, collect:

- The full diff and the list of changed files.
- The repo's tooling config: linters, formatters, type checkers, test setup
  (e.g. `pyproject.toml`, `ruff.toml`, `.eslintrc*`, `checkstyle.xml`,
  `.golangci.yml`, `Makefile`/`justfile`/`package.json` scripts, CI workflow
  files under `.github/workflows/`).
- The PR template, if one exists (`.github/PULL_REQUEST_TEMPLATE*`,
  `PULL_REQUEST_TEMPLATE*`, `docs/PULL_REQUEST_TEMPLATE*`).
- Enough surrounding code to judge changes in context — review the diff, but
  read the touched files where the diff alone is ambiguous.

## 3. The checklist

Grade every finding into one of three tiers:

- **Blocker** — would reject the PR: broken logic, failing/absent CI, missing
  tests for changed behaviour, secrets in the diff.
- **Should fix** — expect it fixed before merge, but wouldn't die on the hill:
  lint violations, swallowed errors, misleading names, stale PR description.
- **Nit** — take it or leave it: minor naming, comment polish, small style
  points. Prefix with "Nit:" so it's skimmable.

The tiers listed per check below are defaults — use judgement when the impact
is clearly higher or lower.

### Naming (Should fix / Nit)

Names must be meaningful and follow the language's conventions — Python things
pythonic (`snake_case`, no Java-style getters), Java things Java-ish
(`camelCase`, conventional bean names), and so on for each language.

The bar: **would a reader pause or guess wrong?** Flag names that mislead,
over-abbreviate, or say nothing (`data2`, `tmp`, `handleStuff`, `mgr`). Stay
silent on names that are merely improvable — do not carpet the review with
naming nits. `i`/`j` are fine for simple loop counters; single letters are fine
where convention blesses them (`e` in a short except clause, `k, v` over items).

### Lint & static analysis (Should fix; Blocker if CI enforces it)

If the repo has lint/format/type-check config, the diff must come up clean
against it:

- Run the configured tools **locally on the changed files** (e.g.
  `ruff check`, `eslint`, `mypy`, `golangci-lint run`, `mvn checkstyle:check`)
  and report violations with file:line.
- **PR mode caveat**: local tools see the checked-out working tree, not the PR.
  Only run them if the working tree is clean and you have checked out the PR's
  code (`gh pr checkout <n>`; return to the original branch afterwards). If
  the working tree is dirty or checkout isn't possible, skip local analysis,
  rely on CI, and say so.
- In PR mode, **also** check CI lint jobs — a local pass with a red CI lint job
  (or vice versa) is itself a finding.
- Respect the repo's config files; do not impose rules the repo hasn't adopted.
- If tools can't run locally (missing deps, no environment), say so and rely on
  CI rather than guessing.

### CI (Blocker) — PR mode only

`gh pr checks` must be green. Failing checks are a Blocker; pending checks mean
the review verdict is provisional — say so. No CI configured at all is worth a
Should-fix note suggesting some.

### PR description (Should fix) — PR mode only

The description must be accurate and match the actual diff — flag descriptions
that describe changes not present, or miss significant changes that are. If
the repo has a PR template, the description should follow it, with sections
actually filled in rather than left as boilerplate.

### Testing (Blocker when behaviour changed)

- Code changes must come with test changes in all but the rarest cases
  (pure comment/doc changes, mechanical renames). Changed behaviour with
  untouched tests is a Blocker — either the tests are missing or they weren't
  actually exercising the code.
- If the repo has no tests for the touched area, suggest specific ones where
  applicable.
- Prefer mature, well-known frameworks that do the heavy lifting over
  hand-crafted mocks — e.g. `moto`, `responses`/`requests-mock`, `freezegun`
  for Python. Consult [references/test-frameworks.md](references/test-frameworks.md)
  for the curated list per language — it lives alongside this SKILL.md in the
  skill's own directory, not in the repo under review. If the stack in the diff isn't covered
  there, search the web for a mature, well-rated option before recommending
  anything. Flag hand-rolled mock scaffolding where a standard library would
  make the tests cleaner.

### Style (Nit)

Match the language's idioms and norms — comprehensions over index loops in
Python, streams where natural in Java, early returns over arrow-shaped nesting.
But be lenient on dogma that doesn't earn its keep: 80-char lines, one-class-
per-file zealotry, cargo-culted patterns. If the linter doesn't care and it
reads fine, let it go.

### Comments (Should fix / Nit)

- Convoluted blocks — dense logic, non-obvious algorithms, workarounds — should
  carry a comment explaining the **why**, not the what.
- Flag comments that merely repeat the code (`# increment counter`), and
  comments the diff has made stale or wrong (worse than no comment).

### Spelling & grammar (Should fix / Nit)

- Typos in **identifiers and public API names** are Should fix — they
  propagate into every call site and haunt the codebase forever
  (`recieve`, `seperate`, `initalize`).
- Typos and grammar slips in comments, docstrings, docs, log messages, and
  the PR description are Nits — flag them, but briefly.
- **User-facing strings** (UI text, error messages shown to end users) get the
  Should-fix bar: those typos ship.
- Match the dialect the codebase already uses (British vs American English);
  don't flag consistent use of either.

### Security basics (Blocker)

Cheap to check, embarrassing to miss: credentials/API keys/tokens committed in
the diff, obvious injection (string-built SQL/shell commands from user input),
disabled TLS verification, secrets logged.

### Error handling (Should fix)

Swallowed exceptions, bare `except:`, ignored error returns, missing cleanup
(unclosed resources where a context manager / try-with-resources / defer
belongs), errors caught and reduced to a log line where the caller needed to
know.

### PR size & atomicity (Should fix)

If the PR does several unrelated things or is too large to review honestly,
say so and suggest how to split it. Review what's there anyway — flagging size
is not an excuse to skim.

### Dead code & debug leftovers (Should fix)

Commented-out blocks, stray `print`/`console.log`/debug logging, leftover
`TODO remove`, unused imports and variables the linter didn't catch.

### DRY (Should fix / Nit)

Flag copy-paste duplication the diff introduces — within the diff itself, or
duplicating an existing helper the author apparently didn't find. Apply the
rule of three: two similar blocks may be coincidence; don't demand premature
abstractions that make the code harder to read than the duplication did.

## 4. Report

Structure the review as:

1. **Verdict** — one line: approve / approve with nits / request changes, plus
   a one-sentence summary of the change as you understood it.
2. **Blockers**, **Should fix**, **Nits** — in that order, each finding with
   `file:line` and, where useful, a concrete suggested fix. Omit empty tiers.
3. **Skipped checks** — anything not run (no CI in local mode, linter couldn't
   execute) so the human knows what's still unverified.

Be specific and honest: if the change is good, say so briefly and don't
manufacture findings to look thorough. If nothing survives, an approval with
zero findings is a valid review.

## 5. Posting to GitHub (PR mode)

Nothing gets posted without the human seeing it first — **no exceptions**:

1. **Preview first, always.** Show the exact content that would be posted:
   the review summary/verdict, and every inline comment with its
   `file:line` anchor and full body, formatted as it will appear on GitHub.
2. **Wait for explicit approval.** Only post after the human confirms; apply
   any edits they ask for and re-show anything that changed materially. If
   they don't want it posted, the terminal review from section 4 stands on
   its own.
3. **Post findings as inline comments**, anchored to the relevant diff line —
   not as one monolithic comment. Submit everything as a single review so it
   arrives as one notification:

   ```bash
   # event is APPROVE / REQUEST_CHANGES / COMMENT per the verdict
   gh api repos/{owner}/{repo}/pulls/{n}/reviews \
     -f body='<summary + any findings that have no diff anchor>' \
     -f event='COMMENT' \
     -f 'comments[][path]=<file>' -F 'comments[][line]=<line>' \
     -f 'comments[][side]=RIGHT' -f 'comments[][body]=<finding>' ...
   ```

   Inline comments can only attach to lines present in the diff; findings
   about untouched code, or repo-wide points (missing CI, PR size), go in the
   review body instead. Prefix nits with "Nit:" in the comment body so the
   author can triage at a glance.
