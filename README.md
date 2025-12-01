# Advent of Zig 2025

This project contains solutions for [Advent of Code](https://adventofcode.com/2024)
challenges, implemented in Zig `0.15.2`.
Each day has dedicated executables for running and benchmarking solutions.

## Requirements

- Tested exclusively with **Zig 0.15.2**: [Download here](https://ziglang.org/download/#release-0.15.2)
- For benchmarking: Install `hyperfine` on your system
  (e.g., `sudo pacman -S hyperfine` on Arch Linux)

## Setup

Use the provided `.envrc` file for `direnv` integration:

```direnv
PATH_add "$HOME/prefixes/zig-x86_64-linux-0.15.2"
```

Adjust the path to match your Zig installation prefix, then run `direnv allow`.

## Download Inputs

Use the `download.fish` script to fetch puzzle inputs:

```bash
# Download all inputs
./download.fish
Please enter your session cookie:
read> ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
Enter day number (1-12) or `all` for all days:
> all
Now downloading `https://adventofcode.com/2024/day/1/input` to `src/day_01/input`
[...]
Now downloading `https://adventofcode.com/2024/day/12/input` to `src/day_12/input`

# Download specific day
./download.fish
Please enter your session cookie:
read> ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
Enter day number (1-12) or `all` for all days:
> 3
Now downloading `https://adventofcode.com/2024/day/3/input` to `src/day_03/input`
```

## Build Commands

Run `zig build` for these steps:

```console
install (default)            Copy build artifacts to prefix path
uninstall                    Remove build artifacts from prefix path
run-day_01                   Run day_01 executable
benchmark-day_01             Benchmark day_01 executable with hyperfine
[... and so on for days 02-12 ...]
run-day_12                   Run day_12 executable
benchmark-day_12             Benchmark day_12 executable with hyperfine
```

**Examples:**

```bash
# Run day 1 solution
zig build run-day_01

# Benchmark day 1 (requires hyperfine)
zig build benchmark-day_01
```

## Structure

```bash
├── src/
│ ├── day_01/
│ │ ├── day_01.zig
│ │ └── input
│ ├── day_02/
│ │ ├── day_02.zig
│ │ └── input
│ └── ... (days 03-12)
├── build.zig
├── .envrc
└── download.fish
```

Each `src/day_NN/day_NN.zig` implements both parts of the puzzle.
Inputs are expected in `src/day_NN/input`.

## Quick Start

```bash
# Setup environment
direnv allow

# Download inputs
./download.fish

# Run a specific day
zig build run-day_01

# Run a specific benchmark
zig build benchmark-day_01
```
