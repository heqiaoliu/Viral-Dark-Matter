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

/**
 * Radio List Element
 *
 * @package  JAT3.Core.Element
 */
class JFormFieldGFonts extends JFormField
{
    /**
     * Element name
     *
     * @access  protected
     * @var     string
     */
    protected $type = 'Fonts';

    /**
     * Method to get the field input markup.
     *
     * @return  string  The field input markup.
     */
    function getInput()
    {
        t3_import('core/admin/util');

        $uri = str_replace(DS, "/", str_replace(JPATH_SITE, JURI::base(), dirname(__FILE__)));
        $uri = str_replace("/administrator", "", $uri);

        // Import css/js
        if (!defined('_GFONTS_ADDED')) {
            define('_GFONTS_ADDED', 1);

            echo "<link href=\"$uri/assets/css/Autocompleter.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
            echo "<link href=\"$uri/assets/css/gfonts.css\" rel=\"stylesheet\" type=\"text/css\" />\n";

            echo "<script type=\"text/javascript\" src=\"$uri/assets/js/autocompleter/Observer.js\"></script>\n";
            echo "<script type=\"text/javascript\" src=\"$uri/assets/js/autocompleter/Autocompleter.js\"></script>\n";
            echo "<script type=\"text/javascript\" src=\"$uri/assets/js/autocompleter/Autocompleter.Request.js\"></script>\n";
            echo "<script type=\"text/javascript\" src=\"$uri/assets/js/gfonts.js\"></script>\n";

            $layout = dirname(__FILE__).DS.'tmpl'.DS.'gfonts.php';
            if (file_exists($layout)) {
                ob_start();
                include $layout;
                $content = ob_get_contents();
                ob_end_clean();
                echo $content;
            }
        }

        $eid   = $this->id;
        $ename = $this->name;

        $template = T3_ACTIVE_TEMPLATE;
        $lists    = '';

        $lists .= "<div class=\"gfont-panel\">";
        $lists .= "  <span id=\"$eid-edit\"  class=\"ja-gfont-edit\">&nbsp;</span>";
        $lists .= "  <span id=\"$eid-family\" class=\"ja-gfont-family\"></span> ";
        $lists .= "  <span id=\"$eid-info\"   class=\"ja-gfont-info\"  ></span>";
        $lists .= "  <span id=\"$eid-custom\"  class=\"ja-gfont-custom\" ></span> ";
        $lists .= '</div>';
        $lists .= "<input type=\"hidden\" id=\"$eid\" name=\"$ename\" value=\"{$this->value}\" rel=\"gfonts\" />\n";

        return $lists;
    }
}