#!/bin/bash

################################################################################
# FileBot V 0.1                                                                #
# Authors:                                                                     #
# - Gianluca Farinelli <g.farinelli@open-box-it>                               #
# - Alberto Romiti <a.romiti@open-box.it>                                      #
################################################################################
CONFIGFILE=./config/config.yml
declare -A FILETYPES

################################################################################
# Configuration parser                                                         #
################################################################################
parseConfig ()
{
    COMMAND=$(cat $1 | ./vendor/shyaml/shyaml get-value  $CONFIG.command.executable)
    COMMANDOPTIONS=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.command.options)

    FOLDERLIST=$(cat $1 | ./vendor/shyaml/shyaml get-values $CONFIG.directories)
    FILETYPES=$(cat $1 | ./vendor/shyaml/shyaml get-values $CONFIG.filetypes)
    ACTIONSFOLDER=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.actionFolder)
    LOGDESTINATIONS=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.log.destinantions)
    LOGFOLDER=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.log.folder)
    LOGEMAILS=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.log.mails)
    LOGFILEPREFIX=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.log.fileprefix)
    LOGMAILSUBJECT=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.log.mailsubject)
    LOGFILENAME=$(cat $1 | ./vendor/shyaml/shyaml get-value $CONFIG.log.filename)"@"$(date "+%d-%m-%Y-%H-%M-%S")".log"
}

################################################################################
# Actions parser                                                               #
################################################################################
parseActions ()
{
    source $1/*
}

typeConfig ()
{
 if [ -z "$1" ]; then
    CONFIG='default'
 else
   # Checks configuration exist
    CHECKCONFIG=$(cut -d' ' -f1 config/config.yml)
    STRING="${CHECKCONFIG//:/ }"
    read -a TMPARRAY <<<$STRING
    TLEN=${#TMPARRAY[@]}
     for (( i=0; i<${TLEN}; i++ ));
       do
        if [ "$1" = "${TMPARRAY[$i]}" ]; then 
         i=$((i+1))
         EXISTCONFIG=true
         break
        fi 
       done       
        if [ "$EXISTCONFIG" ]; then
         CONFIG="$1"
        else 
         echo "Configuration "$1 "not foud. Please check config file"
        exit
        fi
 fi
}

# Logger
logMessage()
{

    # Checks whenever timestamp must be set in log message                         
    if [ "$2" = "NT" ]; then
      MESSAGE=$1
    else
      MESSAGE=$(date "+%Y-%m-%d %H:%M:%S")" - $1"
    fi

    # Checks log message deestinations based on LOGDESTINATIONS
    # C = Console
    # F = File
    # S = Syslog
    if [[ "$LOGDESTINATIONS" =~ "C" ]]
    then
      echo $MESSAGE
    fi

    if [[ "$LOGDESTINATIONS" =~ "F" ]]
    then
      echo $MESSAGE >> $LOGFOLDER$LOGFILENAME
    fi

    if [[ "$LOGDESTINATIONS" =~ "S" ]]
    then
      logger -i -t -- $LOGFILEPREFIX" - "$MESSAGE
    fi
}

################################################################################
# Send mail                                                                    #
################################################################################
sendMail()
{
    for DESTEMAIL in $LOGEMAILS
    do
      if [ -s $LOGFOLDER$LOGFILENAME ];then
      mail -s "$LOGMAILSUBJECT" "$DESTEMAIL" < "$LOGFOLDER$LOGFILENAME"
      fi
    done
}

################################################################################
# Folder file scanner                                                          #
################################################################################
scanFolder ()
{
    for FILE in $FOLDERFILES;
    do
      FILETYPE=$($COMMAND $COMMANDOPTIONS $FILE) 
      #logMessage "Scanning: $FILE > $FILETYPE" NT
     if [ ! -d "$FILE" ]; then
      checkFileTypeForAction $FILETYPE
      $FILEACTION
     fi
    done
}

checkFileTypeForAction ()
{
    STRING="${FILETYPES//=/ }" 
    read -a TMPARRAY <<<$STRING
    TLEN=${#TMPARRAY[@]}
      for (( i=0; i<${TLEN}; i++ ));
       do
        if [ "$FILETYPE" = "${TMPARRAY[$i]}" ]; then
         echo "Match found: " $FILETYPE "=" ${TMPARRAY[$i]}
         i=$((i+1))
         ${TMPARRAY[$i]} $FILE
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
   if [ -s $LOGFOLDER$LOGFILENAME ];then
    sendMail
   fi
}

################################################################################
# Script runner                                                                #
################################################################################
typeConfig $1
parseConfig $CONFIGFILE
parseActions $ACTIONSFOLDER
botMain
