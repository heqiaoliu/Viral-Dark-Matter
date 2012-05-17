<?php
require("common.php"); 
require_authentication(); 
?>

<!DOCTYPE html>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="reset.css" />
	<link rel="stylesheet" type="text/css" href="stylesheet.css" />
	<title>viral dark matter</title>
	<!--[if IE]>
	<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->
	<script type="text/javascript">
            function validateForm() {
                var registerForm = document.getElementById("registerForm");
                var pw1 = registerForm.password1.value;
                var pw2 = registerForm.password2.value;
                var invalid = " "; // Invalid character is a space
				var minLength = 6; // Minimum length
				// Passwords do not match
                if (pw1 != pw2) {
                    alert("You did not enter the same new password twice. Please re-enter your password.");
                    return false;
                }
                // check for minimum length
				if (pw1.length < minLength) {
					alert('Your password must be at least ' + minLength + ' characters long. Please re-enter your password.');
					return false;
				}
                // check for spaces
				if (pw1.indexOf(invalid) > -1) {
					alert("Sorry, your password may not contain spaces.");
					return false;
				}
                //var submitForm = document.getElementById("submitForm");
                //submitForm.username.value = loginForm.username.value;
                //submitForm.response.value = 
                //    hex_md5(loginForm.challenge.value+loginForm.password.value);
                //submitForm.submit();
            }
        </script> 
</head>


<body id="register">
<?php require "header.html"; ?>
<?php require "nav.html"; ?>
	<section id="mainarea">
		<article id="description" >
		<h1>Register a new User</h1>
		<p>Please provide the user's information below: </p>
		</article><!-- /#description -->
		<form id="registerForm" action="http://viraldarkmatter.sdsu.edu/cgi-bin/reg.cgi" method="POST" >
			<table>
				<tr>
					<td><p class="inputTitle" >First Name: <em>*</em></p></td>
					<td><input name="firstName" placeholder="First Name" required /></td>
				</tr>
				<tr>
					<td><p class="inputTitle" >Last Name: <em>*</em></p></td>
					<td><input name="lastName" placeholder="Last Name" required /></td>
				</tr>
				<tr>
					<td><p class="inputTitle" >User Name: <em>*</em></p></td>
					<td><input name="userName" placeholder="User Name" required /></td>
				</tr>
				<tr>
					<td><p class="inputTitle" >Password: <em>*</em></p></td>
					<td><input type="password" name="password1" placeholder="Password" required /></td>
				</tr>
				<tr>
					<td><p class="inputTitle" >Confirm Password: <em>*</em></p></td>
					<td><input type="password" name="password2" placeholder="Password" required /></td>
				</tr>
				<tr>
					<td><input type="submit" onclick="validateForm()" method="post"/></td>
				</tr>
			</table>
		</form>
	</section><!-- /#mainarea -->
	<footer>
		<ul>
			<li><a href="index.php" id="Ffirst">external link</a></li>
		</ul>
	</footer>
</body>
</html>
