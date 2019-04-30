#!/bin/bash

#   Accepts 'deleteAll' as extra argument
#   If 'deleteAll' passed, will allow to delete Valid(unexpired) profiles too
#
#   Usage:
#   sh ppc.sh
#   sh ppc.sh deleteAll

kDeleteAll="deleteAll"
kHelp="help"; kMan="man"
user="$(whoami)"
paths=("AppIDName" "CreationDate" "ExpirationDate" "Name" "TeamName" "Entitlements:application-identifier" )
plistBuddy=/usr/libexec/PlistBuddy
arg=$1

adjustedStr()
{
    strartStr=$1
    neededLen=$2
    startLen=${#strartStr}
    lenDiff=$(($neededLen - $startLen))
    space=$(printf "%0.s." $(seq 1 $lenDiff))

    echo $strartStr$space
}

tryDelete()
{
    echo "\n"
    read -p "Do you want to delete $1? (Y/N): " delete

    if [ "$delete" = "Y" ] || [ "$delete" = "y" ]; then
        rm $1
        echo "Deleted $1"
    fi
}

#Flow

if [ "$arg" = "$kHelp" ] || [ "$arg" = "$kMan" ]; then
    nl="\n"

    echo $nl$nl$nl\
    "<----------------------------------------------------------------------->"\
    $nl$nl\
    "Accepts 'deleteAll' as extra argument"\
    $nl\
    "If 'deleteAll' passed, will allow to delete Valid(unexpired) profiles too"\
    $nl$nl\
    "Usage:"\
    $nl\
    "sh ppc.sh"\
    $nl\
    "sh ppc.sh deleteAll"\
    $nl$nl\
    "<----------------------------------------------------------------------->"\
    $nl$nl$nl
    exit 0
fi

if pgrep -x "Xcode" > /dev/null; then
    read -p 'This will close Xcode! Proceed?(Y/N)' proceed
    if [ "$proceed" = "Y" ] || [ "$proceed" = "y" ]; then
        killall Xcode
    else
        exit 0
    fi
fi

cd /Users/$user/Library/MobileDevice/Provisioning\ Profiles

minAppLen=7
maxLen=0
for e in "${paths[@]}"; do
    len=${#e}

    if [ $len -gt $maxLen ]; then
        maxLen=$len
    fi
done

maxLen=$(($maxLen+$minAppLen))

for file in *; do
    echo "\n\n"

    kfilename="Filename"
    echo "$(adjustedStr $kfilename $maxLen)$file"

    for path in "${paths[@]}"; do
        echo $(adjustedStr $path $maxLen)"$($plistBuddy -c "Print :$path" /dev/stdin <<< $(security cms -D -i $file))"
    done

    datestr="$($plistBuddy -c "Print :ExpirationDate" /dev/stdin <<< $(security cms -D -i $file))"
    expts=$(date -j -f "%a %b %d %T %Z %Y" "$datestr" "+%s")
    cts=$(date +%s)

    spacedExpirrationStr=$(adjustedStr "Expiration status" $maxLen)

    if [ $expts -gt $cts ]; then
        echo $spacedExpirrationStr"VALID"

        if [ "$kDeleteAll" = "$arg" ]; then
            tryDelete $file
        fi
    else
        echo $spacedExpirrationStr"INVALID"
        tryDelete $file
    fi
done
