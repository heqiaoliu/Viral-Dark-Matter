<?php
/**
 * ------------------------------------------------------------------------
 * JA Extensions Manager
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */
// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );

 /**
 * @desc convert xml to object
 * @desc implement on php4
 *
 * @sample:
 *
 include_once("class.xmlparser.php");

 $xml = new jaXmlParser();
 $xml->loadFile("test.xml");
 $obj = $xml->toObject();
 print_r($obj);
 */

class jaXmlParser
{
	var $xml;
	
	var $obj = null;
	var $stackNode = array();


	function jaXmlParser()
	{
		$this->xml = "";
	}


	function loadString($str)
	{
		$this->xml = trim($str);
	}


	function loadFile($file)
	{
		if (JFile::exists($file)) {
			$this->loadString(file_get_contents($file));
		}
	}


	function _preParser()
	{
		$arr = array();
		$parser = xml_parser_create('');
		xml_parser_set_option($parser, XML_OPTION_TARGET_ENCODING, "UTF-8");
		xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, 0);
		xml_parser_set_option($parser, XML_OPTION_SKIP_WHITE, 1);
		xml_parse_into_struct($parser, $this->xml, $arr);
		xml_parser_free($parser);
		return $arr;
	}


	function toObject()
	{
		$this->obj = new stdClass();
		$this->stackNode = array();
		$arrXml = $this->_preParser();
		
		$parent = new stdClass();
		$this->_toOjbect($arrXml);
		return $this->obj;
	}


	function _toOjbect($arrXml)
	{
		foreach ($arrXml as $node) {
			if (is_array($node) && isset($node['type'])) {
				if ($node['type'] == 'close') {
					array_pop($this->stackNode);
					continue;
				}
				$tag = $node['tag'];
				$obj = $this->_createNode($node);
				
				//go to current parent node
				$parent = &$this->obj;
				if (count($this->stackNode) > 0) {
					foreach ($this->stackNode as $pathNode) {
						$parent = &$parent->$pathNode;
						
						if (is_array($parent)) {
							//if more than one child with same name => conver to array
							$lastItem = count($parent) - 1;
							$parent = &$parent[$lastItem];
						}
						$parent = &$parent->children;
					}
				}
				//echo implode('/', $this->stackNode) . "<br />";
				

				//add child
				if (isset($parent->$tag)) {
					if (!is_array($parent->$tag)) {
						$firstObj = $parent->$tag;
						$parent->$tag = array();
						array_push($parent->$tag, $firstObj);
					}
					array_push($parent->$tag, $obj);
				} else {
					$parent->$tag = $obj;
				}
				
				if ($node['type'] == 'open') {
					array_push($this->stackNode, $tag);
				}
			}
		}
	}


	function _createNode($arr)
	{
		$obj = new stdClass();
		foreach ($arr as $key => $value) {
			//$key = "_{$key}";
			if (is_array($value)) {
				//attributes
				$obj->$key = new stdClass();
				foreach ($value as $attr => $attrVal) {
					$obj->$key->$attr = $attrVal;
				}
			} else {
				$obj->$key = $value;
			}
		}
		$obj->children = new stdClass();
		return $obj;
	}
}
?>