<?php


// Capture variables from form POST
$file = $_POST['file'];
$clone = $_POST['clone'];

//echo "file: ".$file."& clone: ".$clone."<br />";

if ($_POST) {
	$kv = array();
	$count = 0;
	foreach ($_POST as $key => $value) {
	    if ($count > 1) {
		   	    $kv[] = "$value";
		}
	$count++;
	}

   $query_string = join("\" OR well_num=\"", $kv);
   $query_string = "well_num = \"" . $query_string;  
   $query_string = $query_string . "\"";

}

//echo $query_string;

/* MYSQL setup 
 * We want to create a query like "SELECT well_num, growth_measurement FROM growth WHERE well_num="A1" OR well_num="A2" 
 * Now we must select from all selected clones and only those selected clones.
 * SELECT well_num, growth_measurement FROM growth WHERE well_num="A1" OR well_num="A2" 
 *
 */

mysql_connect("localhost", "nturner", "LOB4steR") or die("Could not connect: " . mysql_error());
mysql_select_db("viral_dark_matter");
$result = mysql_query("SELECT well_num, growth_measurement FROM growth WHERE $query_string");

$well_nums = array(); // Well_nums will be 2D array with wells and growth ($well_num[$wn][$gm])
$well_exists = "no";
$cnt = 0;
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	$wn = $row['well_num'];
	$gm = $row['growth_measurement'];	
		
	foreach ($well_nums as $well => $value) {
		if (strcmp($wn, $well) == 0) {
			// The row from the database has already been entered into the array $well_nums, append data to existing place.  
			$well_nums[$wn][] = $gm; //**append** to second dimension
			$well_exists = "yes";
			break; 
		} 
	}
	// The row from the database has NOT yet been added to $well_nums, create a new well and append data to it.
	// If well does not exist, add it.  
	if ($well_exists != "yes") {
		
		//array_push($well_nums, $wn);
		$well_nums[$wn] = array($gm); //create array in 2nd dimension
	}	
	$well_exists = "no";	
	$cnt++;
}
//echo "<pre>".htmlspecialchars(print_r($well_nums, TRUE))."</pre>";

$string = '';

foreach ($well_nums as $well => $growth) {
	$string .= $well.",".implode(",", $growth)."\n"; //change to \n for file	
}

$filename = FileHandler::writeFile($string);
// example:  /var/www/vdm/data/csv/foolKfRev
// Take only from starting from /csv... 
$filename = substr($filename, 18);
echo $filename;

Class FileHandler {

	public static function writeFile($string) {
		$tmpfname = tempnam("csv/", "foo");
		$handle = fopen($tmpfname, 'w+');
		echo exec("chmod 755 $tmpfname");
		if (fwrite($handle, $string) === FALSE)
		{
		    echo "Cannot write to file ($tmpfname)";
		    fclose($handle);
		    exit;
		}
		fclose($handle);
		return $tmpfname;
	    }
}
