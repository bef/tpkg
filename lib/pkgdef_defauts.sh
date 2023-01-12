pkg_format=1
pkg_desc=""
pkg_description=""
pkg_homepage=""
pkg_download_info_url=""
pkg_version=""
pkg_url=""
pkg_checksum=""
pkg_archive_filename=""
pkg_archive_extension="tar.gz"
pkg_requires=( )

## DOWNLOAD

function pkg_pre_download() {
	return
}
function pkg_download() {
	call $CURL -o "$pkg_archive" --progress-bar --location "$pkg_url"
}
function pkg_post_download() {
	pkg_check_checksum
}

## EXTRACT

function pkg_pre_extract() {
	return
}
function pkg_extract() {
	case "$pkg_archive_filename" in
	*.tar.gz)
		tar zxf "$pkg_archive" -C "$pkg_builddir" --strip-components 1
		;;
	*.tar.bz2)
		tar jxf "$pkg_archive" -C "$pkg_builddir" --strip-components 1
		;;
	*)
		msg_error "$pkg_archive_filename: unknown archive type"
		return 1
	esac
}
function pkg_post_extract() {
	return
}

## CONFIGURE / MAKE

function pkg_pre_configure() {
	cd "$pkg_builddir"
    pkg_std_configure_flags=( --prefix="$TCL_PREFIX" --with-tcl="$TCL_PREFIX/lib" )
    if echo "$TCL_DEFS" |grep "DTCL_CFG_DO64BIT=1" >/dev/null; then
        pkg_std_configure_flags+=( --enable-64bit )
    fi
    if [[ "$TCL_THREADS" -eq 1 ]]; then
        pkg_std_configure_flags+=( --enable-threads )
    fi
}
function pkg_configure() {
	msg_debug "nothing to configure"
	return
}
function pkg_post_configure() {
	return
}
function pkg_pre_make() {
	return
}
function pkg_make() {
	msg_debug "nothing to make"
	return
}
function pkg_post_make() {
	return
}

## DEPLOY (after building)

function pkg_pre_deploy() {
	cd "$pkg_builddir"
}
function pkg_deploy() {
	msg_debug "nothing to deploy."
	return
}
function pkg_post_deploy() {
	return
}

## local / non-versioned overrides
if [[ -f "$tpkg_libdir/pkgdef_defaults.local.sh" ]]; then
	. "$tpkg_libdir/pkgdef_defaults.local.sh"
fi