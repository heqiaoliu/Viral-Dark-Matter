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

/**
 * Import T3 object
 *
 * @param string $object    Object path that seperate by dot (.)
 *
 * @return void
 */
function t3import($object)
{
    $object = str_replace('.', DS, $object);
    $path = dirname(dirname(__FILE__)) . DS . $object . '.php';
    if (file_exists($path)) {
        include_once $path;
    }
}


/**
 * Import T3 object
 *
 * @param string $object    Object path that separate by splash (/)
 *
 * @return void
 */
function t3_import($object)
{
    $path = dirname(dirname(__FILE__)) . DS . $object . '.php';
    if (file_exists($path)) {
        include_once $path;
    }
}

/**
 * T3Common class
 *
 * @package JAT3.Core
 */
class T3Common
{
    /**
     * Determite active template is T3 template or not
     *
     * @param string $template  Template name
     *
     * @return bool  True if T3 template otherwise False
     */
    function detect($template = '')
    {
        t3_import('core/framework');
        if (! $template) {
            $template = T3_ACTIVE_TEMPLATE;
        }
        $path = T3Path::path(T3_TEMPLATE) . DS . 'info.xml';
        return is_file($path);
    }

    /**
     * Get template name is being actived
     *
     * @return string   Template name
     */
    function get_active_template()
    {
        $mainframe = JFactory::getApplication();
        if ($mainframe->isAdmin()) {
            t3import('core.admin.util');
            return strtolower(JAT3_AdminUtil::get_active_template());
        }
        return strtolower($mainframe->getTemplate());
    }

    /*
     * Get all active templates in J1.6
     *
     * @return array  List of template name
     */
    function get_active_templates()
    {
        t3import('core.admin.util');
        return JAT3_AdminUtil::get_active_templates();
    }

    /*
    function getinfo($info, $name, $default = null)
    {
        if (isset($info) && isset($info [$name]))
            return $info [$name];
        return $default;
    }
    */

    /**
     * Merge 2 multi-dimension array
     *
     * @param array $arr1  Array data
     * @param array $arr2  Array data
     *
     * @return array  Merged array
     */
    function merge_array($arr1, $arr2)
    {
        foreach ( $arr1 as $k => $v ) {
            if (isset($arr2[$k])) {
                if (is_array($arr1[$k]) && is_array($arr2[$k])) {
                    $arr2[$k] = T3Common::merge_array($arr1[$k], $arr2[$k]);
                }
            } else {
                $arr2[$k] = $arr1[$k];
            }
        }
        return $arr2;
    }

    /**
     * Merge information of 2 xml element (was converted to array)
     *
     * @param array &$element1  Array element
     * @param array &$element2  Array element
     *
     * @return array Merged array
     */
    function merge_info(& $element1, & $element2)
    {
        for ($i = 0, $n = count($element1['children']); $i < $n; $i ++) {
            $child1 = $element1['children'][$i];
            $name = $child1['name'];
            if ($name == 'blocks') {
                $child2 = T3Common::arr_find_child($element2, 'blocks', 'name', $child1['attributes']['name']);
                if (! $child2) {
                    //Add child1 into element2
                    $element2['children'][] = $child1;
                }
            } else {
                $child2 = null;
                if (isset($child1['attributes']['name']))
                    $child2 = T3Common::arr_find_child($element2, $name, 'name', $child1['attributes']['name']);
                else
                    $child2 = T3Common::arr_find_child($element2, $name);

                if (! count($child1['children']) || ! $child2) {
                    //$element2->{$name} = array();
                    //Add child1 into element2
                    $element2['children'][] = $child1;
                } else {
                    $element2['children'][isset($child2['index']) ? $child2['index'] : 0] = T3Common::merge_info($child1, $child2);
                }
            }
        }
        return $element2;
    }

