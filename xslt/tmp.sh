mp3file="$1"
baseuri="file:///$PWD"
mp3fileuri="$baseuri/$mp3file"
mp3filesize=$(stat -c %s "$mp3file")
pubdate=$(date -R)
rssfile=test.xml
oldrssfile=
if [[ -f "$rssfile" ]]
then
    oldrssfile="$rssfile"
fi

newxml=$(xsltproc \
         --stringparam mp3-file-size $mp3filesize \
         --stringparam mp3-file-uri "$mp3fileuri" \
         --stringparam pubDate "$pubdate" \
         --stringparam old-rss-file "$oldrssfile" \
         podcast.xsl \
        "${mp3file%%mp3}xml")
if [[ $? -eq 0 ]]
then
    echo "$newxml" > $rssfile
fi
