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

class T3Path extends JObject {
	var $_paths = array();
	function _construct () {
	}
	//Parse layout information from ini path

	function getInstance () {
		static $instance = null;
		if (!isset($instance)) $instance = new T3Path();
		return $instance;
	}
	
	function addPath ($theme, $path, $url) {
		$this->_paths[$theme] = array($path, $url);
	}
	
	function find ($file, $all=false) {
		$result = array();
		//$rpaths = array_reverse ($this->_paths);
		foreach ($this->_paths as $theme=>$_path)
		{
			if (t3_file_exists ($file, $_path[0])) {
				$fullpath = array();
				$fullpath[0] = $_path[0].DS.$file;
				$fullpath[1] = $_path[1].'/'.str_replace('\\','/',$file);
				if ($all) $result[$theme] = $fullpath;
				else return $fullpath;
			}
		}		
		return count($result)?$result:false;
	}
	
	function getPath ($file, $all=false) {
		$pathobj = T3Path::getInstance();
		$path = $pathobj->find ($file, $all);
		if (!$path) return false;
		if ($all) {
			$result = array();
			foreach ($path as $t=>$p) $result[$t] = $p[0];
			return $result;
		} else return $path[0];
	}
	
	function getUrl ($file, $all=false) {
		$pathobj = T3Path::getInstance();
		$path = $pathobj->find ($file, $all);
		if (!$path) return false;
		if ($all) {
			$result = array();
			foreach ($path as $t=>$p) $result[$t] = $p[1];
			return $result;
		} else return $path[1];
	}
	
	function get ($file, $all=false) {
		$pathobj = T3Path::getInstance();
		return $pathobj->find ($file, $all);
	}
	
	function js ($file) {
	}
	function css ($file) {
	}
	function image ($file) {
	}
	
	function findLayoutINI ($layout=null) {
		$pathobj = T3Path::getInstance();
		$file = $layout?'layouts'.DS.$layout.'.ini':'layout_default'.DS.'layout.ini';
		return $pathobj->getPath($file);
	}
	function findLayout ($layout=null) {
		$pathobj = T3Path::getInstance();
		$file = $layout?'layouts'.DS.$layout.'.php':'layout_default'.DS.'layout.php';
		return $pathobj->getPath($file);
	}
	function findBlock ($block) {
		$pathobj = T3Path::getInstance();
		$file = 'blocks'.DS.$block.'.php';
		return $pathobj->getPath($file);
	}
	
	function path ($path, $fullpath=true) {
		//remove after ? or #
		$path = preg_replace ('#[?\#]+.*$#', '', $path);
		$fpath = str_replace ('/', DS, $path);
		return $fullpath ? JPATH_SITE.DS.$fpath : $fpath;
	}
	
	function url ($path, $pathonly = true) {
		return JURI::root($pathonly).'/'.$path;
	}
}