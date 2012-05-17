<?php
/**
 * ------------------------------------------------------------------------
 * JA Extensions Manager
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

@set_time_limit(0);
@ini_set("memory_limit", "128M");
// no direct access
defined('_JEXEC') or die('Restricted access');

//error_reporting(E_ALL & ~E_STRICT & ~E_NOTICE);


define('JACOMPONENT', 'com_jaextmanager');

jimport('joomla.filesystem.file');
// Require the base controller
require_once (JPATH_COMPONENT . DS . 'controller.php');

// Require constants
require_once (JPATH_COMPONENT . DS . "constants.php");

require_once (JPATH_COMPONENT . DS . "helpers" . DS . "menu.class.php");
require_once (JPATH_COMPONENT . DS . "helpers" . DS . "helper.php");
require_once (JPATH_COMPONENT . DS . "helpers" . DS . "jahelper.php");
require_once (JPATH_COMPONENT . DS . "helpers" . DS . "jauc.php");
require_once (JPATH_COMPONENT . DS . "helpers" . DS . "tree.php");
require_once (JPATH_COMPONENT . DS . "helpers" . DS . "repo.php");
require_once (JPATH_COMPONENT . DS . "helpers" . DS . "uploader" . DS . "uploader.php");
// Define global data


$baseURI = "components/" . JRequest::getVar('option');

// Load global stylesheets and javascript
if (!defined('JA_GLOBAL_SKIN')) {
	define('JA_GLOBAL_SKIN', 1);
	$assets = JURI::root() . 'administrator/components/' . JACOMPONENT . '/assets/';

	JHTML::stylesheet('default.css', $assets . 'css/');
	JHTML::stylesheet('style.css', $assets . 'css/');
	JHTML::stylesheet('ja.popup.css', $assets . 'japopup/');
	JHTML::stylesheet('diffviewer.css', $assets . 'jadiffviewer/');
	JHTML::stylesheet('style.css', $assets . 'jatooltips/themes/default/');
	JHTML::stylesheet('jquery.alerts.css', $assets . 'jquery.alerts/');

	JHTML::script('jquery.js', $assets . 'js/');
	JHTML::script('jquery.event.drag-1.4.min.js', $assets . 'js/');
	JHTML::script('jauc.js', $assets . 'js/');
	JHTML::script('jatree.js', $assets . 'js/');
	JHTML::script('menu.js', $assets . 'js/');
	JHTML::script('ja.popup.js', $assets . 'japopup/');
	JHTML::script('diffviewer.js', $assets . 'jadiffviewer/');
	JHTML::script('ja.tooltips.js', $assets . 'jatooltips/');
	JHTML::script('jquery.alerts.js', $assets . 'jquery.alerts/');

	//JHTML::_('behavior.tooltip');
	JHTML::_('behavior.modal');
}

// Require jaupdater library
require_once (JPATH_COMPONENT . DS . "lib" . DS . "UpdaterClient.php");

global $compUri, $settings, $jauc;
$compUri = "index.php?option=" . JRequest::getVar('option');
$jauc = new UpdaterClient();

JToolbarHelper::title(JText::_("JOOMART_EXTENSIONS_MANAGER"));

// -----
// Require specific controller if requested
if ($controller = JRequest::getWord('view', 'components')) {
	$path = JPATH_COMPONENT . DS . 'controllers' . DS . $controller . '.php';
	if (file_exists($path)) {
		require_once $path;
	} else {
		$controller = '';
	}
}

// Create the controller
$className = 'JaextmanagerController' . $controller;

$controller = new $className();

// Perform the Request task
$controller->execute(JRequest::getVar('task'));

// Redirect if set by the controller
$controller->redirect();
