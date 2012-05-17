<?php
/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */
// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );
 
/**
 * Visual package emulator
 *
 */
class VPackageHelper
{
	// Static variables using for decide error code
	var $ERROR = -1;
	var $CLASS_NOT_FOUND = -2;
	var $FAILURE = -3;
	var $SUCCESS = 0;
	
	var $debug = false;


	function debug()
	{
		return false;
	}


	/**
	 * PHP package import implement. Now we have support following syntax:
	 * - namespace.packagename.ClassName
	 *
	 * @param $class  string
	 * @param $path  string overwritten path to load class instead of default path
	 * @param $stripExt boolean strip extension if available, default is null. If true will force strip extension, false will skip check extension and null will be auto detect.
	 */
	function import($class, $path = null, $stripExt = null)
	{
		$classPath = realpath(dirname(__FILE__) . DS . ".." . DS . "..");
		$classPath = empty($path) ? $classPath : $path;
		$className = $class;
		
		if ($stripExt === null && !empty($path)) {
			$stripExt = true;
		}
		
		// Auto remove file extension if exists
		if ($stripExt && preg_match("/\.\w+$/", $className)) {
			$className = preg_replace("/\.\w+$/", "", $className);
		}
		
		if (strpos($className, '.') !== false && empty($path)) {
			$pieces = explode('.', $className);
			$className = array_pop($pieces);
			$classPath = $classPath . DS . implode(DS, $pieces);
		}
		
		$fullClassPath = $classPath . DS . $className . '.php';
		if (file_exists($fullClassPath)) {
			require_once ($fullClassPath);
			return 0;
		} else {
			if (VPackageHelper::debug()) {
				var_dump("class not found in: $fullClassPath");
			}
			return -2;
		}
	}


	/**
	 *  Import all .php file found on the $path
	 *
	 * @param $path  string
	 * @param $ext  string file extension to import
	 */
	function importAll($path, $ext = "php")
	{
		$dh = opendir($path);
		$pattern = "/\.$ext$/";
		if (VPackageHelper::debug()) {
			echo "<h3>Import all file with ext=$ext in $path</h3>";
		}
		// Import files
		while (($file = readdir($dh)) !== false) {
			if (VPackageHelper::debug()) {
				echo "$file\n";
			}
			if (preg_match($pattern, $file)) {
				VPackageHelper::import($file, $path);
			}
		}
	}


	/**
	 *  Import all .php file found on $path recursively
	 *
	 * @param $path  string
	 */
	function importRecursive($path)
	{
		$cwd = dir($path);
		
		// Import all file in current directory
		VPackageHelper::importAll($path);
		
		// recursive directory
		while (($entry = $cwd->read()) !== false) {
			if ($entry == "." || $entry == ".." || preg_match("/^\./", $entry)) {
				if (VPackageHelper::debug()) {
					echo "skip: $entry<br>";
				}
				continue;
			}
			$fullPath = $path . DS . $entry;
			if (VPackageHelper::debug()) {
				echo "entry: $entry<br>";
				echo "full path: $fullPath<br>";
			}
			if (JFolder::exists($fullPath)) {
				VPackageHelper::importAll($fullPath);
				VPackageHelper::importRecursive($fullPath);
			}
		}
		$cwd->close();
	}
}
