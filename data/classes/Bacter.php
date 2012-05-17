<?php
class Bacter extends Model {
    //private $db = NULL;

    // Common methods

    public function __construct() {}

    // Read all bacteria
    public function readBacteria() {
        $sth = $this->db->query("SELECT bacteria_id, bact_external_id, bact_name, vc_id, vector FROM bacteria ORDER BY bact_external_id DESC");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $objs = $sth->fetchAll();
        return $objs;
    }

    // Read one bacteria
    // Parameter example - Name: Type: bact_external_id, EDT2235
    public function readBacterium($type, $name) {
        $sth = $this->db->query("SELECT bact_external_id, bact_name, vc_id, vector FROM bacteria WHERE $type='$name' LIMIT 1");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row;
    }

}

?>