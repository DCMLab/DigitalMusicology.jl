# Developer Documentation

## Setup

### 1. Install [Julia](https://julialang.org/downloads/).

Choose the most up to date version, but at least 1.0.
Make sure to **read the instructions** for you platform.
   
### 2. Get DigitalMusicology.jl.
   
If you don't have push access to the repository, you should first create a fork on GitHub.
This step can be done using Julia. Open your terminal and type `julia`.
Type `]` to enter the package manager.

```julia-repl
julia> ]
# EITHER: if you have push access to the main repo:
(1.x) pkg> dev git@github.com:DCMLab/DigitalMusicology.jl.git
# OR:
(1.x) pkg> dev git@github.com:<yourusername>/<yourfork>.git
```
   
This will install DigitalMusicology.jl (or your fork of it) in development mode
in the default directory (`.julia/dev`).
If you want to use a different location,
have a look at the options for `dev` by typing `?dev` in package mode.
You can also clone the repo yourself to an arbitrary location using git.

### 3. Start Hacking

Go to your local clone of the repository (by default `./julia/dev/DigitalMusicology/`).
Start a Julia session in that directory and in package mode (`]`) type
```
(1.x) pkg> activate .
(DigitalMusicology) pkg> instantiate
```

These commands do two things:
1. `activate .` activates the *project* DigitalMusicology.
   This needs to be done everytime you restart Julia (even in Atom),
   and tells Julia to respect the dependencies of that project.
   The currently active project is indicated by the prompt in package mode.
   When starting Julia, you are in the *default project* (1.x).
2. `instantiate` downloads the current project's dependencies.
   This needs to be done only once, as Julia will automatically download
   new dependencies when you add them.
   
For more information on projects and packages, refer to the
[official documentation](https://docs.julialang.org/en/v1/stdlib/Pkg/).

### 4. Use Feature Branches and Pull Requests

If you just want to fix typos or smaller bugs, it's fine to do this on the master branch.
If you want to implement a new feature, reorganize the library or make any bigger changes,
please create a *feature branch* first.
Once the subproject is completed, the feature branch might be merged into master again.
Usually this is done by *pull requests*, i.e. you make changes on your own branch or fork
and then request that these changes are *pulled* to the master branch.

GitHub has a [good introduction](https://help.github.com/articles/proposing-changes-to-your-work-with-pull-requests/) to using branches and pull requests.

## Structure of the Repository

### Julia Package

The DigitalMusicology.jl repository has the form of a Julia package,
which means that it has
1. A directory `src/` with a file `DigitalMusicology.jl`.
   This file is the entry point to the library and is responsible for loading all other files.
2. A `test/` directory for unit tests.
3. A `docs/` directory for documentation.
4. A file `Project.toml` (listing all declared dependencies used directly).
5. A file `Manifest.toml` (listing all transitive dependencies with exact version numbers)

The latter two files are usually not touched directly but manipulated by the package manager
when adding, removing, or updating dependencies.

### Source Code

The Julia source code can be found in the `src/` directory.
A very rough overview of the files can be found in `DigitalMusicology.jl`,
but structuring the library is WIP.

### Tests

Tests are contained in the `test/` directory with a file `test/runtests.jl`,
which runs standard Julia [unit tests](https://docs.julialang.org/en/v1/stdlib/Test/).
You can run all tests from the Julia REPL in package manager mode with `test DigitalMusicology`.

### Documentation

Documentation is generated from markdown files using
[Documenter.jl](https://github.com/JuliaDocs/Documenter.jl).
The `docs/` directory contains the file `make.jl`,
which, when run, compiles the documentation and pushes it to the the library's
[documentation page](https://dcmlab.github.io/DigitalMusicology.jl/latest).
To compile and view the documentation locally, use `makelocal.jl`:
```
$ cd docs
$ julia makelocal.jl
```

For now, this requires you to have Documenter.jl installed in the global project.
**TODO** fix issue with Documenter.jl dependency and add new info here.

If you add new markdown files, don't forget to add them both in `make.jl` and `makelocal.jl`.

## Workflow

**TODO**

## Design Principles

**TODO**

- representations should be interchangable
  - interfaces are important
- representations are chosen to
  - be easy to work with programmatically
  - be easy to convert to other representations
