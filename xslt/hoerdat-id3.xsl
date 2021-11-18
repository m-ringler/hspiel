<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
(c) Moritz Ringler, 2009
Dieses XSLT stylesheet wandelt die Ausgabe von hoerdat-parser.xsl 
in ID3 XML um (RELAX NG Schema in Arbeit). Die ID3-XML-Datei kann dann mit 
einem Tag-Writer der ID3 XML versteht (oder solange noch kein solcher existiert 
mit id3-bash.xsl und id3v2) in die MP3-Datei geschrieben werden. 
Die Abbildung von Hoerdat-Elementen auf ID3-Frames entspricht meinen
persönlichen Vorlieben. Fühlen Sie sich frei Ihr eigenes Stylesheet zu 
schreiben.

Zuletzt geändert: 2009-01-25

Und so macht man das:                                                                                                 
    xsltproc hoerdat-id3.xsl hoerdat.xml > hoerdat.id3
bzw.
    saxon hoerdat.xml hoerdat-id3.xsl > hoerdat.id3
-->
<xsl:transform version="1.0" 
  exclude-result-prefixes="html hoerdat xs xsl" 
  xmlns="http://id3xml.sf.net/id3/2/4/0/" 
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hoerdat="http://hspiel.mospace.de/hoerdat/1" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:strip-space elements="hoerdat:*"/>
    <xsl:preserve-space elements="hoerdat:Inhaltsangabe"/>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <id3v2 version="2.4.0">
            <xsl:apply-templates select="descendant::hoerdat:Sendung"/>
        </id3v2>
    </xsl:template>

    <xsl:template match="hoerdat:Sendung">
        <tag>
            <xsl:apply-templates />
            <TCON>Hörspiel</TCON>
        </tag>
    </xsl:template>

    <xsl:template match="hoerdat:Titel">
        <xsl:variable name="t" select="normalize-space(text())"/>
        <xsl:variable name="hatUntertitel" as="xs:boolean" select="contains($t,'(')"/>
        <TIT2>
            <xsl:choose>
                <xsl:when test="$hatUntertitel">
                    <xsl:value-of select="normalize-space(substring-before($t,'('))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$t"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="../hoerdat:Sendetermine" mode="titel"/>
        </TIT2>
        <xsl:if test="$hatUntertitel">
            <xsl:variable name="untertitel" select="substring-before(substring-after($t,'('),')')"/>
            <xsl:if test="$untertitel">
                <TIT3>
                    <xsl:value-of select="$untertitel"/>
                </TIT3>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="hoerdat:Autoren">
        <!-- Autor als Künstler -->
        <TPE1>
            <xsl:value-of select="text()"/>
        </TPE1>
    </xsl:template>

    <xsl:template match="hoerdat:Inhaltsangabe">
        <COMM lang="deu" description="Inhaltsangabe">
            <xsl:value-of select="text()"/>
        </COMM>
    </xsl:template>

    <xsl:template match="hoerdat:Produktion">
        <!-- Produzierender Sender als Label/Publisher -->
        <TPUB>
            <xsl:value-of select="substring-before(text(), ' ')"/>
        </TPUB>
        <!-- Produktionsjahr -->
        <TDRC>
            <xsl:value-of select="substring(substring-after(text(), ' '),1, 4)"/>
        </TDRC>
    </xsl:template>

    <xsl:template match="hoerdat:Regisseure">
        <TPE3>
            <xsl:value-of select="."/>
        </TPE3>
    </xsl:template>

    <xsl:template match="hoerdat:Sendetermine">
        <xsl:if test="contains(text(), 'Teil')">
            <TPOS>
                <xsl:value-of select="normalize-space(substring-before(substring-after(text(), 'Teil'),'/'))" />
            </TPOS>
        </xsl:if>
    </xsl:template>

    <xsl:template match="hoerdat:Sendetermine" mode="titel">
        <xsl:if test="contains(text(), 'Teil')">
            <xsl:value-of select="concat(' (',normalize-space(substring-before(substring-after(text(), 'Teil'),'/')),')')" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>
</xsl:transform>


