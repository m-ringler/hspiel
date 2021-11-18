#!/bin/bash
## THIS PROGRAM COMES WITHOUT ANY WARRANTY
## USE AT YOUR OWN RISK!
##
## Nimmt Webradio auf.
## Die Originalversion geht zurück auf
## http://groups.google.com/group/de.comp.os.unix.shell/browse_thread/thread/e215f94ccf572331
## $Id$
##
## USAGE:
## record.sh (start|stop|status) <sendername> <sendung>
##
## Dieses Skript ist dafuer gedacht als cron job zu laufen.
## Ein crontab Eintrag wuerde dabei typischerweise so aussehen:
## 00 10 * * 6 record.sh start wdr5 WDR5_Krimi_am_Samstag
## 00 11 * * 6 record.sh stop  wdr5 WDR5_Krimi_am_Samstag
##
## Wenn das Ergebnis ein anderes Format als mp3 hat, kann es in
## der Regel nur mit mplayer wiedergegeben werden.
##

## Setzt das Home-Verzeichnis wenn es noch nicht gesetzt ist
if [[ -z $HOME ]]
then
    HOME=/home/$(whoami)
fi

## MPlayer-Aufruf als UNIX-Pfad
## Unter cygwin können Sie den Befehl
## cygpath -ua 'C:\Programme\mplayer\mplayer.exe'
## benutzen, um den richtigen Pfad zu bekommen.
mplayer="/usr/bin/mplayer"

## Das Zielverzeichnis, in dem die Aufnahmen gespeichert werden.
## Unter Windows muss das ein Windows-Pfad sein.
#dest='C:\Benutzer\HoerspielNutzer\Downloads\Hoerspiele'
dest="$HOME/aufnahmen"

## Automatisches Herunterladen von Metadaten (s. a. Nachverarbeitung)
## Dokumentation unter http://hspiel.mospace.de/autotag.html
## Bitte erwaegen Sie eine Spende an hoerdat!
hoerdat_html=true
hoerdat_xml=true     # geht nur mit hoerdat_html
hoerdat_id3=false     # geht nur mit hoerdat_xml
hoerdat_sh=false      # geht nur mit hoerdat_id3

## Schneiden (siehe http://hspiel.mospace.de/mp3autocut.html)
## Nicht schneiden:
autocut=
## Schnitt-Dateien fuer Mp3DirectCut
# autocut=mpd
#mp3autocut="java -jar -DHoerdatExtraMins=5.0 $dest/mp3autocut.jar"
## Direkt schneiden
#autocut=mp3
#mp3autocut="java -jar -DHoerdatExtraMins=5.0 $dest/mp3autocut.jar"

## Taggen (siehe unter http://hspiel.mospace.de/autotag.html)
run_hoerdat_sh=false  # geht nur mit hoerdat_sh

## RSS 2.0 XML-Datei fuer Podcatcher erzeugen.
## Podcast funktioniert beispielsweise mit gpodder.
## geht nur mit hoerdat_xml
podcast=false

## Wenn nicht gesetzt
#podcastbaseuri=file:///$dest
## Local web server, e.g. a NanoHTTPD started with
## java NanoHTTPD -p 8081
#ipaddr=$(ip -4  addr show scope global  | awk '$1=="inet" { print $2 }' | cut -d'/' -f1  | head -n 1)
if [[ -n "$ipaddr" ]]
then
    podcastbaseuri=http://$ipaddr:8081
else
    podcastbaseuri=
fi

## Wenn nicht gesetzt:
#rssfile=rss.xml
rssfile=

## Wenn nicht gesetzt
#oldrssfile=$podcastbaseuri/$rssfile
oldrssfile="file:///$dest/$rssfile"
#oldrssfile=

## Zusätzliche mplayer-Argumente.
#  mplayerflags="-priority belownormal"
mplayerflags="-nolirc -prefer-ipv4"

