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
// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );
 
define('JA_WORKING_DATA_FOLDER', PATH_ROOT . DS . "jaextmanager_data" . DS);


function jaucRaiseMessage($message, $error = false)
{
	if ($error) {
		echo "<div style=\"color:red; font-weight:bold;\">$message</div>";
	} else {
		echo "<div style=\"color:green; font-weight:bold;\">$message</div>";
	}
}

$errMsg = "";
if (!JFolder::exists(JA_WORKING_DATA_FOLDER)) {
	if (!JFolder::create(JA_WORKING_DATA_FOLDER, 0777)) {
		$errMsg .= "JA Updater can not create below folder automatically. Please manual create and chmod it to wriable!" . "<br />";
		$errMsg .= "<i>" . JA_WORKING_DATA_FOLDER . "</i>";
	}
} elseif (!is_writeable(JA_WORKING_DATA_FOLDER)) {
	if (!chmod(JA_WORKING_DATA_FOLDER, 0777)) {
		$errMsg .= "JA Updater can not automatically chmod for below folder to wriable. Please manual chmod it to wriable!" . "<br />";
		$errMsg .= "<i>" . JA_WORKING_DATA_FOLDER . "</i>";
	}
}
if ($errMsg != "") {
	jaucRaiseMessage($errMsg, true);
}

// This file will hold configuration for UpdaterClient
global $config;

//echo "other flatform";
$config = new UpdaterConfig(array(// Define the web service URI


"WS_MODE" => "remote", "WS_URI" => "http://update.joomlart.com/service/", "WS_USER" => "joomlart", "WS_PASS" => "joomlart", //
"REPO_PATH" => "", "MYSQL_HOST" => "localhost", "MYSQL_USER" => "thanhnv", "MYSQL_PASS" => "1234", "MYSQL_DB" => "ja_updater", "MYSQL_DB_PREFIX" => "jos_", "MYSQL_PATH" => 'mysql', //for backup database
"MYSQLDUMP_PATH" => 'mysqldump'));

ini_set('xdebug.max_nesting_level', 100);
ini_set('xdebug.var_display_max_depth', 100);
