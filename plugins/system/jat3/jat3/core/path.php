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

/**
 * T3Path class
 *
 * @package JAT3.Core
 */
class T3Path extends JObject
{
    var $_paths = array();

    /**
     * Get instance object of T3Path
     *
     * @return T3Path
     */
    function getInstance()
    {
        static $instance = null;
        if (!isset($instance)) $instance = new T3Path();
        return $instance;
    }

    /**
     * Add path
     *
     * @param string $theme  Theme name
     * @param string $path   Path
     * @param string $url    URL
     *
     * @return void
     */
    function addPath($theme, $path, $url)
    {
        $this->_paths[$theme] = array($path, $url);
    }

    /**
     * Find path by a part of filename
     *
     * @param string $file  A part of filename
     * @param bool   $all   Return all files or once file
     *
     * @return mixed  Fullpath or list of fullpath
     */
    function find($file, $all = false)
    {
        $result = array();
        //$rpaths = array_reverse ($this->_paths);
        foreach ($this->_paths as $theme => $_path) {
            if (t3_file_exists($file, $_path[0])) {
                $fullpath = array();
                $fullpath[0] = $_path[0] . DS . $file;
                $fullpath[1] = $_path[1] . '/' . str_replace('\\', '/', $file);
                if ($all)
                    $result[$theme] = $fullpath;
                else
                    return $fullpath;
            }
        }
        return count($result) ? $result : false;
    }

    /**
     * Get full path file by a part of file path
     *
     * @param string $file  A part of filepath
     * @param bool   $all   Get all or one filepath
     *
     * @return mixed List or one fullpath
     */
    function getPath($file, $all = false)
    {
        $pathobj = T3Path::getInstance();
        $path = $pathobj->find($file, $all);
        if (!$path) return false;
        if ($all) {
            $result = array();
            foreach ($path as $t => $p)
                $result[$t] = $p[0];
            return $result;
        } else
            return $path[0];
    }

    /**
     * Get url by a part of file path
     *
     * @param string $file  A part of file path
     * @param bool   $all   Return all urls or one url
     *
     * @return mixed  List url if $all = true, otherwise one url
     */
    function getUrl($file, $all = false)
    {
        $pathobj = T3Path::getInstance();
        $path = $pathobj->find($file, $all);
        if (!$path) return false;
        if ($all) {
            $result = array();
            foreach ($path as $t => $p)
                $result[$t] = $p[1];
            return $result;
        } else
            return $path[1];
    }

    /**
     * Static get path file list
     *
     * @param string $file  Sub file path
     * @param bool   $all   Return all files or one file
     *
     * @return mixed  List file if all = true, otherwise one file
     */
    function get($file, $all = false)
    {
        $pathobj = T3Path::getInstance();
        return $pathobj->find($file, $all);
    }

    /**
     * Find layout path
     *
     * @param string $layout  Layout name
     *
     * @return string  Found layout path
     */
    function findLayout($layout = null)
    {
        $pathobj = T3Path::getInstance();
        $file = $layout ? 'layouts' . DS . $layout . '.php' : 'layout_default' . DS . 'layout.php';
        return $pathobj->getPath($file);
    }

    /**
     * Find block path
     *
     * @param string $block  Block name
     *
     * @return string  Block layout path
     */
    function findBlock($block)
    {
        $pathobj = T3Path::getInstance();
        $file = 'blocks' . DS . $block . '.php';
        return $pathobj->getPath($file);
    }

    /**
     * Clean file path
     *
     * @param string $path      File path
     * @param bool   $fullpath  Get full path or not
     *
     * @return string
     */
    function path($path, $fullpath = true)
    {
        //remove after ? or #
        $path = preg_replace('#[?\#]+.*$#', '', $path);
        $fpath = str_replace('/', DS, $path);
        return $fullpath ? JPATH_SITE . DS . $fpath : $fpath;
    }

    /**
     * Get URL
     *
     * @param string $path      File path
     * @param string $pathonly  If false, prepend the scheme, host and port information. Default is false..
     *
     * @return string The URL of file path
     */
    function url($path, $pathonly = true)
    {
        return JURI::root($pathonly) . '/' . $path;
    }
}