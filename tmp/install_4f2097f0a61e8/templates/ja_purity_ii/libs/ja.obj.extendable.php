<?php
/*
#------------------------------------------------------------------------
  T3 Framework for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/


define ('_PHP_', intval (phpversion ()));

if (!function_exists('property_exists')) {
    function property_exists($oObject, $sProperty) {
        if (is_object($oObject)) {
            $oObject = get_class($oObject);
        }
        
        return array_key_exists($sProperty, get_class_vars($oObject));
    }
}

function method_callable($oObject, $sMethod)
{
    // must be object or string
    if (!is_object($oObject) && !is_string($oObject)) {
        return false;
    }
    
    // return
    return array_key_exists($sMethod, array_flip(get_class_methods($oObject)));
}

function make_object_extendable ($classname) {
	if (_PHP_ < 5) {
		overload ($classname);
	}	
}

if (_PHP_ >= 5) {
	require_once (dirname(__FILE__).DS.'ja.object.5.php');
} else {
	require_once (dirname(__FILE__).DS.'ja.object.4.php');
}