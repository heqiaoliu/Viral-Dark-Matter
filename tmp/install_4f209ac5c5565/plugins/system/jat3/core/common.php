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

function t3import ($object) {
	$object  = str_replace( '.', DS, $object );
	$path = dirname(dirname(__FILE__)).DS.$object.'.php';
	if (file_exists ($path)) require_once ($path);
}
function t3_import ($object) {
	$path = dirname(dirname(__FILE__)).DS.$object.'.php';
	if (file_exists ($path)) require_once ($path);
}

class T3Common {
	//Detect a template is T3 based
	function detect_ ($template = '') {
		static $ist3 = array();
		if (!$template) {
			$template = T3Common::get_active_template();
		}
		if (isset ($ist3[$template])) {
			return;
		}
		$ist3[$template] = false;
		$path = JPATH_SITE.DS.'templates'.DS.$template.DS.'templateDetails.xml';		
		if (is_file ($path)) {
			$xml = & JFactory::getXMLParser('Simple');	
			if ($xml->loadFile($path))
			{
				if (($templateinfo = & $xml->document) && isset($templateinfo->engine) && trim($templateinfo->engine[0]->_data=='t3')) {
					$ist3[$template] = true;
				}
			}
		}
		
		return $ist3[$template];
	}
	
	function detect ($template = '') {
        t3_import('core.framework');
		if (!$template) {
			$template = T3_ACTIVE_TEMPLATE;
		}
		$path = T3Path::path(T3_TEMPLATE).DS.'info.xml';
		return is_file ($path);
	}
	
	function get_active_template () {
		$mainframe = JFactory::getApplication();
		if ($mainframe->isAdmin()) {
			t3import ('core.admin.util');
			return strtolower(JAT3_AdminUtil::get_active_template());
		}
		return strtolower($mainframe->getTemplate());
	}
	
	function getinfo ($info, $name, $default=null){
		if (isset ($info) && isset($info[$name])) return $info[$name];
		return $default;
	}
	//Merge multi-dimension array
	function merge_array ($arr1, $arr2) {
	    foreach( $arr1 as $k => $v ) {
	        if (isset($arr2[$k])) {
	        	if (is_array($arr1[$k]) && is_array($arr2[$k])) {
	        		$arr2[$k] = T3Common::merge_array ($arr1[$k], $arr2[$k]); 
	        	}
	        } else {
	        	$arr2[$k] = $arr1[$k];
	        }
	    }
	    return $arr2;
	}
	
	function merge_info (& $element1, & $element2) {
		for ($i=0,$n=count($element1['children']);$i<$n;$i++)
		{
			$child1 = $element1['children'][$i]; 
			$name = $child1['name'];
			if ($name == 'blocks') {
				$child2 = T3Common::arr_find_child ($element2, 'blocks', 'name', $child1['attributes']['name']);
				if (!$child2) {
					//Add child1 into element2
					$element2['children'][] = $child1;
				}
			} else {
				$child2 = null;
				if (isset($child1['attributes']['name'])) $child2 = T3Common::arr_find_child ($element2, $name, 'name', $child1['attributes']['name']);
				else $child2 = T3Common::arr_find_child ($element2, $name);
				
				if (!count($child1['children']) || !$child2) {
					//$element2->{$name} = array();
					//Add child1 into element2
					$element2['children'][] = $child1;
				} else {
					$element2['children'][isset($child2['index'])?$child2['index']:0] = T3Common::merge_info ($child1, $child2);
				}
			}
		}
		return $element2;
	}

	function &arr_find_child (&$element, $name, $attr='', $value='', $all=false) {
		$null = null;
		if (!$element || !count ($element['children'])) return $null;
		//if (!$attr) return $element->{$name}[0]; //get the first match
		$children = array();
		for ($j=0,$m=count($element['children']);$j<$m;$j++) {
			$child = & $element['children'][$j];
			if ($child['name']!=$name) continue;
			$child['index'] = $j;
			if (!$attr || (isset($child['attributes'][$attr]) && $child['attributes'][$attr] == $value)) {
				if ($all) 
					$children[] = $child;
				else 
					return $child;
			}
		}
		if ($all) 
			return $children;
		else
			return $null;
	}
	
