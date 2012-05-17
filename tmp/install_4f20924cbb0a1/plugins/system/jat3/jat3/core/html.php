<?php 
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */
$t3_based_path = JPATH_SITE.DS.'templates'.DS.T3_ACTIVE_TEMPLATE.DS;
$layout = str_replace ($t3_based_path, '', $t3_current_layout);		
$layout_path = T3Path::getPath ($layout);
if (!$layout_path) {
	//Detect if it is module or component
	$parts = explode(DS, $layout, 4);
	$type = '';
	if (isset($parts[1])) $type = $parts[1];
	if ($type) {
		if (preg_match ('/^com_/', $type)) {
			//component
			$layout_path = JPATH_SITE.DS.'components'.DS.$parts[1].DS.'views'.DS.$parts[2].DS.'tmpl'.DS.$parts[3];
		} else if (preg_match ('/^mod_/', $type)) {
			//component
			$layout_path = JPATH_SITE.DS.'modules'.DS.$parts[1].DS.'tmpl'.DS.$parts[2];
			if (isset($parts[3])) $layout_path = $layout_path.DS.$parts[3]; 
		} 
	}
}
if ($layout_path && is_file ($layout_path)) include ($layout_path);
?>