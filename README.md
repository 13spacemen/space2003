# Space Station 13 (late 2003)

Source code for a late-2003 version of **Space Station 13**, the BYOND game (world name `Space Station 13`, hub `Exadv1.spacestation13`, project name `cellautomata`).

The original source code of this version is not available. This source was recovered by decompiling the compiled game files from [Glloyd/Pre-Open-SS13-Host-Files-and-Source](https://github.com/Glloyd/Pre-Open-SS13-Host-Files-and-Source) (`SS13 - Late 2003/cellautomata`):

- `cellautomata.dmb`, the compiled world (154,533 bytes)
- `cellautomata.rsc`, the packed resources (263,542 bytes)

Compiling this source with **BYOND 334** (the 2003 version) produces a `.dmb` that is a **bit-perfect copy** of the original `cellautomata.dmb`.

## Branches

| Branch | Contents |
|---|---|
| [`bitperfect`](https://github.com/13spacemen/space2003/tree/bitperfect) | The decompiled source exactly as recovered. It compiles with BYOND 334 to a bit-perfect copy of the original `.dmb`, and is kept unchanged. |
| `master` | The source for modern BYOND (516). It does not compile to the original `.dmb`; use the `bitperfect` branch for that. |

To build or play the original with BYOND 334, see [The original 2003 version](#the-original-2003-version-byond-334).

## About the decompilation

The source was not only decompiled but also laid out so that BYOND 334 compiles it back to the exact same bytes. That means more than getting the code right: the `.dmb` also records the order of every string, variable, type and proc, plus the line number of every proc, and all of those depend on how the source is written and arranged.

**What is exact:** every byte of the compiled `.dmb`, including the code, strings, variables, types, procs and their line numbers, the map, and the resource list.

**What is a best guess:** some spellings compile to the same bytes whichever way you write them, so the bytes can't tell us which one the original author used. Examples are the declared types of some local variables, `W as obj` versus `obj/W`, one-line `{ }` blocks and `;`-separated lines, one-line versus indented settings, the order of settings that don't involve strings, and blank lines. The original source may have looked different in those places. This source is one of the sources that produce the exact file.

**Icons:** all 30 icons in `rsc/` were extracted from the original `cellautomata.rsc` and are the genuine 2003 files. Each one matches the checksum the original `.dmb` expects.

**The `.rsc`:** compiling also produces a new `cellautomata.rsc`. The 30 files inside it are identical to the original's, but the `.rsc` file as a whole is not. The record order and timestamps differ, and the original also contains leftover space and older, deleted copies of some icons.

## The original 2003 version (BYOND 334)

- **Source:** the [`bitperfect`](https://github.com/13spacemen/space2003/tree/bitperfect) branch. Its README explains how to build it with BYOND 334 and check the result against the original `.dmb`.
- **Original files:** the compiled `cellautomata.dmb` and `cellautomata.rsc` are in the [Pre-Decompile Host Files](https://github.com/13spacemen/space2003/releases/tag/original-2003) release.
- **BYOND 334 on modern Windows:** BYOND 334's programs crash or freeze on current Windows. The [BYOND 334 Fix Script](https://github.com/13spacemen/space2003/releases/tag/byond-334-fixer) release has start files that fix this.
