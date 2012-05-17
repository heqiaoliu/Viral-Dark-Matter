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
    echo "error1"; //Cannot open connection to $user@$server
    die();
}
if (!mysql_select_db( "viral_dark_matter", $db )) {
    echo "error2"; //Cannot select database 'viral_dark_matter'.
    die();
}
/* Parse the filename and check to see if it has already been uploaded. */
// Goes from C:\\fakepath\\2236A-ID326.txt -> 2236A-ID326.txt
$file = substr($_POST['file'], strrpos($_POST['file'], '\\')+1); 
$result = mysql_query("SELECT file_name FROM file WHERE file_name='$file';");

//$edt = substr($file, 0, 4);

/* Problem with Query */
if(!$result) {
	echo "error3"; //Cannot execute the query
}
$numrows = mysql_num_rows($result);
if($numrows > 0) {
	echo 'error4'; //Table already in DB
} else {
	echo 'success';
}

?>