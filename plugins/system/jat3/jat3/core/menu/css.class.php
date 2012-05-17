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

if (!defined('_JA_CSS_MENU_CLASS')) {
    define('_JA_CSS_MENU_CLASS', 1);
    include_once dirname(__FILE__) . DS . "base.class.php";

    /**
     * JAMenuCSS class
     *
     * @package JAT3.Core.Menu
     */
    class JAMenuCSS extends JAMenuBase
    {
        /**
         * Echo markup before a menu markup
         *
         * @param int $startlevel  Start menu level
         * @param int $endlevel    End menu level
         *
         * @return void
         */
        function beginMenu($startlevel = 0, $endlevel = 10)
        {
        }

        /**
         * Echo markup after a menu items markup
         *
         * @param int $pid    Menu item id
         * @param int $level  Menu level
         *
         * @return void
         */
        function beginMenuItems($pid = 0, $level = 0)
        {
            if ($level == 0)
                echo "<ul id=\"ja-cssmenu\" class=\"clearfix\">\n";
            else
                echo "<ul>";
        }

        /**
         * Echo markup after a menu markup
         *
         * @param int $startlevel  Start menu level
         * @param int $endlevel    End menu level
         *
         * @return void
         */
        function endMenu($startlevel = 0, $endlevel = 10)
        {
        }

        /**
         * Check having submenu
         *
         * @param int $level  Level
         *
         * @return bool  FALSE
         */
        function hasSubMenu($level)
        {
            return false;
        }

        /**
         * Echo markup before menu item markup
         *
         * @param object $row    Menu item
         * @param int    $level  Level
         * @param string $pos    Position
         *
         * @return void
         */
        function beginMenuItem($row = null, $level = 0, $pos = '')
        {
            /*
            $active = $this->genClass ($tmp, $level, $pos);
            $active = in_array($row->id, $this->open);
            $active = ($level?"":"menu-item{$row->_idx}"). ($active?" active":"").($pos?" $pos-item":"");
            */
            $active = $this->genClass($row, $level, $pos);
            if ($level == 0) {
                $active = preg_replace('/haschild/', 'havechild', $active);
            } else {
                $active = preg_replace('/haschild/', 'havesubchild', $active);
            }
            if ($level == 0 && $level < $this->getParam('endlevel') && @$this->children[$row->id]) {
                echo "<li class=\"havechild {$active}\">";
            } elseif ($level > 0 && $level < $this->getParam('endlevel') && @$this->children[$row->id]) {
                echo "<li class=\"havesubchild {$active}\">";
            } else {
                echo "<li " . (($active) ? "class=\"$active\"" : "") . ">";
            }
        }

        /**
         * Echo markup after menu item markup
         *
         * @param object $mitem  Menu item
         * @param int    $level  Level
         * @param string $pos    Position
         *
         * @return void
         */
        function endMenuItem($mitem = null, $level = 0, $pos = '')
        {
            echo "</li> \n";
        }

        /**
         * Generate menu item
         *
         * @param object $item   Menu item
         * @param int    $level  Level
         * @param string $pos    Position
         * @param int    $ret    Return or not
         *
         * @return string  Menu item markup
         */
        function genMenuItem($item, $level = 0, $pos = '', $ret = 0)
        {
            //if ($level) return parent::genMenuItem($item, $level, '', $ret);
            //else
            return parent::genMenuItem($item, $level, $pos, $ret);
        }
    }
}
?>