<?php

$dbhostname = 'localhost';
$dbusername = 'nturner';
$dbpassword = 'LOB4steR';
$dbdatabase = 'vdm_joomla';

// From Form
$username_to_check = 'nturner';
$password_to_check = 'changeme';

$mysqli = new mysqli($dbhostname,$dbusername,$dbpassword,$dbdatabase);
if ($result = $mysqli->query('SELECT username,password FROM vdm_users WHERE username="'.$username_to_check.'" LIMIT 1;')) {
  if ($result->num_rows == 0) {
    echo 'Username does not exist.';
  }else{
    while ($row = $result->fetch_object()) {
      $joomla_user = $row->username;
      $pass_array = explode(':',$row->password);
      $joomla_pass = $pass_array[0];
      $joomla_salt = $pass_array[1];
    }

    if ($joomla_pass == md5($password_to_check.$joomla_salt)) {
      echo 'Username and password combination validated';
    }else{
      echo 'Invalid password for username';
    }
  }
} else {
  echo 'LOGIN VALIDATION: MySQL Error - '.$mysqli->error;
}
?>
