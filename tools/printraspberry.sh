#!/bin/bash

printraspberry()
{
	echo
	echo -en " \033[1;32m"
	echo -e "⋱⋱ ⋰⋰			$1"
	echo -en "\033[1;31m"
	echo -e " ◖ ● ◗			$2"
	echo -e "◖ ● ● ◗			$3"
	echo -e " ◖ ● ◗			$4"
	echo -e "   ●"
	echo -en "\033[0m"
	echo
}

