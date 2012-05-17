<?php
function __autoload($class_name) {
    require_once 'classes/'.$class_name . '.php';
}
/* database information */
$server   = "localhost";
$user     = "nturner";
$password = "LOB4steR";
$dbname   = "viral_dark_matter";

try {
	# MySQL with PDO_MYSQL
	$db = new PDO("mysql:host=$server;dbname=$dbname", $user, $password);
	$db->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
}
catch(PDOException $e) {
	echo $e->getMessage();
}

if($_POST['id']) {
	$id  = mysql_escape_String($_POST['id']);
	$bei = mysql_escape_String($_POST['bei']);
	$bn  = mysql_escape_String($_POST['bn']);
	$vi  = mysql_escape_String($_POST['vi']);
	$v   = mysql_escape_String($_POST['v']);

	$Bacteria = new Bacteria();
	$bactArr = $Bacteria->readBacterium('bacteria_id', $id);
	print_r($bactArr);

	// This is the update of both the growth_new and bacteria tables done as one atomic action
	try {
		$db->beginTransaction();
		$sth = $db->prepare("UPDATE growth_new 
						SET bacteria_external_id='$bei', vc_id=$vi 
						WHERE bacteria_external_id='$bactArr[0]' OR vc_id='$bactArr[2]'");
		$sth->execute();
		$sth = $db->prepare("UPDATE bacteria 
						SET bact_external_id='$bei', bact_name='$bn', vc_id=$vi, vector='$v' 
						WHERE bacteria_id=$id");
		$sth->execute();
		$db->commit();
	} catch(PDOException $e) {
		echo "Write to database failed.  Abandon ship.";
    	file_put_contents('logs/PDOErrors.txt', $e->getMessage()."\n", FILE_APPEND);
    	$db->rollBack();
	}

}
?>