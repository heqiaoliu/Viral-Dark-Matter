<?php
/*
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
*/ 

// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );

jimport ( 'joomla.application.component.model' );

class JaextmanagerModelServices extends JModel {
	
	var $_pagination = NULL;
	var $_total = 0;
	
	function getRow($cid = array(0)) 
	{
		$table = &$this->getTable ( 'services', 'Table' );		
		// Load the current item if it has been defined
		$edit = JRequest::getVar ( 'edit', true );
		if (! $cid || @! $cid [0]) {
			$cid = JRequest::getVar ( 'cid', array (0 ), '', 'array' );
			JArrayHelper::toInteger ( $cid, array (0 ) );
		}

		if ($edit) {
			$table->load ( $cid [0] );
		}

		$item = $table;
		
		return $item;
	}
	
	function getRow2($cid) 
	{
		$table = &$this->getTable ( 'services', 'Table' );		
		$table->load ( $cid );
		return $table;
	}
	
	function getList($cond = '', $order = '', $limitstart=0, $limit=20) {
		$db = JFactory::getDBO ();
		$services = array ();
		
		if($order != '') {
			$order = "ORDER BY {$order}";
		}
		
		$sql = "
				SELECT t.*
				FROM #__jaem_services AS t
				WHERE 1 {$cond}
				{$order}
				LIMIT {$limitstart}, {$limit}";
		$db->setQuery ( $sql );
		$services = $db->loadObjectList();
		return $services;
	}
	
	function getTotal($cond) {
		$db = JFactory::getDBO ();
		$query = "
				SELECT COUNT(*)  
				FROM #__jaem_services AS t
				WHERE 1 {$cond}";
		
		$db->setQuery ( $query );
		$this->_total = $db->loadResult ();
		return $this->_total;
	}
	
	function getListServiceMode()
	{
		$aData = array();
		$aData[] = JHTML::_( 'select.option', 'local', JText::_('LOCAL') );
		$aData[] = JHTML::_( 'select.option', 'remote', JText::_('REMOTE') );
		return $aData;
	}
	
	function store() 
	{
		$row = & $this->getRow ();
		$post = $this->getState ( 'request' );
		
		if(!$row->id){			
			
		}
		
		if (! $row->bind ( $post )) {
			return $row->getError ( true );
		}
		
		//dont save passowrd if no require change
		if(empty($row->ws_pass)) {
			unset($row->ws_pass);
		} else {
			//encrypt password
			$row->ws_pass = base64_encode($row->ws_pass);
		}
		//
		
		if ( ($erros = $row->check ())) {
			//print_r($erros);
			return implode ( "<br/>", $erros );
		}
		
		if (! $row->store ()) {
			//echo 'error';
			return $row->getError ( true );
		} else {
			//reset default
			if($row->id && $row->ws_default) {
				$this->resetDefault($row->id);
			}
		}

		return $row;
	}
	
	function _getVars() {
		static $lists;
		if($lists) return $lists;
		
		global $javconfig;		
		
		$lists = array ();
		$lists ['order'] = JRequest::getString('order', 't.ws_name desc' );
		$lists ['order_Dir'] = JRequest::getCmd( 'order_Dir', '');
		$lists ['limit'] = JRequest::getInt( 'limit', $javconfig['systems']->get('display_num', 20) );
		$lists ['limitstart'] = JRequest::getInt('limitstart', 0);
		return $lists;
	}
	function _getVars_admin() {
		$mainframe = JFactory::getApplication('administrator');
		$option='services';
		$lists = array ();
		$lists ['filter_order'] = $mainframe->getUserStateFromRequest ( $option . '.filter_order', 'filter_order', 't.id', 'string' );
		$lists ['filter_order_Dir'] = $mainframe->getUserStateFromRequest ( $option . '.filter_order_Dir', 'filter_order_Dir', 'desc', 'word' );
		$lists ['limit'] = $mainframe->getUserStateFromRequest ( $option . 'limit', 'limit', 20, 'int' );
		$lists ['limitstart'] = $mainframe->getUserStateFromRequest ( $option . '.limitstart', 'limitstart', 0, 'int' );
		return $lists;
	}	
		
	function setDefault(){
		$db		=& JFactory::getDBO();
		
		$ids = JRequest::getVar('cid', array());		
		$ids = implode( ',', $ids );
		
		//reset
		$this->resetDefault($ids[0]);
		//make default
		$query = "UPDATE #__jaem_services SET ws_default = 1 WHERE id IN ( $ids )";
		$db->setQuery( $query );
		if (!$db->query()) {
			return false;
		}
		return true;
 	}
	
	function resetDefault($defaultId) {
		$db		=& JFactory::getDBO();
		$query = "UPDATE #__jaem_services SET ws_default = 0 WHERE id <> {$defaultId}";
		$db->setQuery( $query );
		$db->query();
	}
	
	function delete($id){
		$query="DELETE FROM #__jaem_services WHERE id={$id} AND ws_core = 0 AND ws_default = 0";
		$this->_db->setQuery($query);
		$result = $this->_db->query();
		return $result;
	}
}