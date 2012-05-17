<?php
/**
* @version 1.5
* @package jDownloads
* @copyright (C) 2009 www.joomlaaddons.de
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*
*/

defined( '_JEXEC' ) or die( 'Restricted access' );


function com_uninstall() {
    
    $msg = '';
    $msg = '<p align="center"><b><span style="color:#00CC00">The download folder and all subfolders still exists!</b></p>' 
           .'<p align="center"><b><span style="color:#00CC00">Folder images/jdownloads/ still exists! </b></p>'
           .'<p align="center"><b><span style="color:#00CC00">All jDownloads database tables still exist!</b></p>'
           .'<p align="center">Please delete it (them) manually, if you want.</p>'
           .'<p align="center">Otherwise you can now also install a newer version, when it is available.</p>';
    echo $msg;
}
?>