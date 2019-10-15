## message output

function msg() {
	echo "[#] $*"
}

function msg_input() {
	echo "[?] $*"
}

function msg_debug() {
	if [[ $g_debug -ne 0 ]]; then
		echo "[D] $*"
	fi
}

function msg_error() {
	echo "[E] $*"
}

function msg_warning() {
	echo "[W] $*"
}

## command execution

function call() {
	msg_debug "calling: $@"
	"$@"
	if [[ $? -ne 0 ]]; then
		msg_error ":( something went terribly wrong here."
	else
		msg_debug "call complete."
	fi
}

## user input

function readinput() {
	local opt
	local varname default_value validator_func dontask=0
	OPTIND=1
	while getopts "v:d:f:n" opt; do
		case "$opt" in
			v) varname="$OPTARG" ;;
			d) default_value="$OPTARG" ;;
			f) validator_func="$OPTARG" ;;
			n) dontask=1 ;;
		esac
	done
	shift $((OPTIND-1))
	local prompt="$1"
	
	local input
	if [[ -n "$varname" && -n "${!varname}" ]]; then
		default_value="${!varname}"
	fi

	while true; do
		if [[ $dontask -eq 1 && -n "${!varname}" ]]; then
			dontask=0
			msg "${prompt} [${!varname}]"
		else
			read -er -p "[?] ${prompt} [$default_value] " input
		fi
		
		if [[ -z "$input" ]]; then
			input="$default_value"
		fi
		
		if [[ -n "$validator_func" ]]; then
			$validator_func "$input"
			if [[ $? != 0 ]]; then
				continue
			fi
		fi
		break
	done
	
	if [[ -n "$varname" ]]; then
		eval "$varname=\"\$input\""
	else
		REPLY="$input"
	fi
}

function readinput_yesno() {
	readinput -f validate_yesno "$@"
	[[ "$REPLY" == "y" ]]
}

## validators

function validate_yesno() {
	case "$1" in
		y|n) return 0 ;;
		*) return 1 ;;
	esac
}

function validate_dir_writable() {
	if [[ ! -d "$1" ]]; then
		if readinput_yesno -d y "Directory does not exist. Create?"; then
			call mkdir -p "$1"
			# call chmod 700 "$1"
		fi
	fi
	[[ -w "$1" ]]
}

function validate_file_exists() {
	if [[ ! -f "$1" ]]; then
		msg_error "$1: file not found"
		return 1
	fi
	return 0
}

function validate_file_not_exists() {
	if [[ -f "$1" ]]; then
		msg_error "$1: file exists"
		return 1
	fi
	return 0
}

## checksums

function calculate_checksum() {
	local method="$1"
	local filename="$2"
	function arg1() {
		echo "$1"
	}
	case "$1" in
	sha1)
		arg1 $(shasum -a 1 -b "$filename")
		return
		;;
	sha256)
		arg1 $(shasum -a 256 -b "$filename")
		return
		;;
	md5)
		if which md5sum >/dev/null 2>&1; then
			arg1 $(md5sum "$filename")
			return
		fi
		if which md5 >/dev/null 2>&1; then
			md5 -q "$filename"
			return
		fi
		msg_error "need either 'md5sum' or 'md5' tool"
		;;
	esac
	return 1
}

function check_checksum() {
	local filename="$1"
	local checksum1="$2"
	local checksum2=""
	case "$checksum1" in
	md5:*)
		checksum2=md5:$(calculate_checksum md5 "$filename")
		;;
	sha1:*)
		checksum2=sha1:$(calculate_checksum sha1 "$filename")
		;;
	sha256:*)
		checksum2=sha256:$(calculate_checksum sha256 "$filename")
		;;
	*)
		return 1
	esac
	[[ "$checksum1" == "$checksum2" ]]
}

## arrays

function in_array() {
	local needle="$1"; shift
	for element in "$@"; do
		if [[ "$element" == "$needle" ]]; then
			return 0
		fi
	done
	return 1
}
