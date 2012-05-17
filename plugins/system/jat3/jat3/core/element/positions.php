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
 * Radio List Element
 *
 * @package  JAT3.Core.Element
 */
class JFormFieldPositions extends JFormField
{
    /**
     * Element name
     *
     * @access    protected
     * @var        string
     */
    protected $type = 'Positions';

    /**
     * Method to get the field input markup.
     *
     * @return  string  The field input markup.
     */
    function getInput()
    {
        if (!defined('_JA_PARAM_HELPER')) {
            define('_JA_PARAM_HELPER', 1);
            $uri = str_replace(DS, "/", str_replace(JPATH_SITE, JURI::base(), dirname(__FILE__)));
            $uri = str_replace("/administrator", "", $uri);
            $javersion = new JVersion();
            if ($javersion->RELEASE == '1.7') {
                JHtml::_('behavior.framework', true);
            } else {
                JHTML::_('behavior.mootools');
            }
            JHTML::stylesheet($uri.'/assets/css/japaramhelper.css');
            JHTML::script($uri.'/assets/js/japaramhelper.js');

            ?>
            <script type="text/javascript">
                window.addEvent( "load", function(){
                    var obj = null;
                    var options = document.adminForm.elements['jform[params][mega_subcontent]'];
                    for(var i=0; i<options.length; i++){
                        options[i].addEvent("click", function(){
                            updateFormMenu(this, true);
                        });
                        if(options[i].checked){
                            obj = options[i];
                        }
                    }
                    updateFormMenu(obj, false);
                } );
            </script>
            <?php
        }

        $db =& JFactory::getDBO();
        $query = "SELECT DISTINCT position FROM #__modules ORDER BY position ASC";
        $db->setQuery($query);
        $groups = $db->loadObjectList();

        $groupHTML = array();
        if ($groups && count($groups)) {
            foreach ($groups as $v=>$t) {
                $groupHTML[] = JHTML::_('select.option', $t->position, $t->position);
            }
        }
        $lists = JHTML::_('select.genericlist', $groupHTML, $this->name.'[]', ' multiple="multiple"  size="10" ', 'value', 'text', $this->value);

        return $lists;
    }
}