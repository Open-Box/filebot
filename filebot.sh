#!/bin/bash

################################################################################
# FileBot V 0.1                                                                #
# Author: Gianluca Farinelli <g.farinelli@open-box-it>                         #
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

      checkFileTypeForAction $FILETYPE
      echo $FILEACTION
    done
}

checkFileTypeForAction ()
{
    ORIGINALIFS="$IFS"
    IFS='='
    
    for FILETYPEACTION in $FILETYPES;
    do
        read -a TYPEACTION <<< "${ns}"
    done

    IFS="$ORIGINALIFS"
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