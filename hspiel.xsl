<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: hspiel.xsl,v 1.63 2008/04/18 12:16:28 Moritz.Ringler Exp $ -->
<xsl:transform
    version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:hsp="http://www.mospace.de/hspiel"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2003/11/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:foo="http://foo.com"
    exclude-result-prefixes="foo fn hsp xs">
  <xsl:strip-space elements="*"/>
  <xsl:param name="frames" select="'no'" tunnel="yes"/>
  <xsl:param name="cron-start-before-minutes" as="xs:integer" select="2"/>
  <xsl:param name="cron-stop-after-minutes" as="xs:integer" select="3"/>
  <xsl:variable
      name="cron-start-before"
      as="xs:dayTimeDuration"
      select="xs:dayTimeDuration(concat('-PT', $cron-start-before-minutes, 'M'))"/>
  <xsl:variable
      name="cron-stop-after"
      as="xs:dayTimeDuration"
      select="xs:dayTimeDuration(concat('PT', $cron-stop-after-minutes, 'M'))"/>
  <xsl:variable
      name="dtsys"
      select="if($frames ne 'no')
                then 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'
                else 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'" />
  <xsl:variable
      name="dtpub"
      select="if($frames ne 'no')
                then '-//W3C//DTD XHTML 1.0 Transitional//EN'
                else '-//W3C//DTD XHTML 1.0 Strict//EN'"/>
  <xsl:variable
      name="filename"
      select="if($frames ne 'no')
                then 'index_frame.html'
                else 'index.html'" />
  <foo:wochentage>
    <foo:wtags number="1">Mo</foo:wtags>
    <foo:wtags number="2">Di</foo:wtags>
    <foo:wtags number="3">Mi</foo:wtags>
    <foo:wtags number="4">Do</foo:wtags>
    <foo:wtags number="5">Fr</foo:wtags>
    <foo:wtags number="6">Sa</foo:wtags>
    <foo:wtags number="7">So</foo:wtags>
    <foo:wtagl number="1">Montag</foo:wtagl>
    <foo:wtagl number="2">Dienstag</foo:wtagl>
    <foo:wtagl number="3">Mittwoch</foo:wtagl>
    <foo:wtagl number="4">Donnerstag</foo:wtagl>
    <foo:wtagl number="5">Freitag</foo:wtagl>
    <foo:wtagl number="6">Samstag</foo:wtagl>
    <foo:wtagl number="7">Sonntag</foo:wtagl>
  </foo:wochentage>
  <xsl:key match="*" name="idkey" use="@id"/>

  <xsl:output standalone="omit"/>
  <xsl:template name="meta">
    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
    <meta name="generator" content="Saxon XSLT Processor" />
    <meta http-equiv="Content-Script-Type" content="text/javascript" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta name="author" content="Moritz Ringler, based on work by R. Eberhard" />
    <meta
      name="keywords"
      content="Hoerspiel, Hörspiel, Hörspielprogramm, Hoerspielprogramm, Sendeplätze" />
    <meta
      name="description"
      content="Übersicht der wöchentlichen Hörspielsendeplätze deutschsprachiger Sender - mit Links zum Programm und zum jeweiligen Live-Stream" />
    <meta name="page-topic" content="Kultur" />
    <meta name="page-type" content="Private Homepage" />
    <meta name="audience" content="Alle" />
    <meta name="robots" content="INDEX,FOLLOW" />
    <link rel="shortcut icon" href="http://mospace.de/favicon.ico" />
            <link rel="alternate" type="application/rss+xml"
                title="RSS" href="http://hspiel.mospace.de/hspiel.rss" />
  </xsl:template>

  <xsl:template match="/hsp:senderliste">
    <xsl:if test="$frames ne 'no'">
      <xsl:result-document
          href="hspiel_frameset.html"
          omit-xml-declaration="yes"
          method="xhtml"
          encoding="ISO-8859-1"
          indent="yes"
          doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"
          doctype-public="-//W3C//DTD XHTML 1.0 Frameset//EN">
        <html>
          <head>
            <xsl:call-template name="meta"/>
            <title>
              <xsl:text>Sendeplätze deutschsprachiger Hörspiele (Frameset)</xsl:text>
            </title>
          </head>
          <frameset rows="67%,*">
            <frame
                src="index_frame.html"
                name="uebersicht"
                marginheight="0"
                scrolling="yes"
                frameborder="1" />
            <frame
                src="disclaimer.html"
                name="programm"
                marginheight="0"
                frameborder="0" />
            <noframes>
              <body>
                <div>
                  <xsl:text>Version ohne Frames: </xsl:text>
                  <a href="index.html" title="Version ohne Frames"/>
                </div>
              </body>
            </noframes>
          </frameset>
        </html>
      </xsl:result-document>
    </xsl:if>
  <!-- Don't use output method 'xml': empty tags will lack the final
   space and the resulting document will not be parsed correctly by
   IE and Opera -->
    <xsl:result-document
        href="{$filename}"
        omit-xml-declaration="yes"
        method="xhtml"
        encoding="ISO-8859-1"
        indent="yes"
        doctype-system="{$dtsys}"
        doctype-public="{$dtpub}">
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <xsl:call-template name="meta"/>
          <xsl:if test="$frames ne 'no'">
            <base target="programm"/>
          </xsl:if>
          <script type="text/javascript" src="hspiel.js" />
          <title>
            <xsl:text>Sendeplätze deutschsprachiger Hörspiele</xsl:text>
          </title>
          <link rel="stylesheet" type="text/css" href="hspiel.css" />
          <link rel="stylesheet" type="text/css" media="handheld, only screen and (max-device-width: 1000px)" href="mobile.css"/>
        </head>
        <body>
          <div class="main">
            <p class="framesornoframes">
              <a href="index.html">
                <xsl:if test="not($frames eq 'no')">
                  <xsl:attribute name="target">_top</xsl:attribute>
                </xsl:if>EINZELFENSTER</a>
              <xsl:text>&#160;&#160;</xsl:text>
              <a href="hspiel_frameset.html">
                <xsl:if test="not($frames eq 'no')">
                  <xsl:attribute name="target">_top</xsl:attribute>
                </xsl:if>DOPPELFENSTER</a>
            </p>
            <h1>
            <a href="http://web.archive.org/web/*/http://www.mospace.de/">
              <img src="10Jahre.png"
                alt="10 Jahre Hörspiel-Sendeplätze auf mospace.de"
                title="10 Jahre Hörspiel-Sendeplätze auf mospace.de"
                style="vertical-align:middle;border-right:10px"/></a><xsl:text>Hörspiel-Sendeplätze</xsl:text>
            </h1>
            <div class="config">
              <h3>
                <xsl:text>KATEGORIEN </xsl:text>
                <a
                    class="toggle"
                    id="pluskat"
                    onclick="simpletoggle('kat')"
                    title="aufklappen">
                  <xsl:text>[+]</xsl:text>
                </a>
                <a
                    class="toggle"
                    id="minuskat"
                    onclick="simpletoggle('kat')"
                    title="einklappen">
                  <xsl:text>[&#8211;]</xsl:text>
                </a>
              </h3>
              <div id="kat">
                <form id="katform" action=".">
                  <fieldset id="kategorie">
                    <xsl:for-each-group
                        select="hsp:senderfamilie/hsp:sender/hsp:sendung"
                        group-by="hsp:kategorie">
                      <xsl:sort
                        select="current-grouping-key()"
                        order="ascending"/>
                      <span style="white-space:nowrap">
                        <input
                            type="checkbox"
                            name="genrecb"
                            checked="checked"
                            onchange="xselect()">
                          <xsl:attribute name="value">
                            <xsl:value-of select="current-grouping-key()"/>
                          </xsl:attribute>
                        </input>
                        <xsl:text>&#160;</xsl:text>
                        <xsl:value-of select="current-grouping-key()"/>
                      </span>
                      <xsl:text> </xsl:text>
                    </xsl:for-each-group>
                  </fieldset>
                  <fieldset>
                    <input
                        type="button"
                        class="button"
                        value="alle Kategorien"
                        onclick="resetAll('katform',true)"/>
                    <xsl:text>&#160;</xsl:text>
                    <input
                        type="button"
                        class="button"
                        value="keine Kategorie"
                        onclick="resetAll('katform',false)"/>
                    <xsl:text>&#160;</xsl:text>
                    <input
                        type="button"
                        class="button2"
                        value="Einstellungen speichern"
                        onclick="writeCookie()"/>
                  </fieldset>
                </form>
              </div>
            </div>
            <div class="config">
              <h3>
                <xsl:text>SENDER </xsl:text>
                <a
                  id="plussen"
                  class="toggle"
                  onclick="simpletoggle('sen')"
                  title="aufklappen">
                  <xsl:text>[+]</xsl:text>
                </a>
                <a
                    id="minussen"
                    class="toggle"
                    onclick="simpletoggle('sen')"
                    title="einklappen">
                  <xsl:text>[&#8211;]</xsl:text>
                </a>
              </h3>
              <div id="sen">
                <form id="senform" action=".">
                  <fieldset id="sender">
                    <xsl:for-each-group
                        select="hsp:senderfamilie/hsp:sender"
                        group-by="tokenize(@name,' *, *')">
                      <xsl:sort
                          select="replace(lower-case(current-grouping-key()),'ö','oe')"
                          order="ascending"/>
                      <span style="white-space:nowrap">
                        <input
                            type="checkbox"
                            name="sencb"
                            checked="checked"
                            onchange="xselect()">
                          <xsl:attribute name="value">
                            <xsl:value-of select="current-grouping-key()"/>
                          </xsl:attribute>
                            <xsl:choose>
                              <xsl:when test="exists(hsp:livestream)">
                                  <xsl:attribute name="class">
                                    <xsl:text>haslivestream</xsl:text>
                                  </xsl:attribute>
                                  <xsl:attribute name="title">
                                    <xsl:value-of select="hsp:livestream/hsp:typ"/>
                                  </xsl:attribute>
                              </xsl:when>
                              <xsl:otherwise>
                                  <xsl:attribute name="class">
                                    <xsl:text>hasnolivestream</xsl:text>
                                  </xsl:attribute>
                              </xsl:otherwise>
                            </xsl:choose>
                        </input>
                        <xsl:text>&#160;</xsl:text>
                        <xsl:value-of select="current-grouping-key()"/>
                      </span>
                      <xsl:text> </xsl:text>
                    </xsl:for-each-group>
                  </fieldset>
                  <fieldset>
                    <input
                        type="button"
                        class="button"
                        value="alle Sender"
                        onclick="resetAll('senform',true)"/>
                    <xsl:text>&#160;</xsl:text>
                    <input
                        type="button"
                        class="button"
                        value="Sender mit MP3 Stream"
                        onclick="showLS('MP3')"/>
                    <xsl:text>&#160;</xsl:text>
                    <input
                        type="button"
                        class="button"
                        value="kein Sender"
                        onclick="resetAll('senform',false)"/>
                    <xsl:text>&#160;</xsl:text>
                    <input
                        type="button"
                        class="button2"
                        value="Einstellungen speichern"
                        onclick="writeCookie()"/>
                  </fieldset>
                </form>
              </div>
            </div>
            <div class="config">
                <h3>WIEDERHOLUNGEN <a id="pluswdh" class="toggle" onclick="simpletoggle('wdh')" title="aufklappen">[+]</a><a id="minuswdh" class="toggle" onclick="simpletoggle('wdh')" title="einklappen">[&#8211;]</a></h3>
                <div id="wdh">
                   <form id="wdhform" action=".">
                      <fieldset id="wiederholungen"><span style="white-space:nowrap"><input type="checkbox" name="wdhcb" checked="checked" onchange="xselect()"
                                   value="anzeigen" /> Anzeigen</span>
                      </fieldset>
                  <fieldset>
                    <input
                        type="button"
                        class="button2"
                        value="Einstellungen speichern"
                        onclick="writeCookie()"/>
                  </fieldset>

                   </form>
                </div>
            </div>
            <p>
              <span style="font-weight:bold; background-color:red; color:white; padding-left:2px; padding-right:2px">Diese Seite wird von mir nicht mehr aktualisiert.</span>
              <xsl:text> Wenn Sie sie gerne auf Ihrer eigenen Webseite weiterpflegen möchten, </xsl:text>
              <a href="javascript:eml('jqgturkgnBoqockn0g6yctf0eqo')" title="erfordert Javascript">
              <xsl:text>schreiben Sie mir</xsl:text>
              </a>.
                    <a href="hspiel.rss" title="Änderungsbenachrichtigungen als RSS-Feed">
                        <img
                            style="border-style:none;height:12px;width:12px"
                            alt="Änderungsbenachrichtigungen als RSS-Feed"
                            src="http://mospace.de/icon/rss"/>
                    </a>
            </p>
            <form id="cronform" action=".">
              <table
                  style="border-spacing:0px"
                  id="maintable"
                  summary="Die folgende Tabelle listet die wöchentlichen Sendezeiten deutschsprachiger Hörspiele auf.">
                <tr class="grey">
                  <th>
                    <xsl:text> </xsl:text>
                  </th>
                  <th>
                    <xsl:text> </xsl:text>
                  </th>
                  <th>
                    <xsl:text>Sender</xsl:text>
                  </th>
                  <th>
                    <xsl:text>Sendung</xsl:text>
                  </th>
                </tr>
                <xsl:for-each-group
                    select="hsp:senderfamilie/hsp:sender/hsp:sendung/hsp:sendetermin"
                    group-by="@tag">
                  <xsl:sort select="@tag"/>
                  <tr>
                    <xsl:attribute name="class" select="concat('c',@tag)"/>
                    <xsl:variable name="heute" select="number(@tag)" />
                    <td colspan="4">
                      <xsl:for-each select="1 to 7">
                        <xsl:variable name="t" select="number(.)" />
                        <xsl:variable
                            name="tns"
                            select="document('')/xsl:transform/foo:wochentage/foo:wtags[@number=$t]" />
                        <xsl:variable
                            name="tnl"
                            select="document('')/xsl:transform/foo:wochentage/foo:wtagl[@number=$t]" />
                        <xsl:choose>
                          <xsl:when test="($heute eq $t)">
                            <a href="#{$tns}" id="{$tns}" name="{$tns}" accesskey="{$t}"
                            class="black">
                              <xsl:if test="$frames ne 'no'">
                                <xsl:attribute name="target" select="'_self'"/>
                              </xsl:if>
                              <xsl:value-of select="$tnl"/>
                            </a>
                            <xsl:text> </xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <a href="#{$tns}" title="{concat($tnl, ' [', $t, ']')}">
                              <xsl:if test="$frames ne 'no'">
                                <xsl:attribute name="target" select="'_self'"/>
                              </xsl:if>
                              <xsl:value-of select="$tns"/>
                            </a>
                            <xsl:text> </xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <xsl:for-each select="current-group()">
                    <xsl:sort select="@zeit"/>
                    <xsl:variable
                        name="sender"
                        select="ancestor::element(hsp:sender)"/>
                    <xsl:variable
                        name="sendung"
                        select="ancestor::element(hsp:sendung)"/>
                    <tr class="eintrag">
                      <td class="zeit">
                        <span
                            class="cron"
                            title="Aufnehmen mit mplayer und cron">
                          <xsl:variable
                              name="crontab-dom"
                              select="if (contains(@intervall, 'ersten'))
                                        then '1-7'
                                      else if (contains(@intervall, 'letzten'))
                                        then '22-31'
                                      else '*'" />
                          <xsl:variable
                              name="time"
                              select="xs:dateTime(concat(
                                                    '2000-01-01T',
                                                    @zeit,
                                                    ':00'))"
                              as="xs:dateTime"/>
                          <xsl:variable
                              name="duration"
                              select="xs:dayTimeDuration(
                                concat(
                                  'PT',
                                  if(exists(@dauer))
                                    then replace(@dauer,'[^0-9]','')
                                    else '90',
                                  'M'))"
                              as="xs:dayTimeDuration"/>
                          <xsl:variable
                              name="starttime"
                              select="$time + $cron-start-before"
                              as="xs:dateTime"/>
                          <xsl:variable
                              name="stoptime"
                              select="$time + $duration + $cron-stop-after"
                              as="xs:dateTime"/>
                          <xsl:variable
                              name="alias"
                              select="replace(replace(
                                    concat($sender/@name, '_', $sendung/@name,
                                    if(@wdhvon) then '_wdh' else ''),
                                    '[ \-_]+', '_' ),
                                    '[^_\p{L}\p{Nd}]', '')" />
                          <input
                              type="checkbox"
                              name="cronrecord"
                              title="Für Aufnahme mit mplayer/cron auswählen">
                            <xsl:variable name="senderid" select="$sender/@id"/>
                            <xsl:attribute name="value">
                              <xsl:value-of
                                select="format-number(
                                          minutes-from-dateTime($starttime),
                                          '00')"/>
                              <xsl:text> </xsl:text>
                              <xsl:value-of
                                  select="format-number(
                                            hours-from-dateTime($starttime),
                                            '00')"/>
                              <xsl:value-of select="concat(' ',$crontab-dom)"/>
                              <xsl:text> * </xsl:text>
                              <xsl:value-of
                                  select="(day-from-dateTime($starttime) - 1 +
                                            number(@tag)) mod 7"/>
                              <xsl:text> record.sh start </xsl:text>
                              <xsl:value-of select="$senderid"/>
                              <xsl:text> </xsl:text>
                              <xsl:value-of select="$alias"/>
                              <xsl:text>&#xA;</xsl:text>
                              <xsl:value-of
                                  select="format-number(
                                            minutes-from-dateTime($stoptime),
                                            '00')"/>
                              <xsl:text> </xsl:text>
                              <xsl:value-of
                                  select="format-number(
                                            hours-from-dateTime($stoptime),
                                            '00')"/>
                              <xsl:value-of select="concat(' ',$crontab-dom)"/>
                              <xsl:text> * </xsl:text>
                              <xsl:value-of
                                    select="(day-from-dateTime($stoptime) - 1 +
                                              number(@tag)) mod 7"/>
                              <xsl:text> record.sh stop  </xsl:text>
                              <xsl:value-of select="$senderid"/>
                              <xsl:text> </xsl:text>
                              <xsl:value-of select="$alias"/>
                            </xsl:attribute>
                          </input>
                        </span>
                        <xsl:value-of select="@zeit"/>
                        <xsl:if
                            test="exists($sender/hsp:livestream/hsp:psradioid)">
                          <span class="record" title="Aufnehmen mit Phonostar">
                            <xsl:attribute
                              name="onclick"
                              select="concat(
                                'javascript:timer(''',
                                  replace($sender/@name,'''',''),
                                  '_',
                                  replace($sendung/@name,'''',''),
                                ''', ''',
                                  $sender/hsp:livestream/hsp:psradioid,
                                ''', ''',
                                  @tag,
                                ''', ''',
                                  @zeit,
                                ''', ''',
                                  @dauer,
                                ''')')" />
                            <xsl:text>&#8226;</xsl:text>
                          </span>
                        </xsl:if>
                      </td>
                      <td class="media">
                    <!-- see http://www.dpawson.co.uk/xsl/sect2/N2624.html -->
                        <xsl:variable
                            name="freq"
                            select="ancestor::hsp:*[@frequenzenurl][1]/@frequenzenurl"/>
                        <xsl:if test="$freq">
                          <a class="frequenzen" title="Frequenzen">
                            <xsl:attribute name="href" select="$freq"/>
                            <xsl:text>F</xsl:text>
                          </a>
                          <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:choose>
                          <xsl:when test="$sender/hsp:livestream">
                            <a class="livestream" title="Webradio">
                              <xsl:attribute
                                  name="href"
                                  select="$sender/hsp:livestream/hsp:url"/>
                              <xsl:value-of
                                  select="$sender/hsp:livestream/hsp:typ"/>
                            </a>
                            <xsl:text> </xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>&#160;&#160;&#160;</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </td>
                      <td class="sender">
                        <a class="sendername">
                          <xsl:attribute
                              name="title"
                              select="$sender/@longname"/>
                          <xsl:attribute name="href" select="$sender/@url"/>
                          <xsl:value-of select="$sender/@name"/>
                          <xsl:text> </xsl:text>
                        </a>
                      </td>
                      <td class="sendung">
                        <span class="kategorie">
                          <xsl:attribute
                              name="title"
                              select="string-join($sendung/hsp:kategorie, ', ')"/>
                          <xsl:value-of
                              select="substring($sendung/hsp:kategorie[1],1,2)"/>
                        </span>
                        <xsl:text> </xsl:text>
                        <xsl:choose>
                          <xsl:when test="@dauer">
                            <xsl:value-of select="@dauer"/>
                            <xsl:text>' </xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>var </xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                        <a>
                          <xsl:attribute
                              name="href"
                              select="ancestor::hsp:*[@programmurl][1]/@programmurl"/>
                          <xsl:value-of select="../@name"/>
                        </a>
                        <xsl:variable name="weiteres">
                          <xsl:if test="@intervall">
                            <span class="intervall">
                              <xsl:value-of select="@intervall"/>
                            </span>
                          </xsl:if>
                          <xsl:if test="@anmerkung">
                            <span class="anmerkung">
                              <xsl:value-of select="@anmerkung"/>
                            </span>
                          </xsl:if>
                          <xsl:if test="@wdhvon">
                            <xsl:variable name="erstsendetermin" select="key('idkey', @wdhvon)" />
                            <xsl:variable name="erstsender" select="$erstsendetermin/ancestor::element(hsp:sender)"/>
                            <span class="wdh">
                              <xsl:text>Wdh. von </xsl:text>
                              <xsl:if test="$erstsender/@name ne $sender/@name">
                                <xsl:value-of select="$erstsender/@name"/>
                                <xsl:text>, </xsl:text>
                              </xsl:if>
                              <xsl:if test="$erstsendetermin/@tag ne @tag">
                                <xsl:variable
                                    name="wdht"
                                    select="number($erstsendetermin/@tag)"/>
                                <xsl:value-of
                                    select="document('')/xsl:transform/foo:wochentage/foo:wtags[@number=$wdht]"/>
                                <xsl:text> </xsl:text>
                              </xsl:if>
                              <xsl:value-of select="$erstsendetermin/@zeit"/>
                            </span>
                          </xsl:if>
                        </xsl:variable>
                        <xsl:if test="$weiteres/*">
                          <xsl:text> </xsl:text>
                          <xsl:copy-of select="$weiteres/*[1]"/>
                          <xsl:for-each select="$weiteres/*[position() ne 1]">
                            <xsl:text>; </xsl:text>
                            <xsl:copy-of select="."/>
                          </xsl:for-each>
                        </xsl:if>
                      </td>
                    </tr>
                  </xsl:for-each>
                </xsl:for-each-group>
              </table>
              <hr style="color:silver; border:solid 10px silver" />
              <h2>
                <xsl:text>Aufnahme mit mplayer und cron</xsl:text>
                <a name="aufnahme" id="aufnahme"></a>
              </h2>
              <div>
                <p style="font-size:150%">
                  <input
                      type="button"
                      class="button2"
                      value="Auswahlkästchen anzeigen"
                      onclick="showCronSelection(true)"/>
                  <xsl:text>&#160;</xsl:text>
                  <input
                      type="button"
                      class="button2"
                      value="crontab ausgeben"
                      onclick="crontab()" />
                  <xsl:text>&#160;</xsl:text>
                  <input
                      type="reset"
                      value="Sendungsauswahl aufheben"
                      class="button2"/>
                </p>
                <p>
                  <a href="aufnahme.html">
                    <xsl:text>Anleitung</xsl:text>
                  </a>
                </p>
              </div>
            </form>
            <hr style="color:silver; border:solid 1px silver" />
                        <h2>
              <xsl:text>Links</xsl:text>
            </h2>
            <table summary="Die folgende Tabelle listet für den Hörspiel- und Internetradiointeressierten relevante Webseiten auf.">
              <tr>
                <td>
                  <xsl:text>HörDat - Umfassende Hörspieldatenbank u. a. mit dem Tagesprogramm</xsl:text>
                </td>
                <td>
                  <a href="http://www.xn--hrdat-jua.de/">
                    <xsl:text>http://www.hördat.de/</xsl:text>
                  </a>
                </td>
              </tr>
              <tr>
                <td>
                  <xsl:text>Der Hörspielkrimi - stets aktuelles Krimiprogramm
(mit Inhaltsangaben)</xsl:text>
                </td>
                <td>
                  <a href="http://www.hoerspielkrimi.net/">
                    <xsl:text>http://www.hoerspielkrimi.net/</xsl:text>
                  </a>
                </td>
              </tr>
              <tr>
                <td>
                  <xsl:text>ARD - Radioportal</xsl:text>
                </td>
                <td>
                  <a href="http://www.ard.de/home/radio/Radio/22550/index.html">
                    <xsl:text>http://www.ard.de/radio/</xsl:text>
                  </a>
                </td>
              </tr>
              <tr>
                <td>
                  <xsl:text>Surfmusik - Übersicht von Webradioangeboten (Livestreams)</xsl:text>
                </td>
                <td>
                  <a href="http://www.surfmusik.de">
                    <xsl:text>http://www.surfmusik.de</xsl:text>
                  </a>
                </td>
              </tr>
              <tr>
                <td>
                  <xsl:text>Phonostar Player - mäßig toll; aber meines Wissens der einzige Player mit einfach programmierbarer Aufnahme</xsl:text>
                </td>
                <td>
                  <a href="http://www.phonostar.de">
                    <xsl:text>http://www.phonostar.de</xsl:text>
                  </a>
                </td>
              </tr>
            </table>


            <h2>
              <xsl:text>Hörspiele zum Herunterladen und Nachhören</xsl:text>
            </h2>
            <table summary="Die folgende Tabelle listet Webseiten auf, auf denen Hörspiele heruntergeladen und per Streaming gehört werden können.">
            <tr>
                <td>&#160;</td>
                <td>
                  <a href="http://www.ardmediathek.de/radio/H%C3%B6rspiele/mehr?documentId=21301890">
                    <xsl:text>ARD Mediathek &#8212; Hörspiel</xsl:text>
                  </a>
                </td>
              </tr>

              <tr>
                <td><a href="http://www.br-online.de/podcast/hoerspiel-pool/cast.xml"><img
                            style="border-style:none;height:12px;width:12px"
                            alt="Podcast"
                            src="http://mospace.de/icon/rss"/></a></td>
                <td>
                  <a href="http://www.br-online.de/podcast/mp3-download/bayern2/mp3-download-podcast-hoerspiel-pool.shtml">
                    <xsl:text>BR2 Hörspiel-Pool</xsl:text>
                  </a>
                </td>
              </tr>

              <tr>
                <td><a href="http://www.ndr.de/wellenord/podcast4201.xml"><img
                            style="border-style:none;height:12px;width:12px"
                            alt="Podcast"
                            src="http://mospace.de/icon/rss"/></a></td>
                <td>
                  <a href="http://www.ndr.de/wellenord/podcast4201.html">
                    <xsl:text>Das Niederdeutsche Hörspiel</xsl:text>
                  </a>
                </td>
              </tr>

              <tr>
                <td><a href="http://web.ard.de/radiotatort/rss/podcast.xml"><img
                            style="border-style:none;height:12px;width:12px"
                            alt="Podcast"
                            src="http://mospace.de/icon/rss"/></a></td>
                <td>
                  <a href="http://radiotatort.de/">
                    <xsl:text>ARD Radiotatort &#8212; zum Herunterladen für begrenzte oder unbegrenzte (BR) Zeit</xsl:text>
                  </a>
                </td>
              </tr>

              <tr>
                <td>&#160;</td>
                <td>
                  <a href="http://www.swr.de/swr2/hoerspiel-feature/hoerspiel-auf-klick/">
                    <xsl:text>SWR 2 Hörspiel auf Klick &#8212; Hörspiele zum Nachhören oder Herunterladen</xsl:text>
                  </a>
                </td>
              </tr>

              <tr>
                <td>&#160;</td>
                <td>
                  <a href="http://www1.wdr.de/radio/hoerspielundfeature/hoerspiel/wdr_hoerspielspeicher104.html">
                    <xsl:text>WDR Hörspielspeicher &#8212; mit WDR-Hörspielen zum Herunterladen</xsl:text>
                  </a>
                </td>
              </tr>

              <tr>
                <td>&#160;</td>
                <td>
                  <a href="http://www1.wdr.de/radio/hoerspielundfeature/feature/feature_depot/feature_depot100.html">
                    <xsl:text>WDR Featuredepot &#8212; mit WDR-Features zum Herunterladen</xsl:text>
                  </a>
                </td>
              </tr>

              <tr>
                <td>&#160;</td>
                <td>
                  <a href="http://www.srf.ch/sendungen/hoerspiel">
                    <xsl:text>SRF Hörspiele &#8212; können teilweise nachgehört und/oder heruntergeladen) werden</xsl:text>
                  </a>
                </td>
              </tr>

            </table>

            <hr style="color:silver; border:solid 1px silver" />
            <p>
              <a href="http://mospace.de">
                <xsl:text>Mospace!</xsl:text>
              </a>
              <br />
              <xsl:text>&#169; 2000 hoerspass.de, R. Eberhard</xsl:text>
              <br />
              <xsl:text>&#169; 2003-2015 www.mospace.de, M. Ringler</xsl:text>
            </p>
            <hr style="color:silver; border:solid 1px silver" />
            <p style="text-align:right">
              <a href="http://jigsaw.w3.org/css-validator/check/referer">
                <img
                    style="border:0;width:88px;height:31px"
                    src="http://jigsaw.w3.org/css-validator/images/vcss"
                    alt="Valid CSS!" />
              </a>
              <a href="http://validator.w3.org/check?uri=referer">
                <img
                    style="border-style:none"
                    src="http://www.w3.org/Icons/valid-xhtml10"
                    alt="Valid XHTML 1.0!"
                    height="31"
                    width="88" />
              </a>
            </p>
          </div>
          <script type="text/javascript">
            <xsl:text>prefixM3UsForAndroid();</xsl:text>
            <xsl:text>simpletoggle("kat");
simpletoggle("sen");
simpletoggle("wdh");
xselect();
readCookie();
xselect();
showCronSelection(false);
updateTooltipAccessKeys();
</xsl:text>
          </script>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*"/>
</xsl:transform>