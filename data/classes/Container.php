<?php 
class Container {
	public static $_database;

	public static function makeBacter() {
		$Bacter = new Bacter();
		$Bacter->setDatabaseConnection(self::$_database);
		return $Bacter;
	}

	public static function makeSupplement() {
		$Supplement = new Supplement();
		$Supplement->setDatabaseConnection(self::$_database);
		return $Supplement;
	}

	public static function makeFile() {
		$File = new File();
		$File->setDatabaseConnection(self::$_database);
		return $File;
	}

	public static function makePlate() {
		$Plate = new Plate();
		$Plate->setDatabaseConnection(self::$_database);
		return $Plate;
	}

	public static function makeRosetta() {
		$Rosetta = new Rosetta();
		$Rosetta->setDatabaseConnection(self::$_database);
		return $Rosetta;
	}

	public static function makeUser() {
		$User = new User();
		$User->setDatabaseConnection(self::$_database);
		return $User;
	}
}

 ?>