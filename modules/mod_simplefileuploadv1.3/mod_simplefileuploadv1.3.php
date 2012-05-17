<?php
/**
 * Simple File Uploader Module Entry Point
 * 
 * @package    Joomla
 * @subpackage Modules
 * @author Anders Wasén
 * @link http://wasen.net/
 * @license		GNU/GPL, see LICENSE.php
 * mod_simplefileupload is free software. This version may have been modified pursuant
 * to the GNU General Public License, and as distributed it includes or
 * is derivative of works licensed under the GNU General Public License or
 * other free or open source software licenses.
 */
 
// no direct access
defined( '_JEXEC' ) or die( 'Restricted access' );

$sfu_version = "1.3";
$sfu_basepath = "modules/mod_simplefileuploadv".$sfu_version."/";

// Get CAPTCHA BG color
$upload_capthcabg = $params->get( 'upload_capthcabg', '120-192' );

if ($upload_capthcabg !== "") {
	$bgcolor = explode('-', $upload_capthcabg);
	if(!is_array($bgcolor)) {
		$bgcolor = array(0 => "120", 1 => "192");
	} else {
		if (!is_numeric($bgcolor[0])) $bgcolor[0] = "120";
		if (!is_numeric($bgcolor[1])) $bgcolor[1] = "192";
	}
} else {
	$bgcolor = array(0 => "120", 1 => "192");
}

// Make ready for Ajax calls and avoid any whitespace
if (isset($_GET["sfuaction"])) {
if(!class_exists('SFUAjaxServlet')) JLoader::register('SFUAjaxServlet' , dirname(__FILE__).DS.'helper.php');
if ($_GET["sfuaction"] === "captcha") {
$mid = $_GET["mid"];
//global $mainframe;
$app = JFactory::getApplication();
header('Cache-control: private');
header('Last-Modified: ' . gmdate("D, d M Y H:i:s") . ' GMT'); 
header('Cache-Control: no-store, no-cache, must-revalidate'); 
header('Cache-Control: post-check=0, pre-check=0', false); 
header('Pragma: no-cache');
echo SFUAjaxServlet::getCaptcha($sfu_version, $bgcolor, $mid, 'ajax');
//$mainframe->close();
$app->close();
} else {
echo SFUAjaxServlet::getContent($_GET["sfuaction"]);
}
}

$session =& JFactory::getSession();
// Get Module ID to create unique names
$mid = $module->id;
// Store MID for use in SFL and SPU
$_SESSION["sfu_mid"] = $mid;

$upload_location = $params->get( 'upload_location', '.'.DS.'images' );
if ( substr( $upload_location , strlen($upload_location) - 1) !== DS ) 
	$upload_location .= DS;

$upload_bgcolor = $params->get( 'upload_bgcolor', '#e8edf1' );
if ( substr( $upload_bgcolor, 0, 1 ) !== "#" ) 	
	$upload_bgcolor = "#" . $upload_bgcolor;

$upload_capthcaheight = $params->get( 'upload_capthcaheight', '40' );
$upload_capthcawidth = $params->get( 'upload_capthcawidth', '120' );
$upload_stdbrowse = $params->get( 'upload_stdbrowse', '0' );
$upload_filewidth = $params->get( 'upload_filewidth', '12' );
$upload_maxsize = $params->get( 'upload_maxsize', '100000' );
$upload_popcaptchamsg = $params->get( 'upload_popcaptchamsg', '1' );
$upload_capthca = $params->get( 'upload_capthca', '1' );
$upload_capthcacase = $params->get( 'upload_capthcacase', '0' );
$upload_capthcacasemsg = $params->get( 'upload_capthcacasemsg', '0' );
$upload_multi = $params->get( 'upload_multi', '0' );
$upload_maxmulti = $params->get( 'upload_maxmulti', '100' );
$upload_startmulti = $params->get( 'upload_startmulti', '0' );
$upload_redirect = $params->get( 'upload_redirect', '' );
$upload_formfields = $params->get( 'upload_formfields', '' );
$upload_useformsfields = $params->get( 'upload_useformsfields', '0' );
if ($upload_useformsfields == 0) 
	$upload_formfields = "";
$sfu_autorefreshsfl = $params->get( 'sfu_autorefreshsfl', '0' );
$upload_jquery = $params->get( 'upload_jquery', '0' );
$upload_jqueryinclude = $params->get( 'upload_jqueryinclude', '0' );
$upload_debug = $params->get( 'upload_debug', '0' );
$moduleclass_sfx = $params->get('moduleclass_sfx')?$params->get('moduleclass_sfx'):'' ;
$upload_debug = $params->get( 'upload_debug', '0' );
// Get user id and check if user is in list
$settingids = $params->get( 'settingids', '' );

// Get current logged in user
$user =& JFactory::getUser();
$usr_id = $user->get('id');
$usr_name = $user->get('username');
$users_name = $user->get('name')." (".$usr_name.")";

