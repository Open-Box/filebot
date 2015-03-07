#!/bin/bash

################################################################################
# FileBot V 0.1                                                                #
# Authors:                                                                     #
# - Gianluca Farinelli <g.farinelli@open-box-it>                                 #
# - Alberto Romiti <a.romiti@open-box.it>                                        #
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
    LOGDESTINATIONS=$(cat $1 | ./vendor/shyaml/shyaml get-value log.destinantions)
    LOGFOLDER=$(cat $1 | ./vendor/shyaml/shyaml get-value log.folder)
    LOGEMAILS=$(cat $1 | ./vendor/shyaml/shyaml get-value log.mails)
    LOGFILEPREFIX=$(cat $1 | ./vendor/shyaml/shyaml get-value log.fileprefix)
    LOGMAILSUBJECT=$(cat $1 | ./vendor/shyaml/shyaml get-value log.mailsubject)
    LOGFILENAME=$(cat $1 | ./vendor/shyaml/shyaml get-value log.filename)"@"$(date "+%d-%m-%Y-%H-%M-%S")".log"
}

################################################################################
# Actions parser                                                               #
################################################################################
parseActions ()
{
    source $1/*
}


# Logger
logMessage()
{
  # Controlla se inserire il timestamp nel messaggio di log
  if [ "$2" = "NT" ]; then
    MESSAGE=$1
  else
    MESSAGE=$(date "+%Y-%m-%d %H:%M:%S")" - $1"
  fi
  
  # Controlla a quali destinazioni inviare il messaggio di log
  # in base al valore della variabile LOGDESTINATIONS
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
    MYSTRING="${FILETYPES//=/ }" 
    read -a MYARR <<<$MYSTRING
    TLEN=${#MYARR[@]}
      for (( i=0; i<${TLEN}; i++ ));
       do
        if [ "$FILETYPE" = "${myArr[$i]}" ]; then
         echo "Match found: " $FILETYPE "=" ${myArr[$i]}
         i=$((i+1))
         ${MYARR[$i]} $FILE
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
parseConfig $CONFIGFILE
parseActions $ACTIONSFOLDER
botMain
