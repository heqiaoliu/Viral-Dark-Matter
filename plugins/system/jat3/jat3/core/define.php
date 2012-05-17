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

define('T3_ACTIVE_TEMPLATE', T3Common::get_active_template());
define('T3_BASE', 'plugins/system/jat3/jat3');
define('T3_CORE', T3_BASE . '/core');
define('T3_BASETHEME', T3_BASE . '/base-themes/default');
define('T3_TEMPLATE', 'templates/' . T3_ACTIVE_TEMPLATE);
define('T3_TEMPLATE_CORE', 'templates/' . T3_ACTIVE_TEMPLATE . '/core');
define('T3_TEMPLATE_LOCAL', 'templates/' . T3_ACTIVE_TEMPLATE . '/local');

define('T3_TOOL_COLOR', 'color');
define('T3_TOOL_SCREEN', 'screen');
define('T3_TOOL_FONT', 'font');
define('T3_TOOL_MENU', 'menu');
define('T3_TOOL_THEMES', 'themes');
define('T3_TOOL_LAYOUTS', 'layouts');