    /**
     * Get children of a xml element (was converted to array)
     *
     * @param array  &$element   Parent element
     * @param string $name       Element children name want to get
     * @param string $attr       Element attribute name want to get
     * @param string $value      Value of attribute
     * @param bool   $all        Indicate get all element or only once
     *
     * @return array
     */
    function &arr_find_child(&$element, $name, $attr = '', $value = '', $all = false)
    {
        $null = null;
        if (! $element || ! count($element['children']))
            return $null;
            //if (!$attr) return $element->{$name}[0]; //get the first match
        $children = array();
        for ($j = 0, $m = count($element['children']); $j < $m; $j ++) {
            $child = & $element['children'][$j];
            if ($child['name'] != $name)
                continue;
            $child['index'] = $j;
            if (! $attr || (isset($child['attributes'][$attr]) && $child['attributes'][$attr] == $value)) {
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

    /**
     * Find element by parent element, name, attribute value
     *
     * @param array  $element  Parent element
     * @param string $name     Element name
     * @param string $attr     Element attribute name
     * @param string $value    Attribute value
     *
     * @return mixed NULL if not find, otherwise element
     */
    function xml_find_element($element, $name, $attr = '', $value = '')
    {
        if (! $element || ! isset($element->{$name}) || ! count($element->{$name}))
            return null;
        if (! $attr)
            return $element->{$name}[0]; //get the first match

        for ($j = 0, $m = count($element->{$name}); $j < $m; $j ++) {
            $node = $element->{$name}[$j];
            if ($node->attributes($attr) == $value) {
                $node->_index = $j;
                return $node;
            }
        }

        return null;
    }

    /**
     * Merge 2 xml element (were convert to array)
     *
     * @param array &$element1   Element data
     * @param arrar &$element2   Element data
     *
     * @return array Merged element
     */
    function merge_xml(& $element1, & $element2)
    {
        for ($i = 0, $n = count($element1->_children); $i < $n; $i ++) {
            $child1 = $element1->_children[$i];
            $name = $child1->name();
            if ($name == 'blocks') {
                $child2 = T3Common::xml_find_element($element2, 'blocks', 'name', $child1->attributes('name'));
                if (! $child2) {
                    //Add child1 into element2
                    $element2->{$name}[] = $child1;
                    //Add the reference to the children array member
                    $element2->_children[] = $child1;
                }
            } else {
                $child2 = null;
                if ($child1->attributes('name'))
                    $child2 = T3Common::xml_find_element($element2, $name, 'name', $child1->attributes('name'));
                else
                    $child2 = T3Common::xml_find_element($element2, $name);

                if (! isset($child1->_children) || ! count($child1->_children) || ! $child2) {
                    //$element2->{$name} = array();
                    //Add child1 into element2
                    $element2->{$name}[] = $child1;
                    //Add the reference to the children array member
                    $element2->_children[] = $child1;
                } else {
                    $element2->{$name}[isset($child2->_index) ? $child2->_index : 0] = T3Common::merge_xml($child1, $child2);
                }
            }
        }
        return $element2;
    }

    /**
     * Convert xml to array
     *
     * @param JSimpleXML $xml   Object XML
     *
     * @return array
     */
    function xmltoarray($xml)
    {
        if (!$xml) return null;

        $arr = array();
        $arr['name'] = $xml->name();
        $arr['data'] = $xml->data();

        // Remove blank space for module position
        if ($arr['name'] == 'block') {
            $arr['data'] = preg_replace('/\s/', '', $arr['data']);
        }

        $arr['attributes'] = $xml->attributes();
        $arr['children'] = array();
        if (count($xml->children())) {
            foreach ( $xml->children() as $child ) {
                $arr['children'][] = T3Common::xmltoarray($child);
                // Assign parent for block
                if ($arr['name'] == 'blocks') {
                    $arr['children'][count($arr['children']) - 1]['attributes']['parent'] = $arr['attributes']['name'];
                }
            }
        }

        return $arr;
    }

    /**
     * Get and parse file content to xml element
     *
     * @param string $xmlfile   Xml file path
     * @param bool   $array     Convert to array or not
     *
     * @return mixed NULL if load or parse file fail, Array if array is true, otherwise JSimpleXML
     */
    function getXML($xmlfile, $array = true)
    {
        $xml = & JFactory::getXMLParser('Simple');
        if ($xml->loadFile($xmlfile)) {
            if ($array)
                return T3Common::xmltoarray($xml->document);
            return $xml->document;
        }
        return null;
    }

    /*
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
    */

    /**
     * Detect mobile device
     *
     * @return mixed   Mobile device name or false
     */
    function mobile_device_detect()
    {
        $ui = T3Parameter::_getParam('ui');
        if ($ui == 'desktop') return false;
        // Detect mobile
        t3import('core.libs.Browser');
        $browser = new Browser();
        // Bypass
        if ($browser->isRobot()) return false;
        // Consider ipad as normal browser
        if ($browser->getBrowser() == Browser::BROWSER_IPAD) return false;

        // Mobile
        if ($browser->isMobile()) {
            if (in_array($browser->getBrowser(), array(Browser::BROWSER_IPHONE, Browser::BROWSER_IPOD)))
                $device = 'iphone';
            else
                $device = strtolower($browser->getBrowser());
                //$device = 'handheld';
            $layout = T3Parameter::get($device . "_layout", '');
            if ($layout == - 1) return false; //disable
            return $device;
            //return 'handheld';
        }
        // Not mobile
        if ($ui == 'mobile') return 'iphone'; //default for mobile layout on desktop
        return false;
    }

    /**
     * Get theme information
     *
     * @param string $theme  Theme name
     *
     * @return array  Theme info
     */
    function get_theme_info($theme)
    {
        static $theme_infos = array();

        if (! isset($theme_infos[$theme[0] . '.' . $theme[1]])) {
            $theme_infos[$theme[0] . '.' . $theme[1]] = null;
            if ($theme[0] == 'engine') {
                $theme_info_path = T3Path::path(T3_BASE) . DS . 'base-themes' . DS . $theme[1] . DS . 'info.xml';
            } else if ($theme[0] == 'template') {
                $theme_info_path = T3Path::path(T3_TEMPLATE) . DS . 'info.xml';
            } else {
                //$theme_info_path = T3Path::path(T3_TEMPLATE) . DS . $theme[0] . DS . 'themes' . DS . $theme[1] . DS . 'info.xml';
                $theme_info_path = self::getThemePath($theme[1], $theme[0] == 'local') . DS . 'info.xml';
            }
            if (!is_file($theme_info_path)) {
                return null;
            }
            $theme_infos[$theme[0] . '.' . $theme[1]] = T3Common::getXML($theme_info_path);
        }

        return $theme_infos[$theme[0] . '.' . $theme[1]];
    }

    /**
     * Check profile exists
     *
     * @param string $profile  Profile name
     *
     * @return mixed  Profile path if exists, otherwise FALSE
     */
    function profile_exists($profile)
    {
        if (!$profile) {
            return false;
        }
        $file = self::getFilePath($profile, 'profiles');
        if (is_file($file)) {
            return $file;
        }
        return false;
    }

    /**
     * Check layout exists
     *
     * @param string $layout  Layout name
     *
     * @return mixed  Layout path if exists otherwise FALSE
     */
    function layout_exists($layout)
    {
        if (! $layout) {
            return false;
        }

        // If rtl, check for rtl override before check for default (ltr)
        if (T3Common::isRTL()) {
            // Check core/local file
            $file = self::getFilePath($layout.'-rtl', 'layouts', '.xml');
            if (is_file($file)) {
                return $file;
            }
            // Check in engine path
            $file = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.$layout.'-rtl.xml';
            if (is_file($file)) {
                return $file;
            }
        }
        // Check core/local file
        $file = self::getFilePath($layout, 'layouts', '.xml');
        if (is_file($file)) {
            return $file;
        }
        // Check in engine path
        $file = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.$layout.'.xml';
        if (is_file($file)) {
            return $file;
        }

        return false;
    }

    /**
     * Get layout infomation
     *
     * @param string $layout  Layout name
     *
     * @return array  Layout info
     */
    function get_layout_info($layout = '')
    {
        static $layout_infos = array();

        $params = T3Common::get_template_params();
        $device = T3Common::mobile_device_detect();
        if (! $layout || ! T3Common::layout_exists($layout)) {
            $layout = T3Common::get_active_layout();
        }

        if (! isset($layout_infos[$layout])) {
            $layout_infos[$layout] = null;

            $active_layout_path = T3Common::layout_exists($layout);
            $engine_layout_path = '';

            $layout_info = null;
            if (is_file($active_layout_path)) {
                $layout_info = T3Common::getXML($active_layout_path);
            }

            // Detect engine layout to extend
            // If the layout property device is set, get the default engine layout by this property
            // If not found - get the engine layout by $device
            $basepath           = T3Path::path(T3_BASETHEME) . DS . 'etc' . DS . 'layouts';
            $layout_device      = T3Common::node_attributes($layout_info, 'device', $device);
            $engine_layout_path = $basepath . DS . $layout_device . '.xml';
            if (!is_file($engine_layout_path)) {
                if (!$device) {
                    $engine_layout_path = $basepath . DS . 'default.xml';
                } else {
                    $engine_layout_path = $basepath . DS . $device . '.xml';
                    if (!is_file($engine_layout_path)) {
                        $engine_layout_path = $basepath . DS . 'handheld.xml';
                    }
                }
            }

            if ($engine_layout_path != $active_layout_path && is_file($engine_layout_path)) {
                $layout_info = $layout_info
                    ? T3Common::merge_info(T3Common::getXML($engine_layout_path), $layout_info)
                    : T3Common::getXML($engine_layout_path);
            }

            $layout_infos[$layout] = $layout_info;
        }
        return $layout_infos[$layout];
    }

    /**
     * Get active layout name
     *
     * @return string
     */
    function get_active_layout()
    {
        //return T3Parameter::_getParam('layouts');
        $params = T3Common::get_template_params();
        $device = T3Common::mobile_device_detect();

        if (! $device) { //desktop
            // Get from override profile
            $active_profile  = T3Common::get_active_profile();
            $default_profile = T3Common::get_default_profile();
            if ($active_profile != $default_profile && $active_profile != 'default') {
                $file = self::getFilePath($active_profile, 'profiles');
                if (is_file($file)) {
                    $content = file_get_contents($file);
                    $params = new JParameter($content);
                    $layout = $params->get('desktop_layout', '');
                    if (T3Common::layout_exists($layout)) {
                        return $layout;
                    }
                }
            }
            // Cannot get from override profile for this page, get from usersetting
            $layout = T3Parameter::get('layouts', '');
            if (T3Common::layout_exists($layout)) {
                return $layout;
            }
            // Get default
            $layout = $params->get('desktop_layout', '');
            if (! T3Common::layout_exists($layout)) {
                $params = T3Common::get_template_params();
                $layout = $params->get('desktop_layout', '');
                if (! T3Common::layout_exists($layout)) {
                    $layout = 'default';
                }
            }
        } else {
            $layout = $params->get($device . '_layout', '');
            if (! $layout) {
                $layout = $params->get('handheld_layout', '');
            }
            if ($layout == - 1) { //disable => use layout from desktop
                $device = '';
                $layout = $params->get('desktop_layout', '');
                if (! T3Common::layout_exists($layout)) {
                    $layout = 'default';
                }
            } elseif ($layout == 1) { //default => use layout from t3 engine
                $layout = $device;
                if (! T3Common::layout_exists($layout)) {
                    $layout = 'handheld';
                }
            } elseif (! T3Common::layout_exists($layout)) {
                $layout = 'handheld';
            }
        }

        return $layout;
    }

    /**
     * Get list of layout name
     *
     * @return array
     */
    function get_layouts()
    {
        // Get from preload object
        $layouts = T3Preload::getObject('layouts');
        if ($layouts) {
            return $layouts;
        }

        $path = T3Path::path(T3_TEMPLATE).DS.'etc'.DS.'layouts';
        // Check if etc/layouts exitst, there is new structure folders
        if (@is_dir($path)) {
            $_layouts = array();
            $_layouts['default'] = null;

            $layout_list = JFolder::files($path, '\.xml$');
            foreach ($layout_list as $file) {
                $filename = substr($file, 0, -4);
                $_layouts[$filename] = $filename;
            }
        } else {
            // Compatible: if template remain old structure folders, try to read it

            // Cannot get from preload object, get direct from template
            $local_layouts = is_dir(T3Path::path(T3_TEMPLATE_LOCAL) . DS . 'etc' . DS . 'layouts')
                ? @ JFolder::files(T3Path::path(T3_TEMPLATE_LOCAL) . DS . 'etc' . DS . 'layouts', '.xml$')
                : null;
            $core_layouts = is_dir(T3Path::path(T3_TEMPLATE_CORE) . DS . 'etc' . DS . 'layouts')
                ? @ JFolder::files(T3Path::path(T3_TEMPLATE_CORE) . DS . 'etc' . DS . 'layouts', '.xml$')
                : null;

            if (!$local_layouts && !$core_layouts) {
                return array();
            }
            if ($local_layouts && $core_layouts) {
                $layouts = array_merge($core_layouts, $local_layouts);
            } elseif ($local_layouts) {
                $layouts = $local_layouts;
            } else {
                $layouts = $core_layouts;
            }

            $_layouts = array();
            $_layouts['default'] = null;
            foreach ($layouts as $layout) {
                $layout = preg_replace('/\.xml$/', '', $layout);
                $_layouts[$layout] = $layout;
            }
        }

        return $_layouts;
    }

    /**
     * Get list of profile name
     *
     * @return array
     */
    function get_profiles()
    {
        // Get from preload object
        $profiles = T3Preload::getObject('profiles');
        if ($profiles) {
            return $profiles;
        }

        $filepath = T3Path::path(T3_TEMPLATE) . DS . 'etc' . DS . 'profiles';
        // Check if profiles folder is exists
        if (@is_dir($filepath)) {
            $profile_list = JFolder::files($filepath, '.ini$');
            $profiles = array();
            foreach ($profile_list as $p) {
                $name = substr($p, 0, -4);
                $profiles[$name] = $name;
            }
        } else {
            // Compatible: Maybe template have old structures folder, so try to read it.
            $local_profiles = is_dir(T3Path::path(T3_TEMPLATE_LOCAL) . DS . 'etc' . DS . 'profiles')
                ? @ JFolder::files(T3Path::path(T3_TEMPLATE_LOCAL) . DS . 'etc' . DS . 'profiles', '.ini$')
                : array();
            $core_profiles = is_dir(T3Path::path(T3_TEMPLATE_CORE) . DS . 'etc' . DS . 'profiles')
                ? @ JFolder::files(T3Path::path(T3_TEMPLATE_CORE) . DS . 'etc' . DS . 'profiles', '.ini$')
                : array();
            $_profiles = array_merge($core_profiles, $local_profiles);
            $profiles = array();
            foreach ($_profiles as $profile) {
                $profile = substr($profile, 0, - 4);
                $profiles[$profile] = $profile;
            }
        }

        return $profiles;
    }

    /**
     * Get list of themes
     *
     * @return array
     */
    function get_themes()
    {
        //get from preload object
        $themes = T3Preload::getObject('themes');
        if ($themes) {
            return $themes;
        }

        $path = T3Path::path(T3_TEMPLATE).DS.'themes';
        // Check if template use newest folder structure or not
        // If themes exists in template folder, considered as template use newest folder structure
        if (@is_dir($path)) {
            $themes['engine.default']   = array('engine', 'default');
            $themes['template.default'] = array('template', 'default');
            $theme_list = JFolder::folders($path);
            if (!empty($theme_list)) {
                foreach ($theme_list as $folder) {
                    $themes['core'.$folder] = array('core', $folder);
                }
            }
        } else {
            // Compatible: if template still use older folder structure, try to use it.
            $themes["engine.default"]   = array('engine', 'default');
            $themes["template.default"] = array('template', 'default');
            $core_themes = is_dir(T3Path::path(T3_TEMPLATE_CORE) . DS . 'themes')
                ? @JFolder::folders(T3Path::path(T3_TEMPLATE_CORE) . DS . 'themes')
                : null;
            if ($core_themes) {
                foreach ($core_themes as $theme) {
                    $themes["core.$theme"] = array('core', $theme);
                }
            }

            $local_themes = is_dir(T3Path::path(T3_TEMPLATE_LOCAL) . DS . 'themes')
                ? @JFolder::folders(T3Path::path(T3_TEMPLATE_LOCAL) . DS . 'themes')
                : null;
            if ($local_themes) {
                foreach ($local_themes as $theme) {
                    $themes["local.$theme"] = array('local', $theme);
                }
            }
        }
        return $themes;
    }

    /**
     * Get list of theme name
     *
     * @return array
     */
    function get_active_themes()
    {
        static $_themes = null;
        if (! isset($_themes)) {
            $_themes = array();

            $themes = T3Parameter::_getParam('themes');
            // Active themes
            $themes = preg_split('/,/', $themes);
            for ($i = 0; $i < count($themes); $i ++) {
                $themes[$i] = trim($themes[$i]);
                $theme = array();
                if (preg_match('/^(local)\.(.*)$/', $themes[$i], $matches)) {
                    $theme[0] = $matches[1];
                    $theme[1] = $matches[2];
                    //$themes[$i] = array('local', $matches[1]);
                } elseif (preg_match('/^(core)\.(.*)$/', $themes[$i], $matches)) {
                    $theme[0] = $matches[1];
                    $theme[1] = $matches[2];
                    //$themes[$i] = array('core', $matches[1]);
                } else {
                    $theme[0] = 'core';
                    $theme[1] = $themes[$i];
                    //$themes[$i] = array('core', $themes[$i]);
                }
                $path = self::getThemePath($theme[1], $theme[0] == 'local');
                if ($theme[1] && is_dir($path)) {
                    $_themes[] = $theme;
                }
            }
            //if (T3Common::isRTL()) $_themes[] = array('core', 'default-rtl');
            $_themes[] = array('template', 'default');
            //if (T3Common::isRTL()) $_themes[] = array('engine', 'default-rtl');
            $_themes[] = array('engine', 'default');

            //if isRTL, and -rtl theme exists then add this theme automatically, before add the current theme to active list
            if (T3Common::isRTL()) {
                $_themesrtl = array();
                foreach ($_themes as $theme) {
                    $themertl = array();
                    $themertl[0] = $theme[0] == 'template' ? 'core' : $theme[0];
                    $themertl[1] = $theme[1] . '-rtl';
                    //$path = T3Path::path(T3_TEMPLATE) . DS . $themertl[0] . DS . 'themes' . DS . $themertl[1];
                    $path = self::getThemePath($themertl[1], $themertl[0] == 'local');
                    if ($themertl[0] == 'engine' || is_dir($path)) {
                        $_themesrtl[] = $themertl;
                    }
                }

                $_themes = array_merge($_themesrtl, $_themes);
            }

        }
        return $_themes;
    }

    /**
     * Get template basic parameters
     *
     * @return JParameter
     */
    function get_template_based_params()
    {
        static $params = null;
        if ($params) return $params;
        $content = '';
        $file = T3Path::path(T3_TEMPLATE) . DS . 'params.ini';
        if (is_file($file)) $content = file_get_contents($file);
        $params = new JParameter($content);
        return $params;
    }

    /**
     * Get template parameters
     *
     * @return JParameter
     */
    function get_template_params()
    {
        static $params = null;
        if (! isset($params)) {
            $key = T3Cache::getProfileKey();
            $t3cache = T3Cache::getT3Cache();
            $data = $t3cache->getFile($key);
            if ($data) {
                $params = new JParameter($data);
                return $params;
            }
            $profile = T3Common::get_active_profile();
            //Load global params
            $content = '';
            $file = T3Path::path(T3_TEMPLATE) . DS . 'params.ini';
            if (is_file($file)) {
                $content = file_get_contents($file);
            }
            //Load default profile setting
            $file = self::getFilePath('default', 'profiles');
            if (is_file($file)) {
                $content .= "\n" . file_get_contents($file);
            }
            //Load all-pages profile setting
            $default_profile = T3Common::get_default_profile();
            if ($default_profile != 'default' && $profile != 'default') {
                $file = self::getFilePath($default_profile, 'profiles');
                if (is_file($file)) {
                    $content .= "\n" . file_get_contents($file);
                }
            }
            //Load override profile setting
            if ($profile != $default_profile && $profile != 'default') {
                $file = self::getFilePath($profile, 'profiles');
                if (is_file($file)) {
                    $content .= "\n" . file_get_contents($file);
                }
            }
            $params = new JParameter($content);
            $t3cache->storeFile($params->toString(), $key);
        }
        return $params;
    }

    /**
     * Get default profile name
     *
     * @return string
     */
    function get_default_profile()
    {
        //Get active profile from user setting
        $k = 'profile';
        $kc = T3_ACTIVE_TEMPLATE . "_" . $k;
        if (($profile = JRequest::getVar($k, null, 'GET')) && T3Common::profile_exists($profile)) {
            $exp = time() + 60 * 60 * 24 * 355;
            setcookie($kc, $profile, $exp, '/');
            return $profile;
        }

        if (($profile = JRequest::getVar($kc, '', 'COOKIE')) && T3Common::profile_exists($profile)) {
            return $profile;
        }

        //Get default profile
        $params = T3Common::get_template_based_params();
        $pages_profile = strtolower($params->get('pages_profile'));

        $regex = '/(^|,|\>|\n)all(,[^=]*)?=([^\<\n]*)/';
        if (preg_match($regex, $pages_profile, $matches) && T3Common::profile_exists($matches[3])) {
            return $matches[3];
        }

        return '';
    }

    /**
     * Get active profile name
     *
     * @return string
     */
    function get_active_profile()
    {
    	// @todo improve way to select profile
        static $profile = null;
        if ($profile) {
            return $profile;
        }

        $lang  = JFactory::getLanguage();
        $lang  = strtolower($lang->getTag());

        $params = T3Common::get_template_based_params();
        $pages_profile = strtolower($params->get('pages_profile'));
        $profile = '';
        //Get active profile by pages
        $menu = &JSite::getMenu();
        $menuid = T3Common::getItemid();
        while ($menuid && !$profile) {
            // Check there is assignment with current language and menu
            $regex = '/(^|,|\>|\n)\s*' . $lang . '#' . $menuid . '(,[^=]*)?=([^\<\n]*)/';
            if (preg_match($regex, $pages_profile, $matches)) {
                $profile = $matches[3];
                if (T3Common::profile_exists($profile)) {
                    return $profile;
                }
            }
            // Check there is assignment with default language and menu
            $regex = '/(^|,|\>|\n)\s*' . $menuid . '(,[^=]*)?=([^\<\n]*)/';
            if (preg_match($regex, $pages_profile, $matches)) {
                $profile = $matches[3];
                if (T3Common::profile_exists($profile)) {
                    return $profile;
                }
            }

            $menuitem = $menu->getItem($menuid);
            $menuid = ($menuitem && isset($menuitem->parent)) ? $menuitem->parent : 0;
        }
        //Get profile by component name(such as com_content)
        $comname = JRequest::getCmd('option');
        if ($comname) {
            // Check there is assignment with current language and component
            $regex = '/(^|,|\>|\n)\s*' . $lang . '#' . $comname . '\s*(,[^=]*)?=([^\<\n]*)/';
            if (preg_match($regex, $pages_profile, $matches)) {
                $profile = $matches[3];
                if (T3Common::profile_exists($profile)) {
                    return $profile;
                }
            }
            // Check there is assingment with default language and component
            $regex = '/(^|,|\>|\n)\s*' . $comname . '\s*(,[^=]*)?=([^\<\n]*)/';
            if (preg_match($regex, $pages_profile, $matches)) {
                $profile = $matches[3];
                if (T3Common::profile_exists($profile)) {
                    return $profile;
                }
            }
        }
        //Get profile by page name (such as home)
        if (JRequest::getCmd('view') == 'frontpage') {
            $regex = '/(^|,|\>|\n)\s*home(,[^=]*)?=([^\<\n]*)/';
            if (preg_match($regex, $pages_profile, $matches)) {
                $profile = $matches[3];
                if (T3Common::profile_exists($profile)) {
                    return $profile;
                }
            }
        }

        // Check there is assingmnet for current language
        $regex = '/(^|,|\>|\n)\s*' . $lang . '(,[^=]*)?=([^\<\n]*)/';
        if (preg_match($regex, $pages_profile, $matches)) {
            $profile = $matches[3];
            if (T3Common::profile_exists($profile)) {
                return $profile;
            }
        }

        //Get active profile from user setting
        $profile = T3Common::get_default_profile();

        return $profile;
    }

    /**
     * Get active themes info
     *
     * @return array   Themes information
     */
    function get_active_themes_info()
    {
        $key = T3Cache::getThemeKey();
        $t3cache = T3Cache::getT3Cache();
        $themes_info = $t3cache->getObject($key);
        if ($themes_info && isset($themes_info['layout']) && $themes_info['layout']) {
            return $themes_info;
        }
        $themes = T3Common::get_active_themes();
        $themes[] = array('engine', 'default');
        $themes_info = null;
        foreach ($themes as $theme) {
            //$theme_info = T3Common::get_themes (implode('.', $theme));
            $theme_info = T3Common::get_theme_info($theme);
            if (!$theme_info) {
                continue;
            }
            if (!$themes_info) {
                $themes_info = $theme_info;
            } else {
                //merge info
                $themes_info = T3Common::merge_info($theme_info, $themes_info);
            }
        }
        //Get layout if tmpl is not component
        $themes_info['layout'] = null;
        $tmpl = JRequest::getCmd('tmpl');
        if ($tmpl != 'component') {
            $themes_info['layout'] = T3Common::get_layout_info();
        }
        $t3cache->storeObject($themes_info, $key);

        return $themes_info;
    }

    /*
    function get_browser()
    {
        $agent = $_SERVER['HTTP_USER_AGENT'];
        if (strpos($agent, 'Gecko')) {
            if (strpos($agent, 'Netscape')) {
                $browser = 'NS';
            } else if (strpos($agent, 'Firefox')) {
                $browser = 'FF';
            } else {
                $browser = 'Moz';
            }
        } else if (strpos($agent, 'MSIE') && ! preg_match('/opera/i', $agent)) {
            $msie = '/msie\s(7|8\.[0-9]).*(win)/i';
            if (preg_match($msie, $agent))
                $browser = 'IE7';
            else
                $browser = 'IE6';
        } else if (preg_match('/opera/i', $agent)) {
            $browser = 'OPE';
        } else {
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
    */

    /**
     * Get browser sort name
     *
     * @return string
     */
    function getBrowserSortName()
    {
        t3import('core.libs.Browser');
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
                return strtolower(str_replace(' ', '-', $bname));
        }
    }

    /**
     * Get browser major version
     *
     * @return string
     */
    function getBrowserMajorVersion()
    {
        t3import('core.libs.Browser');
        $browser = new Browser();
        $bver = explode('.', $browser->getVersion());
        return $bver[0]; //Major version only
    }

    /**
     * Check RTL website
     *
     * @return bool
     */
    function isRTL()
    {
        $lang = &JFactory::getLanguage();
        return $lang->isRTL();
    }

    /**
     * Get data of node
     *
     * @param array $node  Element
     *
     * @return mixed NULL if data isn't exists, otherwise string
     */
    function node_data($node)
    {
        return isset($node['data']) ? $node['data'] : null;
    }

    /**
     * Get data of attribute node
     *
     * @param array  $node      Element
     * @param string $attr      Attribute name
     * @param string $default   Default data if attribute node data isn't exists
     *
     * @return string
     */
    function node_attributes($node, $attr, $default = null)
    {
        return isset($node['attributes'][$attr]) ? $node['attributes'][$attr] : $default;
    }

    /**
     * Set data of attribute node
     *
     * @param array  &$node  Element
     * @param string $attr   Attribute name
     * @param string $value  Setted value
     *
     * @return void
     */
    function set_node_attributes(&$node, $attr, $value)
    {
        $node['attributes'][$attr] = $value;
    }

    /**
     * Get children node by name & index
     *
     * @param array  &$node   Element
     * @param string $name    Children name
     * @param int    $index   Index of children
     *
     * @return mixed  NULL if there isn't any element, Array element if index = -1, otherwise Simple element
     */
    function &node_children(&$node, $name = null, $index = -1)
    {
        $children = array();
        if (! $node) return $children;
        if (! $name) return $node['children'];
        foreach ($node['children'] as $child) {
            if ($child['name'] == $name) $children[] = $child;
        }
        if ($index > - 1) $children = isset($children[$index]) ? $children[$index] : null;
        return $children;
    }

    /**
     * Get last updated date
     *
     * @param string $fieldname   Fieldname
     *
     * @return string
     */
    function getLastUpdate($fieldname = null)
    {
        if (! $fieldname) $fieldname = 'created';
        $db = &JFactory::getDBO();
        $query = "SELECT `$fieldname` FROM #__content a ORDER BY `$fieldname` DESC LIMIT 1";
        $db->setQuery($query);
        $data = $db->loadObject();
        if ($data != null && $data->$fieldname) {
            $date = JFactory::getDate($data->$fieldname);
            //get timezone configured in Global setting
            $app = & JFactory::getApplication();
            // Get timezone offset
            $tz = $app->getCfg('offset');
            // Set timezone offset for date
            $date->setTimezone(new DateTimeZone($tz));
            //return by the format defined in language
            return $date->toFormat(JText::_('T3_DATE_FORMAT_LASTUPDATE'), true);
        }
        return;
    }

    /**
     * Logging
     *
     * @param string $msg        Message data
     * @param bool   $traceback  Indicate traceback or not
     *
     * @return void
     */
    function log($msg, $traceback = false)
    {
        $app = & JFactory::getApplication();
        $log_path = $app->getCfg('log_path');
        if (! is_dir($log_path)) $log_path = JPATH_ROOT . DS . 'logs';
        if (! is_dir($log_path)) @JFolder::create($log_path);
        if (! is_dir($log_path)) return false; //cannot create log folder
        //prevent http access to this location
        $htaccess = $log_path . DS . '.htaccess';
        if (! is_file($htaccess)) {
            $htdata = "Order deny,allow\nDeny from all\n";
            @JFile::write($htaccess, $htdata);
        }
        // Build log message
        $data = date('H:i:s') . "\n" . $msg;
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
        $log_file = $log_path . DS . 't3.log';
        if (! ($f = fopen($log_file, 'a'))) return false;
        fwrite($f, $data);
        fclose($f);
        return true;
    }

    /**
     * Get active item id
     *
     * @return int
     */
    function getItemid()
    {
        if (JVERSION < '1.6') {
            //for joomla 1.5 and 1.0
            global $Itemid;
            return $Itemid;
        }
        //for joomla 1.6
        $app = JFactory::getApplication();
        $menu = $app->getMenu();
        $active = $menu->getActive();
        $active_id = isset($active) ? $active->id : $menu->getDefault()->id;
        return $active_id;
    }

    /**
     * Add class into body tag
     *
     * @param string $class  Class name
     *
     * @return void
     */
    function addBodyClass($class)
    {
        $t3 = T3Template::getInstance($doc);
        $t3->addBodyClass($class);
    }

    /**
     * Check path is writable
     *
     * @param string $path  Folder/file path
     *
     * @return bool
     */
    function checkWriteable($path)
    {
        if (file_exists($path)) {
            $filepath = $path . '/tmp' . uniqid(mt_rand());
            if (!JFolder::create($filepath)) {
                return false;
            }
            JFolder::delete($filepath);
            return true;
        } else {
            $parent = dirname($path);
            if ($parent == $path) {
                return false;
            }
            return self::checkWriteable($parent);
        }
    }

    /**
     * Get file path of template element (profiles, layouts, themes)
     *
     * @param string $name  File name
     * @param string $type  Element name (profiles, layouts, themes,
     * @param string $ext   Extension of file
     *
     * @return string
     */
    function getFilePath($name, $type, $ext = '.ini')
    {
        $filepath = T3Path::path(T3_TEMPLATE) . DS . 'etc' . DS . $type . DS;
        // Check to sure that core & local folders were remove from template.
        // If etc/$type exists, considered as core & local folders were removed
        if (@is_dir($filepath)) {
            $file = $filepath . $name . $ext;
        } else {
            // Compatible: if etc/$type isn't extsts, check in core & local folders
            $path = 'etc' . DS . $type . DS . $name . $ext;
            $file = T3Path::path(T3_TEMPLATE_LOCAL) . DS . $path;
            if (!is_file($file)) {
                $file = T3Path::path(T3_TEMPLATE_CORE) . DS . $path;
            }
        }
        return $file;
    }

    /**
     * Get theme path
     *
     * @param string $name   Theme name
     * @param bool   $local  Indicate theme is local or not
     *
     * @return string
     */
    function getThemePath($name, $local = true)
    {
        $path = T3Path::path(T3_TEMPLATE);
        // Check template use newest folder structure or not
        // If themes is exists, considered as template use newest folder structure
        if (@is_dir($path.DS.'themes')) {
            $path .= DS.'themes'.DS.$name;
        } else {
            if ($local) {
                $path .= DS.'local'.DS.'themes'.DS.$name;
            } else {
                $path .= DS.'core'.DS.'themes'.DS.$name;
            }
        }
        return $path;
    }
}