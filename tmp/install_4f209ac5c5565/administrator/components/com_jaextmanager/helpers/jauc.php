<?php
/**
 * ------------------------------------------------------------------------
 * JA Extensions Manager
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');

jimport('joomla.application.component.helper');
jimport('joomla.filesystem.file');

class JaextmanagerHelper extends JComponentHelper
{
	var $params;
	var $services;
	var $defaultService;


	function JaextmanagerHelper($params, $services)
	{
		$this->params = $params;
		$this->services = $services;
		
		foreach ($services as $id => $sv) {
			if ($id == 0 || $sv->ws_default) {
				$this->defaultService = $sv;
			}
		}
	}


	function getServiceInfo($serviceId)
	{
		$obj = null;
		foreach ($this->services as $id => $sv) {
			if ($sv->id == $serviceId) {
				$obj = $sv;
				break;
			}
		}
		if ($obj === null) {
			$obj = $this->defaultService;
		}
		return $obj;
	}


	function loadExtension($obj, $type)
	{
		if (!is_object($obj) || !isset($obj->type) || !isset($obj->id)) {
			return false;
		}
		$obj->extId = $obj->type . "-" . $obj->id; //use type+id => unique id for each product of all extension types
		$obj->coreVersion = 'j15'; //this com is worked on joomla 1.5.x, so all extensions have same core version with it.
		$obj->serviceKey = $obj->extId . "-service";
		
		//service setting
		$serviceId = $this->params->get($obj->serviceKey);
		$service = $this->getServiceInfo($serviceId);
		
		$obj->ws_id = $serviceId;
		$obj->ws_name = $service->ws_name;
		$obj->ws_mode = $service->ws_mode;
		$obj->ws_uri = $service->ws_uri;
		$obj->ws_user = $service->ws_user;
		$obj->ws_pass = $service->ws_pass;
		//
		

		$method = '_load' . ucfirst(strtolower($type));
		if (!method_exists($this, $method))
			return false;
		return $this->$method($obj);
	}


	function _parseExtensionInfo($obj, $xmlfile)
	{
		if (JFile::exists($xmlfile)) {
			if ($data = JApplicationHelper::parseXMLInstallFile($xmlfile)) {
				$obj->configFile = $xmlfile;
				
				foreach ($data as $key => $value) {
					$obj->$key = $value;
				}
				if (!empty($obj->folder) && empty($obj->group)) {
					$obj->group = $obj->folder;
				}
				return $obj;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}


	function _loadModule($obj)
	{
		$installDir = ($obj->client_id) ? JPATH_ADMINISTRATOR : JPATH_ROOT;
		$installDir .= DS . 'modules' . DS . $obj->extKey . DS;
		$installDir = JPath::clean($installDir);
		if (JFolder::exists($installDir) === false) {
			return false;
		}
		
		$xmlfile = $installDir . $obj->extKey . ".xml";
		return $this->_parseExtensionInfo($obj, $xmlfile);
	}


	function _loadPlugin($obj)
	{
		$installDir = JPATH_ROOT . DS . 'plugins' . DS . $obj->folder . DS;
		if (JFile::exists($installDir . $obj->extKey . ".php") === false) {
			return false;
		}
		
		$xmlfile = $installDir . $obj->extKey . ".xml";
		return $this->_parseExtensionInfo($obj, $xmlfile);
	}


	function _loadTemplate($obj)
	{
		$installDir = ($obj->client_id) ? JPATH_ADMINISTRATOR : JPATH_ROOT;
		$installDir .= DS . 'templates' . DS . $obj->extKey . DS;
		$installDir = JPath::clean($installDir);
		if (JFolder::exists($installDir) === false) {
			return false;
		}
		
		$xmlfile = $installDir . "templateDetails.xml";
		return $this->_parseExtensionInfo($obj, $xmlfile);
	}


	function _loadComponent($obj)
	{
		/* Get the component base directory */
		$adminDir = JPATH_ADMINISTRATOR . DS . 'components' . DS . $obj->extKey . DS;
		$siteDir = JPATH_SITE . DS . 'components' . DS . $obj->extKey . DS;
		
		$xmlfiles = JFolder::files($adminDir, '.xml$', 1, true);
		$found = false;
		if (!empty($xmlfiles)) {
			foreach ($xmlfiles as $xmlfile) {
				if ($data = JApplicationHelper::parseXMLInstallFile($xmlfile)) {
					$found = true;
					break;
				}
			}
		}
		if (!$found) {
			$xmlfiles = JFolder::files($siteDir, '.xml$', 1, true);
			if (!empty($xmlfiles)) {
				foreach ($xmlfiles as $xmlfile) {
					if ($data = JApplicationHelper::parseXMLInstallFile($xmlfile)) {
						$found = true;
						break;
					}
				}
			}
		}
		
		if (isset($xmlfile) && JFile::exists($xmlfile)) {
			return $this->_parseExtensionInfo($obj, $xmlfile);
		} else {
			return false;
		}
	}
}
