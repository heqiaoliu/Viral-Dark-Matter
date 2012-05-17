<?php
	$temp=$_GET['filename'];
        header("Pragma: public");
        header("Expires: 0");
        header("Cache-Control: private");
        header("Content-type: application/octet-stream");
        header("Content-Disposition: attachment; filename=yourselect.csv");
        header("Accept-Ranges: bytes");
        readfile($temp);
	unlink($temp);
?>
