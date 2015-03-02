#!/bin/bash

# FileBot V 0.1
# Author: Gianluca Farinelli <g.farinelli@open-box-it>

CONFIGFILE=./config/config.yml

################################################################################
# Configuration parser                                                         #
################################################################################
parseConfig ()
{
    COMMAND=$(cat $1 | ./vendor/shyaml/shyaml get-value command.executable)
    COMMANDOPTIONS=$(cat $1 | ./vendor/shyaml/shyaml get-value command.options)

    FOLDERLIST=$(cat $1 | ./vendor/shyaml/shyaml get-values directories)
    FILETYPES=$(cat $1 | ./vendor/shyaml/shyaml get-values filetypes)

}

scanFolder ()
{
  for FILE in $FOLDERFILES;
  do
    $COMMAND $COMMANDOPTIONS $FILE
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
    #scanFolder $FOLDERFILES
  done

  for FILETYPE in $FILETYPES;
  do
    echo $FILETYPE
  done
}

################################################################################
# Script runner                                                                #
################################################################################
parseConfig $CONFIGFILE
botMain