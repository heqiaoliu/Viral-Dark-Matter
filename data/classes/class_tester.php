<?php 
//////////////////////////////////////////////
// File: class_tester.php
// Original Author: Nick Turner
// Function: Testing classes
// Notes: Define testing parameters at the top of the file rather than 
// commenting out code
//////////////////////////////////////////////

/// Test Parameters
$BACTERIA_TEST = TRUE; 
$SUPPLEMENT_TEST = FALSE;
$FILE_TEST = FALSE;
$PLATE_TEST = FALSE;
$ROSETTA_TEST = FALSE;

function __autoload($class_name) {
    require_once $class_name . '.php';
}

$dbo = new DBObject("localhost", "nturner", "LOB4steR", "viral_dark_matter");
$db = $dbo->getDB();
Container::$_database = $db;

/// Bacteria test
/// type and name refer to database
if ($BACTERIA_TEST == TRUE) {
	$type = 'bact_external_id';
	$name = 'EDT2231';

	$bacteria = Container::makeBacter();
	$readB = $bacteria->readBacteria();
	$readB2 = $bacteria->readBacterium($type, $name);

	echo "bacteria->readBacteria()<pre>";
	print_r($readB);
	echo "</pre>";

	echo "bacteria->readBacterium($type, $name)<pre>";
	print_r($readB2);
	echo "</pre>";
}

/// Supplement test
if ($SUPPLEMENT_TEST == TRUE) {
	$supplement = Container::makeSupplement();
	/*
	echo "<pre>";
	print_r($read);
	echo "</pre>pre>";

	echo "<pre>";
	print_r($read2);
	echo "</pre>";
	*/
}


/// File test
if ($FILE_TEST == TRUE) {
	$file = Container::makeFile();
	/*
	echo "<pre>";
	print_r($read);
	echo "</pre>pre>";

	echo "<pre>";
	print_r($read2);
	echo "</pre>";
	*/
}

/// Plate test
if ($PLATE_TEST == TRUE) {
	$plate = Container::makePlate();
	/*
	echo "<pre>";
	print_r($read);
	echo "</pre>pre>";

	echo "<pre>";
	print_r($read2);
	echo "</pre>";
	*/
}

/// Rosetta test
if ($ROSETTA_TEST == TRUE) {
	$rosetta = Container::makeRosetta();

	/*
	echo "<pre>";
	print_r($read);
	echo "</pre>pre>";

	echo "<pre>";
	print_r($read2);
	echo "</pre>";
	*/
}








 ?>