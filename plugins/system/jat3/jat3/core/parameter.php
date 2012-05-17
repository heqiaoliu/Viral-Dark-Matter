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
 * T3Parameter class
 *
 * @package JAT3.Core
 */
class T3Parameter extends JObject
{
    var $_params = array();
    var $_params_cookie = array();
    var $template = 'joom';
    var $template_info = null;

    /**
     * Constructor
     *
     * @param string $template        Template name
     * @param string $_params_cookie  Parameters of cookie
     */
    function __construct($template = 'joom', $_params_cookie = array())
    {
        $this->template = $template;
        $this->template_info = T3Common::get_template_params();
        if ($_params_cookie) {
            foreach ($_params_cookie as $k) {
                $this->_params_cookie[$k] = '';
            }
        }
        $this->getUserSetting();
    }

    /**
     * Get instance of object
     *
     * @param array $plgParams  Plugin params
     *
     * @return T3Parameter
     */
    function &getInstance($plgParams = null)
    {
        static $_instance = null;
        if (!isset($_instance)) {
            $template = T3_ACTIVE_TEMPLATE;
            $template_info = T3Common::get_template_params();
            //get cookie options
            $params_cookie = array();
            $params_cookie[] = 'ui';
            foreach (array_keys($template_info->toArray()) as $name) {
                if (preg_match('/^option_(.+)$/', $name, $matches) && $template_info->get($name)) {
                    $params_cookie[] = $matches[1];
                }
            }
            $_instance = new T3Parameter($template, $params_cookie);

            if ($plgParams) {
                foreach ($plgParams->toArray() as $key => $value)
                    $_instance->setParam($key, $value);
            }
        }
        return $_instance;
    }

    /**
     * Get user settings
     *
     * @return T3Parameter
     */
    function getUserSetting()
    {
        $exp = time() + 60 * 60 * 24 * 355;
        if (JRequest::getVar($this->template . '_tpl', '', 'COOKIE') == $this->template) {
            foreach ($this->_params_cookie as $k => $v) {
                $kc = $this->template . "_" . $k;
                if (JRequest::getVar($k, null, 'GET') !== null) {
                    $v = JRequest::getVar($k, null, 'GET');
                    setcookie($kc, $v, $exp, '/');
                } else if (JRequest::getVar($kc, '', 'COOKIE')) {
                    $v = JRequest::getVar($kc, '', 'COOKIE');
                } else {
                    $v = $this->getParam($k, '');
                }
                $this->setParam($k, $v);
            }

            //get custom T3 cookie variables
            $regex = '/^' . preg_quote($this->template . "_t3custom_") . '(.+)$/';
            foreach ($_COOKIE as $name => $value) {
                if (preg_match($regex, $name, $matches)) {
                    $this->_params_cookie[$matches[1]] = $value;
                }
            }
        } else {
            setcookie($this->template . '_tpl', $this->template, $exp, '/');
        }
        return $this;
    }

    /**
     * Get parameter value
     *
     * @param string $param    Parameter name
     * @param string $default  Default value
     *
     * @return string  Parameter value
     */
    function getParam($param, $default = '')
    {
        if (isset($this->_params_cookie[$param]) && $this->_params_cookie[$param]) {
            return $this->_params_cookie[$param];
        }
        if ($this->template_info->get($param, null) != null) return $this->template_info->get($param);
        if ($this->template_info->get('setting_' . $param, null) != null) return $this->template_info->get('setting_' . $param);
        return $default;
    }

    /**
     * Set value to parameter
     *
     * @param string $param  Parameter name
     * @param string $value  Setted value
     *
     * @return void
     */
    function setParam($param, $value)
    {
        $this->_params_cookie[$param] = $value;
    }

    /**
     * Get parameter value
     *
     * @param string $param    Parameter name
     * @param string $default  Default value
     *
     * @return string  Parameter value
     */
    function _getParam($param, $default = '')
    {
        $params = T3Parameter::getInstance();
        return $params->getParam($param, $default);
    }

    /**
     * Get parameter value
     *
     * @param string $param    Parameter name
     * @param string $default  Default value
     *
     * @return string  Parameter value
     */
    function get($param, $default = '')
    {
        return T3Parameter::_getParam($param, $default);
    }

    /**
     * Set value to parameter
     *
     * @param string $param  Parameter name
     * @param string $value  Setted value
     *
     * @return void
     */
    function _setParam($param, $value)
    {
        $params = T3Parameter::getInstance();
        return $params->setParam($param, $value);
    }
}