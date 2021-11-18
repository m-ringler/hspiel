/* javascripts für www.mospace.de/hspiel
 * $Id: hspiel.js,v 1.23 2007/12/14 09:51:42 Moritz.Ringler Exp $
 * (c) Moritz Ringler, 2005
 * charset iso-8859-1
 */

/* GLOBALS */
/** date and time the page was loaded **/
var startdate = new Date();
/**kategorien holds all checked values
 * of the "Kategorien-Auswahl" form
 * e. g. kategorien.Krimi = true
 **/
var kategorien = new Object();
/** sender holds all checked values
 * of the "Sender-Auswahl" form
 * e. g. sender.wdr5 = true
 **/
var sender = new Object();
var wdh = new Object();

/* GENERAL-PURPOSE FUNCTIONS */
/** For a given date calculates the date of the next dayOfWeek. **/
function getNextSuchDay(date,dayOfWeek){
  var daysToAdd = (dayOfWeek-date.getDay())%7;
  if (daysToAdd < 0){
      daysToAdd += 7;
  }
  var time = date.getTime();
  time    -= 60000 * date.getMinutes();
  time    -= 60 * 60000 * date.getHours();
  time    += 24 * 60 * 60000 * daysToAdd;
  return (new Date(time));
}

/** Formats the given date as YYYYMMDDhhmm00*/
function formatDate(date){
  var result="";
  result = result.concat(date.getFullYear());
  result = result.concat(formatNum(date.getMonth()+1));
  result = result.concat(formatNum(date.getDate()));
  result = result.concat(formatNum(date.getHours()));
  result = result.concat(formatNum(date.getMinutes()));
  result = result.concat("00");
  return result;
}

/** Removes German umlauts from a string. **/
function keineUmlaute(str){
    var result = unescape(str).replace(/ä/g,"ae");
    result = result.replace(/ö/g,"oe");
    result = result.replace(/ü/g,"ue");
    result = result.replace(/Ä/g,"Ae");
    result = result.replace(/Ö/g,"Oe");
    result = result.replace(/Ü/g,"Ue");
    return result.replace(/ß/g,"ss");
}

/** Returns a string representing num that has at least a length of two,
    adding leading 0s if necessary. **/
function formatNum(num){
    if(num <10){
        return "0".concat(num);
    } else {
        return num.toString();
    }
}

/** Toggles between two alternative sets of elements in a web page.
 *  @param elementsA, elementsB two Arrays holding the alternative sets of
 *                               elements. elementsB may be empty.
 *  @param displayModesA, displayModesB two Arrays holding the display modes
 *                               for each of the elements in elementsA and
 *                               elementsB (when visible).
 **/
function toggle(elementsA, displayModesA, elementsB, displayModesB){
    if(!document.getElementById){
        return
    }
    if(document.getElementById(elementsA[0]).style.display != "none"){
        for (var i=0; i<elementsA.length; i++){
            eval(document.getElementById(elementsA[i])).style.display="none";
        }
        for (var i=0; i<elementsB.length; i++){
            eval(document.getElementById(elementsB[i])).style.display=displayModesB[i];
        }
    } else {
        for (var i=0; i<elementsB.length; i++){
            eval(document.getElementById(elementsB[i])).style.display="none";
        }
        for (var i=0; i<elementsA.length; i++){
            eval(document.getElementById(elementsA[i])).style.display=displayModesA[i];
        }
    }
}

/** displayModes arrays for simpletoggle **/
var abi = new Array('block', 'inline');
/** displayModes arrays for simpletoggle **/
var ai = new Array('inline');
/** Simpletoggle toggles between
 * a) a single element (id=id) plus a hide button (id=minusid)
 * b) a show button (id=plusid)
 **/
function simpletoggle(id){
    toggle (new Array(id, "minus"+id), abi, new Array("plus"+id), ai);
}

/* SENDERS AND CATEGORIES **/
/** Makes the object reflect changes in the web page.
 * @param form html form with checkboxes
 * @param object new object or object that has one boolean field for each checkbox of the form
 **/
function updateObject(form, object){
    var el = document.getElementById(form).elements;
    for (var i=0; i<el.length; i++){
        if(el[i].type && el[i].type == "checkbox"){
          object[el[i].value.replace(/\W/g,"")]=el[i].checked;
        }
    }
}

/** Makes the html form reflect changes in the object.
 * @param form html form with checkboxes
 * @param object object that has one boolean field for each checkbox of the form
 **/
