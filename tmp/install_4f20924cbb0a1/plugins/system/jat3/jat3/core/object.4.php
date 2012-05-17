<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */

class ObjectExtendable extends JObject
{
	var $_extendableObjects =     array();
	
	function _extend($oObject)
	{
		$this->_extendableObjects = $oObject;
	}
    	
	function __get($sName, &$sValue)
	{
		for ($i=0;$i<count($this->_extendableObjects);$i++) {
			if (property_exists($this->_extendableObjects[$i], $sName)) {
				$sValue = $this->_extendableObjects[$i]->$sName;
				return true;
			}
		}
		
		return false;
	}
	
	function __set($sName, &$sValue)
	{
		for ($i=0;$i<count($this->_extendableObjects);$i++) {
			if (property_exists($this->_extendableObjects[$i], $sName)) {
				$this->_extendableObjects[$i]->$sName = $sValue;
				return true;
			}
		}
		return false;
	}
	
	function __call($sName, $aArgs = array(), &$return)
	{
		// try call itself method
		if (method_exists($this, $sName)) {
			$return = call_user_func_array(array($this, $sName), $aArgs);
			return true;
		}
		
		// try to call method extended from objects
		for ($i=0;$i<count($this->_extendableObjects);$i++) {		
			//if (method_callable($this->_extendableObjects[$i], $sName)) {
			if (method_exists($this->_extendableObjects[$i], $sName)) {
				$return = call_user_func_array(array(&$this->_extendableObjects[$i], $sName), $aArgs);
				return true;
			}
		}

		return false;
	}
}