#!/usr/bin/env bash
#
# $1: g|get|s|set|c|convert
# $2: layout to set (if $1="s|set") or to convert to (if $1="c|convert")
# $3: scope: w|word|l|line|s|selection

# \x2F = / = slash
# \x5C = \ = backslash
US1='~!@#$%^&*()_+'
us1='`1234567890-='
US2='QWERTYUIOP{}|'
us2='qwertyuiop[]\x5C'
US3='ASDFGHJKL:"'
us3="asdfghjkl;'"
US4='ZXCVBNM<>?'
us4='zxcvbnm,.\x2F'

RU1='Ё!"№;%:?*()_+'
ru1='ё1234567890-='
RU2='ЙЦУКЕНГШЩЗХЪ\x2F'
ru2='йцукенгшщзхъ\x5C'
RU3='ФЫВАПРОЛДЖЭ'
ru3='фывапролджэ'
RU4='ЯЧСМИТЬБЮ,'
ru4='ячсмитьбю.'

# TODO: detect and parse keyboard layouts from the current xkb config
# (maybe using https://github.com/39aldo39/klfc)
declare -A chardict
chardict["us"]="$us1""$us2""$us3""$us4""$US1""$US2""$US3""$US4"
chardict["ru"]="$ru1""$ru2""$ru3""$ru4""$RU1""$RU2""$RU3""$RU4"

function setlayout() {
	# Switch keyboard layout using Gnome extension
	gdbus call --session --dest org.gnome.Shell \
		--object-path /me/madhead/Shyriiwook \
		--method me.madhead.Shyriiwook.activate "$1" &>/dev/null
}

function convert() {
	# sed "y/$aaa/$bbb/" transliterates input string by replacing characters
	# which appear in $aaa to corresponding characters in $bbb
	echo -n "$(echo -n "$1" | sed "y/$2/$3/")"
}

# Get current keyboard layout using Gnome extension and regex magic
curlayout=$(gdbus introspect --session --dest org.gnome.Shell \
	--object-path /me/madhead/Shyriiwook --only-properties |
	grep -oP "currentLayout = '\K\w+")

srcchars="${chardict["$curlayout"]}"

case "$1" in

g | get)
	# Print current layout short name and its chars to stdout
	echo "$curlayout"
	echo "$srcchars"
	;;

s | set)
	# Switch keyboard layout using Gnome extension
	setlayout "$2"
	;;

c | convert)
	# Convert (punto-switch) recently typed text

	setlayout "$2"

	destchars="${chardict["$2"]}"

	# Save clipboard content
	old_clipboard=$(xsel --output --clipboard)

	case "$3" in
	s | selection)
		# Read and convert currently selected text
		# Get content of the primary buffer, i.e. latest active selection made in any window
		instr=$(xsel --output --primary)
		outstr=$(convert "$instr" "$srcchars" "$destchars")
		;;
	l | line)
		# Select and convert line, up to the cursor position
		xdotool key --clearmodifiers Shift+Home
		instr=$(xsel --output --primary)
		outstr=$(convert "$instr" "$srcchars" "$destchars")
		;;
	w | word)
		# Select line up to the cursor position, convert last word, concatenate
		xdotool key --clearmodifiers Shift+Home
		instr=$(xsel --output --primary)
		# grep -oP "\S+$" returns last word in a string
		lastword=$(echo -n "$instr" | grep -oP "\S+$")
		lastword_converted=$(convert "$lastword" "$srcchars" "$destchars")
		# ${#string} returns length of string
		# ((${#string} - ${#lastword})) returns length of string minus length of last word
		# ${string::N} returns first N chars of string
		outstr="${instr::((${#instr} - ${#lastword}))}""$lastword_converted"
		;;
	*)
		printf >&2 'puny-switcher: error: 3rd argument must be w|word|l|line|s|selection\n'
		exit 1
		;;
	esac

	# Debug
	printf >&1 "%s\n" "$outstr"

	# xsel -ip writes to the primary buffer, as if the user has made a new selection
	# xsel -ib writes to clipboard, as if the user has pressed "copy"
	echo -n "$outstr" | xsel --input --clipboard

	# Принудительно отключаем Insert
	#xdotool keyup Insert

	# Delete selected text in the application and clear primary buffer
	xsel --delete --primary

	# Paste clipboard content
	xdotool key --clearmodifiers Shift+Insert

	# Restore previous clipboard content
	echo -n "$old_clipboard" | xsel --input --clipboard

	# Отпускаем возможно залипшие Shift и Insert
	xdotool keyup Shift_L Shift_R Insert
	;;

*)
	printf >&2 'puny-switcher: error: 1st argument must be g|get|s|set|c|convert\n'
	exit 1
	;;
esac

exit 0
