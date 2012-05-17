<?php
/*
// "AJAX Vote" Plugin for Joomla! 1.0.x - Version 1.1
// License: http://www.gnu.org/copyleft/gpl.html
// Authors: George Chouliaras - Fotis Evangelou - Luca Scarpa
// Copyright (c) 2006 - 2007 JoomlaWorks.gr - http://www.joomlaworks.gr
// Project page at http://www.joomlaworks.gr - Demos at http://demo.joomlaworks.gr
// ***Last update: October 25th, 2007***
// modified for jdownloads by Arno Betz - www.jdownloads.com       
*/

// Set flag that this is a parent file
define( '_JEXEC', 1 );
//Error_Reporting(E_ERROR);

/* Initialize Joomla framework */
define('JPATH', dirname(__FILE__) );
define( 'DS', DIRECTORY_SEPARATOR );
$parts = explode( DS, JPATH );  
$j_root =  implode( DS, $parts ) ;
$x = array_search ( 'components', $parts  );
$path = '';
for($i=0; $i < $x; $i++){
    $path = $path.$parts[$i].DS; 
}
define('JPATH_BASE', $path );    
/* Required Files */
require_once ( JPATH_BASE.'includes'.DS.'defines.php' );
require_once ( JPATH_BASE.'includes'.DS.'framework.php' );
jimport('joomla.database.database');
jimport('joomla.database.table');
$mainframe = &JFactory::getApplication('site');
$mainframe->initialise();
$database = &JFactory::getDBO();

switch($_GET['task']){
	case 'vote':recordVote(); break;
	case 'show':showVotes(); break;
}

function recordVote() {
	global $database;
	
	$user_rating 	= intval( $_GET['user_rating'] );
	$cid 			= intval( $_GET['cid'] );
	
	if (($user_rating >= 1) and ($user_rating <= 5)) {
        if(!empty($_SERVER['HTTP_CLIENT_IP'])) {
            $currip = $_SERVER['HTTP_CLIENT_IP']; // share internet
        } elseif(!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $currip = $_SERVER['HTTP_X_FORWARDED_FOR']; // pass from proxy
        } else {
            $currip = $_SERVER['REMOTE_ADDR'];
        }
    
		$query = "SELECT *"
		. "\n FROM #__jdownloads_rating"
		. "\n WHERE file_id = " . (int) $cid
		;
		$database->setQuery( $query );
		$votesdb = NULL;
        $votesdb = $database->loadObject();
		if (!$votesdb){
			$query = "INSERT INTO #__jdownloads_rating ( file_id, lastip, rating_sum, rating_count )"
			. "\n VALUES ( " . (int) $cid . ", " . $database->Quote( $currip ) . ", " . (int) $user_rating . ", 1 )";
			$database->setQuery( $query );
			$database->query() or die( $database->stderr() );
		} else {
			if ($currip != ($votesdb->lastip)) {
				$query = "UPDATE #__jdownloads_rating"
				. "\n SET rating_count = rating_count + 1, rating_sum = rating_sum + " . (int) $user_rating . ", lastip = " . $database->Quote( $currip )
				. "\n WHERE file_id = " . (int) $cid
				;
				$database->setQuery( $query );
				$database->query() or die( $database->stderr() );
			} else {
				echo 0;
				exit();
			}
		}
		echo 1;
	}
}

function getPercentage (){
	global $database;
	$result = 0;
	
	$id = intval( $_GET['cid'] );
	
	$database->setQuery('SELECT * FROM #__jdownloads_rating WHERE file_id='. (int) $id);
	$database->loadObject($vote);
	
	if($vote->rating_count!=0){
		$result = number_format(intval($vote->rating_sum) / intval( $vote->rating_count ),2)*100;
	}
	
	echo $result;	
}
?>