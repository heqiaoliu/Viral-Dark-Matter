<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager Client Library
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license - PHP files are GNU/GPL V2. CSS / JS are Copyrighted Commercial,
# bound by Proprietary License of JoomlArt. For details on licensing, 
# Please Read Terms of Use at http://www.joomlart.com/terms_of_use.html.
# Author: JoomlArt.com
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# Redistribution, Modification or Re-licensing of this file in part of full, 
# is bound by the License applied. 
# ------------------------------------------------------------------------
*/ 

// no direct access
defined( '_JA' ) or die( 'Restricted access' );

class CheckSums {

	// Common ignore pattern such as: .svn, .* ...
	var $ignorePattern = array("^\..*", "jaupdater\..*?\.xml");

	/**
   *  Use to check $entry matches any pattern in $patterns
   *
   * @param $entry
   * @param $patterns  array
   *
   * @return  boolean true if found matches pattern
   */
	function isIgnore($entry, $patterns) {
		if (is_array($patterns)) {
			foreach ($patterns as $key=>$pattern) {
				// Regex format
				if (!preg_match("/^\/[^\/]+\/\w+?$/" ,$pattern)) {
					$pattern = "/$pattern/";
				}
				if (preg_match($pattern, $entry) > 0) {
					return true;
				}
			}
		}
		return false;
	}

	/**
   * Return check sum string
   *
   * @param $file
   */
	function getCheckSum($file) {

	}

	/**
   * Return a set of the CRC depends on path is file or directory
   *
   * @param $path  string path of the directory to be dump crc
   * @param $ignore  array list of ignore pattern
   *
   * @return  array
   */
	function dumpCRC($path, $ignore = null) {
		if (!JFolder::exists($path) ||
		$this->isIgnore(basename($path), $ignore)) {
			return false;
		}

		$ignore = empty($ignore) ? $this->ignorePattern : $ignore;

		//$dirCheckSum = array("name"=>basename($path));
		$dirCheckSum = array();
		$fileCheckSum = array();
		$entries = $this->_scanDir($path, 0);

		foreach ($entries as $entry) {
			if ($entry != '.' && $entry != '..' && !$this->isIgnore($entry, $ignore)) {
				if (JFolder::exists($path.DS.$entry)) {
					$fileCheckSum[$entry] = $this->dumpCRC($path.DS.$entry, $ignore);
				} else {
					$fileCheckSum[$entry] = $this->getCheckSum($path.DS.$entry);
				}
			}
		}
		$dirCheckSum["files"] = $fileCheckSum;
		//return md5(implode('', $fileCheckSum));
		//return $dirCheckSum;
		return $fileCheckSum;
	}

	/**
   * Return a set of the CRC depends on path is file or directory
   *
   * @param $path  string path of the directory to be dump crc
   * @param $ignore  array list of ignore pattern
   *
   * @return  Object
   */
	function dumpCRCObject($path, $ignore = null) {
		$path = FileSystemHelper::clean($path);
		if ($this->isIgnore(basename($path), $ignore)) {
			return false;
		}

		if (JFile::exists($path)) {
			return $this->getCheckSum($path);
		}

		if (!JFolder::exists($path)) {
			return false;
		}

		$ignore = empty($ignore) ? $this->ignorePattern : $ignore;

		$dirCheckSum = new stdClass();
		$fileCheckSum = new stdClass();
		$d = dir($path);

		$entries = $this->_scanDir($path, 0);
		foreach ($entries as $entry) {
			if (!$this->isIgnore($entry, $ignore)) {
				if (JFolder::exists($path.DS.$entry)) {
					$fileCheckSum->$entry = $this->dumpCRCObject($path.DS.$entry, $ignore);
				} else {
					$fileCheckSum->$entry = $this->getCheckSum($path.DS.$entry);
				}
			}
		}
		$dirCheckSum->files = $fileCheckSum;
		return $fileCheckSum;
	}

	/**
	 * thanhnv
	 *
	 * @param (string) $path
	 * @param (boolean) $rsort - Sort an array in reverse order
	 * @return unknown
	 */
	function _scanDir($path, $rsort = 0) {
		if (!JFolder::exists($path)) {
			return false;
		}
		$d = dir($path);

		$aFiles = array();
		$aFolders = array();
		while (false !== ($entry = $d->read())) {
			if($entry == '.' || $entry == '..') {
				continue;
			}
			if (JFolder::exists($path.DS.$entry)) {
				$aFolders[] = $entry;
			} else {
				$aFiles[] = $entry;
			}
		}
		$d->close();

		if($rsort) {
			rsort($aFiles);
			rsort($aFolders);
		} else {
			sort($aFiles);
			sort($aFolders);
		}
		return array_merge($aFolders, $aFiles);
	}

