<?php
class Plate {
    private $db = NULL;

    // Common methods

    public function __construct() {}

    public function setDatabaseConnection($databaseConnection) {
        $this->db = $databaseConnection;
    }

    // Create a plate
    public function createPlate($plate_name, $base_name) {
        $sth = $this->db->prepare("INSERT INTO plate (plate_name, base_name) VALUES ( '$plate_name', '$base_name' )");
        $sth->execute();
    }


    // Read a plate
    public function readPlate($plate_name) {
        $sth = $this->db->query("SELECT plate_name, base_name FROM plate WHERE plate_name='$plate_name'");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row;
    }

    // Read all plates
    public function readPlates() {
        $sth = $this->db->query("SELECT plate_name, base_name FROM plate ORDER BY plate_name DESC");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $objs = $sth->fetchAll();
        return $objs;
    }

    // Update a plate
    public function updatePlate($new_plate_name, $old_plate_name, $new_base_name) {
        $sth = $this->db->prepare("UPDATE plate SET plate_name='$new_plate_name', base_name='$new_base_name' WHERE plate_name='$old_plate_name' ");
        $sth->execute();
    }

    // Delete a plate
    public function deletePlate($plate_name) {
        $this->db->exec("DELETE FROM plate WHERE plate_name='$plate_name' ");
    }


}


?>