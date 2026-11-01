---
name: spreadless
description: Maintain spreadless dwl and slstatus patch queues, subsystem configuration, Nix packages, Home Manager modules and upstream upgrades.
---

# spreadless maintenance

## Program references

Read [dwl](references/dwl.md) for compositor changes and [slstatus](references/slstatus.md) for status components. Each reference contains its patch ownership map and build details.

## Source ownership

- `upstream/PROGRAM/` is a read-only Git submodule. Advance its checked-out revision only for an upstream upgrade; do not edit or commit source there.
- `patches/PROGRAM/` is a two-level `NN-group/NN-name.patch` series. The selected worktree is `.worktree/PROGRAM/`; both programs may have active queues.
- `nix/packages/` owns installable packages, `nix/home-manager/` owns consumer options, and `nix/lib/` contains shared patch discovery and `config.h` generators (`dwl-config.nix` and `slstatus-config.nix`).
- `scripts/spreadless-queue` owns Git queue operations. `scripts/build/PROGRAM` compiles the selected queue using `config.def.h` and removes build artifacts. `verify` runs it after every commit.
- Workspace instructions belong in `flake.nix`; this skill and its references belong in `skills/spreadless/`. NAW generates workspace instructions and installed skill links.

## Queue rules

1. Organize each program's queue into contiguous functional groups (`NN-group/`), with low-coupling, high-cohesion capability patches (`NN-name.patch`) inside each group. Find the owning patch before editing; fold changes into that patch rather than appending follow-up fixups.
2. Keep each patch's code, declarations, `config.def.h` defaults and documentation together. Split changes spanning several patches or groups, even when they touch the same files. Cross-program changes update each program's queue separately.
3. Add a new patch within the appropriate group for a distinct mechanism, extension or bug fix, placed after its dependencies. Update the selected reference's ownership map when boundaries change. Preserve community authorship, source links and license notices.
4. Do not track `config.h` in Git. Feature patches update `config.def.h` with minimal default declarations so every commit compiles standalone; Nix generates the complete `config.h` at package build time.
5. Subjects use `group/name: English summary` without a commit-type prefix. Both `group` and `name` start with a letter, use one or two lowercase words separated by a hyphen, may include digits, and contain at most 24 characters. Review boundaries rather than truncating long names.
6. Export derives `NN-group/NN-name.patch` paths from `group/name` scopes. Before replacing patches, it rejects missing, invalid, overlong or duplicate scopes and non-contiguous groups. Fold fixups before exporting. Every commit must compile.

## Update an existing patch

Run queue operations inside `nix develop "path:$PWD"`. Set `program` to `dwl` or `slstatus`.

```sh
program=dwl
spreadless-queue "$program" checkout
upstream_rev="$(git -C "upstream/$program" rev-parse HEAD)"
worktree=".worktree/$program"
git -C "$worktree" log --oneline --reverse "$upstream_rev..HEAD"
```

Set `patch_commit` to the owning commit's hash. Edit the selected worktree and run `spreadless-queue "$program" build`. Stage only the owning patch's changes, using `git add -p` for shared files. Amend the owner if it is `HEAD`; otherwise create a fixup:

```sh
git -C "$worktree" commit --fixup "$patch_commit"
GIT_SEQUENCE_EDITOR=true git -C "$worktree" rebase -i --autosquash "$upstream_rev"
spreadless-queue "$program" verify
spreadless-queue "$program" export
spreadless-queue "$program" clean
```

Create a new `group/name: summary` commit only for a distinct patch, then use `git -C "$worktree" rebase -i "$upstream_rev"` to place it inside its contiguous group after its dependencies. After conflicts, inspect code and `config.def.h`, compile the paused state, and continue the Git rebase. Keep patches in the selected program's directory.

## Upgrade upstream

Reconstruct the queue before advancing the selected upstream revision. After the requested upgrade, run `spreadless-queue "$program" rebase`; it uses the recorded checkout base. Resolve conflicts and compile before continuing. Update the owning package version and the dwl branch in `.gitmodules` when changing release branches. Finish with `verify`, `export` and `clean`.

## Validation and cleanup

- Format modified Nix and shell files. Run ShellCheck on `scripts/spreadless-queue` and both build scripts, and run `git diff --check`.
- Build `spread-dwl` and `spread-slstatus`, and run `nix flake check --no-write-lock-file "path:$PWD"`. Preserve existing package names, binary names and option paths.
- After queue changes, verify every selected commit and confirm export/checkout preserves the final source tree. Check that operations leave the other program's queue unchanged.
- Remove all `.worktree/PROGRAM/` directories before delivery and keep both upstream submodules clean. Follow the workspace Nix Switch Policy and never execute activation scripts.

## Clean Delivery Policy

- Deliver only the files, dependencies, configuration, and behavior needed for the requested result. Before finishing, actively review the working tree and clean up this task's temporary tests, fixtures, validation reports, logs, caches, intermediate outputs, and debug code or settings. Do not leave cleanup for the user.
- Testing during development is encouraged, but temporary unit tests and other verification scripts belong outside the repository and must be removed after use. Keep tests in the delivered project only when the user explicitly asks to retain them. Remove test-only helpers, command-line options, and documentation references as well.
- Prefer temporary, isolated environments such as `nix shell` or `nix develop` for tools needed only for testing. Remove packages and dependencies added solely for development, testing, or debugging from persistent configuration and profiles when they are not needed by the delivered result.
- Stop temporary processes and services, undo temporary environment or configuration changes, and remove temporary files created for this task, including those outside the repository. Preserve anything that is part of the requested result.
- Limit cleanup to changes and resources introduced by this task. Preserve the user's existing tools, data, tests, and unrelated modifications. Do not delete shared Nix Store contents or run broad garbage collection as a cleanup shortcut.
- Cleanup must respect the Nix Switch Policy. If removing a live dependency or other temporary state requires a prohibited action, prepare the configuration change, report exactly what remains, and provide the manual command; do not execute `switch` or claim cleanup is complete.
