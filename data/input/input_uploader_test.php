<?php  
/*
* This page is the inbetween for input_parser.pl and input.php.
* The POST data from input.php is turned into meaningful database information, i.e. some SELECT statements must be used 
* to determine table IDs that will speed up input into the database.  
* This page also checks to see if an overwrite is necessary, (only happens when a file of the same name is being uploaded for the second time),
* in which case the applicable information will be deleted from file, exp and growth tables
*
*/

// Initialization of classes and DB
function __autoload($class_name) {
    require_once '../classes/'.$class_name . '.php';
}
$dbo = new DBObject("localhost", "nturner", "LOB4steR", "viral_dark_matter");
$db = $dbo->getDB();
$exception = "None";
Container::$_database = $db;
/* ------------ + ------------- */

// user input variables: 
// input.php html form -> uploader.php -> parse.pl -> MySQL DB
$name = $_POST['name'];
$plate = $_POST['plate'];
$additionalInfo = $_POST['additionalInfo'];
$overwrite = $_POST['overwrite'];
// The upload directory is where the uploaded file will be added, before data is entered into the database
$target_path = "../upload/" . basename( $_FILES['uploadedfile']['name']);  
$file = basename($_FILES['uploadedfile']['name']);

// Get bactid or vcid, set the other with $_POST['other']
// If both are empty (should never happen due to javascript on client side, but hey... ) redirect user with error
if (empty($_POST['bactid']) && empty($_POST['vcid'])) {
    // change back to input.php when switch is made
    header("Location: http://vdm.sdsu.edu/data/input/input_test.php?inputError=".
        urlencode("Error: VCID and Bacteria External ID not specified.  If this problem persists, contact an administrator."), true); 
} elseif (empty($_POST['bactid'])) {
    $bactid = $_POST['bactid'];
    $vcid = $_POST['other'];
} elseif (empty($_POST['vcid'])) {
    $vcid = $_POST['vcid'];
    $bactid = $_POST['other'];
} 
/* ------------ + ------------- */

/*
*
*/

// NOTE: future change, make function checkConsistency and replace rows affected, this function checks to make sure FILE EXP and GROWTH are consistent
$FileObj = Container::makeFile();
try {
    $rows_affected = $FileObj->readFiles_getRowsAffected('file_name', $file);
    echo "$rows_affected $overwrite";
    if ($rows_affected > 1) {
        throwMultipleFilesError($file);
    } elseif ($rows_affected == 1 && $overwrite == 'yes') {
        deleteFromFileExpGrowth($FileObj, $file);
    } elseif ($rows_affected == 1 && $overwrite == 'no') {
        // ERROR
        echo "problem??";
        throw new Exception('wtf is this');
    } elseif ($rows_affected == 0) {
        // This file is the first with its name!  Easy as cake.  Pop the data in! 
        echo "no probs";
    }
} catch(PDOException $e) {  
    $exception = $e->getMessage();  
    echo $exception;
} catch(Exception $e) {
    $exception = $e->getMessage();
    echo $exception;
}
/* ------------ + ------------- */


// Check to see if we need to overwrite the existing data.  
// Input.php will pass yes if the same file is uploaded twice.(Must have the same name.)
// Delete from: 
//    - file: using 'file_name'
//    - exp: using file_id from file
//    - growth: using exp_id from exp

function throwMultipleFilesError($filename) {
    $sth = Container::$_database->query("SELECT file_name, file_id FROM file WHERE file_name='$filename';");
    $multipleFiles = "<pre>File Name          |          File Database ID\n" .
                          "______________________________________________</pre>";
    while($row = $sth->fetch()) {  
        $multipleFiles .= $row['file_name']." ... ".$row['file_id']." <br> ";  
    }  
    throw new Exception('Multiple files in database of the same name. <br> '.$multipleFiles.' Contact an administrator.');
}

function deleteFromFileExpGrowth($FileObj, $file) {
    echo "<br>deleting from file...";

    // get fid
    $row = $FileObj->readFile('file_name', $file);
    $file_id = $row['file_id'];
    echo "<br>file_id: ".$file_id."<br>".$file;

    // delete from file
    $fileDeleteCount = $FileObj->deleteFile($file);

    // get expid
    
    // delete from exp

    // delete from growth

    echo "<br>delCount";
}

//function logDeletedRows($obj) {
    
//}

?>