function updateForm(form, object){
    var el = document.getElementById(form).elements;
    for (var i=0; i<el.length; i++){
        if(el[i].type && el[i].type == "checkbox"){
          el[i].checked=object[el[i].value.replace(/\W/g,"")];
        }
    }
}

/** Sets all checkboxes in the given form to the value of checked. Also
  * updates the corresponding object if formid is one of "katform". "wdhform"
  * or "senform".
  */
function resetAll(formid, checked){
    var el = document.getElementById(formid).elements;
    for (i=0;i<el.length;i++){
        if(el[i].type && el[i].type=="checkbox"){
            el[i].checked=checked
        }
    }
    showChecked()
}

/** For the given row in the main table of the web page returns the sender
  * string with non-word characters removed.
  */
function getSender(tr){
    var mysender = tr.cells[2].firstChild.firstChild.nodeValue;
    return mysender.substr(0,mysender.length -1).replace(/\W/g,"");
}

/** For the given row in the main table of the web page returns the category
  * string unchanged.
  */
function getCategory(tr){
    return tr.cells[3].firstChild.getAttribute("title");
}

function getWdh(tr){
    var cell = tr.cells[3];
    var spans = cell.getElementsByTagName("span");
    var isWdh = false;
    for(var i=0; i<spans.length; i++){
        var vclass = spans[i].getAttribute("class");
        if(vclass == "wdh"){
            isWdh = true;
            break;
        }
    }
    return isWdh;
}

/** Selects and displays all senders that have a livestream. **/
function showLS(){
    var checkType = (showLS.arguments.length > 0);
    var el = document.getElementById("senform").elements;
    for (var i=0;i<el.length;i++){
        if(el[i].type && el[i].type=="checkbox"){
            if (el[i].className=="haslivestream"){
                if(checkType){
                    var w = false;
                    var typ = el[i].getAttribute("title");
                    for (var k=0;k<showLS.arguments.length;k++){
                        if(showLS.arguments[k] == typ){
                            w = true;
                            break;
                        }
                    }
                    el[i].checked = w;
                } else {
                    el[i].checked=true;
                }
            }else{
                el[i].checked=false
            }
        }
    }
    showChecked()
}

function crontab(){
    showCronSelection(true);
    var el = document.getElementById("cronform").elements;
    var entries = new Array();
    for (i=0;i<el.length;i++){
        if(el[i].type && el[i].type=="checkbox"){
            if (el[i].name=="cronrecord" && el[i].checked){
                entries.push(el[i].value);
            }
        }
    }
    if(entries.length > 0){
        specs="resizable=yes,scrollbars=yes,width=575,height=385,screenX=100,screenY=100";
        win=window.open("","crontab", specs);
        win.document.open();
        win.document.write("<html><head><title>crontab (user)</title></head><body><pre>");
        for(entry in entries){
            win.document.writeln(keineUmlaute(entries[entry]));
        }
        win.document.writeln("</pre></body></html>");
        win.document.writeln();
        win.document.close();
        win.focus();
    } else {
        alert("Keine Sendungen ausgewählt");
    }
}

function showCronSelection(visible){
    var el = document.getElementById("cronform").elements;
    var entries = new Array();
    for (var i=0;i<el.length;i++){
        if(el[i].type && el[i].type=="checkbox"){
            if (el[i].name=="cronrecord"){
                if(visible){
                    el[i].style.display="inline";
                } else {
                    el[i].style.display="none";
                }
            }
        }
    }
}

/** See @link{#xselect()} **/
function showChecked(){
    xselect();
}

