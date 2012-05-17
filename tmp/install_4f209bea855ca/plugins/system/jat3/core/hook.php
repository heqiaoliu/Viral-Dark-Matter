<?php
/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');
/*
T3Hook: load custom code 
hook function is defined in theme with format: [theme folder]_[theme name]_[hook_name]
Eg: core_blue_custom_body_class: defined in theme blue in core folder
Eg: custom_body_class: defined in default theme of template
*/

class T3Hook extends JObject {
	function _ ($hookname, $args = array()) {
		//load custom hook
		T3Hook::_load();
		//find hook function 
		$themes = T3Common::get_active_themes();
		foreach ($themes as $theme) {
			$func = $theme[0]."_".$theme[1]."_".$hookname;
			if (function_exists ($func)) return call_user_func_array ($func, $args);
		}
		if (function_exists ($hookname)) return call_user_func_array ($hookname, $args);
		if (function_exists ("T3Hook::$hookname")) return call_user_func_array ("T3Hook::$hookname", $args);
		return false;
	}
	
	function _load () {
		if (defined ('_T3_HOOK_CUSTOM')) return;
		define ('_T3_HOOK_CUSTOM', 1);
		//include hook. Get all path to hook.php in themes
		$paths = T3Path::getPath ('hook.php', true);
		if (is_array($paths)) {
			foreach ($paths as $path) include ($path);
		}		
	}
}