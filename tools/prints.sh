#!/bin/bash

printn() {
  echo -n "$1"
  if [ -z "$2" ]; then echo; fi
}

print_error () {
  tput sgr0;
  tput bold;
  tput setaf 1;
  echo -n "$1"
  tput sgr0;
  
  if [ -z "$2" ]; then echo; fi
}

print_ok () {
  tput sgr0;
  tput bold;
  tput setaf 2;
  echo -n "$1"
  tput sgr0;
  
  if [ -z "$2" ]; then echo; fi
}

print_noch () {
  tput sgr0;
  tput bold;
  tput setaf 3;
  echo -n "$1"
  tput sgr0;
  
  if [ -z "$2" ]; then echo; fi
}

print_info () {
  tput sgr0;
  tput bold;
  tput setaf 6;
  echo -n "$1"
  tput sgr0;
  
  if [ -z "$2" ]; then echo; fi
}

print_title () {
  tput sgr0;
  tput bold;
  tput setaf 5;
  tput setab 4;
  echo
  echo -n "$1"
  tput sgr0;
  echo
  echo
}
