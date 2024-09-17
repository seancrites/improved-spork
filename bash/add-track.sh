#!/bin/bash
##
## Usage: add-track.sh [options] PATH
##
## Options:
##    -h, --help   Display this message.
##    -n           Dry-run; only show what would be done.
##
## Purpose: Prepend random number (1-Num of Files) to all files in a directory.
##
## Useful when adding track numbers to a collection of audio files for a
## personal "MixTape"
##
## Copyright (C) 2024 Sean Crites (sean.crites@gmail.com)
## Last revised 2024-09-16
##

SCRIPT_NAME=$(basename "$0")

usage() {
   [ "$*" ] && echo "$0: $*"
   sed -n '/^##/,/^$/s/^## \{0,1\}//p' "$0"
   exit 2
} 2>/dev/null

main() {

   # If no args are passed, show usage
   if [[ $# -eq 0 ]]; then
      usage 2>&1
   
   # Else parse options and args
   else
      while [ $# -gt 0 ]; do
         case $1 in
         (-n) DRY_RUN=1;;
         (-h|--help) usage 2>&1;;
         (--) shift; break;;
         (-*) usage "$1: unknown option";;
         (*) break;;
         esac
         shift 1
     done

      # Take next argument as path for files to prepend.
      file_dir="${1}"

      #Check if passed variable is a directory
      if [[ -d "${file_dir}" ]]; then

         # Get list of all files in passed directory
         files=$(find "${file_dir}" ! -name "${SCRIPT_NAME}" -type f)

         # Count the number of files
         total_files=$(echo "${files}" | wc -l)

         # Generate an array of numbers from 1 to total_files
         numbers=$(seq 1 "${total_files}" | shuf)

         # Loop over each file
         i=0

         while read -r file; do
            # Get the next random number
            number=$(echo "${numbers}" | sed -n "$((i+1))p")
            # Prepend the random number to the file name
            if [[ "${DRY_RUN}" = 1 ]]; then
               printf "mv(%s, %s)\n" "${file}" "$(dirname "${file}")/${number}. $(basename "${file}")"
            else
               mv "$file" "$(dirname "${file}")/${number}. $(basename "${file}")"
            fi
         i=$((i+1))
         done <<< "${files}"
      else
         if [[ -z "${file_dir}" ]]; then
            printf "ERROR: Directory not specified.\n"
         else
            printf "ERROR: \"%s\" is not a directory.\n" "${file_dir}" 
         fi
      fi
   fi
}

main "$@"