//echo $usr_id;


$upload_username = $params->get( 'upload_username', '' );
$upload_password = $params->get( 'upload_password', '' );
$_SESSION["upload_username$mid"] = $upload_username;
$_SESSION["upload_password$mid"] = $upload_password;
$session->set( 'upload_username$mid', $upload_username );
$session->set( 'upload_password$mid', $upload_password );

// ++User defined upload
$upload_usernameddir = $params->get( 'upload_usernameddir', '0' );
$upload_usernameddirdefault = $params->get( 'upload_usernameddirdefault', '0' );
$upload_createdir = $params->get( 'upload_createdir', '0' );
$upload_userlocation = $params->get( 'upload_userlocation', '' );
$settingidsund = $params->get( 'settingidsund', '' );
$settingidsudd = $params->get( 'settingidsuddpath', '' );

//$settingidsuddpath = $params->get( 'settingidsuddpath', '' );

$upload_userpath = array($upload_location);

if (($upload_usernameddir == 1) && ($usr_name !== "")) {
	if ($upload_debug == 1) echo "<br/>Use UND!";
	if ( substr( $upload_userlocation , strlen($upload_userlocation) - 1) !== DS ) {
		$upload_userlocation .= DS;
	}

	if(is_array($settingidsund)) {
		foreach($settingidsund as $value){
			
			if($value==="[ALL]") {
				if ($upload_debug == 1) echo "<br/>UND array found as [ALL].";
				$upload_userpath[] = $upload_userlocation.$usr_name.DS;
				break;
			}
			
			if($value===$usr_id) {
				if ($upload_debug == 1) echo "<br/>UND array found as ".$upload_userlocation.$usr_name.DS.".";
				$upload_userpath[] = $upload_userlocation.$usr_name.DS;
				break;
			}

		}
	} else {
		if($settingidsund==="[ALL]") {
			// If all users are to have UDD
			if ($upload_debug == 1) echo "<br/>UND var found as [ALL].";
			$upload_userpath[] = $upload_userlocation.$usr_name.DS;
		} else {
			if($settingidsund!=="") {
				// If only current user uses UDD
				if($settingidsund===$usr_id) {
					if ($upload_debug == 1) echo "<br/>UND var found as ".$upload_userlocation.$usr_name.DS.".";
					$upload_userpath[] = $upload_userlocation.$usr_name.DS;
				}
			}
		}
	}
}


//echo "upload_usernameddirdefault=".$upload_usernameddirdefault." count(upload_userpath)".count($upload_userpath); 
// If Deafult+UND,check if remove Default
	if (($upload_usernameddirdefault == 1) && (count($upload_userpath) == 2)) {
		//We should have Defalut and one UND path, only leave the UND path
		if ($upload_debug == 1) echo "<br/>UND only, default removed.";
		$upload_userpath = array($upload_userpath[1]);
	}

// ++ TEST: USER DEFINED
if(!(is_array($settingidsudd)) && ($settingidsudd !== "")) {
	//Make it an array
	$settingidsudd = array("0", $settingidsudd);
	if ($upload_debug == 1) echo "<br/>UDD exists.";
}
// It's an array if it's present as value=0 (zero) is default info text. Always skip zero!
	if(is_array($settingidsudd)) {
		foreach($settingidsudd as $value){
			
			if($value==="0") {
				//nothing
			} else {
				
				//$name_chk = substr($value, 0, strpos($value, ">"));
				$name_chk = explode(">", $value);

				if($name_chk[0]===$usr_name) {
					if ( substr( $name_chk[1] , strlen($name_chk[1]) - 1) !== DS ) {
						$name_chk[1] .= DS;
					}
					$upload_userpath[] = $name_chk[1];
					if ($upload_debug == 1) echo "<br/>Added ".$name_chk[1]." to UDD.";
				}
			}
		}
	}

// --


if (isset($_FILES["uploadedfile$mid"]["name"])) {
	if (count($upload_userpath) == 1) {
		$upload_location = $upload_userpath[0];
		if ($upload_debug == 1) echo "<br/>Default upload location selected.";
	} else {
		$idx = 0;
		if (isset($_POST["selPathId$mid"])) {
			$idx = $_POST["selPathId$mid"];
		}
		$upload_location = $upload_userpath[$idx];
		if ($upload_debug == 1) echo "<br/>Upload location index [".$idx."] selected as '".$upload_location."'.";
		//Print_R($upload_userpath);
	}
}
// --User defined upload

$upload_users = "false";
		
