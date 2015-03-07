#!/bin/bash

################################################################################
# FileBot V 0.1                                                                #
# Authors:                                                                     #
# Gianluca Farinelli <g.farinelli@open-box-it>                                 #
# Alberto Romiti <a.romiti@open-box.it>                                        #
################################################################################
CONFIGFILE=./config/config.yml
declare -A FILETYPES

################################################################################
# Configuration parser                                                         #
################################################################################
parseConfig ()
{
    COMMAND=$(cat $1 | ./vendor/shyaml/shyaml get-value command.executable)
    COMMANDOPTIONS=$(cat $1 | ./vendor/shyaml/shyaml get-value command.options)

    FOLDERLIST=$(cat $1 | ./vendor/shyaml/shyaml get-values directories)
    FILETYPES=$(cat $1 | ./vendor/shyaml/shyaml get-values filetypes)
    ACTIONSFOLDER=$(cat $1 | ./vendor/shyaml/shyaml get-value actionFolder)
}

################################################################################
# Actions parser                                                               #
################################################################################
parseActions ()
{
    source $1/*
}

################################################################################
# Folder file scanner                                                          #
################################################################################
scanFolder ()
{
    for FILE in $FOLDERFILES;
    do
      FILETYPE=$($COMMAND $COMMANDOPTIONS $FILE) 
      echo "Scanning: " $FILE ">" $FILETYPE
     if [ ! -d "$FILE" ]; then
      checkFileTypeForAction $FILETYPE
      echo $FILEACTION
      $FILEACTION
     fi
    done
}

checkFileTypeForAction ()
{
    myString="${FILETYPES//=/ }" 
    read -a myArr <<<$myString
    tLen=${#myArr[@]}
      for (( i=0; i<${tLen}; i++ ));
       do
        if [ "$FILETYPE" = "${myArr[$i]}" ]; then
         echo "Match found: " $FILETYPE "=" ${myArr[$i]}
         i=$((i+1))
         ${myArr[$i]} $FILE
        fi 
      done
}
################################################################################
# Main                                                                         #
################################################################################
botMain ()
{
    for FOLDER in $FOLDERLIST;
    do
      FOLDERFILES=$(ls -1d $FOLDER/*)
      scanFolder $FOLDERFILES
    done
}

################################################################################
# Script runner                                                                #
################################################################################
parseConfig $CONFIGFILE
parseActions $ACTIONSFOLDER
botMain