	function xml_find_element ($element, $name, $attr='', $value='') {
		if (!$element || !isset ($element->{$name}) || !count ($element->{$name})) return null;
		if (!$attr) return $element->{$name}[0]; //get the first match
		
		for ($j=0,$m=count($element->{$name});$j<$m;$j++) {
			$node = $element->{$name}[$j];
			if ($node->attributes ($attr) == $value) {
				$node->_index = $j;			
				return $node;
			}
		}
		return null;
	}
	
	function merge_xml (& $element1, & $element2) {
		for ($i=0,$n=count($element1->_children);$i<$n;$i++)
		{
			$child1 = $element1->_children[$i]; 
			$name = $child1->name();
			if ($name == 'blocks') {
				$child2 = T3Common::xml_find_element ($element2, 'blocks', 'name', $child1->attributes('name'));
				if (!$child2) {
					//Add child1 into element2
					$element2->{$name}[] = $child1;
					//Add the reference to the children array member
					$element2->_children[] = $child1;				
				}
			} else {
				$child2 = null;
				if ($child1->attributes('name')) $child2 = T3Common::xml_find_element ($element2, $name, 'name', $child1->attributes('name'));
				else $child2 = T3Common::xml_find_element ($element2, $name);
				
				if (!isset($child1->_children) || !count($child1->_children) || !$child2) {
					//$element2->{$name} = array();
					//Add child1 into element2
					$element2->{$name}[] = $child1;
					//Add the reference to the children array member
					$element2->_children[] = $child1;
				} else {
					$element2->{$name}[isset($child2->_index)?$child2->_index:0] = T3Common::merge_xml ($child1, $child2);
				}
			}
		}
		return $element2;
	}
	
	function xmltoarray($xml) {
		if (!$xml) return null;
		$arr = array();
		$arr['name'] = $xml->name();
		$arr['data'] = $xml->data();
		//remove blank space for module position 
		if ($arr['name'] == 'block') $arr['data'] = preg_replace ('/\s/','', $arr['data']);
		$arr['attributes'] = $xml->attributes();
		$arr['children'] = array();
		if (count ($xml->children())) {
			foreach ($xml->children() as $child) {
				$arr['children'][] = T3Common::xmltoarray($child);
				//assign parent for block
				if ($arr['name'] == 'blocks') $arr['children'][count($arr['children'])-1]['attributes']['parent'] = $arr['attributes']['name'];
			}
		}
		return $arr;
	}
	
	function getXML ($xmlfile, $array = true) {
		$xml = & JFactory::getXMLParser('Simple');
		if ($xml->loadFile($xmlfile))
		{
			if ($array) return T3Common::xmltoarray($xml->document); 
			return $xml->document;
		}
		return null;
	}
	
	function mobile_device_detect_ () {
		$ui = T3Parameter::_getParam('ui');
		//detect mobile
		t3import ('core.libs.mobile_device_detect');
		//bypass special browser:
		$special = array('jigs', 'w3c ', 'w3c-', 'w3c_');		
		if (in_array(strtolower(substr($_SERVER['HTTP_USER_AGENT'],0,4)), $special)) $mobile_device = false;
		else $mobile_device = mobile_device_detect('iphone','android','opera','blackberry','palm','windows');
		
		return $ui=='desktop'?false:(($ui=='mobile' && !$mobile_device)?'iphone':$mobile_device);
	}
	
	function mobile_device_detect () {
		$ui = T3Parameter::_getParam('ui');
		if ($ui=='desktop') return false;
		//detect mobile
		t3import ('core.libs.Browser');
		$browser = new Browser();
		//bypass
		if ($browser->isRobot()) return false; 
		//consider ipad as normal browser
		if ($browser->getBrowser() == Browser::BROWSER_IPAD) return false;
		
		//mobile
		if ($browser->isMobile()) {
			if (in_array($browser->getBrowser(), array(Browser::BROWSER_IPHONE, Browser::BROWSER_IPOD))) 
				$device = 'iphone';
			else
				$device = strtolower($browser->getBrowser());
				//$device = 'handheld';
			$layout = T3Parameter::get ($device."_layout", '');
			if ($layout == -1) return false; //disable
			return $device;
			//return 'handheld';
		}
		//Not mobile
		if ($ui=='mobile') return 'iphone'; //default for mobile layout on desktop
		return false;
	}
	
