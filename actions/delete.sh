#!/bin/bash

delete ()
{
    rm $1
    logMessage "File has been deleted: $1 "
}