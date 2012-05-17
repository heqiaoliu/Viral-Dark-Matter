<?php
class Supplement {

    private $db = NULL;

    // Common methods
    
    public function __construct() {}

    public function setDatabaseConnection($databaseConnection) {
        $this->db = $databaseConnection;
    }

    // Create a Supplement
    public function createSupplement($medium_supplement_name, $KEGGID, $SeedID) {
        $sth = $this->db->prepare("INSERT INTO medium_supplement (medium_supplement_name, KEGGID, SeedID) VALUES ( '$medium_supplement_name', '$KEGGID', '$SeedID' )");
        $sth->execute();
    }

    // Read a Supplement
    public function readSupplement($type, $name) {
        $sth = $db->query("SELECT medium_supplement_name, KEGGID, SeedID FROM medium_supplement WHERE $type='$name' LIMIT 1");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row;
    }

    // Read Supplements
    public function readSupplements() {
        $sth = $this->db->query("SELECT medium_supplement_id, medium_supplement_name, KEGGID, SeedID FROM medium_supplement");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $objs = $sth->fetchAll();
        return $objs;
    }

    // Update a Supplement
    public function updateSupplement($new_medium_supplement_name, $old_medium_supplement_name, $new_base_name, $new_KEGGID, $new_SeedID) {
        $sth = $this->db->prepare("UPDATE medium_supplement SET medium_supplement_name='$new_medium_supplement_name', KEGGID='$new_KEGGID' SeedID='$new_SeedID' WHERE medium_supplement_name='$old_medium_supplement_name' ");
        $sth->execute();
    }

    // Delete a Supplement
    public function deleteSupplement($medium_supplement_name) {
        $this->db->exec("DELETE FROM medium_supplement WHERE medium_supplement_name='$medium_supplement_name' ");
    }


}


?>