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

if (!defined('_JA_SPLIT_MENU_CLASS')) {
    define('_JA_SPLIT_MENU_CLASS', 1);
    include_once dirname(__FILE__) . DS . "base.class.php";

    /**
     * JAMenuSplit class
     *
     * @package JAT3.Core.Menu
     */
    class JAMenuSplit extends JAMenuBase
    {
        /**
         * JAMenuMega class
         *
         * @param array &$params  An array parameter
         *
         * @package JAT3.Core.Menu
         */
        function __construct(&$params)
        {
            parent::__construct($params);
            // To show sub menu on a separated place
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
            if ($startlevel == 0) {
                echo "<div id=\"ja-splitmenu\" class=\"mainlevel clearfix\">\n";
            } else {
                echo "<div class=\"sublevel\">\n";
            }
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
            echo "\n</div>";
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
            if ($level == 1)
                echo "<ul class=\"active\">";
            else
                echo "<ul>";
        }

        /**
         * Generate menu
         *
         * @param int $startlevel  Start menu level
         * @param int $endlevel    End menu level
         *
         * @return string  The generate menu rendering
         */
        function genMenu($startlevel = 0, $endlevel = 10)
        {
            if ($startlevel == 0)
                parent::genMenu(0, 0);
            else
                parent::genMenu($startlevel, $endlevel);
        }

    }
}
?>
