<?php
/*
#------------------------------------------------------------------------
  T3 Framework for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/


defined( '_VALID_MOS' ) or defined('_JEXEC') or die('Restricted access');
if (!defined ('_JA_MOO_MENU_CLASS')) {
	define ('_JA_MOO_MENU_CLASS', 1);
	require_once (dirname(__FILE__).DS."base.class.php");
	
	class JAMenuMoo extends JAMenuBase{
		function beginMenu($startlevel=0, $endlevel = 10){
		}
  
  		function beginMenuItems($pid=0, $level=0){
			if($level==0) echo "<ul id=\"ja-cssmenu\" class=\"clearfix\">\n";
			else echo "<ul>";
		}
  		function endMenuItems($pid=0, $level=0){
			if($level==0) echo "</ul>\n";
			else echo "</ul>";
		}
      
		function endMenu($startlevel=0, $endlevel = 10){
		}
        
        function hasSubMenu($level) {
            return false;
        }
        
        function beginMenuItem($row=null, $level = 0, $pos = '') {
            $active = in_array($row->id, $this->open);
			$active = ($level?"":"menu-item{$row->_idx}"). ($active?" active":"").($pos?" $pos-item":"");
            if ($level == 0 && $level < $this->getParam ('endlevel') && @$this->children[$row->id]) echo "<li class=\"havechild{$active}\">";
            else if ($level > 0 && $level < $this->getParam ('endlevel') && @$this->children[$row->id]) echo "<li class=\"havesubchild{$active}\">";
            else echo "<li ".(($active) ? "class=\"active\"" : "").">";
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