<?php
/*
// "AJAX Vote" Plugin for Joomla! 1.0.x - Version 1.0
// License:http://www.gnu.org/copyleft/gpl.html
// Authors:George Chouliaras - Fotis Evangelou - Luca Scarpa
// Copyright (c) 2006 - 2007 JoomlaWorks.gr - http://www.joomlaworks.gr
// Project page at http://www.joomlaworks.gr - Demos at http://demo.joomlaworks.gr
// ***Last update:May 14th, 2007***
*/
ob_start ("ob_gzhandler");
header("Content-type: text/css; charset: UTF-8");
header("Cache-Control: must-revalidate");
$offset = 60 * 60 ;
$ExpStr = "Expires: " . 
gmdate("D, d M Y H:i:s",
time() + $offset) . " GMT";
header($ExpStr);
include("ajaxvote.css");
ob_flush();
?>
