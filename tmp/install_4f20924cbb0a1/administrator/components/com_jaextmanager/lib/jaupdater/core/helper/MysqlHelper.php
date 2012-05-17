<?php
define('JA_BACKUP_ALL', 0);//backup all tables if no specific tables provied


class jaMysqlHelper
{
	var $_host = "localhost";
	var $_user = "root";
	var $_pass = "";
	var $_db = "";
	var $_prefix = "";
	var $_tables = array();
	
	var $_backupPath = '';
	var $_mysqlPath = '';
	var $_mysqlDumpPath = '';
	
	/**
	 * Enter description here...
	 *
	 * @param unknown_type $host
	 * @param unknown_type $user
	 * @param unknown_type $pass
	 * @param unknown_type $db
	 * @param unknown_type $prefix
	 * @param unknown_type $mysql - path to mysql bin
	 * @param unknown_type $mysqlDump - path to mysqldump bin
	 */
	function jaMysqlHelper($host, $user, $pass, $db, $prefix, $mysql = 'mysql', $mysqlDump = 'mysqldump')
	{
		@set_time_limit(0); // No time limit
		$this->_host = $host;
		$this->_user = $user;
		$this->_pass = (!empty($pass)) ? "-p{$pass}" : "";//passworded or not
		$this->_db = $db;
		$this->_prefix = $prefix;
		$this->_mysqlPath = $mysql;
		$this->_mysqlDumpPath = $mysqlDump;
	}
	
	/**
	 * backup selected tables
	 *
	 * @param (string) $backupFile - absolute path to backup file
	 * @param (array) $tables - array
	 * @return unknown
	 */
	function dump($backupFile, $aTables=array()){
		$backupFile = FileSystemHelper::clean($backupFile);
		
		if(count($aTables) == 0 && !JA_BACKUP_ALL) {
			return false;
		}
		
		$backupDir = dirname($backupFile);
		if(!(@JFolder::exists($backupDir) && @is_writable($backupDir))) {
			return false;
		}
		
		$tables = count($aTables > 0) ? implode(' ', $aTables) : '';
		
		$command = sprintf("%s -u%s %s %s %s --opt > \"%s\"", 
						$this->_mysqlDumpPath,
						$this->_user,
						$this->_pass,
						$this->_db,
						$tables,
						$backupFile
						);
		return $this->_exec($command, $this->_pass);
	}
	
	/**
	 * restore
	 *
	 * @param (string) $backupFile
	 * @return unknown
	 */
	function restore($backupFile){
		$backupFile = FileSystemHelper::clean($backupFile);
		
		if(!JFile::exists($backupFile)) {
			return false;
		}
		//create temp file with replaced #__ by db prefix
		$tmpDir = FileSystemHelper::tmpDir(null, 'ja', 0777);
		$tmpFile = $tmpDir . basename($backupFile);
		$sql = file_get_contents($backupFile);
		$sql = preg_replace('/\`\#__([a-zA-Z_0-9]*)\`/', "`".$this->_prefix."$1`", $sql);
		
		JFile::write($tmpFile, $sql);
		//echo $tmpFile;
		
		$command = sprintf("%s -u%s %s %s < %s",
						$this->_mysqlPath,
						$this->_user,
						$this->_pass,
						$this->_db,
						$tmpFile);
		//echo $command;
		return $this->_exec($command, $this->_pass);
	}
	
	function _exec($command, $password) {
		//echo $command;
		$descriptorspec = array(
            0 => array("pipe", "r"),
            1 => array("pipe", "w"),
            2 => array("pipe", "w")
        );
		$process = proc_open($command, $descriptorspec, $pipes);
		
		if(is_resource($process)) {
            // push password to stdin
            fwrite($pipes[0], $password);
            fclose($pipes[0]);
            
            if ( substr(PHP_OS,0,3) != 'WIN') {
	            // Read StdOut
	            $StdOut = '';
	            while(!feof($pipes[1])) {
	                $StdOut .= fgets($pipes[1], 1024);
	            }
	            fclose($pipes[1]);
	            
	            // Read StdErr
	            $StdErr = '';
	            while(!feof($pipes[2]))    {
	                $StdErr .= fgets($pipes[2], 1024);
	            }
	            fclose($pipes[2]);
            }
            // Close the process
            $ReturnCode = proc_close($process);
            return true;

        } else {
            return false; 
        }
	}
}

?>