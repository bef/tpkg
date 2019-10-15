# TPKG - The Tcl package manager

## What is it?
TPKG is a prototype implementation of a Tcl installer and package manager.

## Why did I write TPKG?
The state of package management in the Tcl world is somewhat unresolved. There is TEApod, developed by ActiveState, which is commercially motivated and may or may not be actively maintained. Then there are numerous binary Tcl distributions, which come with a lot of packages preinstalled. Also, there is no central repository of packages, however several attempts have been made, most notably [GUTTER](https://core.tcl-lang.org/jenglish/gutter/) and a loose list of packages under the [Category Package](https://wiki.tcl-lang.org/page/Category+Package) in the Tcler's Wiki. A format for meta data associated with packages was proposed with [TIP 55](https://core.tcl-lang.org/tips/doc/trunk/tip/55.md) as well.

All in all package management seems to be a burning topic in the Tcl community and at the The 26th Annual Tcl/Tk Conference (aka Tcl 2019), too. I am really looking forward to their ideas and conclusions.

So, in the end I wanted a stable, reproducible Tcl installations from source, not unlike what BSD ports or homebrew on MacOS provide for system packages. And I wanted it today. Due to lack of viable candidates I wrote this working proof-of-concept prototype and this is it.

## Design decisions
The entire installer is written in Bash (the GNU Bourne-Again SHell). One might ask, why not write just a Tcl installer in Bash and implement the rest of the package manager in Tcl itself? Well, this is true, but since most package installation procedures require shell execution anyway -- e.g. configure, make, make install, copy, link, ... -- an additional Tcl layer would add more complexity than needed.

After experimenting with the idea of a pure-Tcl installer (and writing five prototypes with different ideas), I decided to keep it simple. The result consists of a only a few hundred lines of Bash code, that are easy to read (for the most part) and a very simple shell-based package format.

## Features
* download, extract, build and install Tcl and a few other packages (see `pkgdefs` directory)
* resolve dependencies
* write receipts and prevent installing already installed packages

## Missing Features
A lot. Please provide comments, feature requests or pull requests via github.

## Quick installation
TPKG resides in `/opt/tpkg` by default, but you may choose to clone it anywhere and set `TPKG_BASE` accordingly.
```
cd /opt
sudo mkdir tpkg
sudo chown $USER tpkg
cd tpkg
git clone https://github.com/bef/tpkg.git
mkdir bin
ln -s ../tpkg/tpkg bin
alias tpkg=/opt/tpkg/bin/tpkg
```

That's it. Now let's install Tcl: (-v generates more messages to look at)
```
tpkg -v install tcl
...
```
