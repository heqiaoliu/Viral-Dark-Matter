<?php
/*
// "AJAX Vote" Plugin for Joomla! 1.0.x - Version 1.1
// License: http://www.gnu.org/copyleft/gpl.html
// Authors: George Chouliaras - Fotis Evangelou - Luca Scarpa
// Copyright (c) 2006 - 2007 JoomlaWorks.gr - http://www.joomlaworks.gr
// Project page at http://www.joomlaworks.gr - Demos at http://demo.joomlaworks.gr
// ***Last update: October 25th, 2007***
// modified for jdownloads by Arno Betz - www.jdownloads.com       
*/
ob_start ("ob_gzhandler");
header("Content-type: text/css; charset: UTF-8");
header("Cache-Control: must-revalidate");
$offset = 60 * 60 ;
$ExpStr = "Expires: " . 
gmdate("D, d M Y H:i:s",
time() + $offset) . " GMT";
header($ExpStr);
include("ajaxvote.js");
ob_flush();
?>
