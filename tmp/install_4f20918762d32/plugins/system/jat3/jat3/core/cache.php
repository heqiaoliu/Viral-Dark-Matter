<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// No direct access
defined('_JEXEC') or die;

jimport('joomla.cache.cache');

/**
 * T3Cache class
 *
 * @package JAT3.Core
 */
class T3Cache extends JObject
{
    const T3_CACHE_GROUP  = 't3_pages';
    const T3_CACHE_ASSETS = 't3_assets';

    var $cache        = null;
    var $_devmode     = false;

    var $started = array();
    var $buffer = array();
    var $_options = null;

    /**
     * Constructor
     *
     * @param bool $devmode    Indicate development mode or not
     */
    public function __construct ($devmode = true)
    {
        $this->_devmode = $devmode;
        $conf = & JFactory::getConfig();
        $options = array(
            'defaultgroup' => self::T3_CACHE_GROUP,
            'caching'      => true,
            'cachebase'    => $conf->get('cache_path', JPATH_SITE . '/cache'),
            'lifetime'      => (int)$conf->get('cachetime') * 60,
        );

        //JFactory::getCache();
        //$this->cache = new JCache($options);
        $this->cache = JCache::getInstance('', $options);
    }

    /**
     * Get instance of T3Cache
     *
     * @param bool $devmode    Developed mode
     *
     * @return T3Cache
     */
    public static function getT3Cache ($devmode = true)
    {
        static $t3cache = null;
        if ($t3cache == null) {
            $t3cache = new T3Cache($devmode);
        }
        return $t3cache;
    }

    /**
     * Store cached data by key & group
     *
     * @param string  $data     Cached data
     * @param string  $key      Cached key
     * @param string  $group    Cached group
     *
     * @return bool  True if cache stored
     */
    public function store($data, $key, $group = null)
    {
        // Not store when devmode = true
        if ($this->_devmode) return false;

        $cache = $this->cache;

        return $cache->store($data, $key, $group);
    }

    /**
     * Get cached data by key & group
     *
     * @param string $key      Cached key
     * @param string $group    Cached group
     *
     * @return mixed  False if failure or cached data string
     */
    public function get($key, $group = null)
    {
        // Nothing was store when devmode = true
        if ($this->_devmode) return false;

        $cache = $this->cache;

        return $cache->get($key, $group);
    }

    /**
     * Store cached object by key & T3_CACHE_ASSETS
     *
     * @param object $object    Cached object (don't contain resource type)
     * @param string $key       Cached key
     *
     * @return bool  True if cache stored
     */
    public function storeObject($object, $key)
    {
        // Not store object when devmode = true
        if ($this->_devmode) return false;

        $data  = serialize($object);
        $cache = $this->cache;
        return $cache->store($data, $key, T3Cache::T3_CACHE_ASSETS);
    }

    /**
     * Get cached object by key & T3_CACHE_ASSETS
     *
     * @param string $key   Cached key
     *
     * @return mixed   False if failure or cached object
     */
    public function getObject($key)
    {
        // No object was store when devmode = true
        if ($this->_devmode) return false;

        $cache = $this->cache;
        $data  = $cache->get($key, T3Cache::T3_CACHE_ASSETS);
        $object = unserialize($data);
        return $object;
    }

    /**
     * Get data file by key & T3_CACHE_ASSESTS
     *
     * @param string $data    Cached data file
     * @param string $key     Cached key
     *
     * @return bool  True if cache stored
     */
    public function storeFile($data, $key)
    {
        // No file was store when devmode = true
        if ($this->_devmode) return false;

        $cache = $this->cache;

        return $cache->store($data, $key, T3Cache::T3_CACHE_ASSETS);
    }

    /**
     * Get data file by key & T3_CACHE_ASSESTS
     *
     * @param string $key   Cached key
     *
     * @return mixed  False if failure or cached data file
     */
    public function getFile($key)
    {
        // No file was store when devmode = true
        if ($this->_devmode) return false;

        $cache = $this->cache;
        $data  = $cache->get($key, T3Cache::T3_CACHE_ASSETS);

        return $data;
    }

    /**
     * Set caching
     *
     * @param bool $enabled    Enabled caching
     *
     * @return void
     */
    public function setCaching($enabled)
    {
        $this->cache->setCaching($enabled);
    }

    /**
     * Clean cache
     *
     * @param int $t3assets    Level of cleaning
     *
     * @return void
     */
    public static function clean($t3assets = 0)
    {
        $cache = T3Cache::getT3Cache();
        $cache->_clean($t3assets);
    }

