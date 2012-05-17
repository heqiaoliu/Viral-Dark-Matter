<?php
/*
# ------------------------------------------------------------------------
# JA Menu Parameters plugin for Joomla 1.5
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
# Author: JoomlArt.com
# Websites: http://www.joomlart.com - http://www.joomlancers.com.
# ------------------------------------------------------------------------
*/

defined( '_JEXEC' ) or die();
jimport( 'joomla.plugin.plugin' );
jimport('joomla.application.module.helper');
// Import library dependencies
jimport( 'joomla.event.plugin' );
jimport('joomla.filesystem.file');
/**
 * JAPopup Content Plugin
 *
 * @package		Joomla
 * @subpackage	Content
 * @since 		1.5
 */
class plgSystemPlg_JAMenuParams extends JPlugin
{

	/** @var object $_modalObject  */
	var $_params;
	var $_dbValue;
	var $_pluginLibPath;
	
	function plgSystemPlg_JAMenuParams ( &$subject ){
		$this->__construct( $subject );
	}
	
	function __construct( &$subject ){
		parent::__construct( $subject );

		// Load plugin parameters
		$this->_plugin = JPluginHelper::getPlugin( 'system', 'plg_jamenuparams' );
		$this->_params = new JParameter( $this->_plugin->params );
		$this->_pluginLibPath = JPATH_PLUGINS.DS."system".DS."plg_jamenuparams".DS;
		$this->loadLanguage ('plg_'.$this->_plugin->type.'_'.$this->_plugin->name, JPATH_ADMINISTRATOR);
	}
	
	function getSystemParams($xmlstring)
	{
		// Initialize variables
		$params	= null;
		$item	= $this->getDatabaseValue();
		if(isset($item->params))
			$params = new JParameter( $item->params );
		else
			$params = new JParameter( "" );
		$xml =& JFactory::getXMLParser('Simple');
		if ($xml->loadString($xmlstring)) {
			$document =& $xml->document;
			$params->setXML($document->getElementByPath('state/params'));
		}
		return $params->render('params');
	}
	
	/**
	 * Popup prepare content method
	 *
	 * @param 	string		The body string content.
	 */
	function replaceContent( $bodyContent ){
		// Build HTML params area
		$xmlFile = $this->_pluginLibPath."params".DS."jatoolbar.xml";
		if(! file_exists($xmlFile) ){
			return $bodyContent;
		}
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
			
			$str .= '<div class="panel">
				<h3 id="jatoolbar-page" class="jpane-toggler title">
				<span>'. $arr[1][0] .'</span></h3>
				<div class="jpane-slider content" style="border-top: medium none; border-bottom: medium none; overflow: hidden; padding-top: 0px; padding-bottom: 0px;">
				'.$this->getSystemParams($xmlstring)."</div></div>";
		}
		
		preg_match_all("/<div class=\"panel\">([\s\S]*?)<\/div>/i", $bodyContent, $arr);
		
		$bodyContent = str_replace($arr[0][count($arr[0])-1], $arr[0][count($arr[0])-1].$str, $bodyContent);
		
		return $bodyContent;
	}
	
	function onAfterRender(){
		global $mainframe;
		// Run only on edit menu
		
		if ( JRequest::getVar("option") == "com_menus" && JRequest::getVar("task") == "edit"  ) {
			// HTML= Parser lib
			require_once(JPATH_PLUGINS.DS."system".DS."plg_jamenuparams".DS."asset".DS."html_parser.php");
			
			if (!isset($this->_plugin)) return;
		
			$_body = JResponse::getBody();
			
			// Replace content
			$_body = $this->replaceContent($_body);
			
			if ( $_body ) {
				JResponse::setBody( $_body );
			}
		}
		return true;		
	}
	
	function getDatabaseValue(){
		$db =& JFactory::getDBO();
		$id = JRequest::getVar ( 'cid', 0, '', 'array' );
		$id = ( int ) $id [0];
		if($id == "") $id = 0;
		$query = "SELECT * FROM #__menu WHERE id = '".$id."'";
		$db->setQuery($query);
		return $db->loadObject();
	}
}
?>