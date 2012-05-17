<?php
/**
 * ------------------------------------------------------------------------
 * plg_jatypobutton
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

defined( '_JEXEC' ) or die( 'Restricted access' );

// define directory separator short constant
if (!defined( 'DS' )) {
	define( 'DS', DIRECTORY_SEPARATOR );
}


jimport('joomla.event.plugin');
jimport('joomla.plugin.plugin');
/**
 * Editor JAComment Off button plugin
 */
class plgButtonJaTypoButton extends JPlugin
{
	function plgButtonJaTypoButton(& $subject, $config)
	{
		parent::__construct($subject, $config);
	}

	function onDisplay($name)
	{
		
		$doc =& JFactory::getDocument();

		$base_url = JURI::base();
		global $mainframe;		
		if($mainframe->isAdmin()) {
			$base_url = dirname ($base_url);
		}
		
		$current_url = 'index.php?'.$_SERVER['QUERY_STRING'];
		
		$str_data = '/task=/';
		if (!preg_match($str_data, $current_url)) {
			$current_url = $current_url."&task=add";
		}
		
		if (JRequest::getCmd('jatypo','')) {
			
			$tmpl = dirname(dirname (__FILE__)).DS.'system'.DS.'jatypo'.DS.'tmpl'.DS.'default.php';	
			$html = $this->loadTemplate ($tmpl);			
			echo $html;
			exit;			
		}
		//Typo css into editor (tinymce)
		
		$editor_form = $name."_ifr";
		$linkcss = $base_url."/plugins/system/jatypo/typo/typo.css";
		
		$jaJS = " 
		var typoeditor = '$name';
		
		function insertTypoHTML(editor) {
			jInsertEditorText(editor, '$name');
		}
		
		function isBrowserIEJA() {
			return navigator.appName==\"Microsoft Internet Explorer\";
		}

		function IeCursorFixJA() {
			if (isBrowserIEJA()) {
				tinyMCE.execCommand('mceInsertContent', false, '');
				global_ie_bookmark = tinyMCE.activeEditor.selection.getBookmark(false);
			}
			return true;
		}
		
		function LoadJSEditor() {
			var doc = $('$editor_form')?($('$editor_form').contentWindow?$('$editor_form').contentWindow.document:$('$editor_form').contentDocument):null;
			if (doc) {
				var head = doc.getElementsByTagName('head')[0];
				var css = doc.createElement ('link');
				css.rel = 'stylesheet';
				css.type = 'text/css';
				css.href = '$linkcss';
				head.appendChild (css);		
			}
		}";		
		
		$doc->addScriptDeclaration($jaJS);		
		
		JHTML::_('behavior.modal');
		
		$button = new JObject();
		$button->set('onclick', 'IeCursorFixJA();  return false;');
		//if (window.event) {window.event.cancelBubble = true;} else {arguments[0].stopPropagation();} jatypo.position(this, \''.$name.'\');
		$button->set('modal', true);
		$button->set('text', 'JA Typo');
		/*$button->set('name', 'button2-right jatypo-btn');*/
		$button->set('name', 'blank');
		$button->set('link', $current_url.'&jatypo=show&editor_form='.$name);
		$button->set('options', "{handler: 'iframe', size: {x: 730, y: 610}}");

		return $button;
	}
	
	function curPageURL() {
		$pageURL = 'http';
		if ($_SERVER["HTTPS"] == "on") {$pageURL .= "s";}
			$pageURL .= "://";
		if ($_SERVER["SERVER_PORT"] != "80") {
			$pageURL .= $_SERVER["SERVER_NAME"].":".$_SERVER["SERVER_PORT"].$_SERVER["REQUEST_URI"];
		} else {
	  		$pageURL .= $_SERVER["REQUEST_URI"];
	 	}
	 return $pageURL;
	}
	
	function loadTemplate ($template) {
		if (!is_file ($template)) return '';
		$buffer = ob_get_clean();
		ob_start();
		include ($template);
		$content = ob_get_clean();
		ob_start();		
		return $content;
	}
}
?>