/** Updates the backup objects and the main table of the web page from
 *  the "katform" and "senform" forms, i. e. shows exclusively those
 *  items whose sender and category are both checked.
**/
function xselect(){
    updateObject("katform",kategorien);
    updateObject("senform",sender);
    updateObject("wdhform",wdh);
    var tr = document.getElementById("maintable").rows;
    for(var i=0; i<tr.length; i++){
        if(tr[i].className=="eintrag"){
            var sentrue = sender[getSender(tr[i])];
            var kat = getCategory(tr[i]); //IE will fail without this 'var'
            var sendungskategorien = kat.split(",");
            var kattrue = false;
            for(var j=0;j<sendungskategorien.length && !kattrue;j++){
                kattrue = kategorien[sendungskategorien[j].replace(/\W/g,"")];
            }
            var wdhtrue = wdh.anzeigen;
            if (!wdhtrue){
                wdhtrue = !getWdh(tr[i]);
            }
            if (sentrue && kattrue && wdhtrue){
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
}

/** After calling xselect. Writes the current category and sender selection
 * to a cookie. Cookie expires after four weeks.
**/
function writeCookie(){
    xselect();
    var expires = new Date();
    expires.setTime(expires.getTime()+2419200000);//expires after 4 weeks = 28 * 24 * 3600 * 1000 ms
    expires =  ";expires=" + expires.toGMTString();
    document.cookie = "katbm=" + toHexString(kategorien) + expires;
    document.cookie = "senbm=" + toHexString(sender) + expires;
    document.cookie = "wdhbm=" + toHexString(wdh) + expires;
}

/** Converts a boolean array into a hex-encoded integer using one bit for
* each array entry. The first array entry will become the least significant
* bit and the last array entry will become the most significant bit.
**/
function toHexString(array){
    var bitmask = 0;
    var i = 0;
    var result = "";
    for(var idx in array){
        if(array[idx]){
            bitmask = bitmask | 1 << i;
        }

        // javascript shift operators handle at most 32 bit,
        // therefore we encode each hex digit separately
        if (++i == 4)
        {
            result = bitmask.toString(16) + result;
            bitmask = 0;
            i = 0;
        }
    }

    if (bitmask != 0)
    {
        result = bitmask.toString(16) + result;
    }

    return result;
}

/** Updates the entries of a boolean array from a hex-encoded integer created
* with toHexString. **/
function fromHexString(array, hexstring){
    var i = 0;
    var fourbits = 0;
    var k = hexstring.length;
    for(var idx in array){
        if (i == 0)
        {
            k--;
            i = 4;
            if (k < 0)
            {
                fourbits = 0;
            }

            fourbits = parseInt(hexstring.charAt(k), 16);
        }

        array[idx] = (fourbits & 1) == 1;
        fourbits = fourbits >> 1;
        i--;
    }
}

/** Reads a cookie written by {@link #writeCookie} into the {@link sender}
*   and {@kategorien} objects and then updates the web page (forms and table)
*   from these.
**/
function readCookie(){
    if (!document.cookie){
        return;
    }
    if(document.cookie.match(/katbm=([0-9a-fA-F]*)/)){
        fromHexString(kategorien, RegExp.$1);
    }
    if(document.cookie.match(/senbm=([0-9a-fA-F]*)/)){
        fromHexString(sender, RegExp.$1);
    }
    if(document.cookie.match(/wdhbm=([0-9a-fA-F]*)/)){
        fromHexString(wdh, RegExp.$1);
    }
    updateForm("senform", sender);
    updateForm("katform", kategorien);
    updateForm("wdhform", wdh);
}

/* PHONOSTAR LINKS */
//Construct the Phonostar time
function getPhonostarTime(dayOfWeek, starttime, duration){
  var time = getNextSuchDay(new Date(), dayOfWeek).getTime();
  var stime = starttime.split(":");
  time += 60 * 60000 * stime[0];
  time += 60000 * stime[1];
  if (time < (new Date()).getTime()){
      time += 24 * 60 * 60000 * 7;
  }
  var startdate = new Date(time);
  var result = formatDate(startdate).concat("|");
  if(duration == "var"){
      duration = 90;
  } else if ((plus = duration.indexOf('+')) != -1){
      duration = Number(duration.substring(0,plus));
      duration = 30 + duration;
  }
  time += 60000 * duration;
  return result.concat(formatDate(new Date(time)));
}

/** Constructs a title for the phonostar record. The format is
    SENDER_SENDUNG_YYYYMMDD.
**/
function getPhonostarTitle(title){
  var result = startdate.getFullYear().toString();
  result = result.concat(formatNum(startdate.getMonth()+1));
  result = result.concat(formatNum(startdate.getDate()));
  return keineUmlaute(title).replace(/\W+/g,"_").concat("_").concat(result);
}

/** Opens a phonostar link for the given details. */
function timer(title, channel, dayOfWeek, starttime, duration){
  var time = getPhonostarTime(dayOfWeek, starttime, duration)
  var newloc = "psradio://|TIMER|".concat(getPhonostarTitle(title)).concat("|");
  newloc = newloc.concat(channel).concat("|");
  newloc = newloc.concat(time);
  newloc = newloc.concat("|0|0|1|0|0");
  window.location.href = newloc;
}


function eml(s){
    var r = unescape(s);
    var l = r.length;
    var o = "";
    for (i = 0; i < l; i++)
    {
        o += String.fromCharCode(r.charCodeAt(i) - 2);
    }
    document.location.href =  "mail" + "to:" + o;
}

// browser detection from MediaWiki JavaScript support functions (wikibits.js)
var clientPC = navigator.userAgent.toLowerCase(); // Get client info
var is_gecko = /gecko/.test( clientPC ) &&
    !/khtml|spoofer|netscape\/7\.0/.test(clientPC);
var webkit_match = clientPC.match(/applewebkit\/(\d+)/);
if (webkit_match) {
    var is_safari = clientPC.indexOf('applewebkit') != -1 &&
        clientPC.indexOf('spoofer') == -1;
    var is_safari_win = is_safari && clientPC.indexOf('windows') != -1;
    var webkit_version = parseInt(webkit_match[1]);
}
// For accesskeys; note that FF3+ is included here!
var is_ff2 = /firefox\/[2-9]|minefield\/3/.test( clientPC );
var ff2_bugs = /firefox\/2/.test( clientPC );
// These aren't used here, but some custom scripts rely on them
var is_ff2_win = is_ff2 && clientPC.indexOf('windows') != -1;
var is_ff2_x11 = is_ff2 && clientPC.indexOf('x11') != -1;
if (clientPC.indexOf('opera') != -1) {
    var is_opera = true;
    var is_opera_preseven = window.opera && !document.childNodes;
    var is_opera_seven = window.opera && document.childNodes;
    var is_opera_95 = /opera\/(9\.[5-9]|[1-9][0-9])/.test( clientPC );
    var opera6_bugs = is_opera_preseven;
    var opera7_bugs = is_opera_seven && !is_opera_95;
    var opera95_bugs = /opera\/(9\.5)/.test( clientPC );
}
// As recommended by <http://msdn.microsoft.com/en-us/library/ms537509.aspx>,
// avoiding false positives from moronic extensions that append to the IE UA
// string (bug 23171)
var ie6_bugs = false;
if ( /MSIE ([0-9]{1,}[\.0-9]{0,})/.exec( clientPC ) != null
&& parseFloat( RegExp.$1 ) <= 6.0 ) {
    ie6_bugs = true;
}


/**
 * Set the accesskey prefix based on browser detection.
 * from MediaWiki JavaScript support functions (wikibits.js)
 */
var tooltipAccessKeyPrefix = 'Alt-';
if ( is_opera ) {
    tooltipAccessKeyPrefix = 'Umschalt-Esc-';
} else if ( !is_safari_win && is_safari && webkit_version > 526 ) {
    tooltipAccessKeyPrefix = 'Strg-Alt-';
} else if ( !is_safari_win && ( is_safari
        || clientPC.indexOf('mac') != -1
        || clientPC.indexOf('konqueror') != -1 ) ) {
    tooltipAccessKeyPrefix = 'Strg-';
} else if ( is_ff2 ) {
    tooltipAccessKeyPrefix = 'Alt-Umschalt-';
}
var tooltipAccessKeyRegexp = /\[(\d)\]$/;

/**
 * Add the appropriate prefix to the accesskey shown in the tooltip.
 * If the nodeList parameter is given, only those nodes are updated;
 * otherwise, all the nodes that will probably have accesskeys by
 * default are updated.
 *
 * @param Array nodeList -- list of elements to update
 */
function updateTooltipAccessKeys( nodeList ) {
    if ( !nodeList ) {
        updateTooltipAccessKeys( document.getElementsByTagName( 'a' ) );
        return;
    }

    for ( var i = 0; i < nodeList.length; i++ ) {
        var element = nodeList[i];
        var tip = element.getAttribute( 'title' );
        if ( tip && tooltipAccessKeyRegexp.exec( tip ) ) {
            tip = tip.replace(tooltipAccessKeyRegexp,
                      '[' + tooltipAccessKeyPrefix + "$1]");
            element.setAttribute( 'title', tip );
        }
    }
}

// Workaround for android issue 7028
// https://code.google.com/p/android/issues/detail?id=7028
function prefixM3UsForAndroid()
{
    var ua = navigator.userAgent.toLowerCase();
    var isAndroid = ua.indexOf("android") > -1;
    if(isAndroid) {
        var streamlinks = document.querySelectorAll(".livestream");
        for (var i = 0; i < streamlinks.length; i++)
        {
            var element = streamlinks[i];
            var href = element.getAttribute('href');
            if (href.lastIndexOf('.m3u') == href.length - 4  && href.indexOf('mospace.de') == -1)
            {
                href = 'http://hspiel.mospace.de/android.php?url=' + encodeURIComponent(href);
                element.setAttribute('href', href);
            }
        }
    }
}
