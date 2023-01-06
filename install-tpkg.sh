#!/bin/bash

tpkg_base="${TPKG_BASE:-/opt/tpkg}"

if [[ ! -d "$tpkg_base" ]]; then
	echo "#> creating tpkg base directory $tpkg_base"
	if ! mkdir -p "$tpkg_base" 2>/dev/null && [[ "$UID" != "0" ]]; then
		sudo -n -- "mkdir -p \"$tpkg_base\"; chown $USER \"$tpkg_base\""
	fi
fi

if [[ -n "${BASH_SOURCE[0]}" && -f "$script_dir/tpkg" && -d "$script_dir/pkgdefs" && ! -d "$tpkg_base/tpkg" ]]; then
	echo "#> creating symlink $script_dir -> $tpkg_base/tpkg"
	ln -s "$script_dir" "$tpkg_base/tpkg"
fi

function dl_tpkg() {
	echo "#> downloading tpkg"
	if ! which curl 2>/dev/null; then
		echo "ERROR> need curl"
		exit 1
	fi
	if [[ ! -d "$tpkg_base/tpkg" ]]; then
		mkdir -p "$tpkg_base/tpkg"
	fi
	curl -fsSL https://github.com/bef/tpkg/tarball/master |tar zxf - -C "$tpkg_base/tpkg" --strip-components 1
}

if [[ -d "$tpkg_base/tpkg/.git" ]]; then
	echo "#> updating git repo $tpkg_base/tpkg"
	git -C "$tpkg_base/tpkg" pull
elif [[ ! -d "$tpkg_base/tpkg" ]]; then
	if which git 2>/dev/null; then
		echo "#> cloning git repository -> $tpkg_base/tpkg"
		cd "$tpkg_base"
		git clone https://github.com/bef/tpkg.git
	else
		dl_tpkg
	fi
else
	dl_tpkg
fi

if [[ ! -f "$tpkg_base/bin/tpkg" ]]; then
	echo "#> linking tpkg to $tpkg_base/bin/tpkg"
	mkdir -p "$tpkg_base/bin"
	ln -s "$tpkg_base/tpkg/tpkg" "$tpkg_base/bin/tpkg"
fi

echo "#> done."
