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

class JAT3_AdminJoomfish {
	
	var $db;
	
	function JAT3_AdminJoomfish(){
		$this->db =& JFactory::getDBO();
	}

	function getValueUrlJoomfish(){
		$cid_str =  JRequest::getVar( 'cid', array(0) );
		$array_id = explode("|",$cid_str[0]);
		// return value reference_id and language_id  
		return $array_id;
	}
	
	//get value [params] from table #__menu
	function getDatabaseValueOrginal(){
		$array_data = $this->getValueUrlJoomfish();
		if (isset($array_data[1])){
			$reference_id = (int)$array_data[1];
			$query = "SELECT params FROM #__menu WHERE id = '".$reference_id."'";
			$this->db->setQuery($query);
			if($this->db->loadResult()){
				return $this->db->loadObject()->params;
			}
		}		
		return "";
	}
	//get value [value] from table #__jf_content
	function getDatabaseValueReference(){
		$array_data = $this->getValueUrlJoomfish();
		if (isset($array_data[1]) && isset($array_data[2])){
			$reference_id = (int)$array_data[1];
			$language_id = (int)$array_data[2];
			$query = "SELECT value FROM #__jf_content WHERE reference_id = '".$reference_id."' and reference_field ='params' and language_id = '".$language_id."'";
			$this->db->setQuery($query);
			if ($this->db->loadResult()){
				return $this->db->loadObject()->value;
			}
		}
		return "";
	}
	/**
	 * Data render 
	 *
	 * @xmlstring 		string		The body string content.
	 * @renderparams	string		Value render
	 */
	function getParamsRender($xmlstring , $renderparams){		
		// Initialize variables
		$params	= null;
		if (($renderparams=='defaultvalue_params')||($renderparams=='refField_params')){
			$item = $this->getDatabaseValueReference();
		}
		else if($renderparams=='orig_params')  {
			$item	= $this->getDatabaseValueOrginal();
		}
		else {
			$item="";
		}
		if(isset($item)) {
			$params = new JParameter( $item );
			//update value to make it compatible with old parameter
			if (!$params->get ('mega_subcontent_mod_modules','') && $params->get ('mega_subcontent-mod-modules')) {
				$params->set ('mega_subcontent_mod_modules', $params->get ('mega_subcontent-mod-modules'));
			}
			if (!$params->get ('mega_subcontent_pos_positions','') && $params->get ('mega_subcontent-pos-positions')) {
				$params->set ('mega_subcontent_pos_positions', $params->get ('mega_subcontent-pos-positions'));
			}
		} else
			$params = new JParameter( "" );
		$xml =& JFactory::getXMLParser('Simple');
		if ($xml->loadString($xmlstring)) {
			$document =& $xml->document;
			$params->setXML($document->getElementByPath('state/params'));
		}
		return $params->render($renderparams);
		
	}
	
	/**
	 * Replace content joomfish 
	 *
	 * @prefix	string		Value render
	 */
	function replaceContentJoomfish( $prefix ){
		// Build HTML params area
		$xmlFile = T3Path::path(T3_CORE) . DS . 'params' . DS ."params.xml";

		$str = "";
		
		$xmlFile = JFile::read( $xmlFile );
		
		preg_match_all("/<params([^>]*)>([\s\S]*?)<\/params>/i", $xmlFile, $matches);
		
		foreach( $matches[0] as $v){
			$v = preg_replace("/group=\"([\s\S]*?)\"/i", '', $v);
			$xmlstring = '<?xml version="1.0" encoding="utf-8"?>
							<metadata>
								<state>
									<name>Component</name>
									<description>Component Parameters</description>';
			$xmlstring .= $v;
			$xmlstring .= '</state>
							</metadata>';
			
			preg_match_all("/label=\"([\s\S]*?)\"/i", $v, $arr);

			switch ($prefix){
				case 'refField_params':
					$str .= '<div class="panel ja_reference">
					<h3 class="jpane-toggler title">
					<span>'. $arr[1][0] .'</span></h3>
					<div class="jpane-slider content" style="border-top: medium none; border-bottom: medium none; overflow: hidden; padding-top: 0px; padding-bottom: 0px;">
					'.$this->getParamsRender($xmlstring, $prefix )."</div></div>";
					break;
				case 'orig_params':
					$str .= '<div class="panel ja_orig">
					<h3 class="jpane-toggler title">
					<span>'. $arr[1][0] .'</span></h3>
					<div class="jpane-slider content" style="border-top: medium none; border-bottom: medium none; overflow: hidden; padding-top: 0px; padding-bottom: 0px;">
					'.$this->getParamsRender($xmlstring, $prefix )."</div></div>";
					break;
				default:
					$str .= '<div class="panel ja_default"><span style="display:none">
					<h3 class="jpane-toggler title">
					<span>'. $arr[1][0] .'</span></h3>
					<div class="jpane-slider content" style="border-top: medium none; border-bottom: medium none; overflow: hidden; padding-top: 0px; padding-bottom: 0px;">
					'.$this->getParamsRender($xmlstring, $prefix )."</div></span></div>";
					break;				
			}
			
		}
		return $str;
	}
	
	function translate(){
		//Get body content
		$_body = JResponse::getBody();		
		
		//render value [orig_params] from params.xml
		$str_orginal = $this->replaceContentJoomfish( 'orig_params' );
		$str_orginal = str_replace('name="orig_params[', 'disabled="" name="orig_params[', $str_orginal);		
		$script_orignal = '<script type="text/javascript">$$(\'.ja_orig\').injectTop($(\'original_value_params\'))</script>';
		$_body = str_replace ("</body>", $str_orginal."\n</body>\n$script_orignal", $_body);
		
		//render value [refField_params] from params.xml
		$str_reference = $this->replaceContentJoomfish( 'refField_params' );
		$script_reference = '<script type="text/javascript">$$(\'.ja_reference\').injectTop($(\'original_value_params\').getNext())</script>';
		$_body = str_replace ("</body>", $str_reference."\n".$script_reference."\n</body>\n", $_body);
		
		//render value [defaultvalue_params] from params.xml
		$str_default = $this->replaceContentJoomfish( 'defaultvalue_params' );
		$script_default = '<script type="text/javascript">$$(\'.ja_default\').injectTop($(\'original_value_params\'))</script>';
		$_body = str_replace ("</body>", $str_default."\n".$script_default."\n</body>\n", $_body);
		
		if ( $_body ) {
			JResponse::setBody( $_body );
		}
		
	}
}