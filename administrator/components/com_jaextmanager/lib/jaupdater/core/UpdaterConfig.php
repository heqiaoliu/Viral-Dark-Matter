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
 * This class will be use for store configuration for both client and service module
 *
 */
class UpdaterConfig
{
	var $id = 0;
	
	/**
	 *
	 * @var Hash table to store configuration
	 */
	var $configHash = array();


	function UpdaterConfig($configs = array())
	{
		$this->id = rand();
		$this->apply($configs);
	}


	/**
	 *  Use for batch config apply
	 *
	 * @param $configs
	 */
	function apply($configs = array())
	{
		foreach ($configs as $key => $value) {
			$this->set($key, $value);
		}
	}


	/**
	 *
	 * @param $key
	 * @param $value
	 *
	 * @return  boolean true if success, otherwise return false
	 */
	function set($key, $value)
	{
		if (!empty($key)) {
			$this->configHash[$key] = $value;
			return true;
		}
		return false;
	}


	/**
	 *
	 * @param $key
	 *
	 * @return  mixed if option is not exists return null
	 */
	function get($key)
	{
		if (array_key_exists($key, $this->configHash)) {
			return $this->configHash[$key];
		}
		return null;
	}


	/**
	 *
	 * @param $config  UpdaterConfig
	 *
	 * @return  boolean true if success, otherwise false is returned
	 */
	function merge($config)
	{
		if (!empty($config) && is_object($config)) {
			$this->configHash = array_merge($this->configHash, $config->configHash);
		}
	}


	/**
	 *
	 * @param $key
	 *
	 * @return  boolean true if config exists, otherwise return false
	 */
	function remove($key)
	{
		if (array_key_exists($key, $this->configHash)) {
			unset($this->configHash[$key]);
			return true;
		}
		return false;
	}
}