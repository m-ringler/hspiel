<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
(c) Moritz Ringler, 2009
Dieses XSLT stylesheet versucht aus mehreren von hoerdat-parser.xsl 
gefundenen Sendungen die richtige herauszufinden, indem es den Sendetermin
der Sendungen mit dem parameter day-hour-minute vergleicht.

Zuletzt geändert 2009-01-22

Und so macht man das:                                                                                                 
    xsltproc -''-stringparam day-hour-minute 19-00-01 hoerdat-select.xsl hoerdat.xml > hoerdat-selected.xml
bzw.
    saxon hoerdat.xml hoerdat-select.xsl day-hour-minute=19-00-01
    
oder:
    xsltproc -''-stringparam day-hour-minute $(date +'%d-%H-%m') hoerdat-select.xsl hoerdat.xml > hoerdat-selected.xml
bzw.
    saxon hoerdat.xml hoerdat-select.xsl day-hour-minute=$(date +'%d-%H-%m')
-->
<xsl:transform version="1.0" 
    exclude-result-prefixes="html hoerdat xs xsl" 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns="http://hspiel.mospace.de/hoerdat/1" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:hoerdat="http://hspiel.mospace.de/hoerdat/1" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="day-hour-minute" as="xs:string" select="''"/>
    <xsl:param name="max-offset" as="xs:integer" select="10"/>
    <xsl:template match="/">
        <Hoerdat>
        <xsl:apply-templates select="descendant::hoerdat:Sendung"/>
        </Hoerdat>
    </xsl:template>
    
    <!-- tries to select a sendung that starts less than $offset-max minutes 
         after the time specified with the day-hour-minute parameter.
         this will not work if the sendung starts in the next month -->  
    <xsl:template match="hoerdat:Sendung">
        <!-- parse the day-hour-minute parameter -->
        <xsl:variable name="day" select="number(substring-before($day-hour-minute,'-'))"/>
        <xsl:variable name="hm" select="substring-after($day-hour-minute,'-')"/>
        <xsl:variable name="hour" select="number(substring-before($hm,'-'))"/>
        <xsl:variable name="min" select="number(substring-after($hm,'-'))"/>
        <xsl:variable name="dhm" select="((24 * $day) + $hour)*60 + $min"/>
        
        <!-- parse the sendetermin -->
        <xsl:variable name="sendetermin" select="normalize-space(substring-after(hoerdat:Sendetermine/text(),','))"/>
        <xsl:variable name="sday" select="number(substring-before($sendetermin,'.'))"/>
        <xsl:variable name="shm" select="substring(substring-after($sendetermin,'.'), 11,5)"/>
        <xsl:variable name="shour" select="number(substring-before($shm,':'))"/>
        <xsl:variable name="smin" select="number(substring-after($shm,':'))"/>
        <xsl:variable name="sdhm" select="((24 * $sday) + $shour)*60 + $smin"/>
        
        <!-- compare -->
        <xsl:variable name="delta" select="$sdhm - $dhm"/>
        <xsl:if test="$delta &gt; -1 and $delta &lt; $max-offset">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>

</xsl:transform>