	/**
   *  Compare between 2 CheckSums arrays and return a result
   *
   * @param $src
   * @param $target
   * @param $result
   *
   * @return  mixed return diff array
   */
	function compare($src, $target) {
		$result = array(
		// common items exists in both
		"common"=>null
		// items only exists src
		, "src"=>null
		// items only exists target
		, "target"=>null
		// items diff in both
		, "diff"=>null
		);

		// === from src
		foreach ($src as $key=>$value) {
			if (!array_key_exists($key, $target)) { // only in src
				//        var_dump("add to src");
				$result["src"][$key] = $value;
			} else if ($value === $target[$key]) {
				$result["common"][$key] = $value;
			} else if (is_array($value) && is_array($target[$key])) { // both are arrays
				//        var_dump("item is array");
				$childResult = self::compare($value, $target[$key]);
				if (!empty($childResult["common"])) {
					$result["common"][$key] = $childResult["common"];
				}
				if (!empty($childResult["src"])) {
					$result["src"][$key] = $childResult["src"];
				}
				if (!empty($childResult["target"])) {
					$result["target"][$key] = $childResult["target"];
				}
				if (!empty($childResult["diff"])) {
					$result["diff"][$key] = $childResult["diff"];
				}
			} else if ($value !== $target[$key]) {
				$result["diff"][$key] = $target[$key];
			}
		}

		// === from target
		foreach ($target as $key=>$value) {
			if (!array_key_exists($key, $src)) { // only in target
				//        var_dump("add to target");
				$result["target"][$key] = $value;
			}
		}

		return $result;
	}

	/**
   *  Compare between 2 CheckSums objects and return a result
   *
   * @param $src
   * @param $target
   * @param $result
   *
   * @return  mixed diff object
   */
	function compareObjects($src, $target) {
		if (!is_object($src) || !is_object($target)) {
			return false;
		}
		$result = new stdClass();

		// common items exists in both
		$result->common = null;
		// items only exists src
		$result->src = null;
		// items only exists target
		$result->target = null;
		// items diff in both
		$result->diff = null;

		// === from src
		foreach ($src as $key=>$value) {
			if (!property_exists($target, $key)) { // only in src
				//        var_dump("add to src");
				$result->src->$key = $value;
			} else if ($value === $target->$key) {
				$result->common->$key = $value;
			} else if (is_object($value) && is_object($target->$key)) { // both are objects
				//        var_dump("item has children");
				$childResult = self::compareObjects($value, $target->$key);
				if (!empty($childResult->common)) {
					$result->common->$key = $childResult->common;
				}
				if (!empty($childResult->src)) {
					$result->src->$key = $childResult->src;
				}
				if (!empty($childResult->target)) {
					$result->target->$key = $childResult->target;
				}
				if (!empty($childResult->diff)) {
					$result->diff->$key = $childResult->diff;
				}
			} else if ($value !== $target->$key) {
				$result->diff->$key = $target->$key;
			}
		}

		// === from target
		foreach ($target as $key=>$value) {
			if (!property_exists($src, $key)) { // only in target
				//        var_dump("add to 2");
				$result->target->$key = $value;
			}
		}

		return $result;
	}

	/**
   * Verify file or directory
   *
   * @param $path  string path to file or directory to verify
   * @param $crc  object structured object with can create early with $this->dumpCRCObject()
   *
   * @return  boolean true if match, otherwise return false
   */
	function verify($path, $crc, &$r) {
		$retVal = true;
		if (JFolder::exists($path)
		&& is_object($crc)) {
			foreach ($crc as $name=>$value) {
				$cPath = $path.DS.$name;
				if (file_exists($cPath)) {
					if (is_object($value)
					&& JFolder::exists($cPath)) {
						$rNew = null;
						if ($this->verify($cPath, $rNew) === false) {
							$retVal = false;
						}
						$r->$name = $rNew;
					} else {
						$r->$name = $this->getCheckSum($cPath) == $value;
						if ($r->$name === false) {
							$retVal = false;
						}
					}
				} else {
					$retVal = $r->$name = false;
				}
			}
		} else if (JFile::exists($path)) {
			$r = $this->getCheckSum($path) == $crc;
			$retVal = $r;
		}
		return $retVal;
	}
}
