<?php
// uploader.php
// Nick Turner
// Jan 2012

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
  error( "Cannot select database 'viral_dark_matter'." );

// user input variables: html form -> uploader.php -> parse.pl -> MySQL DB
$name = $_POST['name'];
$plate = $_POST['plate'];
$additionalInfo = $_POST['additionalInfo'];
$overwrite = $_POST['overwrite'];

// Get bactid and vcid
if (isset($_POST['bactid'])) {
    $bactid = $_POST['bactid'];
    $vcid = $_POST['other'];
}
elseif (isset($_POST['vcid'])) {
    $vcid = $_POST['vcid'];
    $bactid = $_POST['other'];
} else {
  echo 'ERROR, neither vcid or bactid were set.';
}

// Get filename
$file2 = basename($_FILES['uploadedfile']['name']);
// Check to see if we need to overwrite the existing data.  Input.php will pass yes if the same file is uploaded twice.(Must have the same name.)
if ($overwrite == 'yes') {
    // Delete file name from file database and data associated with it from growth
    mysql_query("DELETE FROM file WHERE file_name = '$file2';");
    mysql_query("DELETE FROM growth_new WHERE file_name = '$file2';");
}


// Get replicate number (auto increments, not the mysql function), it increments every time a file is added with the same EDT as a previous file, CANT THINK OF A BETTER WAY TO DO IT RIGHT NOW!!!
// 
$query = "
SELECT file.replicate_num
FROM file 
JOIN bacteria 
ON (file.bacteria_id = bacteria.bacteria_id) 
WHERE bacteria.bact_external_id = '$bactid' 
ORDER BY replicate_num DESC;
";
$result = mysql_query($query);
$row = mysql_fetch_row($result);
$numrows = mysql_num_rows($result);
if($numrows > 0) {
    $replicate_num = $row[0] + 1;
} else {
    $replicate_num = 1;
}

$query = "
SELECT bacteria_id
FROM bacteria
WHERE bact_external_id = '$bactid'
LIMIT 1;
";
$result = mysql_query($query);
$row = mysql_fetch_row($result);
$bacteria_id = $row[0];
/* ** ** ** ** ** End Replicate ** ** ** ** ** ** */

/* upload file */
// $target_path is where the text file will be uploaded
$target_path = "../upload/";
$target_path = $target_path . basename( $_FILES['uploadedfile']['name']); 
$perlfile = "./input_parse.pl " . implode(" ", array_map("escapeshellarg", array($name, $bactid, $vcid, $replicate_num, $plate, $target_path )));

//echo 'Handed from form to php: ' .$name. ' ' .$bactid. ' ' .$vcid. ' ' .$replicate_num. ' ' .$plate."<br />";

// if file was uploaded, send everything onto parse.pl 
if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
    //echo "The file ".  basename( $_FILES['uploadedfile']['name']). " has been uploaded.\n";
    $handle = fopen($target_path, "r");
    $phpdate = fgets($handle, 11);
    $mysqldate = date( 'Y-m-d', strtotime($phpdate) );
    mysql_query("INSERT INTO file (file_name, name, exp_date, bacteria_id, replicate_num, notes) VALUES ('$file2', '$name', '$mysqldate', '$bacteria_id', '$replicate_num', '$additionalInfo')"); 
    //echo $phpdate."<br/>".$mysqldate;
    fclose($handle);
    ob_start();
    echo passthru($perlfile);
    //echo "<br />";
    $perlreturn = ob_get_contents();
    ob_end_clean();
    //echo "return from perl: ". $perlreturn;
} else{
    if ($_FILES['uploadedfile1']['error'] !== UPLOAD_ERR_OK) {
        die("file #1 failed with error code " . $_FILES['uploadedfile']['error']);
    }
    echo "<br /><br />There was an error uploading the file, please try again!<br />";
}
mysql_close($db);
header("Location: http://vdm.sdsu.edu/data/input/input.php?success=".urlencode("Upload of ".$file2." complete."), true);
exit();
?>