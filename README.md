# A Practical Guide to BitBake — 2026 Edition

A practical standalone BitBake tutorial updated and tested with:

* BitBake 2.18.0
* Python 3.14.4
* Ubuntu 26.04

The tutorial starts with the smallest possible BitBake project and introduces recipes, tasks, classes, layers, `.bbappend` files, configuration includes, and variables step by step.

## Read the Tutorial

[Read the complete tutorial](A-Practical-Guide-to-BitBake-2026.md)

## Practical Examples

The chapter directories contain the completed project at each stage of the tutorial:

* `ch04` — Minimal BitBake project
* `ch05` — First recipe
* `ch06` — Classes and functions
* `ch07` — Multiple layers
* `ch08` — Class inheritance, append files, and includes
* `ch09` — Global and recipe-local variables
* [ch10](ch10) — Overrides, operators, and task flags ([chapter](docs/ch10.md))
* [ch11](ch11) — Task dependencies and ordering ([chapter](docs/ch11.md))
* [ch12](ch12) — Fetching and unpacking sources ([chapter](docs/ch12.md))
* [ch13](ch13) — Patching sources ([chapter](docs/ch13.md))
* [ch14](ch14) — Configuring, compiling, and installing ([chapter](docs/ch14.md))

Each chapter contains its own `build` directory and the layers required for that stage.

## Using the Examples

First install BitBake 2.18.0 as explained in the tutorial.

You can then enter a chapter’s build directory and run BitBake:

```bash
cd ch05/build
bitbake -s
bitbake first
```

Always run BitBake commands from the chapter’s `build` directory.

The optional `bbenv.include` file can configure the current terminal when BitBake is stored elsewhere:

```bash
export BITBAKE_ROOT_DIR=/path/to/bitbake-2.18.0
source bbenv.include
```

## Acknowledgment

This edition follows the learning sequence of Harald Achitz’s original [A Practical Guide to BitBake](https://a4z.noexcept.dev/docs/BitBake/guide.html).

The examples and instructions were updated and validated for BitBake 2.18.0 and Python 3.14.4 by Adn Elkawas.
