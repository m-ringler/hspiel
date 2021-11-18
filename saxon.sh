SAXON="java -jar saxonb9-1-0-5j/saxon9.jar"
$SAXON hspiel.xml hspiel.xsl
$SAXON hspiel.xml hspiel.xsl frames=yes
$SAXON hspiel.xml mplayer.xsl
#cp -v livestreams.txt /usr/share/streams.dat

