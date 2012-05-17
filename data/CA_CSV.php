<?php

mysql_connect("localhost", "nturner", "LOB4steR") or die("Could not connect: " . mysql_error());
mysql_select_db("viral_dark_matter");
$result = mysql_query("SELECT well_num, growth_measurement FROM growth");



while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	echo $row['well_num']." ".$row['growth_measurement'];
}

include 'CA_FileDownload.php';
//file named CA_CSV.php
$array_for_csv = array(
	'A1' => array('[0,0.108331]','[30,0.198922]','[60,0.104828]'),
        'A2' => array('[0,0.248231]', '[30,0.214820]', '[60,0.294962]'), 
        'A3' => array('[0,0.302311]', '[30,0.394522]', '[60,0.396562]'),
        'A4' => array('[0,0.408351]', '[30,0.497432]', '[60,0.494522]'), 
        'A5' => array('[0,0.504331]', '[30,0.548422]', '[60,0.594522]'), 
);

CA_CSV::download($array_for_csv);


class CA_CSV {
 
    public static function download($arrays, $filename = 'output.csv') {
        $string = '';
        $c=0;
	$val_array = array();
        $key_array = array();
        foreach($arrays AS $key => $array) {
	    $key_array[] = $key; 
            foreach($array AS $value) {
                $val_array[] = "$value";
            }
	    $string .= implode("\t", $val_array)."\n";
	    unset($val_array);
        }
	if($c == 0) {
            $string = implode("\t", $key_array)."\n".$string;
        }
        $c++; 

        $filename = CA_FileDownload::writeFile($string);
        echo $filename;
    }
 
}
?>
