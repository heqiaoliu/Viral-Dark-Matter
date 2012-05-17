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
 * Enable, re-order the plugin to last position after install
 *
 * @package JAT3
 */
class plgSystemJAT3InstallerScript
{
    function postflight($type, $parent)
    {
        $db = JFactory::getDBO();
        //Get this plugin groupn, element
        $group = 'system';
        $element = 'jat3';
        //enable plugin and update ordering to 1000 (great enough to be last ordering)
        $query = 'update `#__extensions`'
               . ' set `ordering`=1000, `enabled`=1'
               . ' WHERE folder = ' . $db->Quote($group)
               . ' AND element = ' . $db->Quote($element);
        $db->setQuery($query);
        try {
            $db->Query();
        } catch ( JException $e ) {
            // Return warning message that cannot update order
            echo JText::_('JAT3_INSTALL_FAIL_UPDATE_ORDER');
        }
    }
}