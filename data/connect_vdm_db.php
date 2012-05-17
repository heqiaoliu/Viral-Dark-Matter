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

if ( ! $db )
  error( "Cannot open connection to $user@$server" );

/* Choose the database to work with: */
if (!mysql_select_db( "viral_dark_matter", $db )) 
  error( "Cannot select database 'vdm_users'." );

?>