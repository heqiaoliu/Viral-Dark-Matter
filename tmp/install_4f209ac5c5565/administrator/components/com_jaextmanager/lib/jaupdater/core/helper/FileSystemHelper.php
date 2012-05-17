<?php
/**
 * ------------------------------------------------------------------------
 * JA Extensions Manager
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
 * Helper for FileSystem functions
 *
 */
class FileSystemHelper
{


	/**
	 * @desc clean path (remove duplicate directory separator)
	 *
	 * @param string $path
	 * @param char $ds - directory separator charactor
	 * @return string
	 */
	function clean($path, $ds = DS)
	{
		$path = trim($path);
		
		if (empty($path)) {
			$path = JPATH_ROOT;
		} else {
			// Remove double slashes and backslahses and convert all slashes and backslashes to DS
			$path = preg_replace('#[/\\\\]+#', $ds, $path);
		}
		
		return $path;
	}


	/**
	 * Create a folder and all necessary parent folders.
	 *
	 * @param string $path
	 * @param string $mod
	 * @return unknown
	 */
	function createDirRecursive($path, $mod = 0700)
	{
		$path = $path . DS;
		$path = FileSystemHelper::clean($path, DS);
		JFolder::create($path, $mod);
		return $path;
	}


	/**
	 * Create a temporary directory
	 *
	 * @param $dir  string based dir to create temporary directory
	 * @param $prefix  string prefix for temporary directory name
	 * @param $mod  int unix permission formated number
	 *
	 * @return  string path to directory
	 */
	function tmpDir($dir = null, $prefix = null, $mod = 0700)
	{
		$dir = empty($dir) ? ja_sys_get_temp_dir() : $dir;
		$tmpName = jaTempnam($dir, $prefix);
		
		if (JFile::exists($tmpName)) {
			JFile::delete($tmpName);
		}
		if (!JFolder::exists($tmpName)) {
			JFolder::create($tmpName, $mod);
		}
		return FileSystemHelper::clean($tmpName . DS);
	}


	/**
	 *
	 *  Support remove a file or directory recursively
	 *
	 * @param $path  string path to file or directory to be remove
	 * @param $recursive  boolean remove directory recursively or not
	 *
	 * @return  boolean true if success, otherwise return false
	 */
	function rm($path, $recursive = false)
	{
		$retVal = true;
		$path = FileSystemHelper::clean($path);
		if (JFolder::exists($path)) {
			$dh = opendir($path);
			while (($entry = readdir($dh)) !== false) {
				if ($entry == "." || $entry == "..") {
					continue;
				}
				$entry = FileSystemHelper::clean($path . DS . $entry);
				if (JFolder::exists($entry) && $recursive === true) {
					if (FileSystemHelper::rm($entry, $recursive) === false) {
						$retVal = false;
					}
				} else if (JFile::exists($entry)) {
					if (JFile::delete($entry) === false) {
						$retVal = false;
					}
				}
			}
			closedir($dh);
			if (@rmdir($path) === false) {
				$retVal = false;
			}
		} else if (JFile::exists($path)) {
			if (JFile::delete($path) === false) {
				$retVal = false;
			}
		}
		
		return $retVal;
	}


	/**
	 *  Advanced copy file and directory with support recursively mode
	 *
	 * @param $src  string source file or directory
	 * @param $dest  string destination file or directory
	 * @param $recursive  boolean recursive mode
	 * @param $mod  int unix permission formated number
	 *
	 * @return  boolean true if success, otherwise return false
	 */
	function cp($src, $dst, $recursive = false, $mod = 0700, $exclude = array('.svn', 'CVS'))
	{
		$retVal = true;
		if (JFolder::exists($src)) {
			$retVal = JFolder::copy($src, $dst, '', true);
		} elseif (JFile::exists($src)) {
			/*if(JFolder::exists($dst)) {
			 $dst = FileSystemHelper::clean($dst . DS) . basename($src);
			 }*/
			$retVal = JFile::copy($src, $dst);
		}
		return $retVal;
	}


	/**
	 *  Advanced move file and directories with support recursively mode
	 *
	 * @param $src  string source file or directory
	 * @param $dest  string destination file or directory
	 * @param $recursive  boolean recursive mode
	 * @param $mod  int unix permission formated number
	 *
	 * @return  boolean true if success, otherwise return false
	 */
	function mv($src, $dest, $recursive = false, $mod = 0700)
	{
		if (FileSystemHelper::cp($src, $dest, $recursive, $mod) === false) {
			return false;
		}
		if (JFolder::exists($src) && preg_match("/\/$/", $src) > 0) {
			$rv = true;
			$dh = opendir($src);
			while (($entry = readdir($dh)) !== false) {
				if (FileSystemHelper::rm($src . $entry, true) === false) {
					$rv = false;
				}
			}
			return $rv;
		} else {
			return FileSystemHelper::rm($src, $dest, $recursive);
		}
	}


	/**
	 * getting list of files in given folder with specific filter
	 *
	 * @param string $path
	 * @param string $filter - regular expression patter (PCRE style)
	 * @param mixed $recurse - True to recursively search into sub-folders, or an integer to specify the maximum depth.
	 * @param boolean $fullpath - True to return the full path to the file. 
	 * @param boolean $exclude - Array with names of files and folder which should not be shown in the result.
	 * @return array	Files in the given folder.
	 */
	function files($path, $filter = '.', $recurse = false, $fullpath = false, $exclude = array('.svn', 'CVS'))
	{
		// Initialize variables
		$arr = array();
		
		// Check to make sure the path valid and clean
		$path = FileSystemHelper::clean($path);
		
		// Is the path a folder?
		if (!JFolder::exists($path)) {
			return false;
		}
		
		// read the source directory
		$handle = opendir($path);
		while (($file = readdir($handle)) !== false) {
			if (($file != '.') && ($file != '..') && (!in_array($file, $exclude))) {
				$dir = $path . DS . $file;
				$isDir = JFolder::exists($dir);
				if ($isDir) {
					if ($recurse) {
						if (is_integer($recurse)) {
							$arr2 = FileSystemHelper::files($dir, $filter, $recurse - 1, $fullpath);
						} else {
							$arr2 = FileSystemHelper::files($dir, $filter, $recurse, $fullpath);
						}
						
						$arr = array_merge($arr, $arr2);
					}
				} else {
					if (preg_match("/$filter/", $file)) {
						if ($fullpath) {
							$arr[] = $path . DS . $file;
						} else {
							$arr[] = $file;
						}
					}
				}
			}
		}
		closedir($handle);
		
		asort($arr);
		return $arr;
	}


	/**
	 * Gets the extension of a file name
	 */
	function getExt($file)
	{
		$dot = strrpos($file, '.') + 1;
		return substr($file, $dot);
	}


	/**
	 * Strips the last extension of a file name
	 *
	 * @param unknown_type $file
	 * @return unknown
	 */
	function stripExt($file)
	{
		return preg_replace('#\.[^.]*$#', '', $file);
	}
}
