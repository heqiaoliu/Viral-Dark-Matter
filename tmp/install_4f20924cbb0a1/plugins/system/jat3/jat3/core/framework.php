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

/*
T3: Joomla Template Engine

*/
t3import ('core.define');
t3import ('core.path');
class T3Framework extends JObject{
	function __construct($data) {
	}
	
	function t3_init () {		
		t3import ('core.parameter');
		t3import ('core.extendable');
		t3import ('core.template');
		t3import ('core.basetemplate');
		t3import ('core.cache');
		t3import ('core.head');
		t3import ('core.hook');
		// Remove JDocumentHTML for compatible J1.6 & J1.7		
		// if (!class_exists ('JDocumentHTML', false)) t3import ('core.joomla.documenthtml');
		if (!class_exists ('JView', false)) t3import ('core.joomla.view');
		if (!class_exists ('JModuleHelper', false)) t3import ('core.joomla.modulehelper');
		if (!class_exists ('JPagination', false)) t3import ('core.joomla.pagination');
		
		//Load template language
		$this->loadLanguage ( 'tpl_'.T3_ACTIVE_TEMPLATE, JPATH_SITE);
		
		$params = T3Common::get_template_based_params();
		//instance cache object.
		$devmode = $params?$params->get ('devmode', '0')=='1':false;
		T3Cache::getInstance ($devmode);
		//Check if enable T3 info mode. Enable by default (if not set)
		if ($params->get ('infomode',1) == 1) {
			if (!JRequest::getCmd ('t3info') && JRequest::getCmd ('tp') && JComponentHelper::getParams('com_templates')->get('template_positions_display')) JRequest::setVar ('t3info', JRequest::getCmd ('tp'));
		}
		
		$key = T3Cache::getPageKey();

		$data = null;
		$user = &JFactory::getUser();
		if ( !$devmode && JRequest::getCmd ('cache') != 'no') {
			T3Cache::setCaching(true);
			JResponse::allowCache(true);
		}
		$data = T3Cache::get ($key);
		if ($data) {
			if (!preg_match ('#<jdoc:include\ type="([^"]+)" (.*)\/>#iU', $data)) {				
				$mainframe = JFactory::getApplication();
				$token	= JUtility::getToken();
				$search = '#<input type="hidden" name="[0-9a-f]{32}" value="1" />#';
				$replacement = '<input type="hidden" name="'.$token.'" value="1" />';
				$data = preg_replace( $search, $replacement, $data );

				JResponse::setBody($data);
	
				echo JResponse::toString($mainframe->getCfg('gzip'));
	
				if(JDEBUG)
				{
					global $_PROFILER;
					$_PROFILER->mark('afterCache');
					echo implode( '', $_PROFILER->getBuffer());
				}
				
				$mainframe->close();
			}		
		}
		//Preload template
		t3import ('core.preload');
		$preload = T3Preload::getInstance ();
		$preload->load ();
			
		$doc =& JFactory::getDocument();
		$t3 = T3Template::getInstance($doc);
		$t3->_html = $data;
	}
	
	function init_layout () {
		$t3 = T3Template::getInstance();
		if (!$t3->_html) $t3->loadLayout();
	}
}	