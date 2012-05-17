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
/*
if (!isset($_POST['bactid'])) {
    $vcid = $_POST['vcid'];
    $query = "SELECT bact_external_id FROM bacteria"; //WHERE vc_id='$vcid'"
    $result = mysql_query($query) or die mysql_error();
    $bactid = $result['bact_external_id'];
    echo "BACTID: ".$bactid."<br/>";
    $vcid = $_POST['vcid'];
    echo "VCID: ".$vcid."<br/>";
} else {
    $result = mysql_query("SELECT vc_id FROM bacteria WHERE bact_external_id='".$_POST['bactid']."' LIMIT 1") or die mysql_error();
    $vcid = mysql_result($result, 0);
    echo "VCID: ".$vcid."<br/>";
    $bactid = $_POST['bactid'];
    echo "BACTID: ".$bactid."<br/>";

}
*/
// user input variables: html form -> uploader.php -> parse.pl -> MySQL DB
$name = $_POST['name'];
$bactid = $_POST['bactid'];
$vcid = $_POST['vcid'];
//$replicate = $_POST['replicate'];
$plate = $_POST['plate'];
$additionalInfo = $_POST['additionalInfo'];
echo 'additionalInfo: <br /><pre>'.$additionalInfo.'</pre><br />';


/* Choose the database to work with: */
if (!mysql_select_db( "viral_dark_matter", $db ))
  error( "Cannot select database 'viral_dark_matter'." );
$file2 = basename($_FILES['uploadedfile']['name']);
mysql_query("INSERT INTO file (file_name, name, bact_id, notes) SELECT '$file2', '$name', bacteria_id, '$additionalInfo' FROM bacteria WHERE bact_external_id = '$bactid'"); 
mysql_close($db);

/* upload file */
// $target_path is where the text file will be uploaded
$target_path = "upload/";
$target_path = $target_path . basename( $_FILES['uploadedfile']['name']); 
$perlfile = "./input_parse.pl " . implode(" ", array_map("escapeshellarg", array($name, $bactid, $vcid, /*$replicate,*/ $plate, $target_path )));

echo 'Handed from form to php: ' .$name. ' & ' .$bactid. ' & ' .$vcid. ' & ' .$replicate. ' & ' .$plate;
//echo "<br />";

// if file was uploaded, send everything onto parse.pl 
if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
    echo "The file ".  basename( $_FILES['uploadedfile']['name']). " has been uploaded.\n";
    ob_start();
    echo passthru($perlfile);
    echo "<br />";
    $perlreturn = ob_get_contents();
    ob_end_clean();
    echo "return from perl: ", $perlreturn;
} else{
    if ($_FILES['uploadedfile1']['error'] !== UPLOAD_ERR_OK) {
        die("file #1 failed with error code " . $_FILES['uploadedfile']['error']);
    }
    echo "<br /><br />There was an error uploading the file, please try again!<br />";
}
?>
