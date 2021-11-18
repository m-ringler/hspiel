<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: mplayer.xsl,v 1.4 2007/04/26 15:08:45 Moritz.Ringler Exp $ -->
<xsl:transform
        version="2.0"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:hsp="http://www.mospace.de/hspiel"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fn="http://www.w3.org/2003/11/xpath-functions"
        xmlns:foo="http://foo.com"
        exclude-result-prefixes="foo fn hsp">


    <xsl:template match="/hsp:senderliste">
        <xsl:result-document href="livestreams.txt"
                omit-xml-declaration="yes"
                method="text"
                encoding="ISO-8859-1"
                indent="no">
            <xsl:apply-templates select="hsp:senderfamilie/hsp:sender">
                <xsl:sort select="@id"/>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="hsp:sender">
            <xsl:if test="exists(hsp:livestream)">
                <xsl:value-of select="@id"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="hsp:livestream/hsp:url"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="hsp:livestream/hsp:mplayertyp"/>
                <xsl:text>&#xA;</xsl:text>
            </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>
</xsl:transform>