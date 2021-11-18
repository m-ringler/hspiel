<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
(c) Moritz Ringler, 2009
Dieses XSLT stylesheet verarbeitet die von
http://www.hoerdat.in-berlin.de/heute.php 
generierten Daten zu einem semantischen XML-Format, das man dann leicht
mit einer weiteren Transformation in ein anderes Ausgabeformat oder z. B.
in die Kommandozeile eines ID3-Taggers umwandeln kann. Dieses Format ist nicht
näher spezifiziert. Element kann alles sein, was bei der hoerdat-Ausgabe
in der linken Tabellenspalte steht.

Letzte Änderung 2009-04-06.

Und so geht's:                                                                                    
curl -s http://www.hoerdat.in-berlin.de/heute.php?dat=$(date -''-iso)&sender=dlf | tidy -asxhtml -numeric 2>/dev/null | xsltproc hoerdat-parsel.xsl -
-->
<xsl:transform
    version="1.0"
    exclude-result-prefixes="html xs xsl"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://hspiel.mospace.de/hoerdat/1"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <Hoerdat>
            <xsl:apply-templates select="descendant::html:table"/>
        </Hoerdat>
    </xsl:template>

    <xsl:template match="html:table">
        <Sendung>
            <xsl:apply-templates select="html:tr"/>
        </Sendung>
    </xsl:template>

    <xsl:template match="html:tr">
        <xsl:apply-templates select="html:th"/>
        <xsl:apply-templates select="html:td[@class = 'right']"/>
    </xsl:template>

    <xsl:template match="html:th">
        <Titel>
            <xsl:variable name="titel">
                <xsl:apply-templates select="text()"/>
            </xsl:variable>
            <xsl:value-of select="normalize-space($titel)"/>
        </Titel>
    </xsl:template>

    <xsl:template match="html:td">
        <xsl:variable name="field" select="translate(text(),'(): /','')"/>
        <xsl:element name="{$field}">
            <xsl:apply-templates select="following-sibling::html:td[1]"
              mode="value">
                <xsl:with-param name="key" select="$field"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="html:td" mode="value">
        <xsl:param name="key" select="''"/>
        <xsl:choose>
            <xsl:when test="html:b">
                <xsl:value-of select="normalize-space(html:b/text())"/>
            </xsl:when>
            <xsl:when test="$key = 'Mitwirkende' or $key = 'Regisseure'">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:when test="$key = 'Inhaltsangabe'">
                <xsl:apply-templates select="text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="t">
                    <xsl:apply-templates select="text()"/>
                </xsl:variable>
                <xsl:value-of
                    select="normalize-space($t)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="html:br">
        <xsl:if test="following-sibling::text()">
            <xsl:text>;</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:transform>
