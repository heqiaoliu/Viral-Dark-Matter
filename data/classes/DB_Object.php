<?php
/*

/// DEPRECATED: TO BE DELETED
/// SEE DBObject.php

abstract class DB_Object {

    // Common methods

    public function __construct() {
        return 'Class DB_Object loaded successfully <br />';
    }

    protected function error($error) {
    	return "<h1>$error</h1>";
    }

    public function connectDB($Server, $User, $Password, $Database) {


        try {
            # MySQL with PDO_MYSQL
            $db = new PDO("mysql:host=$Server;dbname=$Database", $User, $Password);
            $db->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
        }
        catch(PDOException $e) {
            echo $e->getMessage();
        }

		return $db;
    }
}

*/
?>