## UNIX-Pfad oder Adresse der Datei mit den Daten der Webradios.
## Für jeden Sender gibt es einen Eintrag der Form
## STATIONNAME URL TYPE
## wobei TYPE entweder smil, m3u, asx ist (für Playlists)
## oder die richtige Erweiterung fuer das betreffende Dateiformat.
## Weder URL noch STATIONNAME duerfen Leerzeichen enthalten,
## ersetzen Sie Leerzeichen in URLs durch %20.
# /cygdrive/c/Benutzer/HoerspielNutzer/livestreams.txt
# streams="/usr/share/streams.dat"
streams="http://hspiel.mospace.de/livestreams.txt"

## Lokale Datei, die die Daten in $streams ergänzt oder überschreibt.
## Kann auch ungesetzt bleiben.
# localstreams=
# localstreams="$HOME/share/livestreams.txt"
localstreams="$dest/livestreams.txt"

## Eine temporäre Datei, in der die Prozess-ID einer Aufnahme abgelegt, wird.
## Der Name muss für 'start' und 'stop' gleich sein.
pidfile="$dest/.$3-mplayer.pid"

## Wohin Fehler geschrieben werden.
## Auf das Terminal (stderr)
#errors=/dev/stderr
## Ignorieren
#errors=/dev/null
errors="$dest/.record.sh.log"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# AB HIER MUSS FUER GEWOEHNLICH NICHTS MEHR GEAENDERT WERDEN!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# error codes
E_FILE_EXISTS=42
E_NO_STREAM_URL=43
E_NO_STREAM_TYPE=44
E_WRONG_NUMBER_OF_ARGUMENTS=45
E_LOCKFILE_FOUND=46

# Returns url and type for a station name
# @param station the name of the station
# @return a single string consisting of
#  stationname, url and type separated by a blank
stream(){
    local station=$1
    result=""
    if [[ -f "$localstreams" ]]
    then
        result=$( grep -m 1 -e ^${station} "$localstreams" )
    fi
    if [[ -z "$result" ]]
    then
        if [[ ${streams:0:7} = "http://" ]]
        then
            result=$( curl $streams 2> /dev/null | grep -m 1 -e ^${station})
        else
            grep -m 1 -e ^${station} "$streams"
        fi
    fi
    echo $result
}

