<?php 
/* database information */
$server   = "localhost";
$user     = "nturner";
$password = "LOB4steR";

trim($server);
trim($user);
trim($password);

function error( $msg )
{
  print( "<h2>ERROR: $msg</h2>\n" );
  exit();
}

/* Make a connection to the database server: */
$db = mysql_connect( $server, $user, $password );
if ( ! $db ) {
    echo "err1"; //Cannot open connection to $user@$server
    die();
}
if (!mysql_select_db( "viral_dark_matter", $db )) {
    echo "err2"; //Cannot select database 'viral_dark_matter'.
    die();
}

$id = $_POST['id'];
//echo "id: ".$id."\n";
if ($id == "bact_id") {
	$bact = $_POST['bact_id'];
	//echo "ba: ".$bact."\n";
	$result = mysql_query("SELECT vc_id FROM bacteria WHERE bact_external_id='$bact';");
} elseif ($id == "vc_id") {
	$vc = $_POST['vc_id'];
	//echo "vc: ".$vc."\n";
	$result = mysql_query("SELECT bact_external_id FROM bacteria WHERE vc_id='$vc';");
} else {
	echo "err0"; // This error should never ever happen... 
}


/* Problem with DB Query */
if(!$result) {
	echo "err3"; // Cannot execute the query
}
$numrows = mysql_num_rows($result);
if($numrows > 1) {
	// Too many... 
	echo 'err4';
} elseif($numrows == 1) {
	// Success
	$row = mysql_fetch_array($result);
	if (isset($row['vc_id'])) {
		echo 'success:'.$row['vc_id'];
	} else {
		echo 'success:'.$row['bact_external_id'];
	}
} else {
	echo 'err5'; // No matching vcid or bactid.  yikes.  
}

?>