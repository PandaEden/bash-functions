#! /bin/bash
file="$1";shift
echo $file
readarray -t lines < file

pf(){
	tput clear
	for (( i=0;i<="${#lines[@]}";i++ ));do
		selected=false
		for input in "${@}";do [[ $i -eq $input ]] && { selected=true;break; }; done
		if [[ $selected == true ]];then
			echo -e "[44m${line}[0m"
		else
			echo "$line"
		fi
	done
}




onExit(){
	echo -e "[?1000l";
	tput rmcup;
}
trap 'onExit' EXIT
tput smcup

pasteRow(){
	tput sc  # save the current cursor position
	tput cup x 0  # move the cursor to line x and column 0
	pbpaste | tr -d '\n' | tput el1  # retrieve clipboard contents, remove newlines, and paste into line
	tput rc  # restore the saved cursor position
}

oldrows=0
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
cuttxt=""
echo mouse enabled

#tput smmous  # enable mouse reporting
echo -e "\e[?1015h"
echo -e "\e[?1000h"
row=-1
tput sc
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
			row=$(echo $ma | cut -d ';' -f 3); row=${row%M}
			[[ $code == "[32" ]] && { cl; event="Started"; } || [[ $code == "[35" ]] && event="Ended" || event="Unknown"
			echo
			[[ -n row ]] && echo -n "  -  Selection $event : ROW $row"	
			[[ -n col ]] && echo "  -  Selection $event :Column $col"	
			#tput sc; tput cup $row 0; cuttxt="$(tput el)"; tput rc;	
			#echo c- $cuttxt
		fi
	fi


done
