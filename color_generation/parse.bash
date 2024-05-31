#!/usr/bin/env bash

term_alpha=100 # Set this to < 100 to make all your terminals transparent
sequences_file='.cache/terminal/sequences.txt'

apply_term() {
	# Check if terminal escape sequence template exists
	if [ ! -f "templates/sequences.txt" ]; then
		echo "Template file not found for Terminal. Skipping that."
		return
	fi

	# Copy template
	mkdir -p "$(dirname "$sequences_file")"
	cp "templates/sequences.txt" "$sequences_file"

	# Apply colors
	for ((i = 0; i < ${#colorlist[@]}; i++)); do
		sed -i "s|${colorlist[$i]} #|${colorvalues[$i]#\#}|g" "$sequences_file"
	done

	sed -i "s|\$alpha|$term_alpha|g" "$sequences_file"

	for file in /dev/pts/*; do
		if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
			cat "$sequences_file" >"$file"
		fi
	done
}

# Assuming colornames and colorstrings are properly defined
colornames=$(cut -d: -f1 ../scss/colors.scss)
colorstrings=$(cut -d: -f2 ../scss/colors.scss | cut -d ' ' -f2 | cut -d '#' -f2 | cut -d ";" -f1)
IFS=$'\n'
colorlist=($colornames)     # Array of color names
colorvalues=($colorstrings) # Array of color values

apply_term
