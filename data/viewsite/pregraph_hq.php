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
/**
* Create MySQL query from POST array.  
* $_POST['clone'] and $_POST['well'] are both strings of values separated by semi-colons.
* These are exploded into an array which is iterated over and each value is placed into a string (MySQL query)
* 
* Example: 
* 
* SELECT g.growth_measurement, g.well_num, b.bact_external_id FROM growth g, bacteria b 
* WHERE g.bacteria_id = b.bacteria_id AND (b.bact_external_id="EDT2231") 
* AND (b.well_num="E2" OR b.well_num="E6" OR b.well_num="E7") 
* ORDER BY g.time ASC
*/

$query = "SELECT growth_measurement, well_num, bacteria_external_id,b.vc_id FROM growth_new g LEFT JOIN bacteria b ON g.bacteria_external_id=b.bact_external_id WHERE (";
if(array_key_exists('clone',$_POST)){
	$clone_string=$_POST['clone'];
	$temp=explode(";", $clone_string);
	for ($i=0; $i < count($temp)-1; $i++) {
		$query = $query."bacteria_external_id=\"".$temp[$i]."\"";
		if ($i < count($temp)-2) {
			$query = $query." OR ";
		}
	}
}

if(array_key_exists('vcid',$_POST)){
	if(array_key_exists('clone',$_POST))
		$query = $query." OR ";
	$vcid_string=$_POST['vcid'];
	$temp=explode(";", $vcid_string);
	for ($i=0; $i < count($temp)-1; $i++) {
		$query = $query."vc_id=".$temp[$i]." ";
		if ($i < count($temp)-2) {
			$query = $query." OR ";
		}
	}
}

$query = $query.") AND (";
$well_string=$_POST['well'];
$temp=explode(";", $well_string);
for ($i=0; $i < count($temp)-1; $i++) {
	$query = $query."well_num=\"".$temp[$i]."\"";
	if ($i < count($temp)-2) {
		$query = $query." OR ";
	}
}
$query = $query.") ORDER BY time ASC";
//echo "<br/>\nQUERY:".$query."\n<br/>";
$result=mysql_query($query);

/**
* Below we iterate through the MySQL array that was returned.
* We create a 3 dimensional array that looks like ...
* 
* $clones => (
* 		$EDT2235 => (
*			$A1 => (.03, .04, .03),
* 			$A2 => (.01, .00, .02)
*		),
*		$EDT2241 => (...)
*		...
* )
***************/

$clones = array();
$clone_exists = "no";

$cnt = 0;
while ($row = mysql_fetch_array($result,MYSQL_ASSOC)) {
	$cl = $row['bacteria_external_id'];
	$wn = $row['well_num'];
	$gm = $row['growth_measurement'];
	$vi = $row['vc_id'];
	$temp="";
	if(strlen($cl)>0)
		$temp.=$cl;
	if(strlen($cl)>0&&strlen($vi)>0)
		$temp.="/";
	if(strlen($vi)>0)
		$temp.=$vi;
	    if (array_key_exists($temp, $clones)) {
	    	    if (array_key_exists($wn, $clones[$temp])) {
		  	    $clones[$temp][$wn][] = $gm;
 		    } else {
		   	    $clones[$temp][$wn] = array($gm);
		    } 
	    } else {
	  	    $clones[$temp] = array($wn => array($gm));
	    }
}
// The end result is passed back as JSON
echo json_encode($clones);
//echo "<pre>".htmlspecialchars(print_r($clones, TRUE))."</pre>";
//echo "<pre>".htmlspecialchars(print_r(json_encode($clones), TRUE))."</pre>"
?>
