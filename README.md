# Space Station 13 (late 2003)

Source code for a late-2003 version of **Space Station 13**, the BYOND game (world name `Space Station 13`, hub `Exadv1.spacestation13`, project name `cellautomata`).

The original source code of this version is not available. This source was recovered by decompiling the compiled game files from [Glloyd/Pre-Open-SS13-Host-Files-and-Source](https://github.com/Glloyd/Pre-Open-SS13-Host-Files-and-Source) (`SS13 - Late 2003/cellautomata`):

- `cellautomata.dmb`, the compiled world (154,533 bytes)
- `cellautomata.rsc`, the packed resources (263,542 bytes)

Compiling this source with **BYOND 334** (the 2003 version) produces a `.dmb` that is a **bit-perfect copy** of the original `cellautomata.dmb`.

## About the decompilation

The source was not only decompiled but also laid out so that BYOND 334 compiles it back to the exact same bytes. That means more than getting the code right: the `.dmb` also records the order of every string, variable, type and proc, plus the line number of every proc, and all of those depend on how the source is written and arranged.

**What is exact:** every byte of the compiled `.dmb`, including the code, strings, variables, types, procs and their line numbers, the map, and the resource list.

**What is a best guess:** some spellings compile to the same bytes whichever way you write them, so the bytes can't tell us which one the original author used. Examples are the declared types of some local variables, `W as obj` versus `obj/W`, one-line `{ }` blocks and `;`-separated lines, one-line versus indented settings, the order of settings that don't involve strings, and blank lines. The original source may have looked different in those places. This source is one of the sources that produce the exact file.

**Icons:** all 30 icons in `rsc/` were extracted from the original `cellautomata.rsc` and are the genuine 2003 files. Each one matches the checksum the original `.dmb` expects.

**The `.rsc`:** compiling also produces a new `cellautomata.rsc`. The 30 files inside it are identical to the original's, but the `.rsc` file as a whole is not. The record order and timestamps differ, and the original also contains leftover space and older, deleted copies of some icons.

## What's in the repository

| Path | Contents |
|---|---|
| `cellautomata.dme` | Project file; open this in Dream Maker |
| `*.dm` | Decompiled DM source code |
| `cellautomata.dmp` | The station map |
| `rsc/` | Icons (`.dmi`) extracted from the original `cellautomata.rsc` |
| `BYOND334-ModernWindows.zip` | Start files that let BYOND 334 run on modern Windows (see below) |

Compiled output (`.dmb`, `.rsc`) and BYOND's `.lk` lock files are not tracked.

## Running BYOND 334 on modern Windows

BYOND 334 is from 2003, and on current Windows its programs crash at startup, freeze while hosting, or never finish connecting. `BYOND334-ModernWindows.zip` contains start files and a small Python helper that fix these problems in memory while the programs run. No BYOND file and no game file is changed.

You need:

- BYOND version 334 (a folder with `bin\dreammaker.exe`, `bin\dreamdaemon.exe`, `bin\dreamseeker.exe`, `bin\byond.dll`, ...)
- Python 3, 64-bit, added to PATH

Extract the zip into your BYOND 334 folder, so that `BYOND334-ModernWindows` sits next to `bin`. The `README.txt` inside the zip has full instructions.

## Building

1. Drag `cellautomata.dme` onto `Compile (Dream Maker 334).bat`.
2. In Dream Maker, choose **Build > Compile**.

This creates `cellautomata.dmb` and `cellautomata.rsc` next to the `.dme`.

To check the build, compare your `cellautomata.dmb` with the original. The original's checksums are:

```
MD5      08926c41d7f94e18a52840d8637ce7b8
SHA-256  e8108a8c3645260e968c29a6d8953f11f2d17ea20c34b5eccf60de08e22f31c7
```

Dream Maker rewrites `cellautomata.dme` when it opens it: it saves it with Windows (CRLF) line endings, and may add a block of its own settings at the top. Git may then show the file as modified. Neither change affects the compiled `.dmb`.

## Playing

- **Single-player:** drag `cellautomata.dmb` onto `Play single-user (Dream Seeker 334).bat`.
- **Hosting:** drag `cellautomata.dmb` onto `Host world (Dream Daemon 334).bat`. It hosts on port 5000.
- **Joining:** run `Join server (Dream Seeker 334).bat` and enter the host's address, for example `192.168.1.20:5000`.

The game runs slowly on the 2003 engine (about 2 game ticks per second). That is how the original engine behaves.
