<?php
/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');

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
	$configForm = new JParameter($generalconfig, $configfile, 'template');
	$jsonData['generalconfigdata'] = $configForm->toArray();
	$jsonData['generalconfigdata'][$name] = str_replace ("\n", "\\\\n", $configForm->get($name, ''));
	/* Parse data*/
	$arr_values = array();
	if($value=$configForm->get($name, '')){
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
	$paramsForm = new JParameter('', $paramsFile, 'template');
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