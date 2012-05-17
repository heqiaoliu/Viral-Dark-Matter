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

// no direct access
defined('_JEXEC') or die('Restricted access');

class T3Layout extends ObjectExtendable {
	function _construct ($template) {
		$this->_extend (array($template));
	}
	
	function &getInstance($template=null)
	{
		static $instance=null;

		if (!isset( $instance )) {
			$instance = new T3Layout ($template);
		}
		
		return $instance;
	}
	
	function parseLayout () {
		//parse layout
		$this->_colwidth = array();
		//Left
		$l = $l1 = $l2 = 0;
		$left1 = $this->getPositionName ('left1');
		$left2 = $this->getPositionName ('left2');
		$mt = $this->getPositionName ('left-mass-top');
		$mb = $this->getPositionName ('left-mass-bottom');
		if ($this->countModules ("$mt") || $this->countModules ("$mb") || ($this->countModules ("$left1") && $this->countModules ("$left2"))) {
			$l = 2;
			$l1 = $this->getColumnBasedWidth ('left1');
			$l2 = $this->getColumnBasedWidth ('left2');
		} else if ($this->countModules("$left1")) {
			$l = 1;
			$l1 = $this->getColumnBasedWidth ('left1');
		} else if ($this->countModules("$left2")) {
			$l = 1;
			$l2 = $this->getColumnBasedWidth ('left2');
		}
		$cls_l = $l?"l$l":"";
		$l = $l1 + $l2;
		
		//right
		$r = $r1 = $r2 = 0;
		$right1 = $this->getPositionName ('right1');
		$right2 = $this->getPositionName ('right2');
		$mt = $this->getPositionName ('right-mass-top');
		$mb = $this->getPositionName ('right-mass-bottom');
		if ($this->countModules ("$mt") || $this->countModules ("$mb") || ($this->countModules ("$right1") && $this->countModules ("$right2"))) {
			$r = 2;
			$r1 = $this->getColumnBasedWidth ('right1');
			$r2 = $this->getColumnBasedWidth ('right2');
		} else if ($this->countModules("$right1")) {
			$r = 1;
			$r1 = $this->getColumnBasedWidth ('right1');
		} else if ($this->countModules("$right2")) {
			$r = 1;
			$r2 = $this->getColumnBasedWidth ('right2');
		}
		$cls_r = $r?"r$r":"";
		$r = $r1 + $r2;
		
		//inset
		$inset1 = $this->getPositionName ('inset1');
		$inset2 = $this->getPositionName ('inset2');		
		$i1=$i2=0;
		if ($this->countModules("$inset1")) $i1 = $this->getColumnBasedWidth ('inset1');
		if ($this->countModules("$inset2")) $i2 = $this->getColumnBasedWidth ('inset2');

		//width
		$this->_colwidth ['r'] = $r;
		if ($r) {
			$this->_colwidth ['r1'] = round($r1 * 100 / $r);
			$this->_colwidth ['r2'] = 100 - $this->_colwidth ['r1'];
		}
		$this->_colwidth ['mw'] = 100 - $r;
		$m = 100 - $l -$r;
		$this->_colwidth ['l'] = ($l + $m)?round($l * 100 / ($l + $m)):0;
		if ($l) {
			$this->_colwidth ['l1'] = round($l1 * 100 / $l);
			$this->_colwidth ['l2'] = 100 - $this->_colwidth ['l1'];
		}
		$this->_colwidth ['m'] = 100 - $this->_colwidth ['l'];
		
		$c = $m - $i1 - $i2;
		$this->_colwidth ['i2'] = round($i2 * 100 / $m);
		$this->_colwidth ['cw'] = 100 - $this->_colwidth ['i2'];
		$this->_colwidth ['i1'] = ($c+$i1)?round($i1 * 100 / ($c+$i1)):0;
		$this->_colwidth ['c'] = 100 - $this->_colwidth ['i1'];
		
		$cls_li = $this->countModules ($inset1)?'l1':'';
		$cls_ri = $this->countModules ($inset1)?'r1':'';
		
		$this->_colwidth ['cls_w'] = ($cls_l || $cls_r)?"ja-$cls_l$cls_r":"";
		$this->_colwidth ['cls_m'] = ($cls_li || $cls_ri)?"ja-$cls_li$cls_ri":"";
		$this->_colwidth ['cls_l'] = $this->countModules ("$left1 && $left2")?"ja-l2":($this->countModules ("$left1 || $left2")?"ja-l1":"");
		$this->_colwidth ['cls_r'] = $this->countModules ("$right1 && $right2")?"ja-r2":($this->countModules ("$right1 || $right2")?"ja-r1":"");
	}
	
	function calSpotlight ($spotlight, $totalwidth=100, $specialwidth=0, $special='first') {

		/********************************************
		$spotlight = array ('position1', 'position2',...)
		*********************************************/
		$modules = array();
		$modules_s = array();
		foreach ($spotlight as $position) {
			if( $this->_tpl->countModules ($position) ){
				$modules_s[] = $position;
			}
			$modules[$position] = array('class'=>'-full','width'=>$totalwidth.'%');
		}

		if (!count($modules_s)) return null;
		if ($specialwidth) {
			if (count($modules_s)>1) {
				$width = round(($totalwidth-$specialwidth)/(count($modules_s)-1),1) . "%";
				$specialwidth = $specialwidth . "%";
			}else{
				$specialwidth = $totalwidth . "%";
			}
		}else{
			$width = (round($totalwidth/(count($modules_s)),2)) . "%";
			$specialwidth = $width;
		}

		if (count ($modules_s) > 1){
			$modules[$modules_s[0]]['class'] = "-left";
			$modules[$modules_s[0]]['width'] = ($special=='left')?$specialwidth:$width;
			$modules[$modules_s[count ($modules_s) - 1]]['class'] = "-right";
			$modules[$modules_s[count ($modules_s) - 1]]['width'] = ($special=='right')?$specialwidth:$width;
			for ($i=1; $i<count ($modules_s) - 1; $i++){
				$modules[$modules_s[$i]]['class'] = "-center";
				$modules[$modules_s[$i]]['width'] = $width;
			}
		}
		return $modules;
	}
	
	function countModules ($modules) {
		if ($this->isContentEdit()) return 0;
		$_tpl = $this->_tpl;
		return $modules?$_tpl->countModules ($modules):0;
		//return $modules?$this->_tpl->countModules ($modules):0;
	}

	function loadLayout ($layout) {
		$layout_path = T3Path::findLayout ($layout);
		if ($layout_path) include ($layout_path);
	}
	
	function loadBlock ($block) {
		$block_path = T3Path::findBlock ($block);
		if ($block_path) {
			include ($block_path);
		}		
	}
	
}
?>