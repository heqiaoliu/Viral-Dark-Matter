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
 * This object will be use for store Information like: product, module...
 *
 */
class InfoObject
{
	
	var $name, $version, $location, $ignores = array("^\..*", "jabk");


	/**
	 *
	 * @param $name  string
	 * @param $version  string
	 * @param $location  string
	 * @param $data JSON object to load into instead of load from description file
	 */
	function InfoObject($name, $version, $location = null, $data = null)
	{
		if (!empty($data)) {
			$this->loadData($data);
			return;
		}
		$this->name = $name;
		$this->version = $version;
		$this->location = $location;
	}


	/**
	 *  Use to check $entry matches any pattern in $patterns
	 *
	 * @param $str
	 *
	 * @return  boolean true if found matches pattern
	 */
	function isIgnore($str)
	{
		foreach ($this->ignores as $key => $pattern) {
			// Regex format
			if (!preg_match("/^\/[^\/]+\/\w+?$/", $pattern)) {
				$pattern = "/$pattern/";
			}
			if (preg_match($pattern, $str) > 0) {
				return true;
			}
		}
		return false;
	}


	/**
	 * Compare 2 InfoObject
	 *
	 * @return  boolean true if exactly matches name & version
	 */
	function compareTo($infoObject)
	{
		$retVal = false;
		if (!empty($infoObject)) {
			if ($this->version == $infoObject->version && $this->name == $infoObject->name) {
				$retVal = true;
			}
		}
		return $retVal;
	}


	/**
	 *
	 * @param $data JSON object
	 */
	function loadData($data)
	{
		if (!empty($data)) {
			$this->name = $data->name;
			$this->version = $data->version;
			$this->location = $data->location;
		}
	}


	/**
	 *
	 * @return string
	 */
	function toString()
	{
		return "name: $this->name - version: $this->version";
	}
}