	function get_theme_info ($theme) {
		static $theme_infos = array();
		if (!isset($theme_infos[$theme[0].'.'.$theme[1]])) {
			$theme_infos[$theme[0].'.'.$theme[1]] = null;
			
			if ($theme[0] == 'engine') {
				$theme_info_path = T3Path::path(T3_BASE).DS.'base-themes'.DS.$theme[1].DS.'info.xml';
			} else if ($theme[0] == 'template') {
				$theme_info_path = T3Path::path(T3_TEMPLATE).DS.'info.xml';
			} else {
				$theme_info_path = T3Path::path(T3_TEMPLATE).DS.$theme[0].DS.'themes'.DS.$theme[1].DS.'info.xml';
			}
			if (!is_file ($theme_info_path)) return null;
			$theme_infos[$theme[0].'.'.$theme[1]] = T3Common::getXML ($theme_info_path);
		}
		return $theme_infos[$theme[0].'.'.$theme[1]];
	}
	
	function profile_exists ($profile) {
		if (!$profile) return false;
		$path = 'etc'.DS.'profiles'.DS.$profile.'.ini';
		
		if (is_file (T3Path::path(T3_TEMPLATE_LOCAL).DS.$path)) return T3Path::path(T3_TEMPLATE_LOCAL).DS.$path;
		if (is_file (T3Path::path(T3_TEMPLATE_CORE).DS.$path)) return T3Path::path(T3_TEMPLATE_CORE).DS.$path;

		return false;
	}
		
	function layout_exists ($layout) {
		if (!$layout) return false;
		
		$path = 'etc'.DS.'layouts'.DS.$layout.'.xml';
		$pathrtl = 'etc'.DS.'layouts'.DS.$layout.'-rtl.xml';
		//if rtl, check for rtl override before check for default (ltr)
		if (T3Common::isRTL()) {
			//check in local path
			if (is_file (T3Path::path(T3_TEMPLATE_LOCAL).DS.$pathrtl)) return T3Path::path(T3_TEMPLATE_LOCAL).DS.$pathrtl;
			//check in core path
			if (is_file (T3Path::path(T3_TEMPLATE_CORE).DS.$pathrtl)) return T3Path::path(T3_TEMPLATE_CORE).DS.$pathrtl;
			//check in engine path
			if (is_file (T3Path::path(T3_BASETHEME).DS.$pathrtl)) return T3Path::path(T3_BASETHEME).DS.$pathrtl;
		}
		//check in local path
		if (is_file (T3Path::path(T3_TEMPLATE_LOCAL).DS.$path)) return T3Path::path(T3_TEMPLATE_LOCAL).DS.$path;
		//check in core path
		if (is_file (T3Path::path(T3_TEMPLATE_CORE).DS.$path)) return T3Path::path(T3_TEMPLATE_CORE).DS.$path;
		//check in engine path
		if (is_file (T3Path::path(T3_BASETHEME).DS.$path)) return T3Path::path(T3_BASETHEME).DS.$path;

		return false;
	}
	
