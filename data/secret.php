<?php  
//////////////////////////////////////////////////////////////////////////////// 
// 
// SECRET PAGE 
// 
//   Invokes require_authentication() to ensure that the user is authenticated 
//     
////////////////////////////////////////////////////////////////////////////////  
require("common.php"); 
require_authentication(); 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"      
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
<html>     
<head>
<title>Secret Page</title>     
</head>
<body>         
<h1>This is a Secret Page</h1>
<p>You must have successfully authenticated since you are seeing this page.</p>
<p>
<a href="<?php echo $_SERVER[PHP_SELF]; ?>">View again?</a>
</p>
<p>
<a href="login.php">Logout?</a>
</p>
</body>
</html>