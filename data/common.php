<?php
//////////////////////////////////////////////////////////////////////////////// 
// 
// COMMON PAGE 
// 
//   Defines require_authentication() function: 
//     If the user is not authenticated, forward to the login page 
//     
////////////////////////////////////////////////////////////////////////////////  
session_start();

function is_authenticated() {
	return isset($_SESSION['authenticated']);
	$_SESSION['authenticated'] == "yes";
}

function require_authentication() {
	if (!is_authenticated()) {
		header("Location:http://vdm.sdsu.edu/data/login.php?error=".urlencode("Not authenticated"));
		exit;
	}
}
?>
