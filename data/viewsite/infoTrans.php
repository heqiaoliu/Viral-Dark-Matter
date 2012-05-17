<?php
$server   = "localhost";
$user     = "nturner";
$password = "LOB4steR";
$db = mysql_connect( $server, $user, $password );
if ( ! $db )
    error( "Cannot open connection to $user@$server" );
if (!mysql_select_db( "viral_dark_matter", $db ))
   error( "Cannot select database 'viral_dark_matter'." );

$well_num=(ord($_POST['well'])-64)+8*((int)substr($_POST['well'],1)-1);

//$query="select m.medium_supplement_name from medium_supplement m left join well_info w on m.medium_supplement_id=w.suplement_id where w.bacteria_id=20 "/*.$_POST['bacteria_id']."*/." and w.plate_id=1"/*.(int)$_POST['plate_id']*/." and w.well_id=".$well_num.";";*/
$query="select m.medium_supplement_name, w.supplement_conc from medium_supplement m left join well_info w on m.medium_supplement_id=w.supplement_id where w.bacteria_id=20 and w.plate_id=1 and w.well_id=".$well_num.";";
$result=mysql_query($query);
$temp;
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) 
  $temp=$row['medium_supplement_name']." ".$row['supplement_conc'];
echo json_encode($temp);
?>
