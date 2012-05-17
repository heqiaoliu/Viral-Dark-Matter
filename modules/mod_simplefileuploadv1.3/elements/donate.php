<?php
/**
* @version		1.5j
* @copyright	Copyright (C) 2010-2011 Anders Wasén
* @license		GNU/GPL
*/

// Check to ensure this file is included in Joomla!
defined('_JEXEC') or die();



class JFormFieldDonate extends JFormField
{
	/**
	 * Element name
	 *
	 * @access	protected
	 * @var		string
	 */
	//public $type = 'Donate';
	//var	$_name = 'Donate';
	protected $type = 'Donate'; //the form field type
	

	//function fetchElement($name, $value, &$node, $control_name)
	protected function getInput()
	{
		
		$html = '';
		
		$html = '<div class="clr"></div><input type="image" src="https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif" border="0" alt="PayPal - The safer, easier way to pay online!" onclick="javascript: window.open (\'http://wasen.net/donate.html\', \'donate\',\'\');" />';
		$html .= '<br />Well, I think it\'s worth AT LEAST 5 bucks! What do you think? (Donate through PayPal. Thanks!)';
		
		return $html;


	}
}