	function get_layout_info ($layout = '') {
		static $layout_infos = array();
		$params = T3Common::get_template_params ();
		$device = T3Common::mobile_device_detect();
		if (!$layout || !T3Common::layout_exists ($layout)) {
			$layout = T3Common::get_active_layout();
		}
		if (!isset($layout_infos[$layout])) {
			$layout_infos[$layout] = null;
			
			$active_layout_path = T3Common::layout_exists ($layout);
			$engine_layout_path = '';
			
			$layout_info = null;
			if (is_file ($active_layout_path)) {
				$layout_info = T3Common::getXML($active_layout_path);
			}
			
			//detect engine layout to extend
			//if the layout property device is set, get the default engine layout by this property
			//if not found - get the engine layout by $device
			$layout_device = T3Common::node_attributes ($layout_info, 'device', $device); 
			$engine_layout_path = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.$layout_device.'.xml';
			if (!is_file ($engine_layout_path)) {
				if (!$device) {
					$engine_layout_path = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.'default.xml';
				} else {
					$engine_layout_path = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.$device.'.xml';
					if (!is_file($engine_layout_path)) $engine_layout_path = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.'handheld.xml';
				}
			}
			
			if ($engine_layout_path != $active_layout_path && is_file ($engine_layout_path)) {
				$layout_info = $layout_info? T3Common::merge_info (T3Common::getXML($engine_layout_path), $layout_info):T3Common::getXML($engine_layout_path);
			}
			
			$layout_infos[$layout] = $layout_info;
		}
		return $layout_infos[$layout];
	}
	
	function get_active_layout () {
		//return T3Parameter::_getParam('layouts');
		$params = T3Common::get_template_params ();
		$device = T3Common::mobile_device_detect();
		
		if (!$device) { //desktop
			//get from override profile
			$active_profile = T3Common::get_active_profile();
			$default_profile = T3Common::get_default_profile();
			if ($active_profile != $default_profile && $active_profile != 'default') {
				$path = 'etc'.DS.'profiles'.DS.$active_profile.'.ini';		
				$file = T3Path::path(T3_TEMPLATE_LOCAL).DS.$path;
				if (!is_file ($file)) $file = T3Path::path(T3_TEMPLATE_CORE).DS.$path;
				if (is_file ($file)) {
					$content = file_get_contents ($file);
					$params = new JParameter ($content);
					$layout = $params->get ('desktop_layout', '');
					if (T3Common::layout_exists ($layout)) return $layout;
				}
			}

			//cannot get from override profile for this page, get from usersetting
			$layout = T3Parameter::get ('layouts', '');
			if (T3Common::layout_exists ($layout)) return $layout;
			//get default
			$layout = $params->get ('desktop_layout', '');
			if (!T3Common::layout_exists ($layout)) {
				$params = T3Common::get_template_params ();
				$layout = $params->get ('desktop_layout', '');
				if (!T3Common::layout_exists ($layout)) $layout = 'default';
			}
		} else {
			$layout = $params->get ($device.'_layout', '');
			if (!$layout) $layout = $params->get ('handheld_layout', '');
			if ($layout == -1) { //disable => use layout from desktop
				$device = '';
				$layout = $params->get ('desktop_layout', '');
				if (!T3Common::layout_exists ($layout)) $layout = 'default';
			} else if ($layout == 1) { //default => use layout from t3 engine
				$layout = $device;
				if (!T3Common::layout_exists ($layout)) $layout = 'handheld';
			} else if (!T3Common::layout_exists ($layout)) {
				$layout = 'handheld';
			}
		}
		return $layout;
	}
	
	function get_layouts () {
		//get from preload object
		$layouts = T3Preload::getObject ('layouts');
		if ($layouts) {
			return $layouts;
		}

		//cannot get from preload object, get direct from template
		$local_layouts = is_dir (T3Path::path(T3_TEMPLATE_LOCAL).DS.'etc'.DS.'layouts')?@ JFolder::files (T3Path::path(T3_TEMPLATE_LOCAL).DS.'etc'.DS.'layouts', '.xml$'):null;
		$core_layouts = is_dir (T3Path::path(T3_TEMPLATE_CORE).DS.'etc'.DS.'layouts')?@ JFolder::files (T3Path::path(T3_TEMPLATE_CORE).DS.'etc'.DS.'layouts', '.xml$'):null;
		
		if (!$local_layouts && !$core_layouts) return array();
		if ($local_layouts && $core_layouts) $layouts = array_merge ($core_layouts, $local_layouts);
		else if ($local_layouts) $layouts = $local_layouts;
		else $layouts = $core_layouts;

		$_layouts = array();
		$_layouts ['default'] = null;
		foreach ($layouts as $layout) {
			$layout = preg_replace ('/\.xml$/', '', $layout);
			$_layouts[$layout] = $layout;
		}
		return $_layouts;
	}
	
