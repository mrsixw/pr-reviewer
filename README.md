# pr-reviewer

Reviews PRs, Steve style. A code-review skill for coding agents (Claude Code,
agy/Antigravity) that checks a diff against the things Steve actually picks up
in review, graded as **Blocker / Should fix / Nit**.

Point it at a change request (number or URL) and it reviews it — diff, CI
status, and description included — via the forge's tooling. It isn't tied to
GitHub: GitHub, GitLab, Gitea/Forgejo/Codeberg, Bitbucket, Azure DevOps,
SourceForge, and even mailing-list patch workflows are covered, over git, hg,
bzr, svn, or fossil (see
[references/tools.md](references/tools.md)). With no change request referenced
it reviews the local working-copy diff against the mainline and tells you
which forge-only checks still apply before merging.

## What it checks

- **Naming** — meaningful, language-idiomatic names; flags names a reader
  would pause on, not every improvable one
- **Lint / static analysis** — runs the repo's configured tools on the changed
  files *and* cross-checks CI lint jobs
- **CI** — checks must be green (change-request mode)
- **Description** — accurate, matches the diff, follows the repo's template
  (change-request mode)
- **Testing** — code changes need test changes; prefers mature frameworks
  (moto, responses, freezegun, Testcontainers, …) over hand-crafted mocks
- **Style** — language idioms, lenient on dogma like 80-char lines
- **Comments** — convoluted blocks explained, comments say *why* not *what*
- **Spelling & grammar** — typos in identifiers and user-facing strings get
  flagged hardest; comment/doc typos are nits; either English dialect is fine
  if consistent
- **Security basics** — secrets in the diff, obvious injection, disabled TLS
- **Error handling** — swallowed exceptions, bare `except:`, missing cleanup
- **Size / atomicity** — flags unreviewably large or unrelated changes
- **Dead code & debug leftovers** — commented-out blocks, stray prints
- **DRY** — copy-paste duplication, tempered by the rule of three

The full checklist lives in [SKILL.md](SKILL.md); the curated test-framework
list per language is in [references/test-frameworks.md](references/test-frameworks.md).

## Installation

The repo is wired into each agent by symlinking it into that agent's global
skills directory. Clone once, then either run the installer:

```bash
git clone https://github.com/mrsixw/pr-reviewer.git "$HOME/git/pr-reviewer"
"$HOME/git/pr-reviewer/install.sh"
```

…or create the symlinks by hand:

```bash
# Claude Code
ln -sfn "$HOME/git/pr-reviewer" "$HOME/.claude/skills/pr-reviewer"

# agy (Antigravity CLI)
ln -sfn "$HOME/git/pr-reviewer" "$HOME/.gemini/config/skills/pr-reviewer"
```

Both agents resolve the symlink to the same working copy, so there is exactly
one copy of the skill to maintain. To add another agent, append its skills
directory to `SKILL_DIRS` in [install.sh](install.sh) and re-run it.

## Updating

```bash
git -C "$HOME/git/pr-reviewer" pull --ff-only
```

The symlinks keep pointing at the repo, so a pull updates every agent at once.

## Usage

Ask your agent to review something:

- `review PR 42` / `review https://github.com/owner/repo/pull/42` /
  `review MR 42` — full change-request review including CI and description
- `review my changes` (on a feature branch) — local diff review

When posting a review to the forge, the skill always shows the full content
(verdict plus every inline comment) for approval before anything is posted,
and findings land as inline comments on the relevant diff lines, submitted as
a single review where the forge supports it.

## Requirements

- The forge's CLI or API access, authenticated, for change-request mode —
  e.g. [`gh`](https://cli.github.com/) for GitHub,
  [`glab`](https://gitlab.com/gitlab-org/cli) for GitLab, `tea` for
  Gitea/Forgejo, or a REST token where no CLI exists
- The repo's VCS (`git`, `hg`, `bzr`, `svn`, …) and whatever lint/test
  tooling the target repo configures
