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

t3_import('core/admin/util');

$obj = new JAT3_AdminUtil();

$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(__FILE__) ));
$uri = str_replace("/administrator", "", $uri);

$template  = $obj->template;

$name = 'pages_profile';
$profiles = $obj->getProfiles();
$pageids = $obj->getPageIds($name);


jimport('joomla.filesystem.file');

$jsonData = $profiles;

$configfile = dirname(__FILE__).DS.'config.xml';
if (file_exists($configfile)) {
	/* For General Tab */
	$generalconfig = $obj->getGeneralConfig();
	$configform = JForm::getInstance('general', $configfile, array('control' => 'jform'));
	
	$params = new JParameter($generalconfig);
	$jsonData['generalconfigdata'] = $params->toArray();
	$jsonData['generalconfigdata'][$name] = str_replace ("\n", "\\\\n", $params->get($name, ''));
	
	$arr_values = array();
	if($value=$params->get($name, '')){
		$arr_values_tmp = explode("\n", $value);
		foreach ($arr_values_tmp as $k=>$v){
			if($v){
				$arr_values[$k] = explode('=', $v);
			}
		}
	}
}

$paramsFile = dirname(__FILE__).DS.'params.xml';
if (file_exists($paramsFile)) {
	/* For General Tab */
	$paramsForm = JForm::getInstance('params', $paramsFile, array('control' => 'jform'));
}

/* For Themes Tab */
$themes = $obj->getThemes();

/* For Layouts Tab*/
$layouts = $obj->getLayouts();


/* Set tab default */
switch (JRequest::getCmd('tab')){
	case 'profile':
		$numbertab = 2;
		break;
	
	case 'layout':
		$numbertab = 3;
		break;
		
	case 'theme':
		$numbertab = 4;
		break;
		
	case 'update':
		$numbertab = 5;
		break;
		
	case 'global':
	default:
		$numbertab = 1;
}

/* Version */
$version = $obj->getTemplateVersion($template);
$layout = dirname(__FILE__).DS.'tmpl'.DS.'default.php';
if (file_exists($layout)) {
	require_once $layout;
}
