# Roadmap: Standalone BitBake Concepts

The tutorial builds on the small `bbTutorial` project without Poky, Yocto,
OpenEmbedded-Core, a cross-toolchain, or an image build. Each chapter should
provide a runnable example in its own `chNN/` snapshot, explain the metadata
and task graph involved, and verify the expected behavior with BitBake 2.18.

Upstream BitBake supplies the parser, scheduler, fetcher, signatures, and
command-line tools. OpenEmbedded-Core supplies many familiar recipes, classes,
tasks, and variables. Where a concept normally uses an OpenEmbedded-Core class,
the tutorial must implement the small amount of task wiring needed for the
standalone example rather than claiming BitBake provides that class or task.

- [x] **Ch 10 — Overrides, operators, and task flags** ([chapter](docs/ch10.md), [snapshot](ch10))
  - Exercise `OVERRIDES`, `:append`, `:prepend`, `:remove`, and assignment timing
    with `bitbake -e` and a small runnable recipe.
  - Explore `[nostamp]`, `[dirs]`, and `[cleandirs]` by rerunning tasks and
    checking their logs and directories.
  - Show a short anonymous Python example and datastore access.

- [x] **Ch 11 — Task dependencies and ordering** ([chapter](docs/ch11.md), [snapshot](ch11))
  - Use `addtask ... before/after` and a direct `[depends]` edge between recipes.
  - Inspect `bitbake -g`, `task-depends.dot`, and `bitbake -e`.
  - Explain that setting `DEPENDS` alone does not wire tasks in this minimal project.

- [x] **Ch 12 — Fetching and unpacking sources** ([chapter](docs/ch12.md), [snapshot](ch12))
  - Introduce `SRC_URI`, `DL_DIR`, `WORKDIR`, and the BitBake fetcher.
  - Define and order small `do_fetch` and `do_unpack` tasks explicitly; bare
    BitBake's `base.bbclass` does not provide them.
  - Start with a local source and then demonstrate a pinned remote archive or
    Git revision, including checksum/revision checks and an offline option.

- [ ] **Ch 13 — Patching sources**
  - Add an explicitly ordered `do_patch` task to a fetched/unpacked example.
  - Explain how `file://` sources are found through `FILESPATH`, and verify
    the patch changes the working tree; introduce search-path customization
    only where the example requires it.
  - Distinguish BitBake's fetch/parse behavior from patch conventions supplied
    by OpenEmbedded-Core.

- [ ] **Ch 14 — Configuring, compiling, and installing**
  - Define the `do_configure` → `do_compile` → `do_install` task chain in a
    tutorial class, using a tiny host-compiled program.
  - Show `S`, `B`, `WORKDIR`, and a destination directory for output; inspect
    task logs and the generated files.
  - Explain that cross-toolchain setup and sysroot staging are out of scope.

- [ ] **Ch 15 — Task outputs and cross-recipe dependencies**
  - Have one recipe produce a file and another consume it through an explicit
    task dependency, verifying both the graph and the output.
  - Contrast task-level `[depends]` with `[deptask]` and `[rdeptask]` only after
    defining the tasks needed to make each example meaningful.
  - Do not present OE-Core package splitting, `do_package`, or package-manager
    backends as built-in BitBake behavior.

- [ ] **Ch 16 — Stamps, signatures, and incremental builds**
  - Demonstrate when a task is skipped or rerun after a metadata or input
    change, using stamps and `bitbake -S`/`bitbake-diffsigs` where available.
  - Explain the difference between BitBake's task signatures and the
    shared-state cache implemented by OpenEmbedded-Core; do not promise an
    sstate cache in this minimal project.

- [ ] **Ch 17 — Providers and selecting recipes**
  - Demonstrate `PROVIDES`, `PREFERRED_PROVIDER`, and `PREFERRED_VERSION` with
    two small standalone implementations of the same target.
  - Inspect how BitBake resolves a virtual target and handles ambiguity or
    missing providers.
  - Avoid OE-Core-specific `native`/`nativesdk` behavior unless a separate,
    explicitly implemented example is added.

- [ ] **Ch 18 — Events, hooks, and diagnostics**
  - Add task pre/post functions and filtered event handlers.
  - Distinguish parse, cooker, and worker contexts; exercise logging and a
    deliberate failure with recovery.

- [ ] **Ch 19 — Multiple configurations**
  - Use `BBMULTICONFIG`, separate output directories, and `[mcdepends]`.
  - Verify an artifact crossing configuration boundaries without a toolchain.

- [ ] **Ch 20 — Advanced metadata and layer selection**
  - Exercise deferred inheritance, custom `BBCLASSEXTEND` variants, masking,
    and conditional layer metadata.
  - Keep recipe cloning distinct from OE-Core's native/nativesdk classes.

## Review decisions

The original eight chapters are retained. The three additional chapters close
important standalone gaps; the summary moves to **Chapter 21**. Chapter 12 is
offline-first and makes remote access opt-in. Chapter 15 implements actual task
relationships before introducing dependency flags. Chapter 16 explicitly
selects a hashing policy rather than assuming an OE-Core configuration.

Every implementation includes a cumulative `chNN/` snapshot, linked chapter
text, and a runnable `tests/check-chNN.sh`. Each chapter is a separate commit.
This covers the major user-facing concepts, not every fetcher backend, internal
API, or production policy. Hash equivalence, setscene/sstate policy, packaging,
sysroots and cross-toolchains are distinguished from this minimal build, not
simulated as a Yocto distribution or bootable image.
