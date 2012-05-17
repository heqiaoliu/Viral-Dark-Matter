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

defined('_JEXEC') or die('Restricted access');
if (!defined ('_JA_DROPLINE_MENU_CLASS')) {
	define ('_JA_DROPLINE_MENU_CLASS', 1);
	require_once (dirname(__FILE__).DS."base.class.php");

	class JAMenuDropline extends JAMenuBase{
		function __construct ($params) {
			parent::__construct($params);

			//To show sub menu on a separated place
			$this->showSeparatedSub = true;
		}

	    function genMenu($startlevel=0, $endlevel = 10){
			if ($startlevel == 0) parent::genMenu(0,0);
			else {
				$this->setParam('startlevel', $startlevel);
				$this->setParam('endlevel', $endlevel);
				$this->beginMenu($startlevel, $endlevel);
				//Sub level
				$pid = $this->getParentId($startlevel - 1);
				if (@$this->children[$pid]) {
					foreach ($this->children[$pid] as $row) {
						if (@$this->children[$row->id]) {
							$this->genMenuItems ($row->id, $startlevel);
						} else {
							echo "<ul id=\"jasdl-subnav{$row->id}\" class=\"clearfix\"><li class=\"empty\">&nbsp;</li></ul>";
						}
					}
				}
				$this->endMenu($startlevel, $endlevel);
			}
		}
		
		function genMenuItems1($pid, $level) {
			if (@$this->children[$pid]) {
				$this->beginMenuItems($pid, $level);
				$i = 0;
				foreach ($this->children[$pid] as $row) {
					$pos = ($i == 0 ) ? 'first' : (($i == count($this->children[$pid])-1) ? 'last' :'');

					$this->beginMenuItem($row, $level, $pos);
					$this->genMenuItem( $row, $level, $pos);

					// show menu with menu expanded - submenus visible
					if ($level < $this->getParam('endlevel')) $this->genMenuItems( $row->id, $level+1 );
					$i++;

					if ($level == 0 && $pos == 'last' && in_array($row->id, $this->open)) {
						global $jaMainmenuLastItemActive;
						$jaMainmenuLastItemActive = true;
					}
					$this->endMenuItem($row, $level, $pos);
				}
				$this->endMenuItems($pid, $level);
			} else if ($level==1){
				echo "<ul id=\"jasdl-subnav$pid\" class=\"clearfix\"><li>&nbsp;</li></ul>";
			}
		}
		
        function beginMenuItems($pid=0, $level=0){
            if(!$level) echo "<ul>";
			else echo "<ul id=\"jasdl-subnav$pid\" class=\"clearfix\">";
        }

        function beginMenuItem($mitem=null, $level = 0, $pos = ''){
			$active = $this->genClass ($mitem, $level, $pos);
			if ($active) $active = " class=\"$active clearfix\"";
            if(!$level) echo "<li id=\"jasdl-mainnav{$mitem->id}\"$active>";
			else echo "<li id=\"jasdl-subnavitem{$mitem->id}\"$active>";
        }

        function beginMenu($startlevel=0, $endlevel = 10){
            if(!$startlevel) echo "<div id=\"jasdl-mainnav\">";
            else echo "<div id=\"jasdl-subnav\">";			
        }

		function endMenu($startlevel=0, $endlevel = 10){
			echo "</div>";
			if(!$startlevel) {
				echo "
				<script type=\"text/javascript\">
					var jasdl_activemenu = [". ( (count($this->open) == 1) ? "\"".$this->open[0]."\"" : implode(",", array_slice($this->open, $this->_start-1)) ) ."];
				</script>
				";
			}
		}

		function hasSubMenu($level) {
			return true;
		}
	}
}
?>
