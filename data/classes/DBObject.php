<?php
class DBObject {
    protected $_db; //Data base connection

    public function __construct($Server, $User, $Password, $Database) {
        try {
            # MySQL with PDO_MYSQL
            $this->_db = new PDO("mysql:host=$Server;dbname=$Database", $User, $Password, array(
                PDO::ATTR_PERSISTENT => true
            ));
            $this->_db->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
        }
        catch(PDOException $e) {
            echo $e->getMessage();
        }
    }

    public function getDB() {
        return $this->_db;
    }

    protected function error($error) {
    	return "<h1>$error</h1>";
    }
}

?>