if(is_array($settingids)) {

	foreach($settingids as $value){
		
		if($value==="[ALL]") {
			$upload_users = "true";
			if ($upload_debug == 1) echo "<br/>Allowed array [ALL] found.";
			break;
		}
		
		if($value===$usr_id) {
			$upload_users = "true";
			if ($upload_debug == 1) echo "<br/>Allowed array [".$usr_id."] found.";
			break;
		}
		
		/*echo "settingids=".$value."<br />";*/
	}
} else {
	if($settingids==="[ALL]") {
		$upload_users = "true";
		if ($upload_debug == 1) echo "<br/>Allowed var [ALL] found.";
	} else {
		if($settingids!=="") {
			if($settingids===$usr_id) {
				if ($upload_debug == 1) echo "<br/>Allowed var [".$usr_id."] found.";
				$upload_users = "true";
			}
			/*echo "settingids=".$settingids."<br />";*/
		} else {
			//Allow all users
			$upload_users = "true";
			if ($upload_debug == 1) echo "<br/>Allowed default to ALL.";
		}
	}
}
// include the helper file
require_once(dirname(__FILE__).DS.'helper.php');
if ($upload_debug == 1) echo "<br/>helper.php loaded.";

$filename = "";
if (isset($_FILES["uploadedfile$mid"]["name"])) {
	if(is_array($_FILES["uploadedfile$mid"]["name"])) {
		foreach($_FILES["uploadedfile$mid"]["name"] as $value){
			if(strlen($value) > 0) {
				//Check that we have a filename
				$filename = $value;
				if ($upload_debug == 1) echo "<br/>Uploaded file name exists.";
			}
		}
	}
}

//print_r($_SERVER);

if (strlen($filename) > 0) {
	// get the items to display from the helper
	
	$results = "";
	$_SESSION["uploaderr$mid"] = 0;
	
	if ($upload_createdir == 1) { 
		if (!file_exists($upload_location)) {
			//Create directory if missing
			if (mkdir($upload_location, 0777, true)) {
				//echo "Created dir: " . $upload_location;
				$results = JText::_('NEW_DIR')."<br/>";
				if ($upload_debug == 1) echo "<br/>Created new directory [".$upload_location."].";
				// Add empty HTML page to newly created directory
				if (!file_exists($upload_location . "index.html")) {
					$fhIndex = fopen($upload_location . "index.html", "w");
					if (!$fhIndex) {
						$stringData = "<html><body bgcolor=\"#FFFFFF\"></body></html>\n";
						fwrite($fhIndex, $stringData);
						fclose($fhIndex);
						if ($upload_debug == 1) echo "<br/>Added index.html in new directory.";
					}
				}

				
			} else {
				$_SESSION["uploaderr$mid"] = 1;
				$results = JText::_('NEW_DIR_FAILED');
				if ($upload_debug == 1) echo "<br/>Failed to create dir: ".$upload_location.".";
				//echo "Failed to create dir: " . $upload_location;
			}
			
		}
	}
	
	$tmp_upload_capthca = $upload_capthca;

	if ((isset($_POST["txtsfucaptcha$mid"])) && ($tmp_upload_capthca == 1) && (isset($_SESSION["capString$mid"]))) {
		$sessioncapString = $_SESSION["capString$mid"];
		$posttxtsfucaptcha = $_POST["txtsfucaptcha$mid"];

		if ($upload_debug == 1) {
			echo "<br/>Stored CAPTCHA:".$sessioncapString;
			echo "<br/>Code provided:".$posttxtsfucaptcha;
		}
		
		if ($upload_capthcacase == 1) {
			$sessioncapString = strtoupper($sessioncapString);
			$posttxtsfucaptcha = strtoupper($posttxtsfucaptcha);
			if ($upload_debug == 1) echo "<br/>Case insensitive CAPTCHA.";
		}
	
		if ($sessioncapString === $posttxtsfucaptcha) $tmp_upload_capthca = 0;
	}

	
	if ($tmp_upload_capthca == 0) {
		if ($_SESSION["uploaderr$mid"] == 0) {
			if ($upload_debug == 1) echo "<br/>Calling ModSimpleFileUploaderHelperv13::getUploadForm!";
			$results .= ModSimpleFileUploaderHelperv13::getUploadForm($params, $upload_location, $sfu_basepath, $mid, $upload_users, $users_name);
			//$sfu_basepath, $sfu_version, $upload_location, $upload_maxsize, $upload_filetypes, $upload_fileexist, $upload_users, $upload_email, $upload_emailmsg, $upload_emailhtml, $upload_unzip, $upload_showerrmsg, $upload_showdircontent, $upload_advancedpopup, $upload_popshowpath, $upload_popshowbytes, $moduleclass_sfx
		}
	} else {
		if ($upload_debug == 1) echo "<br/>Failed on CAPTCHA [".$_SESSION["capString$mid"]."=".$_POST["txtsfucaptcha$mid"]."].";
		$_SESSION["uploaderr$mid"] = 1;
		$results = JText::_('FAULTY_CAPTCHA');
	}
	
}


// include the template for display
require(JModuleHelper::getLayoutPath('mod_simplefileuploadv'.$sfu_version));


?>
