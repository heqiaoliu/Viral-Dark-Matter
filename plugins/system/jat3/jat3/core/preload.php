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
defined('_JEXEC') or die();

t3import('core.define');

/**
 * T3Preload class
 *
 * @package JAT3.Core
 */
class T3Preload extends JObject
{
    var $_devmode = 0;
    var $data = array();

    /**
     * Constructor
     *
     * @return void
     */
    function __construct()
    {
        jimport('joomla.filesystem.folder');
        jimport('joomla.filesystem.file');
    }

    /**
     * Get instance object of T3Preload
     *
     * @return T3Preload
     */
    function &getInstance()
    {
        static $instance = null;

        if (!isset($instance)) {
            $instance = new T3Preload();
        }

        return $instance;
    }

    /**
     * Load resource of template
     *
     * @param string $template  Template name
     *
     * @return void
     */
    function load($template = '')
    {
        if (!$template) {
            $template = T3_ACTIVE_TEMPLATE;
        }
        if (isset($this->data[$template])) return $this->data[$template];

        $key = T3Cache::getPreloadKey($template);
        $t3cache = T3Cache::getT3Cache();

        $this->data[$template] = $t3cache->getObject($key);
        if (!$this->data[$template]) {
            $this->data[$template] = array();
            $themes = $this->getT3Themes($template);
            foreach ($themes as $theme => $path) {
                $this->scanFiles(JPATH_SITE . DS . $path, '\.php|\.js|\.css|\.bmp|\.gif|\.jpg|\.png', $template);
            }

            $this->data[$template]['themes']   = T3Common::get_themes();
            $this->data[$template]['layouts']  = T3Common::get_layouts();
            $this->data[$template]['profiles'] = T3Common::get_profiles();
            //store in cache
            $t3cache->storeObject($this->data[$template], $key);
        }
    }

    /**
     * Get theme list
     *
     * @param string $template  Template name
     *
     * @return array  List of theme
     */
    function getT3Themes($template)
    {
        $themes = array();
        $themes["engine.default"] = T3Path::path(T3_BASETHEME, false);

        $path = T3Path::path(T3_TEMPLATE) . DS .'themes';
        // Check if template use newest folder structure or not
        // If themes folder is exists in template folder, considered as template use newest folder structure
        if (@is_dir($path)) {
            $path = T3Path::path(T3_TEMPLATE, false) . DS . 'themes';
            $_themes = @JFolder::folders($path);
            foreach ($_themes as $theme) {
                if ('.local' == substr($theme, -6)) {
                    $themes['local'.substr($theme, 0, -6)] = $path.DS.$theme;
                } else {
                    $themes['core'.$theme] = $path.DS.$theme;
                }
            }
        } else {
            // Compatible: if template use
            $path = T3Path::path(T3_TEMPLATE_CORE) . DS . 'themes';
            $_themes = @ JFolder::folders($path);
            if (is_array($_themes)) {
                foreach ($_themes as $theme) {
                    $themes["core.$theme"] = T3Path::path(T3_TEMPLATE_CORE, false) . DS . 'themes' . DS . $theme;
                }
            }
            $path = T3Path::path(T3_TEMPLATE_LOCAL) . DS . 'themes';
            if (is_dir($path)) {
                $_themes = @ JFolder::folders($path);
                if (is_array($_themes)) {
                    foreach ($_themes as $theme) {
                        $themes["local.$theme"] = T3Path::path(T3_TEMPLATE_LOCAL, false) . DS . 'themes' . DS . $theme;
                    }
                }
            }
        }
        return $themes;
    }

    /**
     * Collect file list from path
     *
     * @param string $path      Resource path
     * @param string $pattern   A filter for file names
     * @param string $template  Template name
     *
     * @return void
     */
    function scanFiles($path, $pattern, $template)
    {
        $files = @ JFolder::files($path, $pattern, true, true);
        if (!$files || !count($files)) return array();
        foreach ($files as $file) {
            $f = str_replace($path . DS, '', $file);
            if (!isset($this->data[$template][$f])) $this->data[$template][$f] = array();
            $this->data[$template][$f][$file] = 1;
            //if (preg_match ('/\.php/', $f)) $this->data [$template][$f][$file]=@file_get_contents ($file);
        }
    }

    /**
     * Get object from resource
     *
     * @param string $name  Object name
     *
     * @return mixed
     */
    function getObject($name)
    {
        $template = T3_ACTIVE_TEMPLATE;
        $preload = T3Preload::getInstance();
        return (isset($preload->data[$template]) && isset($preload->data[$template][$name])) ? $preload->data[$template][$name] : null;
    }

    /**
     * Set object
     *
     * @param string $name    Object name
     * @param string $object  Instance of object
     *
     * @return void
     */
    function setObject($name, $object)
    {
        $template = T3_ACTIVE_TEMPLATE;
        $preload = T3Preload::getInstance();
        $preload->data[$template][$name] = $object;
        //$key = T3Parameter::getKey ('preload-'.$template, 0);
        $key = T3Cache::getPreloadKey($template);
        $t3cache = T3Cache::getT3Cache();
        $t3cache->storeObject($preload->data[$template], $key);
    }
}

/**
 * Check T3 file exists
 *
 * @param string $file       A part of file path
 * @param string $themepath  Theme path
 *
 * @return bool  TRUE if exists, otherwise FALSE
 */
function t3_file_exists($file, $themepath)
{
    $file = str_replace('/', DS, $file);
    $preload = T3Preload::getInstance();
    $data = $preload->load();
    return (isset($data[$file]) && isset($data[$file][$themepath . DS . $file])) || file_exists($themepath . DS . $file);
}

?>
