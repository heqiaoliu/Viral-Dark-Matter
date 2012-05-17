<?php  

require("../common.php"); 
require_authentication();

function __autoload($class_name) {
    require_once '../classes/'.$class_name . '.php';
}
function createSelect($array, $column) {
    $string = '';
    for ($i=0; $i<count($array); $i++) {
        $string .= '<option>'.$array[$i][$column].'</option>';
    }
    return $string;
}

$dbo = new DBObject("localhost", "nturner", "LOB4steR", "viral_dark_matter");
$db = $dbo->getDB();
Container::$_database = $db;

?>