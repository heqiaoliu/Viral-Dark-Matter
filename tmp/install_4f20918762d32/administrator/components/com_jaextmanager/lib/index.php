<?php
// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );
 

define("_JA", "JoomlArt Enterprise");
defined("DS") or define("DS", DIRECTORY_SEPARATOR);

define("_JA_ROOT", realpath(dirname(__FILE__)));
define("_JA_TESTZONE", realpath(_JA_ROOT . DS . ".." . DS . "testzone"));

require_once ("jaupdater" . DS . "JAUpdater.php");
require_once ("config.php");
require_once ("UpdaterClient.php");

$updaterClient = new UpdaterClient();

$updaterClient->execute();
