#!/bin/bash

extract_str_between()
{
	if [[ "$#" -lt 3 ]]; then
		printf "$(grep -oP "(?<=$1).*?(?=$2)" < /dev/stdin)"
	else
		printf "$(echo $3 | grep -oP "(?<=$1).*?(?=$2)")"
	fi
}

if [[ ! -z "$1" ]] && [[ ! -z "$2" ]] && [[ ! -z "$3" ]]; then
	extract_str_between "$1" "$2" "$3"
else
	extract_str_between "$1" "$2"
fi