	function get_profiles () {
		//get from preload object
		$profiles = T3Preload::getObject ('profiles');
		if ($profiles) {
			return $profiles;
		}
		
		$local_profiles = is_dir (T3Path::path(T3_TEMPLATE_LOCAL).DS.'etc'.DS.'profiles')?@ JFolder::files (T3Path::path(T3_TEMPLATE_LOCAL).DS.'etc'.DS.'profiles', '.ini$'):array();
		$core_profiles = is_dir (T3Path::path(T3_TEMPLATE_CORE).DS.'etc'.DS.'profiles')?@ JFolder::files (T3Path::path(T3_TEMPLATE_CORE).DS.'etc'.DS.'profiles', '.ini$'):array();
		$_profiles = array_merge ($core_profiles, $local_profiles);
		$profiles = array();
		foreach ($_profiles as $profile) {
			$profile = substr ($profile, 0, -4);
			$profiles[$profile] = $profile;
		}
		return $profiles;
	}
		
	function get_themes () {
		//get from preload object
		$themes = T3Preload::getObject ('themes');
		if ($themes) {
			return $themes;
		}
		
		$themes["engine.default"] = array('engine','default');
		$themes["template.default"] = array('template','default');
		$core_themes = is_dir(T3Path::path(T3_TEMPLATE_CORE).DS.'themes')?@ JFolder::folders (T3Path::path(T3_TEMPLATE_CORE).DS.'themes'):null;
		if ($core_themes) {
			foreach ($core_themes as $theme) {
				$themes["core.$theme"] = array('core',$theme);
			}
		}
		$local_themes = is_dir(T3Path::path(T3_TEMPLATE_LOCAL).DS.'themes')?@ JFolder::folders (T3Path::path(T3_TEMPLATE_LOCAL).DS.'themes'):null;
		if ($local_themes) {
			foreach ($local_themes as $theme) {
				$themes["local.$theme"] = array('local',$theme);
			}
		}
		return $themes;
	}
	
	function get_active_themes () {
		static $_themes = null;
		if (!isset($_themes)) {
			$_themes = array();
			
			$themes = T3Parameter::_getParam('themes');
			//active themes
			$themes = preg_split ('/,/', $themes);
			for ($i=0;$i<count($themes);$i++) {
				$themes[$i] = trim($themes[$i]);
				$theme = array();
				if (preg_match ('/^(local)\.(.*)$/', $themes[$i], $matches)) {
					$theme[0] = $matches[1];
					$theme[1] = $matches[2];
					//$themes[$i] = array('local', $matches[1]);
				} else if (preg_match ('/^(core)\.(.*)$/', $themes[$i], $matches)) {
					$theme[0] = $matches[1];
					$theme[1] = $matches[2];
					//$themes[$i] = array('core', $matches[1]);
				} else {
					$theme[0] = 'core';
					$theme[1] = $themes[$i];
					//$themes[$i] = array('core', $themes[$i]);
				}
				if ($theme[1] && is_dir (T3Path::path(T3_TEMPLATE).DS.$theme[0].DS.'themes'.DS.$theme[1])) {
					$_themes[] = $theme; 
				}
			}
			//if (T3Common::isRTL()) $_themes[] = array('core', 'default-rtl');
			$_themes[] = array('template', 'default');
			//if (T3Common::isRTL()) $_themes[] = array('engine', 'default-rtl');
			$_themes[] = array('engine', 'default');
			
			/*if isRTL, and -rtl theme exists then add this theme automatically, before add the current theme to active list*/
			if (T3Common::isRTL()) {
				$_themesrtl = array();
				foreach ($_themes as $theme) {
					$themertl = array();
					$themertl[0] = $theme[0]=='template'?'core':$theme[0];
					$themertl[1] = $theme[1].'-rtl';
					if ($themertl[0]=='engine' || is_dir (T3Path::path(T3_TEMPLATE).DS.$themertl[0].DS.'themes'.DS.$themertl[1])) {
						$_themesrtl[] = $themertl; 
					}
				}
				
				$_themes = array_merge ($_themesrtl, $_themes);
			}
			
		}
		return $_themes;
	}
	
