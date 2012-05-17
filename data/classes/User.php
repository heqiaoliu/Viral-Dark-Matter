<?php
class User extends Model {
    // Inherited 


    // Common methods

    public function __construct() {
        return 'Class User loaded successfully <br />';
    }

    public function getName($name) {
        $sth = $this->db->query("SELECT name FROM vdm_users WHERE vdm_users.username = '$name'");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row;
    }

    /*
    // Get the name of a User
    public function getName($name) {
    	$db = $this->connectDB("localhost", "nturner", "LOB4steR", "vdm_joomla");
    	$sth = $db->query("SELECT name FROM vdm_users WHERE vdm_users.username = '$name'");
        $sth->setFetchMode(PDO::FETCH_BOTH);
		$row = $sth->fetch();
		return $row['name'];
    }
    */

    // Get the name of the current User
    public function getCurrentName() {
        $sth = $this->db->query("SELECT name FROM vdm_users WHERE vdm_users.username = '$_SESSION[username]'");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row['name'];
    }
}


?>