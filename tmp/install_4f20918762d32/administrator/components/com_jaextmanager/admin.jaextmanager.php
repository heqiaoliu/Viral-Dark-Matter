<?php
/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

@set_time_limit(0);
// no direct access
defined('_JEXEC') or die('Restricted access');

//error_reporting(E_ALL & ~E_STRICT & ~E_NOTICE);


define('JACOMPONENT', 'com_jaextmanager');
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
	JHTML::_('behavior.framework', true);
	JHTML::_('behavior.mootools');
	//JHTML::_('behavior.tooltip');
	JHTML::_('behavior.modal', 'a.modal');
	
	JHTML::_('stylesheet', $assets . 'css/' . 'default.css', false, true);
	JHTML::_('stylesheet', $assets . 'css/' . 'style.css', false, true);
	JHTML::_('stylesheet', $assets . 'japopup/' . 'ja.popup.css', false, true);
	JHTML::_('stylesheet', $assets . 'jadiffviewer/' . 'diffviewer.css', false, true);
	JHTML::_('stylesheet', $assets . 'jatooltips/themes/default/' . 'style.css', false, true);
	JHTML::_('stylesheet', $assets . 'jquery.alerts/' . 'jquery.alerts.css', false, true);
	
	//JHTML::_('script',  $assets. 'js/'.'mootools-legacy.js', false, true);//Mootools 1.11 Legacy
	JHTML::_('script', $assets . 'js/' . 'jquery.js', false, true);
	JHTML::_('script', $assets . 'js/' . 'jquery.event.drag-1.4.min.js', false, true);
	JHTML::_('script', $assets . 'js/' . 'jauc.js', false, true);
	JHTML::_('script', $assets . 'js/' . 'jatree.js', false, true);
	JHTML::_('script', $assets . 'js/' . 'menu.js', false, true);
	JHTML::_('script', $assets . 'japopup/' . 'ja.popup.js', false, true);
	JHTML::_('script', $assets . 'jadiffviewer/' . 'diffviewer.js', false, true);
	JHTML::_('script', $assets . 'jatooltips/' . 'ja.tooltips.js', false, true);
	JHTML::_('script', $assets . 'jquery.alerts/' . 'jquery.alerts.js', false, true);

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