	function get_template_based_params () {
		static $params = null;
		if ($params) return $params;
		$content = '';
		$file = T3Path::path(T3_TEMPLATE).DS.'params.ini';
	 	if (is_file ($file)) $content = file_get_contents($file);	 	
		$params = new JParameter($content);
		return $params;
	}
	
	function get_template_params () {
		static $params = null;
		if (!isset ($params)) {
			$key = T3Cache::getProfileKey();
			$data = T3Cache::get_file($key);
			if ($data) {
				$params = new JParameter ($data);
				return $params;
			}
			
			$profile = T3Common::get_active_profile ();
			//Load global params
			$content = '';
			$file = T3Path::path(T3_TEMPLATE).DS.'params.ini';
		 	if (is_file ($file)) $content = file_get_contents($file);	 	
			//Load default profile setting
			$path = 'etc'.DS.'profiles'.DS.'default.ini';		
			$file = T3Path::path(T3_TEMPLATE_LOCAL).DS.$path;
			if (!is_file ($file)) $file = T3Path::path(T3_TEMPLATE_CORE).DS.$path;
			if (is_file ($file)) {
				$content .= "\n".file_get_contents ($file);
			}
			//Load all-pages profile setting
			$default_profile = T3Common::get_default_profile ();
			if ($default_profile != 'default' && $profile != 'default') {
				$path = 'etc'.DS.'profiles'.DS.$default_profile.'.ini';		
				$file = T3Path::path(T3_TEMPLATE_LOCAL).DS.$path;
				if (!is_file ($file)) $file = T3Path::path(T3_TEMPLATE_CORE).DS.$path;
				if (is_file ($file)) {
					$content .= "\n".file_get_contents ($file);
				}
			}
			//Load override profile setting
			if ($profile != $default_profile && $profile != 'default') {
				$path = 'etc'.DS.'profiles'.DS.$profile.'.ini';		
				$file = T3Path::path(T3_TEMPLATE_LOCAL).DS.$path;
				if (!is_file ($file)) $file = T3Path::path(T3_TEMPLATE_CORE).DS.$path;
				if (is_file ($file)) {
					$content .= "\n".file_get_contents ($file);
				}
			}
			$params = new JParameter ($content);
			T3Cache::store_file ($params->toString(), $key);
		}
		return $params;		
	}
	
	function get_default_profile () {
		//Get active profile from user setting
		$k = 'profile';
		$kc = T3_ACTIVE_TEMPLATE."_".$k;
		if (($profile = JRequest::getVar($k, null, 'GET')) && T3Common::profile_exists ($profile)) {
			$exp = time() + 60*60*24*355;
			setcookie ($kc, $profile, $exp, '/');
			return $profile;
		}
		
		if (($profile = JRequest::getVar($kc, '', 'COOKIE')) && T3Common::profile_exists ($profile)) {
			return $profile;
		} 

		//Get default profile
		$params = T3Common::get_template_based_params();
		$pages_profile = strtolower($params->get ('pages_profile'));
		
		$regex = '/(^|,|\>|\n)all(,[^=]*)?=([^\<\n]*)/';
		if (preg_match ($regex, $pages_profile, $matches) && T3Common::profile_exists ($matches[3])) {
			return $matches[3];
		}
		
		return '';
	}
	
