<?php
// This php script is the target of your form.

// Begin the session
session_start();
$SID = session_id();

$query_string = "";
if ($_POST) {
  $kv = array();
  foreach ($_POST as $key => $value) {
    $kv[] = "$key=$value";
  }
  $query_string = join("&", $kv);
}
else {
  $query_string = $_SERVER['QUERY_STRING'];
}
ob_start();
echo "query here:$query_string\n\n";
echo passthru('perl get_pap_data.cgi '.$SID.' '.escapeshellarg($query_string));
$perlreturn = ob_get_contents();
ob_end_clean();
#echo "output buffer: <br /> $perlreturn";
$_SESSION['perlreturn'] = $perlreturn;

//putenv('QUERY_STRING');
//system('rm ../pap/duh.gif');
//session_write_close();

header('Location: http://vdm.sdsu.edu/data/phenotype_arrays/index.php?img=true');
?>
