<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
# Author: JoomlArt.com
# Websites: http://www.joomlart.com - http://www.joomlancers.com.
# ------------------------------------------------------------------------
*/

defined ( '_JEXEC' ) or die ( 'Restricted access' );

jimport ( 'joomla.application.component.controller' );

class JaextmanagerController extends JController {
  function display() {
    $view = JRequest::getVar("view");
    if (empty($view)) {
      JRequest::setVar("view", "default");
    }
    parent::display();
  }

  function getLink() {
    return "index.php?option=".JACOMPONENT;
  }
}
