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
		if (is_object($oObject)) {
			$this->_extendableObjects[] = $oObject;
		} else if (is_array($oObject)) {
			$this->_extendableObjects = array_merge($this->_extendableObjects, $oObject);
		}
	}

	function __get($sName)
	{
		foreach ($this->_extendableObjects as $oObject) {
			if (property_exists($oObject, $sName)) {
				$sValue = $oObject->$sName;
				return $sValue;
			}
		}
		
		return null;
	}
	
	function __set($sName, $sValue)
	{
		foreach ($this->_extendableObjects as $oObject) {
			if (property_exists($oObject, $sName)) {
				return $oObject->$sName = $sValue;
			}
		}
	}
	
	function __call($sName, $aArgs = array())
	{
		// try call itself method
		if (method_exists($this, $sName)) {
			$return = call_user_func_array(array($this, $sName), $aArgs);
			return $return;
		}
		
		// try to call method extended from objects
		foreach ($this->_extendableObjects as $oObject) {
			//if (method_callable($oObject, $sName)) {
			if (method_exists($oObject, $sName)) {
				$return = call_user_func_array(array($oObject, $sName), $aArgs);
				return $return;
			}
		}
 
		return NULL;
	}
}