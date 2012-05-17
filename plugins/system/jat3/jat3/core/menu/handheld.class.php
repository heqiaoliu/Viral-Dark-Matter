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

if (!defined('_JA_HANDHELD_MENU_CLASS')) {
    define('_JA_HANDHELD_MENU_CLASS', 1);
    include_once dirname(__FILE__) . DS . "base.class.php";

    /**
     * JAMenuHandheld class
     *
     * @package JAT3.Core.Menu
     *
     */
    class JAMenuHandheld extends JAMenuBase
    {
        /**
         * Constructor
         *
         * @param array &$params  An array parameter
         *
         * @return void
         */
        function __construct(&$params)
        {
            parent::__construct($params);
            //To show sub menu on a separated place
            $this->showSeparatedSub = true;
        }

        /**
         * Echo markup before menu markup
         *
         * @param int $startlevel  Start menu level
         * @param int $endlevel    End menu level
         *
         * @return void
         */
        function beginMenu($startlevel = 0, $endlevel = 10)
        {
            echo "<select id=\"handheld-nav\" onchange=\"window.location.href=this.value;\">";
        }

        /**
         * Echo markup after menu markup
         *
         * @param int $startlevel  Start menu level
         * @param int $endlevel    End menu level
         *
         * @return void
         */
        function endMenu($startlevel = 0, $endlevel = 10)
        {
            echo "</select>";
        }

        /**
         * Echo markup before menu item makrup
         *
         * @param object $mitem  Menu item object
         * @param int    $level  Menu level
         * @param string $pos    Position
         *
         * @return void
         */
        function beginMenuItem($mitem = null, $level = 0, $pos = '')
        {
        }

        /**
         * Echo markup after menu item makrup
         *
         * @param object $mitem  Menu item object
         * @param int    $level  Menu level
         * @param string $pos    Position
         *
         * @return void
         */
        function endMenuItem($mitem = null, $level = 0, $pos = '')
        {
        }

        /**
         * Echo markup before menu items makrup
         *
         * @param int $pid    Menu id
         * @param int $level  Menu level
         *
         * @return void
         */
        function beginMenuItems($pid = 0, $level = 0)
        {
        }

        /**
         * Echo markup after menu items makrup
         *
         * @param int $pid    Menu id
         * @param int $level  Menu level
         *
         * @return void
         */
        function endMenuItems($pid = 0, $level = 0)
        {
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
            $tmp = $item;

            $space = '---';
            $prespace = '';
            for ($i = 0; $i < $level; $i++)
                $prespace .= $space;

            $txt = $prespace . $tmp->name;

            if ($tmp->type == 'menulink') {
                $menu = &JSite::getMenu();
                $alias_item = clone ($menu->getItem($tmp->query['Itemid']));
                if ($alias_item) {
                    $tmp->url = $alias_item->link;
                }
            }

            $active = in_array($tmp->id, $this->open);
            $selected = $active ? "selected=\"selected\"" : "";
            $data = "<option " . $selected . " value=\"$tmp->url\">$txt</option>";

            if ($ret)
                return $data;
            else
                echo $data;
        }
    }
}
?>