	function get_active_profile () {
		static $profile = null;
		if ($profile) return $profile;
		
		$params = T3Common::get_template_based_params();
		$pages_profile = strtolower($params->get ('pages_profile'));
		$profile = '';
		//Get profile by component name(such as com_content)
		$comname = JRequest::getCmd( 'option' );
		if ($comname) {
			$regex = '/(^|,|\>|\n)\s*'.$comname.'\s*(,[^=]*)?=([^\<\n]*)/';
			if (preg_match ($regex, $pages_profile, $matches)) {
				$profile = $matches[3];
				if (T3Common::profile_exists ($profile)) return $profile;
			}
		}
		//Get active profile by pages
		$menu = &JSite::getMenu();
		$menuid = T3Common::getItemid ();		
		while ($menuid && !$profile) {			
			$regex = '/(^|,|\>|\n)\s*'.$menuid.'(,[^=]*)?=([^\<\n]*)/';
			if (preg_match ($regex, $pages_profile, $matches)) {
				$profile = $matches[3];
				if (T3Common::profile_exists ($profile)) return $profile;
			}
			
			$menuitem = $menu->getItem ($menuid);
			$menuid = ($menuitem && isset ($menuitem->parent)) ? $menuitem->parent:0;
		}
		//Get profile by page name (such as home)
		if (JRequest::getCmd( 'view' ) == 'frontpage') {
			$regex = '/(^|,|\>|\n)\s*home(,[^=]*)?=([^\<\n]*)/';
			if (preg_match ($regex, $pages_profile, $matches)) {
				$profile = $matches[3];
				if (T3Common::profile_exists ($profile)) return $profile;
			}
		}

		//Get active profile from user setting
		$profile = T3Common::get_default_profile ();
		
		return $profile;
	}
	
	function get_active_themes_info () {
		global $mainframe;
		//$key = T3Parameter::getKey ('themes-info',2);
		$key = T3Cache::getThemeKey();
		$themes_info = T3Cache::get_object ($key); //force cache
		if ($themes_info && isset ($themes_info['layout']) && $themes_info['layout']) {
			return $themes_info;
		}
		$themes = T3Common::get_active_themes();
		$themes[] = array('engine', 'default');
		$themes_info = null;
		foreach ($themes as $theme) {
			//$theme_info = T3Common::get_themes (implode('.', $theme));
			$theme_info = T3Common::get_theme_info ($theme);
			if (!$theme_info) continue;
			if (!$themes_info) $themes_info = $theme_info;
			else {
				//merge info
				$themes_info = T3Common::merge_info ($theme_info, $themes_info);
			}
		}
		//Get layout if tmpl is not component
		$themes_info['layout'] = null;
		$tmpl = JRequest::getCmd ('tmpl');
		if ($tmpl != 'component') {
			$themes_info['layout'] = T3Common::get_layout_info();
		}
		T3Cache::store_object($themes_info, $key);

		return $themes_info;
	}
	
	function get_browser () {
		$agent = $_SERVER['HTTP_USER_AGENT'];
		if ( strpos($agent, 'Gecko') )
		{
		   if ( strpos($agent, 'Netscape') )
		   {
		     $browser = 'NS';
		   }
		   else if ( strpos($agent, 'Firefox') )
		   {
		     $browser = 'FF';
		   }
		   else
		   {
		     $browser = 'Moz';
		   }
		}
		else if ( strpos($agent, 'MSIE') && !preg_match('/opera/i',$agent) )
		{
			 $msie='/msie\s(7|8\.[0-9]).*(win)/i';
		   	 if (preg_match($msie,$agent)) $browser = 'IE7';
		   	 else $browser = 'IE6';
		}
		else if ( preg_match('/opera/i',$agent) )
		{
		     $browser = 'OPE';
		}
		else
		{
		   $browser = 'Others';
		}
		return $browser;
	}
	
	function createObject ($class, $args) {
		$object = new $class ('');
		foreach ($args as $key=>$value) {
			$object->$key = $value;
		}
		return $object;
	}
	
	function getBrowserSortName () {
		t3import ('core.libs.Browser');
		$browser = new Browser();
		$bname = $browser->getBrowser();
		switch ($bname) {
			case Browser::BROWSER_IE:
				return 'ie';
			case Browser::BROWSER_POCKET_IE:
				return 'pie';
			case Browser::BROWSER_FIREFOX:
				return 'ff';
			case Browser::BROWSER_OPERA:
				return 'op';
			case Browser::BROWSER_OPERA_MINI:
				return 'mop';
			case Browser::BROWSER_MOZILLA:
				return 'moz';
			case Browser::BROWSER_KONQUEROR:
				return 'kon';
			case Browser::BROWSER_CHROME:
				return 'chr';
			default:
				return strtolower(str_replace (' ', '-', $bname));
		}
	}
	function getBrowserMajorVersion () {
		t3import ('core.libs.Browser');
		$browser = new Browser();
		$bver = explode ('.', $browser->getVersion());
		return $bver[0]; //Major version only		
	}

