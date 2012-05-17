<?php
/*------------------------------------------------------------------------
# $JA#PRODUCT_NAME$ - Version $JA#VERSION$ - Licence Owner $JA#OWNER$
# ------------------------------------------------------------------------
# Copyright (C) 2004-2008 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
# @license - Copyrighted Commercial Software
# Author: J.O.O.M Solutions Co., Ltd
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# This file may not be redistributed in whole or significant part.
-------------------------------------------------------------------------*/

// no direct access
defined( '_JEXEC' ) or die( 'Restricted access' );
	
function jaGetListServices() {
	$db = JFactory::getDBO ();
	
	$sql = "SELECT * FROM #__jaem_services AS t WHERE 1 ORDER BY t.ws_name";
	$db->setQuery ( $sql );
	return $db->loadObjectList();
}

function jaGetDefaultService() {
	$services = jaGetListServices();
	$default = new stdClass();
	foreach ($services as $id => $sv) {
		if($id == 0 || $sv->ws_default) {
			$default = $sv;
		}
	}
	//set default values
	if(!isset($default->ws_mode)) {
		$default->ws_mode = 'local';
	}
	if(!isset($default->ws_uri)) {
		$default->ws_uri = 'http://update.joomlart.com/service/';
	}
	if(!isset($default->ws_user)) {
		$default->ws_user = 'joomlart';
	}
	if(!isset($default->ws_pass)) {
		$default->ws_pass = '';
	}
	
	return $default;
}

function jaEMTooltips($tipid, $title) {
	$title = preg_replace("/\r\n/", "", $title);
	$title = addslashes($title);
	$script = "
			<script type=\"text/javascript\">
			/*<![CDATA[*/
			window.addEvent('domready', function(){
				new JATooltips ([$('{$tipid}')], {
						content: '{$title}'
				});
			});
			/*]]>*/
			</script>
			";
	return $script;
}

/**
 * Create file with unique file name
 *
 */
function jaTempnam($dir, $prefix) {
	$dir = JPath::clean($dir.DS);
	if(!JFolder::exists($dir)) {
		$dir = JPath::clean(ja_sys_get_temp_dir().DS);
	}
	
	$sand = md5(microtime());
	$fileName = $prefix.date("YmdHis").$sand;
	$i=0;
	$fileNameTest = $fileName.".tmp";
	while (JFile::exists($dir.$fileNameTest)) {
		$i++;
		$fileNameTest = $fileName ."_{$i}.tmp";
	}
	$file = $dir . $fileNameTest;
	//$content = '';
	//JFile::write($file, $content);
	//chmod
	//@chmod($file, '0755');
	return $file;
}

?>