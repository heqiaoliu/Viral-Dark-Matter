<?php
/*
class Bacteria extends DB_Object {

/// DEPRECATED: TO BE DELETED
/// SEE Bacter.php

    
    public $bacteria_id;
    public $bact_external_id;
    public $bact_name;
    public $vc_id;
    public $vector;
    // Inherited 


    // Common methods

    public function __construct() {
        return 'Class Bacteria loaded successfully <br />';
    }

    // Read all bacteria
    public function readBacteria() {
        $db = $this->connectDB("localhost", "nturner", "LOB4steR", "viral_dark_matter");
        $sth = $db->query("SELECT bacteria_id, bact_external_id, bact_name, vc_id, vector FROM bacteria ORDER BY bact_external_id DESC");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        //$objs = $sth->fetchAll(PDO::FETCH_CLASS, "Bacteria");
        //return $objs;
    }

    // Read one bacteria
    // Parameter example - Name: Type: bact_external_id, EDT2235
    public function readBacterium($type, $name) {
        $db = $this->connectDB("localhost", "nturner", "LOB4steR", "viral_dark_matter");
        $sth = $db->query("SELECT bact_external_id, bact_name, vc_id, vector FROM bacteria WHERE $type='$name' LIMIT 1");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row;
    }

}*/

?>