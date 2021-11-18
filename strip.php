<?php
/* @ suppresses error output */
$datei = @ fopen ($_GET["url"], "r");
if (!$datei) {
    /* Will produce the correct error. */
    header('Location: '.$_GET["url"]);
    exit;
}
header('Content-type: audio/x-mpegurl; charset=utf-8');
/* Counter protects us if we are (maliciously) fed large files **/
for($i=0; $i<10 && !feof ($datei); $i++) {
    $zeile = fgets ($datei, 1024);
    /* Extract the first line that starts with http:// */
    if (preg_match ("/^http:\/\/(.*)/", $zeile, $treffer)) {
        echo $zeile;
        break;
    }
}
fclose($datei);
?>

