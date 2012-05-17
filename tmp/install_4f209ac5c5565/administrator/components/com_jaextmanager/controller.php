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

defined('_JEXEC') or die('Restricted access');

jimport('joomla.application.component.controller');

class JaextmanagerController extends JController
{


	function display()
	{
		$view = JRequest::getVar("view");
		if (empty($view)) {
			JRequest::setVar("view", "default");
		}
		parent::display();
	}


	function getLink()
	{
		return "index.php?option=" . JACOMPONENT;
	}
}
