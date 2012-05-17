<?php

$server   = "localhost";
$user     = "nturner";
$password = "LOB4steR";

/* Make a connection to the database server: */
$db = mysql_connect( $server, $user, $password );

if ( ! $db )
    error( "Cannot open connection to $user@$server" );

/* Choose the database to work with: */
if (!mysql_select_db( "viral_dark_matter", $db ))
   error( "Cannot select database 'viral_dark_matter'." );
$click=$_POST['clickeditem'];
$query='select distinct replicate_num from growth_new where bacteria_external_id=\''.$click.'\';';
$result=mysql_query($query);
$repArray=Array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) 
  $repArray[]=$row['replicate_num'];
echo json_encode($repArray);
