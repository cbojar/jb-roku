#!/bin/bash
DEBUG=0
PRESERVE_TEMP=0
TARGET="JB-Roku.zip"
BRSALL="source/jupiterbroadcasting-roku.brs" # Monolithic source file to be made

PARSED_OPTIONS=$( getopt -n "$0" -o hdp --long "help,debug,preserve-temp"  -- "$@" )
if [ $? -ne 0 ]; then #Bad arguments, something has gone wrong
	exit 1
fi
eval set -- "$PARSED_OPTIONS" # getopt magic

while true; do
	case "$1" in
		-h|--help)
			echo "Usage: $0 [-d|--debug] [-p|--preserve-temp]"
			shift
			exit;;
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
FILES=$( find ./ ) # List all files
FILES=$( echo "$FILES" | grep -v "$0" ) # Filter out this script
FILES=$( echo "$FILES" | grep -v '\.git' ) # Filter out Git-related files
FILES=$( echo "$FILES" | grep -v '\.hg' ) # Filter out Mercurial-related files
FILES=$( echo "$FILES" | grep -v '\.svn' ) # Filter out SVN-related files
FILES=$( echo "$FILES" | grep -v '\.project' ) # Filter out Eclipse project file
FILES=$( echo "$FILES" | grep -v '\.buildpath' ) # Filter out Eclipse buildpath file
FILES=$( echo "$FILES" | grep -v '\.settings' ) # Filter out Eclipse settings folder
FILES=$( echo "$FILES" | grep -v 'resources' ) # Filter out resources folder
FILES=$( echo "$FILES" | grep -v "$TARGET" ) # Filter out target file
FILES=$( echo "$FILES" | grep -v '^\./$' ) # Filter out current directory listing

if [ $DEBUG = 1 ]; then # Don't concatenate all files if debugging
	# Remove target file if it already exists
	if [ -e "$TARGET" ]; then
		rm -f "$TARGET"
	fi
	echo "$FILES" | zip -9 -@ "$TARGET" # Add in all resources
	exit
fi

# Concatenate all source files together into a single file to improve compression
if [ -e "$BRSALL" ]; then
	rm -f "$BRSALL"
fi
BRS=$( echo "$FILES" | grep ".brs$" )
cat $BRS | tr -d "\t" | sed -r 's|^\s+||g' | sed -r 's|\s+$||g' | grep -v "^'" | grep -v "^REM " | grep -v "^REM$" | grep -v "^$" > "$BRSALL"

# Filter out source files
FILESNOSRC=$( echo "$FILES" | grep -v ".brs$" | grep -v "source" )

# Remove target file if it already exists
if [ -e "$TARGET" ]; then
	rm -f "$TARGET"
fi

# Build compressed archive
echo "$BRSALL" | zip -9 -@ "$TARGET" # Add in monolithic source file
echo "$FILESNOSRC" | zip -9 -@ "$TARGET" # Add in all other resources

if [ $PRESERVE_TEMP = 0 ]; then
	rm "$BRSALL" # Remove monolithic source file
fi