	function isRTL () {
		$doc =& JFactory::getDocument();
		$params = & T3Parameter::getInstance();
		return ($doc->direction == 'rtl' || $params->getParam ('direction', 'ltr')=='rtl');
	}

	//simulate xml
	function node_data ($node) {
		return isset ($node['data'])?$node['data']:null;
	}
	function node_attributes ($node, $attr, $default = null) {
		return isset ($node['attributes'][$attr])?$node['attributes'][$attr]:$default;
	}
	function set_node_attributes (&$node, $attr, $value) {
		$node['attributes'][$attr] = $value;
	}	
	function &node_children (&$node, $name=null, $index = -1) {
		$children = array();
		if (!$node) return $children;
		if (!$name) return $node['children'];
		foreach ($node['children'] as $child) {
			if ($child['name'] == $name) $children[] = $child;
		}
		if ($index > -1) $children = isset ($children[$index])?$children[$index]:null;
		return $children;
	}
	
	function getLastUpdate($fieldname=null){
		if (!$fieldname) $fieldname = 'created';
		$db	 = &JFactory::getDBO();
		$query = "SELECT `$fieldname` FROM #__content a ORDER BY `$fieldname` DESC LIMIT 1";
		$db->setQuery($query);
		$data = $db->loadObject();
		if( $data->$fieldname ){  //return gmdate( 'h:i:s A', strtotime($data->created) ) .' GMT ';
			 $date =& JFactory::getDate(strtotime($data->$fieldname));
			 //get timezone configured in Global setting
   			 $app = & JFactory::getApplication();
			 $tz = $app->getCfg('offset')*60*60;	
   			 $sec =$date->toUNIX();   //set the date time to second
   			 //return by the format defined in language
   			 return strftime (JText::_('T3_DATE_FORMAT_LASTUPDATE'), $sec+$tz);
		}
		return ;
	}		

	function log ($msg, $traceback=false) {
		$app = & JFactory::getApplication();
		$log_path = $app->getCfg('log_path');		
		if (!is_dir ($log_path)) $log_path = JPATH_ROOT.DS.'logs';
		if (!is_dir ($log_path)) @JFolder::create ($log_path);
		if (!is_dir ($log_path)) return false; //cannot create log folder
		//prevent http access to this location
		$htaccess = $log_path.DS.'.htaccess';
		if (!is_file ($htaccess)) {
			$htdata = "Order deny,allow\nDeny from all\n";
			//@JFile::write ($htaccess, $htdata);
		}
		//Build log message
		$data = date ('H:i:s')."\n".$msg;
		if ($traceback) {
			$data .= "\n---------\n";
			$cdata = ob_get_contents(); //store old data
			ob_start();
			debug_print_backtrace();
			$data .= ob_get_contents();
			ob_end_clean();
			echo $cdata; //write the old data
			$data .= "\n---------";
		}
		$data .= "\n\n";
		$log_file = $log_path.DS.'t3.log';
		if (!($f = fopen ($log_file, 'a'))) return false;
		fwrite ($f, $data);
		fclose ($f);
		return true;
	}

	function getItemid () {
		if (JVERSION < '1.6') {
			//for joomla 1.5 and 1.0
			global $Itemid;
			return $Itemid;
		}
		//for joomla 1.6
		$app	= JFactory::getApplication();
		$menu	= $app->getMenu();
		$active	= $menu->getActive();
		$active_id = isset($active) ? $active->id : $menu->getDefault()->id;
		return $active_id;
	}

	function addBodyClass ($class) {
		$t3 = T3Template::getInstance($doc);
		$t3->addBodyClass ($class);
	}
	
	function checkWriteable($path) 
	{
		if (file_exists($path)) {
			return is_writeable($path);
		} else {
			$parent = dirname($path);
			if ($parent == $path) return false;
			return self::checkWriteable($parent);
		}
	}
}