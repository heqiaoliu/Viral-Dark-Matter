<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager Client Library
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license - PHP files are GNU/GPL V2. CSS / JS are Copyrighted Commercial,
# bound by Proprietary License of JoomlArt. For details on licensing, 
# Please Read Terms of Use at http://www.joomlart.com/terms_of_use.html.
# Author: JoomlArt.com
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# Redistribution, Modification or Re-licensing of this file in part of full, 
# is bound by the License applied. 
# ------------------------------------------------------------------------
*/ 

// no direct access
defined( '_JA' ) or die( 'Restricted access' );

// This file will hold configuration for UpdaterClient
global $config;

$jConfig = new JConfig();
$params = &JComponentHelper::getParams( JACOMPONENT );
$defaultService = jaGetDefaultService();

$data_folder = jaucGetDataFolder($params->get("DATA_FOLDER", "jaextmanager_data"));

define('JA_WORKING_DATA_FOLDER', $data_folder);

function jaucRaiseMessage($message, $error = false) {
	if(!empty($message)) {
		if($error) {
			echo "<div style=\"color:red; font-weight:bold;\">$message</div>";
			JError::raiseWarning(100, $message);
		} else {
			echo "<div style=\"color:green; font-weight:bold;\">$message</div>";
			JError::raiseNotice(100, $message);
		}
	}
}

function jaucGetDataFolder($path) {
	$path = FileSystemHelper::clean($path . DS);
	$rootPath = FileSystemHelper::clean($_SERVER['DOCUMENT_ROOT']);
	return (strpos($path, $rootPath) === 0) ? $path : JPATH_ROOT . DS . $path;
}
//validate settings
function jaucValidServiceSettings($params) {
	$errMsg = "";
	if(!JFolder::exists(JA_WORKING_DATA_FOLDER)) {
		if(!JFolder::create(JA_WORKING_DATA_FOLDER, 0777)) {
			$errMsg .= JText::_("JA_UPDATER_CAN_NOT_CREATE_BELOW_FOLDER_AUTOMATICALLY_PLEASE_MANUAL_DO_IT") . "<br />";
			$errMsg .= "<i>".JA_WORKING_DATA_FOLDER."</i>";
		}
	} elseif(!is_writeable(JA_WORKING_DATA_FOLDER)) {
		if(!chmod(JA_WORKING_DATA_FOLDER, 0777)) {
			$errMsg .= JText::_("JA_UPDATER_CAN_NOT_AUTOMATICALLY_CHMOD_FOR_BELOW_FOLDER_TO_WRIABLE_PLEASE_MANUAL_DO_IT") . "<br />";
			$errMsg .= "<i>".JA_WORKING_DATA_FOLDER."</i>";
		}
	} else {
		$fileAccess = JA_WORKING_DATA_FOLDER . ".htaccess";
		if(!JFile::exists($fileAccess)) {
		  $buffer = "Order deny,allow\r\nDeny from all";
			JFile::write($fileAccess, $buffer);
		}
	}
	if ( substr(PHP_OS,0,3) == 'WIN') {
		if(!JFolder::exists(dirname($params->get("MYSQL_PATH")))) {
			$errMsg .= JText::_("PATH_TO_MYSQL_CLI_IS_NOT_CORRECT") . "<br />";
		}
		if(!JFolder::exists(dirname($params->get("MYSQLDUMP_PATH")))) {
			$errMsg .= JText::_("PATH_TO_MYSQL_DUMP_CLI_IS_NOT_CORRECT") . "<br />";
		}
	}
	if($errMsg != "") {
		if(JRequest::getVar('layout') == 'config_service') {
			jaucRaiseMessage($errMsg, true);
		}
		/*$errMsg .= "<a href=\"index.php?option=".JACOMPONENT."&view=default&layout=config_service\" title=\"\">".JText::_('CLICK_HERE_TO_EDIT_SETTINGS')."</a>";
		JError::raiseWarning(100, $errMsg);*/
	}
}
//option=com_jauc&view=default&layout=config_service
if(!(JRequest::getVar('option') == JACOMPONENT && JRequest::getVar('view') == 'default' && JRequest::getVar('layout') == 'config_service')) {
	jaucValidServiceSettings($params);
}
// Component config

$config = new UpdaterConfig(
		array(
			// Define the web service URI
			"WS_MODE"	=> $defaultService->ws_mode,
			"WS_URI"	=> $defaultService->ws_uri,
			"WS_USER"	=> $defaultService->ws_user,
			"WS_PASS"	=> $defaultService->ws_pass,
			//root path to installed product (is root path of website)
			//it is different from the concept of repo path on server
			"REPO_PATH" => JPATH_ROOT . DS,
			// MySQL info
			"MYSQL_HOST" 	=> $jConfig->host,
			"MYSQL_USER" 	=> $jConfig->user,
			"MYSQL_PASS" 	=> $jConfig->password,
			"MYSQL_DB" 		=> $jConfig->db,
			"MYSQL_DB_PREFIX" 	=> $jConfig->dbprefix,
			// Using for backup database
			"MYSQL_PATH" 		=> $params->get("MYSQL_PATH"),
			"MYSQLDUMP_PATH" 	=> $params->get("MYSQLDUMP_PATH")
		)
	);

ini_set('xdebug.max_nesting_level', 100);
ini_set('xdebug.var_display_max_depth', 100);