# Starts recording a livestream from a station
# @param station the station name
# @param alias a name for the recording
start(){
    local station=$1
    local alias=$2
    local stream=(`stream $station`)
    local url=${stream[1]}
    local type=${stream[2]}
    local dayHourMinute=$(date +'%d-%H-%M')

    if [[ $# -ne 2 ]]
    then
        usage
        return $E_WRONG_NUMBER_OF_ARGUMENTS
    fi

    if [[ -z $url ]]
    then
        echo "No stream URL for $station" >> "$errors"
        return $E_NO_STREAM_URL
    fi

    if [[ -z $type ]]
    then
        echo "No stream type for $station" >> "$errors"
        return $E_NO_STREAM_TYPE
    fi

    local playlist=""
    #handle playlists
    if [[ "$type" = "smil" || "$type" = "rm" ]]
        then
        type="ra"
        playlist="-playlist"
    elif [[ "$type" = "m3u" ]]
        then
        type="mp3"
        playlist="-playlist"
    elif  [[ "$type" = "asx" ]]
        then type="wma"
        playlist="-playlist"
    fi

    if test -f "$pidfile"
        then
        echo "Lockfile found!"
        return $E_LOCKFILE_FOUND
    fi
    echo $$ > $pidfile

    dat=`date '+%Y-%m-%d'`
    fname="${alias}_${dat}"
    CYG="$(uname  | grep CYGWIN)"
    if [[ -n "$CYG" ]]
    then
        file="${dest}\\${fname}.${type}"
    else
        file="${dest}/${fname}.${type}"
    fi

    if test -f "$file"
        then
        echo "Target file $file exists." >> "$errors"
        return $E_FILE_EXISTS
    fi
    #echo $file
    # unfortunately -endpos does not work with -dumpstream so we cannot use that to terminate mplayer
    "$mplayer" $playlist $url $mplayerflags -msglevel all=2 -dumpstream -dumpfile "$file"  >/dev/null 2>>"$errors" <&2 &
    if [[ ! $? ]]
    then
        echo "FAILED: $mplayer $playlist $url $mplayerflags -msglevel all=2 -dumpstream -dumpfile $file"
        return $?
    fi
    echo $! >$pidfile
    disown

    echo "$file" >> $pidfile

    if [[ "$hoerdat_html" = "true" ]]
    then
        local html="${dest}/${fname}.html"
        local xmln="${dest}/${fname}.xml"
        local xml1="${dest}/${fname}~1.xml"
        local id3="${dest}/${fname}.id3"
        local sh="${dest}/${fname}.sh"
        local mp3="${fname}.mp3"
        local hoerdatsender=
        case $station in
        einslive)
            hoerdatsender=wdr
            ;;
        *)
            # use first three letters with numbers removed
            hoerdatsender=$(echo ${station:0:3} | sed 's/[0-9]//')
            ;;
        esac

        curl -s http://www.xn--hrdat-jua.de/index.php?dat=${dat}\&sender=${hoerdatsender} \
            | tidy -asxhtml -numeric \
            > "$html" \
            2> /dev/null
        if [[ "$hoerdat_xml" == true ]]
        then

            # Extract data as XML from XHTML
            xsltproc -novalid -nodtdattr http://hspiel.mospace.de/xslt/hoerdat-parser2.xsl "$html" \
                > "${xmln}" \
                2>> "$errors"
            # Try to select the currently running program
            xsltproc --stringparam day-hour-minute $dayHourMinute \
                http://hspiel.mospace.de/xslt/hoerdat-select.xsl \
                "${xmln}" \
                > "${xml1}" \
                2>> "$errors"
            # If we have found a matching entry use it, else remove the empty output file
            if [[ $(stat -c %s "${xml1}") -gt "80" ]]
            then
                mv "${xml1}" "${xmln}"
            else
                rm "${xml1}"
            fi

            if [[ "$hoerdat_id3" == "true" ]]
            then
                # Generate ID3 XML
                xsltproc http://hspiel.mospace.de/xslt/hoerdat-id3.xsl "${xmln}" \
                    > "$id3" \
                    2>> "$errors"

                if [[ "$hoerdat_sh" == "true" ]]
                then
                    # Generate bash script for tagging
                    echo '#!/bin/bash' > "$sh"
                    cmd=$(xsltproc http://hspiel.mospace.de/xslt/id3-bash.xsl "$id3") \
                        >> "$sh" \
                        2>> "$errors"
                    echo $cmd $mp3 >> "$sh"
                fi
            fi
        fi
    fi

}

# pgrep substitute
function _pgrep_(){
    if which pgrep >/dev/null 2>/dev/null
    then
        pgrep $1
    elif [[ $(uname -o) == 'Cygwin' ]]
    then
        ps -e | awk '
        NR==1 {
            for (c=1;c<=NF;c++){
                if ($c == "PID") {
                    break;
                }
            }
        };
        match($0, prog) {
            print $c;
        }' prog="$1"
    else
        ps -eopid,comm | grep mplayer | grep -v grep | awk '{print $1}'
    fi
}

# Creates or extends an RSS 2.0 podcast file
# @param audiofile the absolute path of the audio file
makepodcast(){
    audiofile=$1
    hoerdatxml="${audiofile%%mp3}xml"
    if [[ "$podcast" == "true" && -f "$hoerdatxml" ]]
    then
        mp3="$audiofile"

        if [[ -z $podcastbaseuri ]]
        then
            podcastbaseuri="file:///$dest"
        fi

        fname=$(basename "$mp3")
        mp3fileuri="$podcastbaseuri/$fname"
        mp3filesize=$(stat -c %s "$mp3")
        pubdate=$(date -R)

        if [[ -z $rssfile ]]
        then
            rssfile=rss.xml
        fi

        rsspath="$dest/$rssfile"

        oldrssfileuri=$podcastbaseuri/$rssfile

        newxml=$(xsltproc \
            --stringparam mp3-file-size $mp3filesize \
            --stringparam mp3-file-uri "$mp3fileuri" \
            --stringparam pubDate "$pubdate" \
            --stringparam old-rss-file "$oldrssfileuri" \
            http://hspiel.mospace.de/xslt/podcast.xsl \
            "$hoerdatxml") 2>> "$errors"
        if [[ $? -eq 0 ]]
        then
            echo "$newxml" > $rsspath
        fi
    fi
}

# Performs autocutting if autocutting is active
# @param audiofile
cut(){
    audiofile=$1
    if [[ -n "$autocut" && -n "$mp3autocut" ]]
    then
        if [[ "$autocut" -eq "mp3" ]]
        then
            $mp3autocut mp3 /var/tmp "$audiofile" >/dev/null 2>> /dev/null
            tmpfile=/var/tmp/$(basename "$audiofile")
            if [[ -f "$tmpfile" ]]
            then
                mv "$audiofile" "$audiofile.original"
                mv /var/tmp/$(basename "$audiofile") "$audiofile"
            fi
        else
            $mp3autocut "$autocut" "$audiofile" >/dev/null 2>> /dev/null
        fi
    fi
}

# Performs autotagging if autotagging is active.
# @param audiofile The file to tag
tag(){
    audiofile=$1
    hoerdatsh="${audiofile%%mp3}sh"
    if [[ "$run_hoerdat_sh" -eq "true" && -f "$hoerdatsh" ]]
    then
        olddir=$PWD
        cd $dest
        source $hoerdatsh 2>> "$errors"
        cd $olddir
    fi
}


# Stops recording a livestream from a station
stop(){
    audiofile=
    if test -f "$pidfile"
        then

        # retrieve the pid from the pidfile
        pid=`head -n 1 "$pidfile"`

        # read the audio file name from the pidfile
        audiofile=$(tail -n +2 "$pidfile" | head -n 1)

        # try to terminate mplayer nicely
        kill -SIGTERM $pid >/dev/null 2>/dev/null

        # give mplayer 2 seconds to terminate
        sleep 2

        # if the mplayer process is still running: kill it
        while [[ $(ps -p $pid  | grep $pid) != "" ]]
        do
            echo record.sh stop: Trying to kill process $pid at `date` >> "$errors"
            kill -KILL $pid >/dev/null 2>/dev/null

            # wait for 5 seconds before trying again
            sleep 5
        done
        rm -f $pidfile
    else
        echo record.sh stop: pidfile missing >> "$errors"

        # no pid? kill all mplayers
        # could use pgrep, but as far as I remember that does not work on Cygwin
        for psid in $(_pgrep_ mplayer)
        do
            echo record.sh stop: Trying to kill $psid at `date` >> "$errors"
            kill -KILL $psid 2>> "$errors"
        done
    fi

    # post-processing
    if [[ -n "$audiofile" ]]
    then
        cut $audiofile
        tag $audiofile
        makepodcast $audiofile
    fi
}

# Prints whether we are currently recording
status(){
    if test -f "$pidfile"
        then
        echo "Mplayer is recording $1"
    else
        echo "Mplayer is not recording $1"
    fi
}

# Displays a usage message
usage(){
    echo "Usage: $0 {start|stop|status} station alias"
}

#main
case "$1" in
start)
    start $2 $3
    error=$?
    if let $error
    then
        echo "\"$0 $*\" failed with error code $error" >> "$errors"
        exit $?
    fi
;;
stop)
    stop
;;
status)
    status $3
;;
*)
    usage
;;
esac
