<?php
/**
 * ------------------------------------------------------------------------
 * JA Typo plugin
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');

jimport( 'joomla.plugin.plugin' );

/**
 * Edit Readmore button
 *
 * @package Editors-xtd
 * @since 1.5
 */
class plgSystemJATypo extends JPlugin
{
	/**
	 * Constructor
	 *
	 * For php4 compatability we must not use the __constructor as a constructor for plugins
	 * because func_get_args ( void ) returns a copy of all passed arguments NOT references.
	 * This causes problems with cross-referencing necessary for the observer design pattern.
	 */
	function plgSystemJATypo(& $subject, $config)
	{
		parent::__construct($subject, $config);
	}
	function allowUseTypo()
	{
		global $mainframe;
		$option = JRequest::getVar("option","");
		$format = JRequest::getVar("format","");
		if( $option == "com_content" && $format == "feed"){
			return false;
		}
		return true;
	}
	/**
	 * onAfterRoute event
	 * Add mootools, css and js
	 */
	function onAfterRoute()
	{
		global $mainframe;
		if( $this->allowUseTypo() ){
			$doc 		=& JFactory::getDocument();
			
			$base_url = JURI::base();
			if($mainframe->isAdmin()) {
				$base_url = dirname ($base_url);
			}
			JHTML::_('behavior.mootools');
			$doc->addScript($base_url.'/plugins/system/jatypo/assets/script.js');
			$doc->addStylesheet($base_url.'/plugins/system/jatypo/assets/style.css');
			$doc->addStylesheet($base_url."/plugins/system/jatypo/typo/typo.css");
		}
	}

	/**
     * load template for typo 
     * 
     * @param string $template
     */
	
	function loadTemplate ($template) {
		if (!is_file ($template)) return '';
		$buffer = ob_get_clean();
		ob_start();
		include ($template);
		$content = ob_get_clean();
		ob_start();
		echo $buffer;
		return $content;
	}
}