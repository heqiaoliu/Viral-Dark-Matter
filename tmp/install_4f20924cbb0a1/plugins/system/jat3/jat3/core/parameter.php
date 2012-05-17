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

/*
adapt with Drupal system
*/

class T3Parameter extends JObject {
	var $_params = array();
	var $_params_cookie = array();
	var $template = 'joom';
	var $template_info = null;
	
	function __construct($template='joom', $_params_cookie=array()) {
		$this->template = $template;
		$this->template_info = T3Common::get_template_params();
		if($_params_cookie) {
			foreach ($_params_cookie as $k) {
				$this->_params_cookie[$k] = '';
			}
		}
		$this->getUserSetting();
	}
	
	function &getInstance ($plgParams = null) {
		static $_instance = null;
		if (!isset($_instance)) {
			$template = T3_ACTIVE_TEMPLATE;
			$template_info = T3Common::get_template_params();
			//get cookie options
			$params_cookie = array();
			$params_cookie [] = 'ui';
			foreach (array_keys ($template_info->toArray()) as $name) {
				if (preg_match ('/^option_(.+)$/', $name, $matches) && $template_info->get($name)) {
					$params_cookie[] = $matches[1];
				}
			}
			$_instance = new T3Parameter ($template, $params_cookie);
			
			if ($plgParams) {
				foreach ($plgParams->toArray() as $key=>$value) $_instance->setParam ($key, $value);
			}
		}
		return $_instance;
	}
	
	function getuserSetting () {
		$exp = time() + 60*60*24*355;
		if (JRequest::getVar($this->template.'_tpl', '', 'COOKIE') == $this->template){
			foreach($this->_params_cookie as $k=>$v) {
				$kc = $this->template."_".$k;
				if (JRequest::getVar($k, null, 'GET') !== null) {
					$v = JRequest::getVar($k, null, 'GET');
					setcookie ($kc, $v, $exp, '/');
				}else if (JRequest::getVar($kc,'','COOKIE')){
					$v = JRequest::getVar($kc,'','COOKIE');
				} else {
					$v = $this->getParam ($k, '');
				}
				$this->setParam($k, $v);
			}
			
			//get custom T3 cookie variables
			$regex = '/^'.preg_quote($this->template."_t3custom_").'(.+)$/';
			foreach ($_COOKIE as $name=>$value) {
				if (preg_match ($regex, $name, $matches)) {
					$this->_params_cookie[$matches[1]] = $value;
				}
			}
		}else{
			setcookie ($this->template.'_tpl', $this->template, $exp, '/');
		}
		return $this;
	}

	function getParam ($param, $default='') {
		if (isset($this->_params_cookie[$param]) && $this->_params_cookie[$param]) {
			return $this->_params_cookie[$param];
		}
		if ($this->template_info->get($param, null) != null) return $this->template_info->get($param);
		if ($this->template_info->get('setting_'.$param, null) != null) return $this->template_info->get('setting_'.$param);
		return $default;
	}

	function setParam ($param, $value) {
		$this->_params_cookie[$param] = $value;
	}
	
	function _getParam ($param, $default='') {
		$params = T3Parameter::getInstance();
		return $params->getParam ($param, $default);
	}
	
	function get ($param, $default='') {
		return T3Parameter::_getParam ($param, $default);
	}
		
	function _setParam ($param, $value) {
		$params = T3Parameter::getInstance();
		return $params->setParam ($param, $value);
	}

	function getKey ($name, $level=10) {
		//$uri = JURI::getInstance();		
		//$string = $uri->getQuery();
		$string = $name;
		if ($level > 0)	$string .= JRequest::getURI();
		if ($level > 1) {
			$params = T3Parameter::getInstance();
			$string .= T3_TOOL_THEMES."=".$params->getParam (T3_TOOL_THEMES);
			$string .= T3_TOOL_LAYOUTS."=".$params->getParam (T3_TOOL_LAYOUTS);
		}
		if ($level > 2) {
			t3import ('core.libs.Browser');
			$browser = new Browser();
			$string .= $browser->getBrowser().":".$browser->getVersion();
		}
		if ($level > 3) {	
			$params = T3Parameter::getInstance();
			foreach($params->_params_cookie as $k=>$v)
				$string .= $k."=".$v;
		}
		return md5 ($string);
	}
}