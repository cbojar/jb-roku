#!/bin/bash
TARGET="JB-Roku.zip"
BRSALL="source/jupiterbroadcasting-roku.brs" # Monolithic source file to be made

# Filter list of files only to those needing built
FILES=$( find ./ ) # List all files
FILES=$( echo "$FILES" | grep -v "$0" ) # Filter out this script
FILES=$( echo "$FILES" | grep -v ".git" ) # Filter out Git-related files
FILES=$( echo "$FILES" | grep -v ".hg" ) # Filter out Mercurial-related files
FILES=$( echo "$FILES" | grep -v ".svn" ) # Filter out SVN-related files
FILES=$( echo "$FILES" | grep -v ".project" ) # Filter out Eclipse project file
FILES=$( echo "$FILES" | grep -v ".buildpath" ) # Filter out Eclipse buildpath file
FILES=$( echo "$FILES" | grep -v "$TARGET" ) # Filter out target file
FILES=$( echo "$FILES" | grep -v "^./$" ) # Filter out current directory listing

if [ "$1" = "--debug" ]; then # Don't concatenate all files if debugging
	echo "$FILES" | zip -9 -@ "$TARGET" # Add in all resources
	exit
fi

# Concatenate all source files together into a single file to improve compression
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

rm "$BRSALL" # Remove monolithic source file
