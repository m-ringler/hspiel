<?xml version="1.0" encoding="UTF-8" ?>
<!--
(c) Moritz Ringler, 2009
Dieses XSLT stylesheet wandelt die Ausgabe von hoerdat-parser.xsl
in ein RSS 2.0 XML-Dokument um.

Und so macht man das:
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
         - -stringparam mp3-file-size $mp3filesize \
         - -stringparam mp3-file-uri "$mp3fileuri" \
         - -stringparam pubDate "$pubdate" \
         - -stringparam old-rss-file "$oldrssfile" \
         podcast.xsl \
        "${mp3file%%mp3}xml")
if [[ $? -eq 0 ]]
then
    echo "$newxml" > $rssfile
fi
-->
<xsl:transform version="1.0" exclude-result-prefixes="html hoerdat xs xsl" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:hoerdat="http://hspiel.mospace.de/hoerdat/1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:strip-space elements="hoerdat:*"/>
    <xsl:preserve-space elements="hoerdat:Inhaltsangabe"/>
    <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
    <xsl:param name="mp3-file-uri" select="''"/>
    <xsl:param name="mp3-file-size" select="''"/>
    <xsl:param name="pubDate" select="''"/>
    <xsl:param name="old-rss-file" select="''"/>
    <xsl:variable name="basename">
        <xsl:call-template name="basename">
            <xsl:with-param name="name" select="$mp3-file-uri"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="parent-uri" select="substring-before($mp3-file-uri, $basename)"/>
    <xsl:variable name="guid" select="concat('/', $basename)"/>

    <xsl:template match="/">
        <rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">

            <!-- Erzeuge neues item-Element -->
            <xsl:variable name="newitem">
                <xsl:apply-templates select="descendant::hoerdat:Sendung"/>
            </xsl:variable>

            <!-- Erzeuge channel-Element -->
            <xsl:choose>

                <!-- Parameter old-rss-file angegeben -->
                <xsl:when test="$old-rss-file">
                    <xsl:variable name="oldchannel" select="document($old-rss-file)//channel"/>
                    <xsl:choose>
                        <!-- old-rss-file enthält channel-Element -->
                        <xsl:when test="$oldchannel">
                            <xsl:apply-templates select="$oldchannel">
                                <xsl:with-param name="newitem" select="$newitem"/>
                            </xsl:apply-templates>
                        </xsl:when>

                        <!-- Ladefehler oder kein channel-Element -->
                        <xsl:otherwise>
                            <xsl:call-template name="create-new-channel">
                                <xsl:with-param name="newitem" select="$newitem"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>

                <!-- Kein old-rss-file -->
                <xsl:otherwise>
                    <xsl:call-template name="create-new-channel">
                        <xsl:with-param name="newitem" select="$newitem"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </rss>
    </xsl:template>

    <!-- Fügt item zu existierendem channel hinzu -->
    <xsl:template match="channel">
        <xsl:param name="newitem"/>
        <xsl:copy select="$oldrss//channel">
            <xsl:apply-templates select="*[not(name() = 'item')]|itunes:*"/>
            <xsl:copy-of select="$newitem"/>
            <xsl:apply-templates select="item[not(guid/text() = $guid)]"/>
        </xsl:copy>
    </xsl:template>

    <!-- Erzeugt neues channel-Element -->
    <xsl:template name="create-new-channel">
        <xsl:param name="newitem"/>
        <channel>
            <title>Mit record.sh aufgenommene Hörspiele</title>
            <description>Enthaelt die mit record.sh aufgenommene Hörspiele als Podcast.</description>
            <link>
                <xsl:value-of select="$parent-uri"/>
            </link>
            <language>de</language>
            <generator>http://hspiel.mospace.de/xslt/podcast.xsl</generator>
            <pubDate>
                <xsl:value-of select="$pubDate"/>
            </pubDate>
            <lastBuildDate>
                <xsl:value-of select="$pubDate"/>
            </lastBuildDate>
            <itunes:explicit>no</itunes:explicit>
            <itunes:category text="Arts">
                <itunes:category text="Literature"/>
            </itunes:category>
            <xsl:copy-of select="$newitem"/>
        </channel>
    </xsl:template>

    <xsl:template name="basename">
        <xsl:param name="name"/>
        <xsl:variable name="next" select="substring-after($name, '/')"/>
        <xsl:choose>
            <xsl:when test="$next">
                <xsl:call-template name="basename">
                    <xsl:with-param name="name" select="$next"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Überschreibe pubDate und lastBuildDate mit aktuellem Datum -->
    <xsl:template match="pubDate|lastBuildDate">
        <xsl:copy>
            <xsl:value-of select="$pubDate"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="hoerdat:Sendung">
        <item>
            <xsl:apply-templates select="hoerdat:*"/>
            <enclosure url="{$mp3-file-uri}" length="{$mp3-file-size}" type="audio/mpeg"/>
            <pubDate>
                <xsl:value-of select="$pubDate"/>
            </pubDate>
            <link>
                <xsl:value-of select="$mp3-file-uri"/>
            </link>
            <guid isPermaLink="false">
                <xsl:value-of select="$guid"/>
            </guid>
        </item>
    </xsl:template>


    <xsl:template match="hoerdat:Titel">
        <xsl:variable name="t" select="normalize-space(text())"/>
        <xsl:variable name="hatUntertitel" as="xs:boolean" select="contains($t,'(')"/>
        <title>
            <xsl:choose>
                <xsl:when test="$hatUntertitel">
                    <xsl:value-of select="normalize-space(substring-before($t,'('))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$t"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="../hoerdat:Sendetermine" mode="titel"/>
        </title>
        <xsl:if test="$hatUntertitel">
            <xsl:variable name="untertitel" select="substring-before(substring-after($t,'('),')')"/>
            <xsl:if test="$untertitel">
                <itunes:subtitle>
                    <xsl:value-of select="$untertitel"/>
                </itunes:subtitle>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="hoerdat:Autoren">
        <itunes:author>
            <xsl:value-of select="text()"/>
        </itunes:author>
    </xsl:template>

    <xsl:template match="hoerdat:Inhaltsangabe">
        <xsl:variable name="t" select="substring(normalize-space(.), 0, 4000)"/>
        <description>
            <xsl:value-of select="$t"/>
        </description>
        <itunes:summary>
            <xsl:value-of select="$t"/>
        </itunes:summary>
    </xsl:template>

    <xsl:template match="hoerdat:Produktion">
        <dc:rights>
        <!-- Produzierender Sender als Label/Publisher -->
            <xsl:value-of select="substring-before(text(), ' ')"/>
            <xsl:text></xsl:text>
        <!-- Produktionsjahr -->
            <xsl:value-of select="substring(substring-after(text(), ' '),1, 4)"/>
        </dc:rights>
    </xsl:template>

    <xsl:template match="hoerdat:Sendetermine" mode="titel">
        <xsl:if test="contains(text(), 'Teil')">
            <xsl:value-of select="concat(' (',normalize-space(substring-before(substring-after(text(), 'Teil'),'/')),')')" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="hoerdat:*"/>

    <!-- By default copy everything -->
    <xsl:template match="*|text()|@*">
        <xsl:call-template name="clone"/>
    </xsl:template>

    <xsl:template name="clone">
        <xsl:param name="what" select="."/>
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

</xsl:transform>


