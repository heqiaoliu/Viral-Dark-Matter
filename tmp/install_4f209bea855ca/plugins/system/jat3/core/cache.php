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
/*
T3: Joomla Template Engine

*/

// no direct access
defined('_JEXEC') or die('Restricted access');

jimport('joomla.cache.cache');
class T3Cache extends JObject {
	var $cache = null;
	var $started = array();
	var $buffer = array();
	var $_options = null;
	var $_devmode = false;
	function getInstance ($devmode=false) {
		//return null;
		static $instance = null;
		if (!isset ($instance)) {
			$config =& JFactory::getConfig();
			$options = array(
				'cachebase' 	=> JPATH_SITE.DS.'cache',
				'defaultgroup' 	=> 't3',
				'lifetime' 		=> $config->getValue ('cachetime') * 60,
				'handler'		=> $config->getValue ('cache_handler'),
				'caching'		=> false,
				'language'		=> $config->getValue('config.language', 'en-GB'),
				'storage'		=> 'file'
			);
	
			//$cache =& JCache::getInstance('', $options );
			$cache = new JCache ($options);
			$instance = new T3Cache();
			$instance->cache = $cache;
			$instance->_options = $options;
			$instance->_devmode = $devmode;
		}
		return $instance;
	}
	
	function cache_path () {
		return $this->_options['cachebase'].DS.$this->_options['defaultgroup'];		
	}
	
	function cache_assets_path () {
		return $this->_options['cachebase'].DS.$this->_options['defaultgroup'].'-assets';		
	}
	
	function cache_path_base() {
		return $this->_options['cachebase'];
	}
	
	function store_object ($object, $key) {
		if (!$key) return null;
		$t3cache = T3Cache::getInstance();
		$pathbase = $t3cache->cache_path_base();
		if (!is_writeable($pathbase)) return null;
		$path = $t3cache->cache_assets_path();		
		if (!is_dir ($path)) @JFolder::create ($path);
		$path = $path.DS.$key.'.php';
		$data = serialize ($object);
		@file_put_contents($path, $data);
	}
	
	function get_object ($key) {
		if (!$key) return null;
		$t3cache = T3Cache::getInstance();
		$object = null;
		$path = $t3cache->cache_assets_path().DS.$key.'.php';;
		if (is_file ($path)) {
			$data = @file_get_contents ($path);
			$object = unserialize ($data);
		}
		return $object;
	}
	
	function store ($data, $key, $force=false) {
		if (!$key) return false;
		
		$t3cache = T3Cache::getInstance();
		if (!$t3cache) return false;
		$cache = $t3cache->cache;
		if (!$cache) return false;
		if ($force) {
			$caching = $t3cache->_options['caching'];
			//$cache->_options['caching'] = true;
			$cache->setCaching(true);
			$cache->store ($data, $key);
			//$cache->_options['caching'] = $caching;
			$cache->setCaching($caching);
		} else {
			$cache->store ($data, $key);
		}
	}
	
	function get ($key, $force=false) {
		if (!$key) return false;
		
		$t3cache = T3Cache::getInstance();		
		if (!$t3cache) return false;
		$cache = $t3cache->cache;
		if (!$cache) return null;
		$result = null;
		if ($force) {
			$caching = $t3cache->_options['caching'];
			//$cache->_options['caching'] = true;
			$cache->setCaching(true);
			$result = $cache->get ($key);
			//$cache->_options['caching'] = $caching;
			$cache->setCaching($caching);
		} else {
			$result = $cache->get ($key);
		}
		return $result;
	}
	
	function clean ($t3assets = false) {
		//clear T3 cache in cache folder		
		$t3cache = T3Cache::getInstance();		
		if (!$t3cache) return false;
		
		if ($t3assets > 0) {
			//clean content cache
			$cache = $t3cache->cache;
			$cache->clean();
		}
		
		//Clear css/js cached in t3-assets
		if ($t3assets > 1) {
			//Clear assets folder in cache
			$path = $t3cache->cache_assets_path();			
			if (is_dir ($path)) {
				@JFolder::delete ($path);
			}
		}
		
		if ($t3assets > 2) {
			//clean t3-assets folder, the cache for js/css
			$params = T3Common::get_template_based_params();
			$cache_path = $params->get('optimize_folder', 't3-assets');
			$path = T3Path::path ($cache_path);
			if (is_dir ($path)) {
				@JFolder::delete ($path);
			}
		}
	}
	
