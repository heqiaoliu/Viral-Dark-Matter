<?php
/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// Ensure this file is being included by a parent file
defined('_JEXEC') or die( 'Restricted access' );

/**
 * Radio List Element
 *
 * @since      Class available since Release 1.2.0
 */
class JElementModules extends JElement
{
	/**
	 * Element name
	 *
	 * @access	protected
	 * @var		string
	 */
	var	$_name = 'Modules';

	function fetchElement( $name, $value, &$node, $control_name ) {
		$script = '';
		if (!defined ('_JA_PARAM_HELPER_MENU')) {
			define ('_JA_PARAM_HELPER_MENU', 1);
			
			$script = '
			<script type="text/javascript">
				window.addEvent( "load", function(){
					var obj = null;
					var options = document.adminForm.elements[\'params[mega_subcontent]\'];
					
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
			';
		}
		$db =& JFactory::getDBO();
		$query = "SELECT * FROM #__modules where client_id=0 ORDER BY title ASC";
		$db->setQuery($query);
		$groups = $db->loadObjectList();
		
		$groupHTML = array();	
		if ($groups && count ($groups)) {
			foreach ($groups as $v=>$t){
				$groupHTML[] = JHTML::_('select.option', $t->id, $t->title);
			}
		}
		$lists = JHTML::_('select.genericlist', $groupHTML, "params[".$name."][]", ' multiple="multiple"  size="10" ', 'value', 'text', $value);
		
		return $script.$lists; 
	}
} 