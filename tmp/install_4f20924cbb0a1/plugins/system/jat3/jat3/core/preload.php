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

t3import ('core.define');
class T3Preload extends JObject {
	var $_devmode = 0;
	var $data = array();
	function _construct () {
		jimport('joomla.filesystem.folder');
		jimport('joomla.filesystem.file');
	}
	
	function &getInstance()
	{
		static $instance=null;

		if (!isset( $instance )) {
			$instance = new T3Preload ();
		}
		
		return $instance;
	}
	
	function load ($template='') {
		if (!$template) {
			$template = T3_ACTIVE_TEMPLATE;
		}
		if (isset ($this->data[$template])) return $this->data[$template];
		//$key = T3Parameter::getKey ('preload-'.$template, 0);
		$key = T3Cache::getPreloadKey($template);
		
		$this->data[$template] = T3Cache::get_object ($key);
		if (!$this->data[$template]) {
			$this->data[$template] = array();
			$themes = $this->getT3Themes($template);
			foreach ($themes as $theme=>$path) {
				$this->scanFiles (JPATH_SITE.DS.$path, '\.php|\.js|\.css|\.bmp|\.gif|\.jpg|\.png', $template);
			}
/*			
			//create fake html, css, image for template
			foreach ($this->data[$template] as $f=>$file) {
				if (preg_match ('/^html/', $f)) {
					$this->buildLayoutFile ($f, $template);
				} else if (preg_match ('/^css/', $f)) {
					$this->buildCSSFile ($f, $template);
				} else if (preg_match ('/^images/', $f)) {
					$this->buildImageFile ($f, $template);
				}
			}
*/
			$this->data[$template]['themes'] = T3Common::get_themes();
			$this->data[$template]['layouts'] = T3Common::get_layouts();
			$this->data[$template]['profiles'] = T3Common::get_profiles();
			//store in cache
			T3Cache::store_object ($this->data[$template], $key);
		}
	}
	
	function getT3Themes($template) {
		$themes = array();
		$themes["engine.default"] = T3Path::path(T3_BASETHEME, false);
		$path = T3Path::path(T3_TEMPLATE_CORE).DS.'themes';
		$_themes = @ JFolder::folders($path);
		if (is_array ($_themes)) {
			foreach ($_themes as $theme) {
				$themes["core.$theme"] = T3Path::path(T3_TEMPLATE_CORE,false).DS.'themes'.DS.$theme;
			}
		}
		$path = T3Path::path(T3_TEMPLATE_LOCAL).DS.'themes';
		if (is_dir ($path)) {
			$_themes = @ JFolder::folders($path);
			if (is_array ($_themes)) {
				foreach ($_themes as $theme) {
					$themes["local.$theme"] = T3Path::path(T3_TEMPLATE_LOCAL,false).DS.'themes'.DS.$theme;
				}
			}
		}
		return $themes;
	}	
	
	function buildLayoutFile ($file, $template) {
		$path = JPATH_SITE.DS.'templates'.DS.$template.DS.$file;
		if (is_file ($path)) return;
		@ JFolder::create (dirname($path));
		$filecontent = '<?php $t3_current_layout=__FILE__; include(T3Path::path (T3_CORE).DS.\'html.php\');';
		file_put_contents ($path, $filecontent);
	}
	
	function buildCSSFile ($file, $template) {
		$path = JPATH_SITE.DS.'templates'.DS.$template.DS.$file;
		if (is_file ($path)) return;
		@ JFolder::create (dirname($path));
		$filecontent = 'autogen';
		file_put_contents ($path, $filecontent);
	}
	
	function buildImageFile ($file, $template) {
		$path = JPATH_SITE.DS.'templates'.DS.$template.DS.$file;
		if (is_file ($path)) return;
		@ JFolder::create (dirname($path));
		$filecontent = '';
		file_put_contents ($path, $filecontent);
	}
	
	//$themepath: path to html folder
	//$path: layout path
	function scanFiles ($path, $pattern, $template) {
		$files = @ JFolder::files ($path, $pattern, true, true);
		if (!$files || !count ($files)) return array();
		foreach ($files as $file) {
			$f = str_replace($path.DS, '', $file);
			if (!isset ($this->data [$template][$f])) $this->data [$template][$f] = array();
			$this->data [$template][$f][$file]=1;
			//if (preg_match ('/\.php/', $f)) $this->data [$template][$f][$file]=@file_get_contents ($file);
		}
	}
	
	function getObject ($name) {
		$template = T3_ACTIVE_TEMPLATE;
		$preload = T3Preload::getInstance();
		return (isset($preload->data[$template]) && isset ($preload->data[$template ][$name])) ? $preload->data[$template][$name]:null;
	}
	
	function setObject ($name, $object) {
		$template = T3_ACTIVE_TEMPLATE;
		$preload = T3Preload::getInstance();
		$preload->data[$template][$name] = $object;
		//$key = T3Parameter::getKey ('preload-'.$template, 0);
		$key = T3Cache::getPreloadKey($template);
		T3Cache::store_object ($preload->data[$template], $key);
	}
}


function t3_file_exists ($file, $themepath) {
	$file = str_replace ('/', DS, $file);
	$preload = T3Preload::getInstance ();
	$data = $preload->load();
	return (isset($data[$file]) && isset ($data[$file][$themepath.DS.$file])) || file_exists ($themepath.DS.$file);
}

?>
