# VCS & forge tooling cheat sheet

Command equivalents for the operations SKILL.md needs: getting the diff,
resolving the base, fetching CR metadata/CI status, and posting reviews.
"CR" = change request (PR, MR, patch series — whatever the forge calls it).

## Version control systems — local mode

| VCS | Diff against mainline base | Notes |
|---|---|---|
| git | `git diff $(git merge-base HEAD "$base")` with the base-resolution snippet from SKILL.md | include `git status` for uncommitted files |
| Mercurial (hg) | `hg diff -r 'ancestor(., default)'` | mainline branch is usually `default`; `hg status` for uncommitted |
| Bazaar/Breezy (bzr/brz) | `bzr diff -r submit:` or `bzr diff -r ancestor:<parent-branch>` | `submit:` uses the configured submit branch |
| Subversion (svn) | `svn diff` for working changes; `svn diff ^/trunk ^/branches/<name>` for branch vs trunk | centralized — "uncommitted" and "branch diff" are more distinct than in DVCS |
| Fossil | `fossil diff --branch <name>` | `fossil changes` for uncommitted |

In every case: verify the base actually resolved (non-empty, command exited
zero) before trusting the diff — a silently empty base yields a wrong review.

## Forges — CR mode

| Forge | CLI | View CR / diff / CI | Inline review comments |
|---|---|---|---|
| GitHub | `gh` | `gh pr view/diff/checks <n>`; draft: `gh pr view --json isDraft`; checkout: `gh pr checkout <n>` | `gh api repos/{o}/{r}/pulls/{n}/reviews` with a `comments[]` array (`path`, `line`, `side`, `body`), one review submission |
| GitLab | `glab` | `glab mr view/diff <n>`, `glab ci status`; checkout: `glab mr checkout <n>` | `glab api projects/:id/merge_requests/:n/discussions` with `position[new_path]`/`position[new_line]` (needs `base_sha`/`head_sha`/`start_sha` from the MR's `diff_refs`) |
| Gitea / Forgejo / Codeberg | `tea` (or API) | `tea pr <n>`; API `repos/{o}/{r}/pulls/{n}` | GitHub-compatible review API: `POST /repos/{o}/{r}/pulls/{n}/reviews` with `comments[]` |
| Bitbucket Cloud | none official — use the REST API | `GET /2.0/repositories/{ws}/{repo}/pullrequests/{n}` (+ `/diff`, `/statuses`) | `POST .../pullrequests/{n}/comments` with `inline: {path, to}` per comment (no single-review batching) |
| Azure DevOps | `az repos` | `az repos pr show --id <n>` | `az repos pr ... thread` API with file path + line context |
| SourceForge | none — web/Allura API | merge request pages under the project's code tool | **no inline comments** — fall back to one structured comment on the merge request |
| Patch series by email (git send-email / LKML style) | `git`, `b4` | the patch *is* the diff; CI is whatever the list's bots report | reply to the patch email quoting the relevant hunks, comments interleaved below the quoted lines |

Where no CLI exists, prefer the forge's REST API via `curl` with the user's
existing credentials/token; never prompt interactively inside the review.

If the forge at hand isn't listed here, look up its review API rather than
degrading to a monolithic comment by default — inline-first is the rule,
monolithic is the documented fallback for forges that genuinely lack it.
