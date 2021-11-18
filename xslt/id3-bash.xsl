<?xml version="1.0" encoding="UTF-8" ?>
<!--
(c) Moritz Ringler, 2009
Dieses XSLT stylesheet erzeugt aus einer ID3-XML Datei eine bash-Kommandozeile
für id3v2 (http://id3v2.sf.net). Der Dateiname der mp3-Datei muss dieser noch
hinzugefügt werden.

Zuletzt geändert 2009-01-25

Und so geht's (in bash):
    mycmd=$(xsltproc id3-bash.xsl Krimi_2009-08-21.id3)
    eval $mycmd Krimi_2009-08-21.mp3
    # Nachschauen ob das Ergebnis passt:
    id3v2 -l Krimi_2009-08-21.mp3
-->
<xsl:transform
    version="1.0"
    xmlns:id3="http://id3xml.sf.net/id3/2/4/0/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:strip-space
        elements="*"/>
    <xsl:variable
        name="sq">'</xsl:variable>
    <xsl:variable
        name="dq">"</xsl:variable>
    <xsl:variable
        name="repl">':</xsl:variable>
    <xsl:variable
        name="with">",</xsl:variable>
    <xsl:output
        method="text"
        encoding="ISO-8859-1"/>

    <xsl:template
        match="/">
        <xsl:apply-templates
            select="descendant::id3:tag[1]"/>
        <xsl:value-of
            select="'&#xa;'"/>
    </xsl:template>

    <xsl:template
        match="id3:tag">
        <xsl:text>id3v2 -2 </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Convert ID3v2.4 TDRC to ID3v2.3 TYER -->
    <xsl:template
        match="id3:TDRC">
        <xsl:text> --TYER '</xsl:text>
        <xsl:value-of
            select="substring(normalize-space(translate(text(),$repl,$with)),1,4)"/>
        <xsl:text>'</xsl:text>
    </xsl:template>

    <xsl:template
        match="id3:COMM">
        <xsl:variable
            name="sep"
            select="concat($sq,':',$sq)"/>
        <xsl:text> -c '</xsl:text>
        <xsl:value-of
            select="translate(@description,$repl,$with)"/>
        <xsl:value-of
            select="$sep"/>
        <xsl:value-of
            select="translate(text(),$repl,$with)"/>
        <xsl:value-of
            select="$sep"/>
        <xsl:choose>
            <xsl:when
                test="@lang">
                <xsl:value-of
                    select="translate(@lang,$repl,$with)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>XXX</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>'</xsl:text>
    </xsl:template>

    <xsl:template
        match="id3:*">
        <xsl:value-of
            select="concat(' --',local-name())"/>
        <xsl:text> '</xsl:text>
        <xsl:value-of
            select="translate(text(),$repl,$with)"/>
        <xsl:text>'</xsl:text>
    </xsl:template>
</xsl:transform>


