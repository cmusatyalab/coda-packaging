This is a script for building and packaging VMNetX and its dependencies
for Windows.  Currently only 32-bit builds are supported.

Building
--------

You will need a Windows system.

### One-time setup

1. [Install 32-bit Cygwin][cygwin], accepting the default set of packages.
    Make note of the location of the installer EXE.

2.  Launch a Cygwin shell and navigate to the directory containing
    `build.sh`.

3.  Execute:

        ./build.sh setup /path/to/cygwin/setup.exe

    If `build.sh` opens a WiX Toolset download page in a web browser,
    download and install the indicated version of WiX.

[cygwin]: http://cygwin.com/install.html

### Building

    ./build.sh bdist

### Troubleshooting

The build will fail if the path to `build.sh` contains spaces.

If the build randomly fails complaining that `fork()` failed due to a DLL
address mismatch, follow the instructions [here][1].

[1]: http://cygwin.wikia.com/wiki/Rebaseall

Substitute Sources
------------------

To override the source tree used to build a package, create a top-level
directory named `override` and place the substitute source tree in a
subdirectory named after the package's shortname.  A list of shortnames
can be obtained by running `build.sh` with no arguments.

build.sh Subcommands
--------------------

#### `setup`

Configure build environment.  The path to Cygwin's `setup.exe` must be
specified as an argument.

#### `sdist`

Build Zip file containing the build system and sources for VMNetX and all
its dependencies.

#### `bdist`

Build MSI installer package for VMNetX.

#### `clean`

Delete build and binary directories, but not downloaded tarballs.  If one
or more package shortnames is specified, delete only the build artifacts for
those packages.

#### `updates`

Check for new releases of software packages.

Options
-------

These must be specified before the subcommand.

#### `-j<n>`

Parallel build with the specified parallelism.
