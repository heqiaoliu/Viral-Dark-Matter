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
class JElementUpdategfont extends JElement {
	
	function fetchElement( $name, $value, &$node, $control_name ) {
		$msg = JText::_('Do you want update google font?');		
		
		$result = "<button type=\"button\" onclick=\"jat3admin.updateGfont(this,'{$msg}');\">Update</button>";
		
		return $result;
	}
}