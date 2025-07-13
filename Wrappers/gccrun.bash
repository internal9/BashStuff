#!/bin/bash

# may support multiple files in future
# add versioning for backups?

STD="c99"

if [ "$#" -ne 1 ]; then
	echo "gccrun: Expected only one file to make executable"
	exit 1
fi

C_FILE="$1"

if [ ! -f "$C_FILE" ]; then
	echo "gccrun: file '$C_FILE' doesn't exist, can't make executable"
	exit 1
fi

if [[ "$C_FILE" != *.c ]]; then
	echo "gccrun: file '$C_FILE' doesn't have '.c' file extension, can't make executable"
	exit 1
fi

EXE_FILE_NAME="${C_FILE%.c}"

sig_int_during_gcc(){
	echo "gccrun:SIGINT sent during gcc may have rendered executable incomplete"
	exit 130
}

replace_existing_exe() {
	rm "$EXE_FILE_NAME"
	gcc -std=$STD -o "$EXE_FILE_NAME" "$C_FILE"
}

if [ -f $EXE_FILE_NAME ]; then
	if [ ! -x $EXE_FILE_NAME ]; then
		echo "gccrun: cannot make executable since non-executable '$EXE_FILE_NAME' exists but is not executable, do you want to overwrite it with one? [Y]es, [N]o\n"
		read will_overwrite_non_exe

		if [ "$will_overwrite_non_exe" = "Y" ] || [ "$will_overwrite_non_exe" = "y" ]; then
			trap sig_int_during_gcc SIGINT
			replace_existing_exe
		else
			exit 0
		fi
	else
		trap sig_int_during_gcc SIGINT
		replace_existing_exe
	fi
else
	trap sig_int_during_gcc SIGINT	
	gcc -std=$STD -o "$EXE_FILE_NAME" "$C_FILE"
fi

# gcc errors won't stop this program
if [ ! -f $EXE_FILE_NAME ]; then
	exit 1
fi

./$EXE_FILE_NAME  