    /**
     * Clean T3 cache
     * If $t3assets > 0,  deleted all cached content in defaultgroup
     * If $t3assets > 1,  deleted all cached content in assets group
     * If $t3assets > 2, deleted all cached content in css/js optimize folder
     *
     * @param int $t3assets    Level cache
     *
     * @return void
     */
    private function _clean($t3assets = 0)
    {
        $cache = $this->cache;
        // Clear cache in default group folder
        if ($t3assets > 0) {
            $cache->clean();
        }

        // Clear cache in assets folder
        if ($t3assets > 1) {
            $cache->clean(self::T3_CACHE_ASSETS);
        }

        if ($t3assets > 2) {
            //clean t3-assets folder, the cache for js/css
            $templates = T3Common::get_active_templates();
            //T3Common::log(var_export($templates, true));
            foreach ($templates as $template) {
                $file = T3Path::path("templates/$template").DS.'params.ini';
                if (is_file($file)) {
                    $content = file_get_contents($file);
                    $params = new JParameter($content);
                    $cache_path = $params->get('optimize_folder', 't3-assets');
                    $path = T3Path::path($cache_path);
                    //T3Common::log($path);
                    if (is_dir($path)) {
                        @JFolder::delete($path);
                    }
                }
            }
        }
    }

    /**
     * Get page key from URI, browser (version), params (cookie params)
     *
     * @return mixed  NULL if devmode/noncache or string key code
     */
    public static function getPageKey ()
    {
        static $key = null;
        if ($key) return $key;

        // No cache in devmode
        $t3cache = T3Cache::getT3Cache();
        if ($t3cache->_devmode) return null;

        // No cache when disable T3 cache
        $config = T3Common::get_template_based_params();
        if ($config->get('cache', 0) == 0) return null;

        // TODO: need to move in cache page code at the end of onAfterRender
        $mainframe = &JFactory::getApplication();
        $messages = $mainframe->getMessageQueue();
        // Ignore cache when there're some message
        if (is_array($messages) && count($messages)) {
            return null;
        }

        // If user log-in, ignore cache
        $user = &JFactory::getUser();
        if (!$user->get('guest') || $_SERVER['REQUEST_METHOD'] != 'GET') {
            return null;
        }

        $uri = JRequest::getURI();

        $browser = T3Common::getBrowserSortName() . "-" . T3Common::getBrowserMajorVersion();
        $params  = T3Parameter::getInstance();
        $cparams = '';
        foreach ($params->_params_cookie as $k => $v) {
            $cparams .= $k . "=" . $v . '&';
        }

        $key = "page - URI: $uri; Browser: $browser; Params: $cparams";

        //T3Common::log($key);

        return $key;
    }

    /**
     * Get preload key from template information
     *
     * @param string  $template    String template information
     *
     * @return mixed  NULL if devmode or keycode string
     */
    public static function getPreloadKey ($template)
    {
        $t3cache = T3Cache::getT3Cache();
        if ($t3cache->_devmode) return null; //no cache in devmode*/
        $string = 'template-' . $template;

        return $string;
    }

    /**
     * Get profile key from active profile & default profile
     *
     * @return mixed  NULL if devmode or keycode string
     */
    public static function getProfileKey ()
    {
        $t3cache = T3Cache::getT3Cache();
        if ($t3cache->_devmode) return null; //no cache in devmode

        $profile = T3Common::get_active_profile().'-'.T3Common::get_default_profile();
        $string  = 'profile-'.$profile;

        return $string;
    }

    /**
     * Get theme key from active layout & active themes
     *
     * @return mixed   NULL if devmode or keycode string
     */
    public static function getThemeKey ()
    {
        $t3cache = T3Cache::getT3Cache();
        if ($t3cache->_devmode) return null; //no cache in devmode

        $themes = T3Common::get_active_themes();
        $layout = T3Common::get_active_layout();
        $string = 'theme-infos-'.$layout;
        if (is_array($themes)) $string .= serialize($themes);

        return $string;
    }

    /*
    function getInstance ($devmode = false)
    {
        //return null;
        static $instance = null;
        if (!isset ($instance)) {
            $config =& JFactory::getConfig();
            $options = array(
                'cachebase'     => JPATH_ROOT.DS.'cache',
                'defaultgroup'     => 't3',
                'lifetime'         => $config->getValue ('cachetime') * 60,
                'handler'        => $config->getValue ('cache_handler'),
                'caching'        => false,
                'language'        => $config->getValue('config.language', 'en-GB'),
                'storage'        => 't3'
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

    function store_object ($object, $key) {
        if (!$key) return null;
        $t3cache = T3Cache::getInstance();
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
            $templates = T3Common::get_active_templates();
            //T3Common::log(var_export($templates, true));
            foreach ($templates as $template) {
                $file = T3Path::path("templates/$template").DS.'params.ini';
                if (is_file ($file)) {
                    $content = file_get_contents($file);
                    $params = new JParameter($content);
                    $cache_path = $params->get('optimize_folder', 't3-assets');
                    $path = T3Path::path($cache_path);
                    //T3Common::log($path);
                    if (is_dir($path)) {
                        @JFolder::delete($path);
                    }
                }
            }
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
        if (!$user->get('guest') || $_SERVER['REQUEST_METHOD'] != 'GET') {
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

        return $key;
    }

    function getPreloadKey ($template) {
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
        if (!is_dir ($path)) @JFolder::create ($path);
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
    */
}
