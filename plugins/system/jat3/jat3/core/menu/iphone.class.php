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

if (!defined('_JA_IPHONE_MENU_CLASS')) {
    define('_JA_IPHONE_MENU_CLASS', 1);
    include_once dirname(__FILE__) . DS . "base.class.php";

    /**
     * JAMenuIphone class
     *
     * @package JAT3.Core.Menu
     */
    class JAMenuiphone extends JAMenuBase
    {

        /**
         * Constructor
         *
         * @param array &$params  An array parameter
         */
        function __construct(&$params)
        {
            parent::__construct($params);
            //To show sub menu on a separated place
            $this->showSeparatedSub = true;
        }

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
         * Echo markup before menu items markup
         *
         * @param int $pid    Menu item id
         * @param int $level  Menu item level
         *
         * @return void
         */
        function beginMenuItems($pid = 0, $level = 0)
        {
            if ($pid && isset($this->items[$pid])) {
                echo "<ul id=\"nav$pid\" title=\"{$this->items[$pid]->name}\" class=\"toolbox\">";
            } else {
                echo "<ul id=\"ja-iphonemenu\" title=\"Menu\" class=\"toolbox\">";
            }
        }

        /**
         * Generate menu item
         *
         * @param object $item   Menu item
         * @param int    $level  Level of menu item
         * @param string $pos    Position of menu item
         * @param int    $ret    Return or show data
         *
         * @return mixed  void if ret = 1, otherwise string data of  menu item generating
         */
        function genMenuItem($item, $level = 0, $pos = '', $ret = 0)
        {
            $data = parent::genMenuItem($item, $level, $pos, true);
            if (@$this->children[$item->id]) {
                $tmp = $item;
                $data .= "<a class=\"ja-folder\" href=\"#nav{$tmp->id}\" title=\"{$tmp->name}\">&gt;</a>";
            }
            if ($ret)
                return $data;
            else
                echo $data;
        }

        /**
         * Generate menu items
         *
         * @param int $pid    Menu item
         * @param int $level  Menu level
         *
         * @return void
         */
        function genMenuItems($pid, $level)
        {
            if (@$this->children[$pid]) {
                $this->beginMenuItems($pid, $level);
                $i = 0;
                foreach ($this->children[$pid] as $row) {
                    $pos = ($i == 0) ? 'first' : (($i == count($this->children[$pid]) - 1) ? 'last' : '');

                    $this->beginMenuItem($row, $level, $pos);
                    $this->genMenuItem($row, $level, $pos);
                    // show menu with menu expanded - submenus visible
                    $i++;

                    $this->endMenuItem($row, $level, $pos);
                }
                $this->endMenuItems($pid, $level);

                foreach ($this->children[$pid] as $row) {
                    if ($level < $this->getParam('endlevel')) $this->genMenuItems($row->id, $level + 1);
                }
            }
        }

    }
}
?>
