<?php
/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
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
		if (!isset($obj->coreVersion)) {
			$obj->coreVersion = 'j17'; //this component is written for joomla 1.7.x, so all extensions have a default core version is joomla 1.7.
		}
		$obj->serviceKey = $obj->extId;
		
		//service setting
		$extId = $obj->extId;
		
		$serviceId = (isset($this->params->$extId)) ? $this->params->$extId->service_id : '';
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
			//$data = JApplicationHelper::parseXMLInstallFile($xmlfile)
			

			if ($data = $this->parseXMLInstallFile($xmlfile)) {
				$obj->configFile = $xmlfile;
				
				foreach ($data as $key => $value) {
					$obj->$key = $value;
				}
				if (!empty($obj->folder) && empty($obj->group)) {
					$obj->group = $obj->folder;
				}
				//echo $obj->coreVersion;
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
		//new stuture for plugins folder from 1.6
		//each plugin will be stored at individual folder
		$installDir = JPATH_ROOT . DS . 'plugins' . DS . $obj->folder . DS . $obj->extKey . DS;
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


	/**
	 * This function is cloned from function JApplicationHelper::parseXMLInstallFile($xmlfile)
	 *
	 * @param unknown_type $file
	 * @return unknown
	 */
	function parseXMLInstallFile($path)
	{
		// Read the file to see if it's a valid component XML file
		if (!$xml = JFactory::getXML($path)) {
			return false;
		}
		
		/*
		 * Check for a valid XML root tag.
		 *
		 * Should be 'install', but for backward compatability we will accept 'extension'.
		 * Languages are annoying and use 'metafile' instead
		 */
		if ($xml->getName() != 'install' && $xml->getName() != 'extension' && $xml->getName() != 'metafile') {
			unset($xml);
			return false;
		}
		
		$data = array();
		
		$coreVersion = (string) $xml->attributes()->version;
		
		$data['legacy'] = ($xml->getName() == 'mosinstall' || $xml->getName() == 'install');
		
		$data['name'] = (string) $xml->name;
		
		$data['coreVersion'] = jaGetCoreVersion($coreVersion, $data['name']);
		
		// check if we're a language if so use that
		$data['type'] = $xml->getName() == 'metafile' ? 'language' : (string) $xml->attributes()->type;
		
		$data['creationDate'] = ((string) $xml->creationDate) ? (string) $xml->creationDate : JText::_('UNKNOWN');
		$data['author'] = ((string) $xml->author) ? (string) $xml->author : JText::_('UNKNOWN');
		
		$data['copyright'] = (string) $xml->copyright;
		$data['authorEmail'] = (string) $xml->authorEmail;
		$data['authorUrl'] = (string) $xml->authorUrl;
		$data['version'] = (string) $xml->version;
		$data['description'] = (string) $xml->description;
		$data['group'] = (string) $xml->group;
		
		return $data;
	}
}
