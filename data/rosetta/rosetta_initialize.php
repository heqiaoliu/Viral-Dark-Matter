<?php  

require("../common.php"); 
require_authentication();

function __autoload($class_name) {
    require_once '../classes/'.$class_name . '.php';
}


$dbo = new DBObject("localhost", "nturner", "LOB4steR", "viral_dark_matter");
$db = $dbo->getDB();
Container::$_database = $db;


?>