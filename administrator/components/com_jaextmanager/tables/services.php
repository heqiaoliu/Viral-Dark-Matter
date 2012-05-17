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

defined('_JEXEC') or die('Restricted access');

class TableServices extends JTable
{
	/** @var int */
	var $id = 0;
	/** @var string */
	var $ws_name = '';
	/** @var string - setting for all new services are remote*/
	var $ws_mode = 'remote';
	/** @var string */
	var $ws_uri = '';
	/** @var string */
	var $ws_user = '';
	/** @var string */
	var $ws_pass = '';
	/** @var string */
	//var $params='';
	/** @var tinyint */
	var $ws_default = 0;
	/** @var tinyint */
	var $ws_core = 0;


	function __construct(&$db)
	{
		parent::__construct('#__jaem_services', 'id', $db);
	}


	function bind($array, $ignore = '')
	{
		if (key_exists('params', $array) && is_array($array['params'])) {
			$registry = new JRegistry();
			$registry->loadArray($array['params']);
			$array['params'] = $registry->toString();
		}
		return parent::bind($array, $ignore);
	}


	function check()
	{
		$error = array();
		/** check error data */
		if ($this->ws_name == '')
			$error[] = JText::_("PLEASE_ENTER_SERVICE_NAME");
		if ($this->ws_mode == '')
			$error[] = JText::_("PLEASE_SELECT_SERVICE_MODE");
		if (!isset($this->id))
			$error[] = JText::_("ID_MUST_NOT_BE_NULL");
		elseif (!is_numeric($this->id))
			$error[] = JText::_("ID_MUST_BE_NUMBER");
		
		return $error;
	}
}
?>
