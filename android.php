<?php

/* @ suppresses error output */
$datei = @ fopen ($_GET['url'], 'r');
if (!$datei) {
    /* Will produce the correct error. */
    header("Location: ".$_GET['url']);
    exit;
}

/* Counter protects us if we are (maliciously) fed large files **/
$url='';
for($i=0; $i<10 && !feof ($datei); $i++) {
    $zeile = fgets ($datei, 1024);
    /* Extract the first line that starts with http:// */

    if (eregi ('^http://(.*)', $zeile, $treffer)) {
        $url = chop($zeile);
        break;
    }
}

fclose($datei);
?>


<!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<?php
if ($url)
{
    echo '<meta http-equiv="refresh" content="0; URL=' . $url . '"/>';
}
?>
    <title>Umleitung zum Livestream</title>
</head>
<body>
<p>
<?php
if ($url)
{
 echo 'Umleitung zu <a href="' . $url .  '">' . $url . '</a>...';
}
else
{
 echo 'Leider kein MP3-Stream gefunden in ' . $_GET['url'];
}
?>
</p>
</body>
</html>


