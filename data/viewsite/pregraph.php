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

$query = "SELECT time,growth_measurement, well_num, bacteria_external_id,b.vc_id, replicate_num FROM growth_new g LEFT JOIN bacteria b ON g.bacteria_external_id=b.bact_external_id WHERE (";
if(array_key_exists('clone',$_POST)){
	$clone_string=$_POST['clone'];
	$temp=explode(";", $clone_string);
	for ($i=0; $i < count($temp)-1; $i++) {
		$cloneNrep=explode(",",$temp[$i]);
		$query = $query."bacteria_external_id=\"".$cloneNrep[0]."\"";
		if ($i < count($temp)-2) {
			$query = $query." OR ";
		}
	}
}

/* this is the part for asking data also by vc_id
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
*/

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
	$rp = $row['replicate_num'];
	$tm = $row['time'];
	$dataPoint= Array($tm,$gm);
	$temp="";
/*	vcid function is make as comment
	now the format is external_id:replicate_num
	with the if conditions , it is going to be 
	external_id/vcid:replicate --has both id
	external_id:replicate      --has only ext_id
	vc_id:replicate	   --has only vc_id
	
*/
//	if(strlen($cl)>0)
		$temp.=$cl;
//	if(strlen($cl)>0&&strlen($vi)>0)
//		$temp.="/";
//	if(strlen($vi)>0)
//		$temp.=$vi;
	$temp.=":".$rp;
	    if (array_key_exists($temp, $clones)) {
	    	    if (array_key_exists($wn, $clones[$temp])) {
	    	    // Clone, well and growth exists, add growth to existing well
		  	    $clones[$temp][$wn][] = $dataPoint;
 		    } else {
 		    	// Clone and Well exists, add growth
		   	    $clones[$temp][$wn] = array($dataPoint);
		    } 
	    } else {
	    	// Clone does not exist, add clone, well and growth 
	  	    $clones[$temp] = array($wn => array($dataPoint));
	    }
}
// The end result is passed back as JSON
echo json_encode($clones);
//echo "<pre>".htmlspecialchars(print_r($clones, TRUE))."</pre>";
//echo "<pre>".htmlspecialchars(print_r(json_encode($clones), TRUE))."</pre>"
?>
