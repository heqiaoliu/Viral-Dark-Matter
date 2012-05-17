<?php
/*
*
* 	exp_id	bacteria_id	plate_id	replicate_num	file_id
*/

class Exp {

    private $db = NULL;

    // Common methods
    
    public function __construct() {}

    public function setDatabaseConnection($databaseConnection) {
        $this->db = $databaseConnection;
    }

    /* CREATE */
    // Create a File
    public function createExp($bacteria_id, $plate_id, $replicate_num, $file_id) {
        $sth = $this->db->prepare("INSERT INTO exp (bacteria_id, plate_id, replicate_num, file_id) VALUES ( '$bacteria_id', '$plate_id', '$replicate_num', '$file_id' );");
        $sth->execute();
    }

    /* READ */
    // Read a File 1, No Duplicates!
    public function readExp($type, $name) {
        $sth = $this->db->query("SELECT exp_id, bacteria_id, plate_id, replicate_num, file_id FROM exp WHERE $type='$name' LIMIT 1;");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $row = $sth->fetch();
        return $row;
    }

    // Read a File, Duplicates allowed.
    public function readExps_getRowsAffected($type, $name) {
        $sth = $this->db->query("SELECT exp_id, bacteria_id, plate_id, replicate_num, file_id FROM exp WHERE $type='$name';");
        $rows_affected = $sth->rowCount();
        return $rows_affected;
    }

    // Read Files
    public function readExp() {
        $sth = $this->db->query("SELECT exp_id, bacteria_id, plate_id, replicate_num, file_id FROM exp;");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $obj = $sth->fetchAll();
        return $obj;
    }

    // Read Files with references 
    public function readExp_getRef() {
        $sth = $this->db->query("
        	SELECT e.exp_id, b.bacteria_id, p.plate_id, replicate_num, f.file_id 
        	FROM exp e 
        	INNER JOIN bacteria b on b.bacteria_id=f.bacteria_id 
        	INNER JOIN plate p on p.plate_id = e.plate_id
        	INNER JOIN file f on f.file_id=e.file_id;");
        $sth->setFetchMode(PDO::FETCH_BOTH);
        $objs = $sth->fetchAll();
        return $objs;
    }

    /* UPDATE */
    // Update a File
    public function updateExp($file_name, $name, $exp_date, $upload_date, $bacteria_id, $replicate_num, $notes, $type, $old) {
        $sth = $this->db->prepare("UPDATE file SET file_name='$file_name', name='$name', exp_date='$exp_date', upload_date='$upload_date', bacteria_id='$bacteria_id', $replicate_num='$replicate_num', notes='$notes' WHERE medium_File_name='$old_medium_File_name';");
        $sth->execute();
    }

    // Update a file when you only have the bact_external_id instead of the bact_id (safer this way). Finds the row to update according to file_id rather than file_name
    public function updateExpRef($file_name, $name, $exp_date, $upload_date, $bacteria_id, $replicate_num, $notes, $type, $old) {
        $sth = $this->db->prepare("UPDATE file f SET f.file_name='$file_name', f.name='$name', f.exp_date='$exp_date', f.upload_date='$upload_date', f.bacteria_id='b.bacteria_id', f.replicate_num='$replicate_num', f.notes='$notes' FROM file f INNER JOIN bacteria b ON b.bacteria_id=f.bacteria_id WHERE f.file_id=$file_id;");
        $sth->execute();
    }

    /* DELETE */
    // Delete a File
    public function deleteExp($file_name) {
        $sth = $this->db->prepare("DELETE FROM file WHERE file_name='$file_name';");
        $sth->execute();
        return $sth->rowCount();
    }




}


?>