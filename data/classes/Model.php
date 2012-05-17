<?php
class Model {
    protected $db = NULL;

    // Common methods

    public function __construct() {}

    public function setDatabaseConnection($databaseConnection) {
        $this->db = $databaseConnection;
    }

}

?>