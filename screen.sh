#! /bin/bash

onExit(){
	echo -e "[?1000l";
	tput rmcup;
}
tput smcup
trap 'onExit' EXIT
cutRow(){
	line="$1"
	tput sc  # save the current cursor position
	tput cup ${line} 0  # move the cursor to line x and column 0
	tput el  # clear the line from the cursor position to the end of the line
	#tput ed  # clear the screen from the cursor position to the end of the screen
	#tput cup ${line} 0  # move the cursor back to line x and column 0
	tput rmcup  # restore the saved cursor position
}

pasteRow(){
	tput sc  # save the current cursor position
	tput cup x 0  # move the cursor to line x and column 0
	pbpaste | tr -d '\n' | tput el1  # retrieve clipboard contents, remove newlines, and paste into line
	tput rmcup  # restore the saved cursor position
}


rows=$(tput lines)  # get the number of rows of the screen
oldrows=${rows}
hl(){
	echo -en "[43m"
	pasteRow
	sleep 2
	echo -en "[0m"
}
cl(){
	tput cup $((rows-8)) 0
	tput ed
}

draw(){
	tput clear  # clear the screen
	for ((i=1; i<=$((rows-8)); i++)); do
		echo "This is line $i"
	done
}
draw
echo mouse enabled

#tput smmous  # enable mouse reporting
echo -e "\e[?1015h"
echo -e "\e[?1000h"

while true; do
	rows=$(tput lines)  # get the number of rows of the screen
	[[ $oldrows -ne $rows ]] && { draw; }
	oldrows=${rows}  # get the number of rows of the screen
	read -rsn1 -t 0.1 key # read the next two characters (the mouse event)
	if [[ $key = $'\e' ]]; then  # if the key is escape (the start of an escape sequence)
		read -rs -t 0.1 ma # read the next two characters (the mouse event)
		if [[ $ma =~ ^\[[0-9]+\;[0-9]+\;[0-9]+M ]]; then  # if the characters are a valid mouse event
			code=$(echo $ma | cut -d ';' -f 1)
			col=$(echo $ma | cut -d ';' -f 2)
			row=$(echo $ma | cut -d ';' -f 3)
			row=${row%M}
			[[ $code == "[32" ]] && { cl; event="Started"; } || [[ $code == "[35" ]] && event="Ended" || event="Unknown"
			echo
			[[ -n col ]] && echo -n "Selection $event :Column $col"	
			[[ -n row ]] && echo "  -  Selection $event : ROW $row"	
				echo -e $ma

			#sleep 1
			#cutRow $row
			#hl
		fi
	fi


done


readmouse(){
	read -rsn1 -t 0.1 key  # read a key with a timeout of 0.1 second
	echo -n $key
	if [[ $key = $'\e' ]]; then  # if the key is escape (the start of an escape sequence)
		read -rsn2 # read the next two characters (the mouse event)
	echo -e " mouse event "$REPLY
		if [[ $REPLY =~ ^\[[0-9]+\;[0-9]+\;[0-9]+ ]]; then  # if the characters are a valid mouse event
			row=$(echo $REPLY | cut -d ';' -f 2)  # get the row of the mouse click
			# highlight the line here
			echo -en "[43m"
			sleep 2
			echo -en "[0m"
		fi
	fi

}
