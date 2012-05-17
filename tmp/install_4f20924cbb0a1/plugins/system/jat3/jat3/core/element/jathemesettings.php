<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */

// Ensure this file is being included by a parent file
defined('_JEXEC') or die( 'Restricted access' );

/**
 * Radio List Element
 *
 * @since      Class available since Release 1.2.0
 */
class JFormFieldJathemesettings extends JFormField
{
	/**
	 * The form field type.
	 *
	 * @var		string
	 * @since	1.6
	 */
	protected $type = 'Jathemesettings';

	function getInput() {
		t3_import('core/admin/util');
		
		$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(__FILE__) ));
		$uri = str_replace("/administrator", "", $uri);
		if (!defined ('_JA_THEME')) {
			define ('_JA_THEME', 1);
						
			$html = "<link href=\"$uri/assets/css/jathemesettings.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
			$html .= "<script type=\"text/javascript\" src=\"$uri/assets/js/jathemesettings.js\"></script>\n";
			echo $html;
		}
		
		$objutil = new JAT3_AdminUtil();
		$template  = $objutil->template;
		$themes = $objutil->getThemes($template);
		
		$value = $this->value;
		$name = $this->fieldname;
		
		if($value && $themes){
			if( ( !isset($themes['core']) || (isset($themes['core']) && !in_array($value, $themes['core']))) && ( !isset($themes['local']) || ( isset($themes['local']) && !in_array($value, $themes['local']))) ){ 			
				$value = isset($themes['local'][0])?$themes['local'][0]:$themes['core'][0];
			}
		}
		
		$layout = dirname(__FILE__).DS.'tmpl'.DS.'jathemesettings.php';
		if (file_exists($layout)) {
			ob_start();
			require $layout;
			$content = ob_get_clean();
			return $content;
		}
		return '';
	}
			
} 