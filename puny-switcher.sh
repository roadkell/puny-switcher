#!/usr/bin/env bash
#
# ============================================================================ #
#
# Puny Switcher: small script for correcting text typed in a wrong layout
# (aka Punto-switching) and layout switching by console command
# https://github.com/roadkell/puny-switcher
#
# Arguments:
# 	$1: action: get|set|iset|switch|convert|restore
# 	$2: layout name (for set) or index (for iset) to switch to: en|ru|0|1
#
# TODO: detect and parse keyboard layouts from the current xkb config
# (maybe by using https://github.com/39aldo39/klfc)
#
# ============================================================================ #

# Debug
printf >&1 "\n"
printf >&1 "puny-switcher started: primary   : %s\n" "$(xsel --output --primary -v)"
printf >&1 "puny-switcher started: secondary : %s\n" "$(xsel --output --secondary -v)"
printf >&1 "puny-switcher started: clipboard : %s\n" "$(xsel --output --clipboard -v)"
printf >&1 "\n"

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

declare -A chardict
chardict["us"]="$us1""$us2""$us3""$us4""$US1""$US2""$US3""$US4"
chardict["ru"]="$ru1""$ru2""$ru3""$ru4""$RU1""$RU2""$RU3""$RU4"

# ============================================================================ #

setlayout() {
	# Switch keyboard layouts using Gnome extension
	# 	$1: layout short name
	gdbus call --session --dest org.gnome.Shell \
		--object-path /me/madhead/Shyriiwook \
		--method me.madhead.Shyriiwook.activate "$1" &>/dev/null
	# TODO: replace with
	# busctl --user call org.gnome.Shell /me/madhead/Shyriiwook me.madhead.Shyriiwook activate s "$1"
}

setlayout-nognome() {
	setxkbmap "$1"
}

readdbus() {
	# Get current and available keyboard layouts using Gnome extension
	echo -n "$(gdbus introspect --session --dest org.gnome.Shell \
		--object-path /me/madhead/Shyriiwook --only-properties)"
	# TODO: replace with
	# busctl --user get-property org.gnome.Shell /me/madhead/Shyriiwook me.madhead.Shyriiwook currentLayout
	# busctl --user get-property org.gnome.Shell /me/madhead/Shyriiwook me.madhead.Shyriiwook availableLayouts
}

getlayout() {
	# Get current keyboard layout name
	# 	$1: gdbus output text
	echo -n "$(echo -n "$1" | grep -oP "currentLayout = '\K\w+")"
}

getlayout-nognome() {
	# Not working yet, requires further parsing:
	xset -q | grep -A 0 'LED' | cut -c59-67
	# https://askubuntu.com/q/973257/408821
}

getlayouts() {
	# Get an array of available layout names
	# 	$1: gdbus output text
	# grep -oP "availableLayouts = \['\K\w+', '\w+" returns a string like "us', 'ru".
	# sed s/"['|,]"/""/g removes apostrophes and commas.
	# read -ra layouts <<< "$mystring" converts the string into an array.
	read -ra layouts <<<"$(echo -n "$1" |
		grep -oP "availableLayouts = \['\K\w+', '\w+" | sed s/"['|,]"/""/g)"
	# In Bash, variables created inside a function are kept by default, i.e.
	# ${layouts} array will persist after function exit.
}

getlayouts-nognome() {
	# Get an array of available layouts
	read -ra layouts <<<"$(setxkbmap -query |
		grep -oP "layout: \s*\K\w*,\w*" | sed y/","/" "/)"
}

strconv() {
	# sed y/$aaa/$bbb/ transliterates input string by replacing characters
	# which appear in $aaa to corresponding characters in $bbb
	echo -n "$(echo -n "$1" | sed y/"$2"/"$3"/)"
}

# ============================================================================ #

case "$1" in

get)
	# Print available layouts, current layout, and its chars to stdout
	gdbusstr=$(readdbus)
	getlayouts "$gdbusstr"
	printf >&1 "puny-switcher: available layouts: %s\n" "${layouts[@]}"
	curlayout=$(getlayout "$gdbusstr")
	printf >&1 "puny-switcher: current layout: %s\n" "$curlayout"
	srcchars="${chardict["$curlayout"]}"
	printf >&1 "puny-switcher: layout characters: %s\n" "$srcchars"
	;;

set)
	# Set keyboard layout by name
	setlayout "$2"
	;;

iset)
	# Set keyboard layout by index: 0|1
	gdbusstr=$(readdbus)
	getlayouts "$gdbusstr"
	newlayout="${layouts["$2"]}"
	setlayout "$newlayout"
	;;

switch)
	# Switch current layout
	gdbusstr=$(readdbus)
	getlayouts "$gdbusstr"
	curlayout=$(getlayout "$gdbusstr")

	if [[ "$curlayout" == "${layouts[0]}" ]]; then
		newlayout=${layouts[1]}
	else
		newlayout=${layouts[0]}
	fi
	setlayout "$newlayout"
	;;

convert)
	# Convert selected text

	# Save clipboard content to secondary buffer
	#xsel --clear --secondary
	xsel --output --clipboard | xsel --input --secondary --selectionTimeout 1000
	# Get content of the primary buffer, i.e. latest active selection made in any window
	instr=$(xsel --output --primary)

	NONSPACE="(.|\s)*\S(.|\s)*"
	if [[ $instr =~ $NONSPACE ]]; then
		# Selection is non-empty and has non-whitespace characters

		gdbusstr=$(readdbus)
		getlayouts "$gdbusstr"
		curlayout=$(getlayout "$gdbusstr")

		if [[ "$curlayout" == "${layouts[0]}" ]]; then
			newlayout=${layouts[1]}
		else
			newlayout=${layouts[0]}
		fi

		srcchars="${chardict["$curlayout"]}"
		destchars="${chardict["$newlayout"]}"

		outstr=$(strconv "$instr" "$srcchars" "$destchars")

		# Debug
		printf >&1 "puny-switcher: output string: %s\n" "$outstr"

		# xsel -ip writes to the primary buffer, as if the user has made a new selection
		# xsel -ib writes to clipboard, as if the user has pressed "copy"
		#xsel --clear --clipboard
		echo -n "$outstr" | xsel --input --clipboard

		# Delete selected text in the application and clear primary buffer
		# (may only be needed in terminal emulators and such)
		#xsel --delete --primary

	else
		# Nothing is selected, so clear clipboard for the paste and restore
		# actions to work properly
		xsel --clear --clipboard
	fi
	;;

restore)
	# Restore previous clipboard content and clear secondary buffer
	#xsel --clear --clipboard
	xsel --output --secondary | xsel --input --clipboard
	xsel --clear --secondary
	;;

*)
	printf >&2 'puny-switcher: error: unknown argument: %s\n' "$1"
	exit 1
	;;
esac

# ============================================================================ #

# Debug
printf >&1 "\n"
printf >&1 "puny-switcher exiting: primary   : %s\n" "$(xsel --output --primary -v)"
printf >&1 "puny-switcher exiting: secondary : %s\n" "$(xsel --output --secondary -v)"
printf >&1 "puny-switcher exiting: clipboard : %s\n" "$(xsel --output --clipboard -v)"
printf >&1 "\n"

exit 0
