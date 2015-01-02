#!/bin/bash
DEBUG=0
PRESERVE_TEMP=0
DEFAULT_TARGET="JB-Roku.zip"
BRSALL="source/jupiterbroadcasting-roku.brs" # Monolithic source file to be made

target="$DEFAULT_TARGET"

PARSED_OPTIONS=$( getopt -n "$0" -o hdpo: --long "help,debug,preserve-temp,output:"  -- "$@" )
if [ $? -ne 0 ]; then #Bad arguments, something has gone wrong
	exit 1
fi
eval set -- "$PARSED_OPTIONS" # getopt magic

while true; do
	case "$1" in
		-h|--help)
			echo "Usage: $0 [[-d|--debug]|[-p|--preserve-temp]] [-o|--output <output-file>]"
			shift
			exit;;
		-o|--ouput)
			target="$2"
			echo "File will be saved to \"$2\""
			shift 2;;
		-d|--debug)
			DEBUG=1
			shift;;
		-p|--preserve-temp)
			PRESERVE_TEMP=1
			shift;;
		--)
			shift
			break;;
	esac
done

# Filter list of files only to those needing built
files=$( find . -type f ) # List all files
files=$( egrep -v "$0" <<< "$files" ) # Filter out this script
files=$( egrep -v '(\.git|\.hg|\.svn)' <<< "$files" ) # Filter out VCS-related files
files=$( egrep -v '(\.project|\.buildpath|\.settings)' <<< "$files" ) # Filter out Eclipse-related files
files=$( egrep -v 'resources' <<< "$files" ) # Filter out resources folder
files=$( grep -v "$DEFAULT_TARGET" <<< "$files" ) # Filter out default target file
files=$( grep -v "$target" <<< "$files" ) # Filter out target file

# Remove target file if it already exists
if [ -e "$target" ]; then
	rm -f "$target"
fi

if [ $DEBUG = 1 ]; then # Don't concatenate all files if debugging
	zip -9 -@ "$target" <<< "$files" # Add in all resources
	exit
fi

# Concatenate all source files together into a single file to improve compression
if [ -e "$BRSALL" ]; then
	rm -f "$BRSALL"
fi
brs=$( egrep  "\.brs$" <<< "$files" )

# Remove tabs, leading spaces, trailing spaces, comments, and blank lines
cat $brs | tr -d "\t" | sed -r 's|^\s+||g' | sed -r 's|\s+$||g' | grep -v "^'" | grep -v "^REM " | grep -v "^REM$" | grep -v "^$" > "$BRSALL"

# Filter out source files
filesnosrc=$( egrep -v "\.brs$" <<< "$files" | grep -v "source" )

# Build compressed archive
zip -9 -@ "$target" <<< "$BRSALL" # Add in monolithic source file
zip -9 -@ "$target" <<< "$filesnosrc" # Add in all other resources

if [ $PRESERVE_TEMP = 0 ]; then
	rm "$BRSALL" # Remove monolithic source file
fi
