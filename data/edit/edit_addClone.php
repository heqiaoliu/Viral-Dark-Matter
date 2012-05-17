<?php  
/* 
author: Nick Turner  &Heqiao Liu
site: viral_dark_matter data_add clone
page: clone.php
last updated: 11/18/2012 by Heqiao Liu */
?>
<!DOCTYPE html>
<html lang="en">
<head> 
<?php require "head.html"; ?>
</head>
<?php echo '<body id="input">';
require "header.html"; ?>
<nav>
  <?php  require "nav.html"; ?>
</nav>
<?php
// user input variables: html form -> uploader.php -> parse.pl -> MySQL DB

/* database information */
$server   = "localhost";
$user     = "nturner";
$password = "LOB4steR";

trim($server);
trim($user);
trim($password);


$bact_external_id=$_POST['bact_external_id'];
$bact_name=$_POST['bact_name'];
$vc_id=$_POST['vc_id'];
$vector = $_POST['vector']; 

function error( $msg )
{
  print( "<h2>ERROR: $msg</h2>\n" );
  exit();
}

/* Make a connection to the database server: */
$db = mysql_connect( $server, $user, $password );

if ( ! $db )
  error( "Cannot open connection to $user@$server" );

/* Choose the database to work with: */
if (!mysql_select_db( "viral_dark_matter", $db ))
  error( "Cannot select database 'viral_dark_matter'." );
mysql_query("INSERT INTO bacteria (bact_external_id, bact_name, vc_id, vector) VALUES ('$bact_external_id','$bact_name','$vc_id','$vector')");

mysql_close($db);	


?>

