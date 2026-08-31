---
layout: default
title: A Practical Guide to BitBake
---

# A Practical Guide to BitBake

## Updated for BitBake 2.18 and Python 3.14

*Build the smallest standalone project, then learn recipes, classes, layers, appends, includes, tasks, and variables.*

|                                       |                                               |
|---------------------------------------|-----------------------------------------------|
| **Original learning path**            | Harald Achitz                                 |
| **2026 modernization and validation** | Adn Elkawas                                   |
| **Tested baseline**                   | Ubuntu 26.04 · Python 3.14.4 · BitBake 2.18.0 |

**Contents**

1.  [Preface](#1-preface)
2.  [BitBake fundamentals](#2-bitbake-fundamentals)
3.  [Setup BitBake](#3-setup-bitbake)
4.  [Create a project](#4-create-a-project)
5.  [The first recipe](#5-the-first-recipe)
6.  [Classes and functions](#6-classes-and-functions)
7.  [BitBake layers](#7-bitbake-layers)
8.  [Share and reuse configurations](#8-share-and-reuse-configurations)
9.  [Using variables](#9-using-variables)
10. [Summary](#10-summary)

## 1. Preface

### 1.1 About this tutorial

BitBake is best known as the task engine used by OpenEmbedded and the Yocto Project to build embedded Linux systems. It is powerful, but the relationship between configuration files, layers, recipes, classes, tasks, and variables is not immediately obvious.

This tutorial starts with an almost empty standalone project and adds one idea at a time. It is deliberately much smaller than a real Yocto build.

### 1.2 Target

By the end, you will be able to:

- Explain what BitBake parses and executes.
- Create a minimal build directory and layer.
- Write `.bb` recipes containing shell and Python tasks.
- Reuse tasks through `.bbclass` files.
- Configure multiple layers and their relationships.
- Extend a recipe with a `.bbappend` file.
- Distinguish `include` from `require`.
- Read global and recipe-local variables.
- Inspect recipes, tasks, layers, append matches, and logs.

This is a fundamentals tutorial. It does not attempt to build a Linux image or replace the official manual.

### 1.3 Acknowledgment and feedback

The learning sequence is inspired by Harald Achitz’s original “A Practical Guide to BitBake.” Issues for the accompanying example repository can be reported at the [BitBake guide issue tracker](https://bitbucket.org/a4z/bitbakeguide/issues).

When reporting a problem, include the OS, Python version, BitBake version, chapter, command, and complete error message.

## 2. BitBake fundamentals

### 2.1 What BitBake is

The official manual describes BitBake as a generic task-execution engine. It parses metadata, constructs a dependency graph, and runs shell or Python tasks in the required order. OpenEmbedded supplies large metadata collections on top of this engine to build complete software stacks. See the [official overview](https://docs.yoctoproject.org/bitbake/2.18/bitbake-user-manual/bitbake-user-manual-intro.html).

A useful mental model is:

1.  **Configuration** tells BitBake where metadata lives and how the build behaves.
2.  **Recipes** describe targets and their tasks.
3.  **Classes** share common functionality.
4.  **Dependencies** determine task order.
5.  **BitBake** executes the resulting task graph and records logs.

### 2.2 The five file types used here

| Extension   | Purpose                                         |
|-------------|-------------------------------------------------|
| `.conf`     | Build or layer configuration                    |
| `.bb`       | A recipe: one buildable target and its metadata |
| `.bbclass`  | Reusable functions and tasks                    |
| `.bbappend` | Metadata that extends a matching recipe         |
| `.inc`      | Reusable metadata included by another file      |

The official manual’s [concepts section](https://docs.yoctoproject.org/bitbake/2.18/bitbake-user-manual/bitbake-user-manual-intro.html#concepts) explains these metadata types in greater depth.

### 2.3 Functions versus tasks

A **function** is executable metadata. A **task** is a function registered in BitBake’s task graph. Task names normally begin with `do_`.

For example:

    do_build () {
        echo "building"
    }

defines `do_build`. An `addtask` statement can register a function and specify ordering:

    addtask mypatch before do_build

This tells BitBake that `do_mypatch` must run before `do_build` when the graph requires the build task.

## 3. Setup BitBake

This tutorial uses one fixed BitBake archive, extracts it, and adds it to the current terminal. No Conda environment, Docker image, or permanent .bashrc change is required.

### 3.1 The installation of BitBake

**Step 1: Check Python and the download tools**

    python3 --version
    wget --version
    unzip -v

Step 2: Download BitBake 2.18.0

The source is the official OpenEmbedded BitBake mirror on GitHub: [github.com/openembedded/bitbake](https://github.com/openembedded/bitbake)

Download the fixed 2.18.0 archive directly: [Download BitBake 2.18.0](https://github.com/openembedded/bitbake/archive/refs/tags/2.18.0.zip)

You can click the link in a browser, or choose a working directory and run these commands:

    export BBTUTOR_DIR="$HOME/bbtutor"
    mkdir -p "$BBTUTOR_DIR"
    cd "$BBTUTOR_DIR"
    wget -O bitbake-2.18.0.zip \
        https://github.com/openembedded/bitbake/archive/refs/tags/2.18.0.zip

**Step 3: Extract the archive**

    cd "$BBTUTOR_DIR"
    unzip bitbake-2.18.0.zip

The extracted folder should be:

    $BBTUTOR_DIR/bitbake-2.18.0

Check it:

    ls "$BBTUTOR_DIR/bitbake-2.18.0/bin/bitbake"
    ls "$BBTUTOR_DIR/bitbake-2.18.0/lib/bb"

**Step 4: Add BitBake to the current terminal**

Set the location of the extracted BitBake folder:

    export BITBAKE_ROOT_DIR="$BBTUTOR_DIR/bitbake-2.18.0"

Add its `bin` directory to `PATH` and its `lib` directory to `PYTHONPATH`:

    export PATH="$BITBAKE_ROOT_DIR/bin:$PATH"
    export PYTHONPATH="$BITBAKE_ROOT_DIR/lib${PYTHONPATH:+:$PYTHONPATH}"

These commands change only the current terminal. If you open a new terminal, run the same three commands again. This keeps the tutorial isolated and avoids changing every future shell.

**Step 5: Verify the setup**

Check which programs the shell will use:

    which python3
    python3 --version
    which bitbake
    bitbake --version

Expected output:

    Python 3.14.4
    BitBake Build Tool Core version 2.18.0

The paths should point to the system Python and the extracted BitBake folder. The version lines are output; do not type them back as commands.

**Step 6: Ubuntu-only permission check**

Before the first build, run:

    unshare --user --map-root-user true

If it returns silently, continue normally. If it reports write failed /proc/self/uid_map: Operation not permitted, Ubuntu’s AppArmor policy is blocking the user namespace that modern BitBake needs. Only in that case, use this temporary workaround:

    echo 0 | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns
    Then repeat the test:
    unshare --user --map-root-user true
    If it now finishes without an error, continue the tutorial. This is an Ubuntu host-security setting, not a BitBake configuration. The change is temporary and is normally restored after restarting the computer. If the same error appears after a reboot, repeat this step before running BitBake tasks.

### 3.2 The BitBake documentation

Use the versioned [BitBake 2.18 User Manual](https://docs.yoctoproject.org/bitbake/2.18/). The manual matches the BitBake version used by this tutorial.

## 4. Create a project

### 4.1 BitBake project layout

We will create:

    bbTutorial/
    ├── build/
    │   └── conf/
    │       └── bblayers.conf
    └── meta-tutorial/
        ├── classes/
        │   └── base.bbclass
        └── conf/
            ├── bitbake.conf
            └── layer.conf

The `build` directory is where we run BitBake. `meta-tutorial` is a **layer**: a collection of related configuration, recipes, classes, and append files.

### 4.2 The smallest possible project

First create the directories:

    mkdir -p "$HOME/bbTutorial/build/conf"
    mkdir -p "$HOME/bbTutorial/meta-tutorial/classes"
    mkdir -p "$HOME/bbTutorial/meta-tutorial/conf"

#### 4.2.1 Create `build/conf/bblayers.conf`

Create `$HOME/bbTutorial/build/conf/bblayers.conf`:

    BBPATH := "${TOPDIR}"
    BBFILES ?= ""
    BBLAYERS = " \
        ${TOPDIR}/../meta-tutorial \
    "

`TOPDIR` is the build directory from which BitBake is running. `BBLAYERS` lists the layers that form this build.

#### 4.2.2 Create `meta-tutorial/conf/layer.conf`

Create `$HOME/bbTutorial/meta-tutorial/conf/layer.conf`:

    BBPATH .= ":${LAYERDIR}"
    BBFILES += "${LAYERDIR}/recipes-*/*/*.bb"

`LAYERDIR` is the current layer’s directory. `BBPATH` is a colon-separated search path. `BBFILES` is a pattern describing where recipes can be found. There are no recipes yet, but defining the pattern now prepares the layer for Chapter 5.

#### 4.2.3 Copy `base.bbclass` and `bitbake.conf`

These two files already exist inside the downloaded BitBake folder. Copy them into the tutorial project:

    cp "$BITBAKE_ROOT_DIR/classes/base.bbclass" \
        "$HOME/bbTutorial/meta-tutorial/classes/base.bbclass"
    cp "$BITBAKE_ROOT_DIR/conf/bitbake.conf" \
        "$HOME/bbTutorial/meta-tutorial/conf/bitbake.conf"

The copies are:

    $BITBAKE_ROOT_DIR/classes/base.bbclass
        -> bbTutorial/meta-tutorial/classes/base.bbclass
    $BITBAKE_ROOT_DIR/conf/bitbake.conf
        -> bbTutorial/meta-tutorial/conf/bitbake.conf

`base.bbclass` provides basic shared BitBake tasks and functions. `bitbake.conf` provides BitBake’s basic variables and default configuration. They must come from BitBake 2.18 so that they match the program being used.

> BitBake 2.18’s supplied bitbake.conf already defines CACHE, so no additional cache setting is required.

### 4.3 The first run

Always run BitBake from the build directory:

    cd "$HOME/bbTutorial/build"
    bitbake

Expected result:

    Nothing to do. Use 'bitbake world' to build everything,
    or run 'bitbake --help' for usage information.

This is success. BitBake found and parsed the project, but there is no recipe to build yet.

If you run BitBake from `meta-tutorial/conf`, it cannot find the build’s `conf/bblayers.conf`. Return to `$HOME/bbTutorial/build`.

## 5. The first recipe

BitBake needs recipes before it can do useful work. First check the current recipe list:

    cd "$HOME/bbTutorial/build"
    bitbake -s

The list is empty because we have not created a recipe yet.

### 5.1 The cache location

BitBake caches parsed metadata to make later commands faster. BitBake 2.18’s supplied bitbake.conf already contains the required CACHE setting, so there is nothing to add in this step.

### 5.2 Adding a recipe location to the tutorial layer

BitBake finds recipes using `BBFILES`. We already placed this line in `meta-tutorial/conf/layer.conf`:

    BBFILES += "${LAYERDIR}/recipes-*/*/*.bb"

It means: look inside directories named `recipes-*`, then inside a recipe directory, and load files ending in `.bb`.

### 5.3 Create the first recipe and task

Recipe files use the form `name_version.bb`. For `first_0.1.bb`, `first` is the recipe name, `0.1` is its version, and `.bb` means it is a BitBake recipe.

Create the directory:

    mkdir -p "$HOME/bbTutorial/meta-tutorial/recipes-tutorial/first"

Create `$HOME/bbTutorial/meta-tutorial/recipes-tutorial/first/first_0.1.bb`:

    DESCRIPTION = "I am the first recipe"
    PR = "r1"

    do_build () {
        echo "first: some shell script running as build"
    }

The recipe defines one shell task named `do_build`. Now list the recipes and build `first`:

    cd "$HOME/bbTutorial/build"
    bitbake -s
    bitbake first

`bitbake -s` should list `first :0.1-r1`. The final build summary should say that all attempted tasks succeeded.

Inspect the task log:

    find tmp/work -path '*first*' -name 'log.do_build*' -print

One log should contain:

    first: some shell script running as build

## 6. Classes and functions

### 6.1 Why use a class?

A `.bbclass` contains reusable metadata. Instead of copying the same build task into multiple recipes, define it once and let recipes inherit it.

### 6.2 Create `mybuild.bbclass`

Create `$HOME/bbTutorial/meta-tutorial/classes/mybuild.bbclass`:

    addtask build

    mybuild_do_build () {
        echo "running mybuild_do_build."
    }

    EXPORT_FUNCTIONS do_build

`EXPORT_FUNCTIONS do_build` exposes the class-specific `mybuild_do_build` implementation as `do_build` to metadata that inherits the class.

### 6.3 Complete the layer collection metadata

Replace `$HOME/bbTutorial/meta-tutorial/conf/layer.conf` with:

    BBPATH .= ":${LAYERDIR}"
    BBFILES += "${LAYERDIR}/recipes-*/*/*.bb"

    BBFILE_COLLECTIONS += "tutorial"
    BBFILE_PATTERN_tutorial = "^${LAYERDIR}/"
    BBFILE_PRIORITY_tutorial = "5"

The suffix `tutorial` connects the collection name to its pattern and priority. BitBake 2.18 will warn that this collection has no declared layer-series compatibility. That warning is expected here and will be fixed in Chapter 7.

### 6.4 Create the second recipe

    mkdir -p "$HOME/bbTutorial/meta-tutorial/recipes-tutorial/second"

Create `$HOME/bbTutorial/meta-tutorial/recipes-tutorial/second/second_1.0.bb`:

    DESCRIPTION = "I am the second recipe"
    PR = "r1"

    inherit mybuild

    def pyfunc(obj):
        print(dir(obj))

    python do_mypatch () {
        bb.note("running mypatch")
        pyfunc(d)
    }

    addtask mypatch before do_build

This recipe demonstrates three kinds of reuse:

- `inherit mybuild` imports class metadata.
- `do_mypatch` is a BitBake Python task.
- `pyfunc` is a regular Python helper called by the task.

`d` is BitBake’s datastore, which contains variables visible in the current metadata context.

### 6.5 Explore and execute tasks

    cd "$HOME/bbTutorial/build"
    bitbake -s
    bitbake -c listtasks second | grep -E 'do_build|do_mypatch'
    bitbake second
    bitbake -c mypatch second
    bitbake world

Important forms:

- `bitbake second`: run the default build task and required predecessors.
- `bitbake -c mypatch second`: explicitly run `do_mypatch`.
- `bitbake world`: build all recipes visible to this configuration.

Task logs are under `build/tmp/work/<recipe>/temp/` in this standalone project.

## 7. BitBake layers

### 7.1 Add a second layer

Create its configuration directory:

    mkdir -p "$HOME/bbTutorial/meta-two/conf"

Create `$HOME/bbTutorial/meta-two/conf/layer.conf`:

    BBPATH .= ":${LAYERDIR}"
    BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
                ${LAYERDIR}/recipes-*/*/*.bbappend"

    BBFILE_COLLECTIONS += "two"
    BBFILE_PATTERN_two = "^${LAYERDIR}/"
    BBFILE_PRIORITY_two = "5"
    LAYERVERSION_two = "1"

    LAYERDEPENDS_two = "tutorial"

`LAYERDEPENDS_two = "tutorial"` means `meta-two` requires the layer collection named `tutorial`.

### 7.2 Add the layer to `bblayers.conf`

Update `$HOME/bbTutorial/build/conf/bblayers.conf`:

    BBPATH := "${TOPDIR}"
    BBFILES ?= ""
    BBLAYERS = " \
        ${TOPDIR}/../meta-tutorial \
        ${TOPDIR}/../meta-two \
    "

### 7.3 Declare layer-series compatibility

This standalone project needs a consistent core-series name. Use the correctly spelled name `bitbakeguide`.

Append to `meta-tutorial/conf/layer.conf`:

    LAYERSERIES_CORENAMES = "bitbakeguide"

    LAYERVERSION_tutorial = "1"
    LAYERSERIES_COMPAT_tutorial = "bitbakeguide"

Append to `meta-two/conf/layer.conf`:

    LAYERSERIES_COMPAT_two = "bitbakeguide"

The same project-defined name, bitbakeguide, must be used in LAYERSERIES_CORENAMES and the LAYERSERIES_COMPAT entries.

### 7.4 Inspect layers

    cd "$HOME/bbTutorial/build"
    bitbake-layers show-layers
    bitbake-layers show-recipes

Both `tutorial` and `two` should be listed with priority `5`. At this exact stage, BitBake warns that no `.bb` files match `BBFILE_PATTERN_two` because `meta-two` is intentionally empty. Chapter 8 adds a recipe to it.

Useful subcommands include:

- `show-layers`: configured layers and priorities.
- `show-recipes`: recipes and providers.
- `show-appends`: append files and their matching recipes.
- `show-overlayed`: recipes hidden by higher-priority providers.

## 8. Share and reuse configurations

### 8.1 Class inheritance

Create the directory:

    mkdir -p "$HOME/bbTutorial/meta-two/classes"

Create `$HOME/bbTutorial/meta-two/classes/confbuild.bbclass`:

    inherit mybuild

    confbuild_do_configure () {
        echo "running confbuild_do_configure."
    }

    addtask do_configure before do_build
    EXPORT_FUNCTIONS do_configure

This class inherits the build behavior from `mybuild` and adds a configure task before it.

Create the third recipe:

    mkdir -p "$HOME/bbTutorial/meta-two/recipes-base/third"

Create `$HOME/bbTutorial/meta-two/recipes-base/third/third_0.1.2.bb`:

    DESCRIPTION = "I am the third recipe"
    PR = "r1"

    inherit confbuild

Build it:

    cd "$HOME/bbTutorial/build"
    bitbake third

Both `do_configure` and `do_build` should succeed.

### 8.2 Extend a recipe with `.bbappend`

Create:

    mkdir -p "$HOME/bbTutorial/meta-two/recipes-base/first"

Create `$HOME/bbTutorial/meta-two/recipes-base/first/first_0.1.bbappend`:

    python do_patch () {
        bb.note("first:do_patch")
    }

    addtask patch before do_build

The root filename matches `first_0.1.bb`, so BitBake merges the append metadata into that recipe. This is how one layer can customize a recipe supplied by another without editing the original layer.

Verify the match and task:

    cd "$HOME/bbTutorial/build"
    bitbake-layers show-appends
    bitbake -c listtasks first | grep -E 'do_patch|do_build'
    bitbake first

### 8.3 `include` versus `require`

Both directives search relative to `BBPATH`:

- `include file`: parse it if present; continue if it is absent.
- `require file`: parse it and fail if it is absent.

Append to `$HOME/bbTutorial/meta-tutorial/conf/bitbake.conf`:

    require local.conf
    include conf/might_exist.conf

Now run:

    cd "$HOME/bbTutorial/build"
    bitbake first

BitBake should report that required `local.conf` is missing. Fix it by creating an empty build-local configuration:

    touch "$HOME/bbTutorial/build/local.conf"
    bitbake first

The missing optional `conf/might_exist.conf` does not cause an error.

## 9. Using variables

### 9.1 Global variable

Put this in `$HOME/bbTutorial/build/local.conf`:

    MYVAR = "hello from MYVAR"

Spaces around `=` matter for clean modern style. `MYVAR="..."` parses in some contexts but BitBake 2.18 warns about missing whitespace.

Create the recipe directory:

    mkdir -p "$HOME/bbTutorial/meta-two/recipes-vars/myvar"

Create `$HOME/bbTutorial/meta-two/recipes-vars/myvar/myvar_0.1.bb`:

    DESCRIPTION = "Show access to global MYVAR"
    PR = "r1"

    do_build () {
        echo "myvar_sh: ${MYVAR}"
    }

    python do_myvar_py () {
        print("myvar_py:" + d.getVar('MYVAR'))
    }

    addtask myvar_py before do_build

Shell-style BitBake functions expand a variable as \${MYVAR}. Python tasks read it from the datastore with d.getVar('MYVAR').

Build and inspect:

    cd "$HOME/bbTutorial/build"
    bitbake myvar
    grep -RhE 'myvar_py:|myvar_sh:' \
        tmp/work/*/temp/log.do_* 2>/dev/null

Expected messages:

    myvar_py:hello from MYVAR
    myvar_sh: hello from MYVAR

Each can appear twice because BitBake can keep a stable log name and a numbered task log.

### 9.2 Recipe-local variable

Create `$HOME/bbTutorial/meta-two/classes/varbuild.bbclass`:

    varbuild_do_build () {
        echo "build with args: ${BUILDARGS}"
    }

    addtask build
    EXPORT_FUNCTIONS do_build

The class knows the variable name but does not choose its value.

Create:

    mkdir -p "$HOME/bbTutorial/meta-two/recipes-vars/varbuild"

Create `$HOME/bbTutorial/meta-two/recipes-vars/varbuild/varbuild_0.1.bb`:

    DESCRIPTION = "Demonstrate a recipe configuring a class task"
    PR = "r1"

    BUILDARGS = "my build arguments"

    inherit varbuild

Here the recipe provides a recipe-local value and the reusable class consumes it. This is a central BitBake pattern: classes define general processes while recipes configure those processes through variables.

Run:

    cd "$HOME/bbTutorial/build"
    bitbake varbuild
    grep -RhF 'build with args: my build arguments' \
        tmp/work/*/temp/log.do_* 2>/dev/null

### 9.3 Final check

**List recipes**

    cd "$HOME/bbTutorial/build"
    bitbake -s

The final project should provide:

    first
    myvar
    second
    third
    varbuild

**Inspect layers and appends**

    bitbake-layers show-layers
    bitbake-layers show-appends

The layers should be `tutorial` and `two`. The append listing should connect `first_0.1.bbappend` to `first_0.1.bb`.

**Build everything**

    bitbake world

In the validated final project, nine tasks were attempted and all succeeded on a clean run. The exact “didn’t need to be rerun” count can differ because it depends on your existing cache and stamps.

**Final layout**

    bbTutorial/
    ├── build/
    │   ├── conf/bblayers.conf
    │   └── local.conf
    ├── meta-tutorial/
    │   ├── classes/
    │   │   ├── base.bbclass
    │   │   └── mybuild.bbclass
    │   ├── conf/
    │   │   ├── bitbake.conf
    │   │   └── layer.conf
    │   └── recipes-tutorial/
    │       ├── first/first_0.1.bb
    │       └── second/second_1.0.bb
    └── meta-two/
        ├── classes/
        │   ├── confbuild.bbclass
        │   └── varbuild.bbclass
        ├── conf/layer.conf
        ├── recipes-base/
        │   ├── first/first_0.1.bbappend
        │   └── third/third_0.1.2.bb
        └── recipes-vars/
            ├── myvar/myvar_0.1.bb
            └── varbuild/varbuild_0.1.bb

## 10. Summary

You have used BitBake as a standalone task engine and practiced:

- Project and build-directory layout.
- Configuration and search paths.
- Recipes, classes, tasks, and task ordering.
- Shell and Python metadata functions.
- Layer collections, priorities, compatibility, and dependencies.
- Recipe extension with `.bbappend`.
- Required and optional includes.
- Global and recipe-local variables.
- Recipe, layer, task, append, and log inspection.
