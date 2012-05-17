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
class JElementGFonts extends JElement
{
	/**
	 * Element name
	 *
	 * @access	protected
	 * @var		string
	 */
	var	$_name = 'Fonts';

	function fetchElement( $name, $value, &$node, $control_name ) {
		t3_import('core/admin/util');
		
		$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(__FILE__) ));
		$uri = str_replace("/administrator", "", $uri);
		
		// Load font
		$path = JPATH_SITE.DS.T3_TEMPLATE_LOCAL.DS.'etc'.DS.'gfonts.xml';
		$path = str_replace(DS, "/", $path);
		if (!file_exists($path)) {
			$path = JPATH_SITE.DS.T3_BASETHEME.DS.'etc'.DS.'gfonts.xml';
			$path = str_replace(DS,"/", $path);
		}
		$gfont_group = array();
		if (file_exists($path)) {
			$xml = T3Common::getXml($path, false);
			foreach ($xml->children() as $subset) {
				$group_name = $subset->attributes('name');
				$gfont_group[$group_name] = array();
				foreach($subset->children() as $font) {
					$gfont_group[$group_name][] = $font->data(); 
				}
			}
		}
		
//		$gfont_group = array (
//						'latin'=>array(
//								'Droid Sans','Droid Serif','Lobster','Yanone Kaffeesatz','Nobile','Reenie Beanie',
//								'Tangerine','Neucha','Josefin Slab','OFL Sorts Mill Goudy TT','Molengo','PT Sans',
//								'Vollkorn','Just Me Again Down Here','Ubuntu','Cantarell','Inconsolata','Crimson Text',
//								'Cardo','Cuprum','Droid Sans Mono','Neuton','Arvo','Philosopher','Old Standard TT','Josefin Sans',
//								'Covered By Your Grace','Arimo','IM Fell','Geo','Copse','Raleway','Allerta','Just Another Hand',
//								'Tinos','Puritan','Mountains of Christmas','Cabin','Sniglet','Allan','Lato','Orbitron','Vibur',
//								'Gruppo','Allerta Stencil','Cousine','Syncopate','Merriweather','Kristi','Anonymous Pro','Coda',
//								'Corben','Buda','Bentham','Lekton','UnifrakturMaguntia','UnifrakturCook','Kenia','Rock Salt',
//								'Calligraffitti','Cherry Cream Soda','Chewy','Coming Soon','Crafty Girls','Crushed','Fontdiner Swanky',
//								'Homemade Apple','Irish Growler','Kranky','Luckiest Guy','Permanent Marker','Schoolbell','Slackey',
//								'Sunshiney','Unkempt','Walter Turncoat'
//							),
//						'Cyrillic'=>array('Anonymous Pro','Cuprum','Neucha','PT Sans','Philosopher','Ubuntu'),
//						'Greek'=>array('GFS Didot','GFS Neohellenic','Ubuntu','Anonymous Pro'),
//						'Khmer'=>array('Hanuman')
//						);
		//embed google fonts
		if (!defined ('_GFONTS_ADDED')) {
			define ('_GFONTS_ADDED', 1);
			echo "<script type=\"text/javascript\">window.addEvent('load', function() {new Asset.css ('http://code.google.com/webfonts/css?kit=fRn5xRji3KlvfYTK4F2Aig');});</script>";
			echo "<script type=\"text/javascript\" src=\"$uri/assets/js/gfonts.js\"></script>\n";
		}
		
		$eid = $control_name.$name;
		$ename = $control_name.'['.$name.']';
		$lists = "";
		$lists .= "<select id=\"$eid.font\" name=\"$eid.font\" class=\"inputbox\">\n";
		if(in_array($name, array('gfont_logo', 'gfont_slogan'))){
			$lists .= "<option value=\"\">--- Select if logo type is text ---</option>\n";
		}
		else{
			$lists .= "<option value=\"\">--- Not applied ---</option>\n";
		}
		foreach ($gfont_group as $group=>$gfonts) {
			$lists .= "<optgroup label=\"$group\">\n";
			foreach ($gfonts as $gfont) {
				$selected = ($value == $gfont)?"selected=\"selected\"":"";
				$lists .= "<option style=\"font-family: '$gfont::Menu';font-size:2em;\" value=\"$gfont\" $selected>$gfont</option>\n";
			}
			$lists .= "</optgroup>\n";
		}
		$lists .= "</select>\n";
		//checkbox
		$lists .= "<input type=\"checkbox\" id=\"$eid.extra\" name=\"$eid.extra\" onclick=\"gfonts_showhideextra('$eid');\" \" />\n";
		$lists .= "<label for=\"$eid.extra\" class=\"editlinktip hasTip\" title=\"".JText::_('Custom CSS Desc')."\">".JText::_('Custom CSS')."</label>";
		//textarea, the extra property - hide by default. show when extra field is checked
		$lists .= "<textarea id=\"$eid.style\" cols=\"40\" rows=\"5\" name=\"$eid.style\" class=\"clearfix\" style=\"display:none; margin-top: 5px; clear: both; \"></textarea>\n";
		
		$lists .= "<input type=\"hidden\" id=\"$eid\" name=\"$ename\" value=\"$value\" rel=\"gfonts\" />\n";
		return $lists;
	}
} 