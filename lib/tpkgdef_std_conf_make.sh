function pkg_configure() {
	if [[ -f Makefile ]]; then
		return
	fi

	if [[ ! -f "configure" ]]; then
		call autoconf
	fi

	call ./configure "${pkg_std_configure_flags[@]}"
}

function pkg_make() {
	call make -j4
}

function pkg_deploy() {
	call make install
}