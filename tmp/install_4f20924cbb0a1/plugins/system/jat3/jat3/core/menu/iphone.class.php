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
if (!defined ('_JA_IPHONE_MENU_CLASS')) {
	define ('_JA_IPHONE_MENU_CLASS', 1);
	require_once (dirname(__FILE__).DS."base.class.php");

	class JAMenuiphone extends JAMenuBase{

		function __construct (&$params) {
			parent::__construct($params);

			//To show sub menu on a separated place
			$this->showSeparatedSub = true;
		}
		function beginMenu($startlevel=0, $endlevel = 10){
		}
		function endMenu($startlevel=0, $endlevel = 10){
		}
		
		function beginMenuItems($pid=0, $level=0){
			if ($pid && isset ($this->items[$pid])) {
				echo "<ul id=\"nav$pid\" title=\"{$this->items[$pid]->name}\" class=\"toolbox\">";
			} else {
				echo "<ul id=\"ja-iphonemenu\" title=\"Menu\" class=\"toolbox\">";
			}
		}

		function genMenuItem($item, $level = 0, $pos = '', $ret = 0)
		{			
			$data = parent::genMenuItem($item, $level, $pos, true);
			if (@$this->children [$item->id]) {
				$tmp = $item;				
				$data .= "<a class=\"ja-folder\" href=\"#nav{$tmp->id}\" title=\"{$tmp->name}\">&gt;</a>"; 				
			}
			if ($ret) return $data; else echo $data;
		}

		function genMenuItems($pid, $level) {
			if (@$this->children[$pid]) {
				$this->beginMenuItems($pid, $level);
				$i = 0;
				foreach ($this->children[$pid] as $row) {
					$pos = ($i == 0 ) ? 'first' : (($i == count($this->children[$pid])-1) ? 'last' :'');

					$this->beginMenuItem($row, $level, $pos);
					$this->genMenuItem( $row, $level, $pos);

					// show menu with menu expanded - submenus visible
					$i++;

					$this->endMenuItem($row, $level, $pos);
				}
				$this->endMenuItems($pid, $level);
				
				foreach ($this->children[$pid] as $row) {
					if ($level < $this->getParam('endlevel')) $this->genMenuItems( $row->id, $level+1 );
				}
			}
			
		}
		
	}
}
?>
