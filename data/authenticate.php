<?php  
session_start();

///////////////////////////////////////////////////////////////////////////// 
// 
// AUTHENTICATE PAGE 
// 
//   Server-side: 
//     1. Get the challenge from the user session 
//     2. Get the password for the supplied user (local lookup) 
//     3. Compute expected_response = MD5(challenge+password) 
//     4. If expected_response == supplied response: 
//        4.1. Mark session as authenticated and forward to secret.php 
//        4.2. Otherwise, authentication failed. Go back to login.php 
////////////////////////////////////////////////////////////////////////////////// 
function getPasswordForUser($username) {

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
if (!mysql_select_db( "vdm_joomla", $db ))
  error( "Cannot select database 'vdm_joomla'." );

$result = mysql_query("SELECT password FROM vdm_users WHERE username ='" . $username . "'");
$userDB = mysql_fetch_array($result);
return $userDB['password'];
}  

function validate($challenge, $response, $password) {
	return md5($challenge . $password) == $response;
	}

function authenticate() {
if (isset($_REQUEST['password']) && isset($_REQUEST['username'])) {
	$password_joomla = getPasswordForUser($_REQUEST['username']);
	if (!isset($password_joomla)) {
		header("Location:http://vdm.sdsu.edu/data/login.php?error=".urlencode("failed to retrieve with joomla getPasswordForUser"));
	}
	list($md5pass, $saltpass) = split(":", $password_joomla);
	trim ($md5pass);
	if (strcmp((md5($_REQUEST['password'].$saltpass)), $md5pass) == 0) {
	//all ok, go on with session
		$_SESSION['authenticated'] = "yes";
		$_SESSION['username'] = $_REQUEST['username']; 
	//	unset($_SESSION['challenge']);
	} else {
		header("Location:http://vdm.sdsu.edu/data/login.php?error=".urlencode("Failed authentication"));
		exit();
	}
} else {
	header("Location:http://vdm.sdsu.edu/data/login.php?error=".urlencode("Session expired"));
	exit();
}
}
authenticate();
header("Location:http://vdm.sdsu.edu/data/index.php");
exit();
?>