	function start ($key) {
		$cache = T3Cache::getInstance();
		if (!$cache) return false;
		if (isset($cache->started[$key]) && $cache->started[$key]) return false;
		$cache->started[$key] = true;

		$data = $cache->get ($key);
		if ($data) {
			$cache->started[$key] = false;
			return $data;
		}

		$cache->buffer[$key] = ob_get_clean();
		//$cache->buffer = ob_get_clean();
		ob_start();
		return false;		
	}
	
	function end ($key) {
		$cache = T3Cache::getInstance();
		if (!$cache) return false;
		if (isset($cache->started[$key]) && !$cache->started[$key]) return false;
		$cache->started[$key] = false;
		$data = ob_get_clean();
		ob_start();
		echo $cache->buffer[$key];
		//echo $cache->buffer;
		$cache->store ($data, $key);
		return $data;
	}
	
	function setCaching ($caching) {
		$t3cache = T3Cache::getInstance();		
		if (!$t3cache) return false;
		$cache = $t3cache->cache;	
		$cache->setCaching ($caching);
	}
	
	function getPageKey () {
		static $key = null;
		if ($key) return $key;
		
		$t3cache = T3Cache::getInstance();
		if ($t3cache->_devmode) return null; //no cache in devmode
		
		$mainframe = &JFactory::getApplication();
		$messages = $mainframe->getMessageQueue();
		// Ignore cache when there're some message
		if (is_array($messages) && count($messages)) {
			$key = null;
			return null;
		}
		
		$user = &JFactory::getUser();
		if ($user->get('aid') || $_SERVER['REQUEST_METHOD'] != 'GET') {
			$key = null;
			return null; //no cache for page
		}
		
		$string = 'page';
		$uri = JRequest::getURI();
		//t3import ('core.libs.Browser');
		//$browser = new Browser();
		//$string .= $browser->getBrowser().":".$browser->getVersion();
		$browser = T3Common::getBrowserSortName()."-".T3Common::getBrowserMajorVersion();
		$params = T3Parameter::getInstance();
		$cparams = '';
		foreach($params->_params_cookie as $k=>$v)
			$cparams .= $k."=".$v.'&';
			
		$string = "page - URI: $uri; Browser: $browser; Params: $cparams";
		$key = md5 ($string);
		//Insert into cache db
		/*
		$query = "insert `#__t3_cache` (`key`, `raw`, `uri`, `browser`, `params`, `counter`) values('$key', '$string', '$uri', '$browser', '$cparams', 1) ON DUPLICATE KEY UPDATE `counter`=`counter`+1;";
		$db =& JFactory::getDBO();
		@$db->setQuery( $query );
		@$db->query();
		*/
		return $key;
	}
	
	function getPreloadKey ($template) {
		$t3cache = T3Cache::getInstance();
        if ($t3cache->_devmode) return null;
        
		return md5 ($template);
	}
	
	function getProfileKey () {
		$t3cache = T3Cache::getInstance();
		if ($t3cache->_devmode) return null; //no cache in devmode
		
		$profile = T3Common::get_active_profile ().'-'.T3Common::get_default_profile ();
		return md5 ('profile-'.$profile);
	}
	
	function getThemeKey () {
		$t3cache = T3Cache::getInstance();
		if ($t3cache->_devmode) return null; //no cache in devmode
		
		$themes = T3Common::get_active_themes();
		$layout = T3Common::get_active_layout();
		$string = 'theme-infos-'.$layout;
		if (is_array($themes)) $string .= serialize($themes);
		return md5 ($string);
	}
	
	function store_file ($data, $filename, $overwrite = false) {
		$t3cache = T3Cache::getInstance();
		$path = $t3cache->cache_assets_path();
		$pathbase = $t3cache->cache_path_base();		
		if (!is_dir ($path) && is_writeable($pathbase)) @JFolder::create ($path);
		$path = $path.DS.$filename;
		if (is_file ($path) && !$overwrite) return false;
		@file_put_contents($path, $data);
		return false;		
	}
	
	function get_file ($key) {
		if (!$key) return null;
		$t3cache = T3Cache::getInstance();
		$data = null;
		$path = $t3cache->cache_assets_path().DS.$key;
		if (is_file ($path)) {
			$data = @file_get_contents ($path);
		}
		return $data;
	}
	
}