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

defined( '_VALID_MOS' ) or defined('_JEXEC') or die('Restricted access');
if (!defined ('_JA_CSS_MENU_CLASS')) {
	define ('_JA_CSS_MENU_CLASS', 1);
	require_once (dirname(__FILE__).DS."base.class.php");
	
	class JAMenuCSS extends JAMenuBase{
		function beginMenu($startlevel=0, $endlevel = 10){
		}
  
  		function beginMenuItems($pid=0, $level=0){
			if($level==0) echo "<ul id=\"ja-cssmenu\" class=\"clearfix\">\n";
			else echo "<ul>";
		}
      
		function endMenu($startlevel=0, $endlevel = 10){
		}
        
        function hasSubMenu($level) {
            return false;
        }
        
        function beginMenuItem($row=null, $level = 0, $pos = '') {
        	/*
        	$active = $this->genClass ($tmp, $level, $pos);
            $active = in_array($row->id, $this->open);
			$active = ($level?"":"menu-item{$row->_idx}"). ($active?" active":"").($pos?" $pos-item":"");
			*/
        	$active = $this->genClass ($row, $level, $pos);
        	if ($level == 0) {
        		$active = preg_replace ('/haschild/', 'havechild', $active);
        	} else {
        		$active = preg_replace ('/haschild/', 'havesubchild', $active);
        	}
            if ($level == 0 && $level < $this->getParam ('endlevel') && @$this->children[$row->id]) echo "<li class=\"havechild {$active}\">";
            else if ($level > 0 && $level < $this->getParam ('endlevel') && @$this->children[$row->id]) echo "<li class=\"havesubchild {$active}\">";
            else echo "<li ".(($active) ? "class=\"$active\"" : "").">";
        }
        function endMenuItem($mitem=null, $level = 0, $pos = ''){
            echo "</li> \n";
        }
		
		function genMenuItem($item, $level = 0, $pos = '', $ret = 0) {
			//if ($level) return parent::genMenuItem($item, $level, '', $ret);
			//else 
			return parent::genMenuItem($item, $level, $pos, $ret);
		}
	}
}
?>