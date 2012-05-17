<?php
class Rosetta {
    private $db = NULL;

    // Common methods

    public function __construct() {}

    public function setDatabaseConnection($databaseConnection) {
        $this->db = $databaseConnection;
    }

    // Read all Rosetta
    public function readRosetta() {
        $sth = $this->db->query("SELECT r.r_id, b.vc_id, r.source, r.name, r.gi, r.length, r.ordered, r.cloned, r.expressed, r.soluble, r.purified, r.crystallization_trials, r.crystals, r.diffraction, r.dataset, r.structure, r.comments FROM rosetta r INNER JOIN bacteria b ON b.bacteria_id=r.bact_id ORDER BY b.vc_id DESC");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $objs = $sth->fetchAll();
        return $objs;
    }
/*
    // Read one Rosetta
    // Parameter example - Name: Type: bact_external_id, EDT2235
    public function readRosetta($type, $name) {
        $sth = $this->_db->query("SELECT bact_external_id, bact_name, vc_id, vector FROM bacteria WHERE $type='$name' LIMIT 1");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row;
    }

    */

}

?>