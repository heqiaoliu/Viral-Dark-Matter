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
defined( '_JEXEC' ) or die( 'Restricted access' );

jimport( 'joomla.application.component.model' );
jimport('joomla.filesystem.file');

/**
 * Default Model
 *
 * @package   Joomla
 * @subpackage  Updater
 * @since   1.5
 */
class JaextmanagerModelDefault extends JModel {

	var $_components = array();
	var $_updateComponents = array();
	var $_updateExtensions = array();
	var $_bkPkgs = array();
	var $_component = null;

	/** @var object JPagination object */
	var $_pagination = null;
	
	var $coreExts = array();
	
	var $supportedTypes = array();

	function __construct() {
		// Initialise variables.
		$app = JFactory::getApplication('administrator');

		parent::__construct();

		// Set state variables from the request
		/*$this->setState('pagination.limit', $mainframe->getUserStateFromRequest('global.list.limit', 'limit', $mainframe->getCfg('list_limit'), 'int'));
		$this->setState('pagination.offset',$mainframe->getUserStateFromRequest(JACOMPONENT.'.limitstart.update', 'limitstart', 0, 'int'));
		$this->setState('pagination.total', 0);*/
		
		//
		$this->coreExts = array(
			//components
			"'com_mailto'", "'com_wrapper'", "'com_admin'", "'com_banners'", "'com_cache'", 
			"'com_categories'", "'com_checkin'", "'com_contact'", "'com_cpanel'", "'com_installer'", 
			"'com_languages'", "'com_login'", "'com_media'", "'com_menus'", "'com_messages'", "'com_modules'", 
			"'com_newsfeeds'", "'com_plugins'", "'com_search'", "'com_templates'", "'com_weblinks'", "'com_content'", 
			"'com_config'", "'com_redirect'", "'com_users'", 
			//modules
			"'mod_articles_archive'", "'mod_articles_latest'", "'mod_articles_popular'", "'mod_banners'", "'mod_breadcrumbs'", 
			"'mod_custom'", "'mod_feed'", "'mod_footer'", "'mod_login'", "'mod_menu'", "'mod_articles_news'", "'mod_random_image'", 
			"'mod_related_items'", "'mod_search'", "'mod_stats'", "'mod_syndicate'", "'mod_users_latest'", "'mod_weblinks'", 
			"'mod_whosonline'", "'mod_wrapper'", "'mod_articles_category'", "'mod_articles_categories'", "'mod_languages'", 
			"'mod_custom'", "'mod_feed'", "'mod_latest'", "'mod_logged'", "'mod_login'", "'mod_menu'", "'mod_online'", "'mod_popular'", 
			"'mod_quickicon'", "'mod_status'", "'mod_submenu'", "'mod_title'", "'mod_toolbar'", "'mod_unread'", 
			//plugins
			"'gmail'", "'joomla'", "'ldap'", "'emailcloak'", "'geshi'", "'loadmodule'", "'pagebreak'", "'pagenavigation'", "'vote'", 
			"'codemirror'", "'none'", "'tinymce'", "'article'", "'image'", "'pagebreak'", "'readmore'", "'categories'", "'contacts'", 
			"'content'", "'newsfeeds'", "'weblinks'", "'languagefilter'", "'p3p'", "'cache'", "'debug'", "'log'", "'redirect'", "'remember'", 
			"'sef'", "'logout'", "'contactcreator'", "'joomla'", "'profile'", 
			//templates
			"'atomic'", "'rhuk_milkyway'", "'bluestork'", "'beez_20'", "'hathor'", "'beez5'");
		
		$this->supportedTypes = array("'component'", "'module'", "'plugin'", "'template'");
	}

	function &getUri() {
		global $compUri;
		return "$compUri&view=update";
	}
	
	function &getPagination() {
		if (empty($this->_pagination)) {
			return null;
		}
		return $this->_pagination;
	}
	
	function getListExtensions() {
		//fix bug paging if checkbox is checked
		JRequest::setVar('cId', array());
		
		$lists = $this->_getUsListExtensions ();
		$total = $this->_getTotalExtensions($lists);
		if ($lists ['limit'] > $total) {
			$lists ['limitstart'] = 0;
		}
		if ($lists ['limit'] == 0) {
			$limit = $total;
		} else {
			$limit = $lists['limit'];
		}
		
		
		if (empty($this->_updateExtensions)) {
			$this->_loadExtensions($lists['limitstart'], $limit, $lists);
		}
		
		jimport ( 'joomla.html.pagination' );
		$this->_pagination = new JPagination ( $total, $lists ['limitstart'], $lists ['limit'] );
		
		return $this->_updateExtensions;
		
	}
	/**
	 * get User State
	 *
	 * @return unknown
	 */
	function _splitTypes($cIds) {
		$aSupportedTypes = array('component', 'module', 'plugin', 'template');
		$aIds = array();
		foreach ($cIds as $eId) {
			$id = explode('-', $eId);//format: type-id
			//
			if(isset($id[1])) {
				$aIds[] = (int) $id[1];
			}
		}
		return $aIds;
	}
	
	function _getUsListExtensions() {
		// Initialise variables.
		$mainframe = JFactory::getApplication('administrator');
		$option=JACOMPONENT;
		$lists = array ();
		$lists ['filter_order'] = $mainframe->getUserStateFromRequest ( $option . '.filter_order', 'filter_order', 't.id', 'string' );
		$lists ['filter_order_Dir'] = $mainframe->getUserStateFromRequest ( $option . '.filter_order_Dir', 'filter_order_Dir', 'desc', 'word' );
		$lists ['limit'] = $mainframe->getUserStateFromRequest ( $option . '.limit', 'limit', 20, 'int' );
		$lists ['limitstart'] = $mainframe->getUserStateFromRequest ( $option . '.limitstart', 'limitstart', 0, 'int' );
		$lists ['search'] = $mainframe->getUserStateFromRequest ( $option . '.search', 'search', JRequest::getVar( 'search', ''), 'string' );
		$lists ['status'] = $mainframe->getUserStateFromRequest ( $option . '.status', 'status', '0', 'int' );
		$lists ['extionsion_type'] = $mainframe->getUserStateFromRequest ( $option . '.extionsion_type', 'extionsion_type', JRequest::getVar( 'type', ''), 'string' );
		// In case limit has been changed, adjust limitstart accordingly
		$limit = $lists ['limit'];
		$limitstart = ( $limit != 0 ? (floor($lists ['limitstart'] / $limit) * $limit) : 0 );
		$lists ['limitstart'] = $limitstart;
		
		return $lists;
	}	
	
	function _getFilterExtensions() {
		$lists = $this->_getUsListExtensions();
		$keyword = empty($lists['search']) ? '' : $lists['search'];
		
		//default filter
		$filter = " AND protected <> 1 AND `element` <> '' ";
		
		//filter by extension type
		$filter = " AND (`type` = " . implode(" OR `type` = ", $this->supportedTypes).") ";
		
		//filter by core extensions
		$filter .= "AND `element` <> " . implode(" AND `element` <> ", $this->coreExts)." ";
		
		//filter by keyword
		$filter .= "AND (name LIKE '%{$keyword}%' OR '' = '{$keyword}') ";
		
		//filter by extension id
		$cIds = JRequest::getVar('cId', array(), '', 'array');
		if(!empty($cIds)) {
			$aIds = $this->_splitTypes($cIds);
			$filter .= "AND extension_id IN (".implode(',', $aIds).") ";
		}
		
		return $filter;
	}
	
	function _getTotalExtensions($lists) {
		$db =& JFactory::getDBO();
		$type = (JRequest::getVar('type', '') != '') ? JRequest::getVar('type') : $lists['extionsion_type'];
		$sFilter = $this->_getFilterExtensions();
		
		$query = "
			SELECT COUNT(extension_id) FROM #__extensions 
			WHERE (`type` = ".$db->Quote($type)." OR '' = ".$db->Quote($type).")
			{$sFilter}
		";
		$db->setQuery ( $query );
		return $db->loadResult ();
	}
	
	function _loadExtensions($limitstart=0, $limit=20, $lists = array()) {
		// Initialise variables.
		$app = JFactory::getApplication('administrator');
		$type = (JRequest::getVar('type', '') != '') ? JRequest::getVar('type') : $lists['extionsion_type'];
		$sFilter = $this->_getFilterExtensions();
		
		$db =& JFactory::getDBO();
		
		$query = "
				SELECT 
					`type`, `element` AS extKey,
					extension_id AS id, name, params, protected, `state` AS enabled, 
					element, client_id, folder 
				FROM #__extensions 
				WHERE (`type` = ".$db->Quote($type)." OR '' = ".$db->Quote($type).")
				{$sFilter} 
				GROUP BY extension_id
				ORDER BY `type`, name
				LIMIT {$limitstart}, {$limit}";
		//echo nl2br($query);
		//die($query);
		$db->setQuery($query);
		$rows = $db->loadObjectList();

		$this->_updateExtensions = array();
		$aSettings = $this->getListExtensionSettings();
		$services = jaGetListServices();
		$helper = new JaextmanagerHelper($aSettings, $services);
		foreach ($rows as $obj) {
			if (($obj2 = $helper->loadExtension($obj, $obj->type)) !== false) {
				$this->_updateExtensions[] = $obj2;
			}
		}
	}
	
	function getListExtensionType() {
		$aData = array();
		$aData[] = JHTML::_( 'select.option', '', JText::_('ALL') );
		$aData[] = JHTML::_( 'select.option', 'component', JText::_('COMPONENTS') );
		$aData[] = JHTML::_( 'select.option', 'module', JText::_('MODULES') );
		$aData[] = JHTML::_( 'select.option', 'plugin', JText::_('PLUGINS') );
		$aData[] = JHTML::_( 'select.option', 'template', JText::_('TEMPLATES') );
		return $aData;
	}
	
	function _getProduct() {
		$this->_updateExtensions = array();
		
		$cIds = JRequest::getVar('cId', array(), '', 'array');
		if(!isset($cIds[0])) {
			return false;
		}
		
		list($type, $id) = explode('-', $cIds[0]);
		JRequest::setVar('type', $type);
		
		$this->_loadExtensions();
		
		if(!isset($this->_updateExtensions[0])) {
			return false;
		}
		return $this->_updateExtensions[0];
	}

	//Step 1 - check update
	function getNewVersions() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			$css = "status-not-support";
			$status = JText::_('THIS_EXTENSION_IS_NOT_SUPPORTED');
		}
		$uploadScript = " <br />[<a href=\"#\" onclick=\"jaOpenUploader(); return false;\" title=\"".JText::_("UPLOAD_VERSION_PACKAGE")."\">".JText::_("UPLOAD_NOW")."</a>]";
		$versionsNote = JText::_("A_VERSION_IS_CONSIDERRED_AS_NEW_VERSION_IF_WE_DETECT_A_HIGHER_NUMBER_IN_XML_FILE");
		$versionsNote = preg_replace("/\r\n/", "", $versionsNote);
		
		$versions = $jauc->getNewerVersions($obj);
		if($versions === false) {
			if($jauc->isLocalMode($obj)) {
				$css = "status-not-uploaded";
				
				$tipid = uniqid("ja-tooltip-");
				$title = JText::sprintf("IT_SEEM_NO_VERSION_OF_S_HAS_BEEN_UPLOADED_TO_S", $obj->name, "<br /><strong>".$jauc->getLocalVersionsPath($obj, false) ."</strong><br />") ;
				$linkRepo = "<a id=\"{$tipid}\" class=\"ja-tips-title\" href=\"#\" title=\"\" >".JText::_("REPOSITORY")."</a>";
				$status = JText::sprintf("SORRY_NO_VERSION_UPLOADED_IN_S", $linkRepo);
				
				$script = jaEMTooltips($tipid, $title);
			} else {
				//this extensions is not an service' extension
				$css = "status-not-found";
				$status = JText::_("PLEASE_UPDATE_THE_SERVICE_SETTING_OR_CONTACT_WITH_SERVICE_PROVIDER");
			}
		} else {
		
			if (!is_object($versions)) {
				$css = "status-not-support";
				$status = JText::_('THIS_EXTENSION_IS_NOT_SUPPORTED');
			} else {
				$extID 		= $obj->extId;
				$css = "status-new";
				
				$tipid 		= uniqid("ja-tooltip-");
				$title		= "<sup><a href=\"#\" id=\"{$tipid}\" class=\"ja-tips-title\" title=\"\">".JText::_("")."</a></sup>";
				$status 	= JText::sprintf("NEW_VERSION_FOUND_S", $title);
				$status		.= jaEMTooltips($tipid, $versionsNote);
				$lastest 	= '';
				
				$index		= 0;
				$showOnly	= 1;
				$more = 0;	
				foreach ($versions as $v => $vInfo) {
					$index++;
					if(isset($vInfo->lastest)) {
						$lastest = $vInfo->version;
					}
					/*if ( $index == $showOnly + 1 ) {
						$more = 1;
						$status .= '<br/> <a href="#" style="color:#800000" onclick="showMoreOlderVersion(this, \'olderVersion'.$extID.'\'); return false;">'.JText::_("MORE").'</a>';
						$status .= '<br/> <div id="olderVersion'.$extID.'" style="display:none">';
					}*/
					
					$status .= '<br />';
					$status .= "- {$v} <sup style=\"color:red;\">[New!";
					$status .= (isset($vInfo->releaseDate) ?  " " . $vInfo->releaseDate : '').(isset($vInfo->lastest) ?  " - " .JText::_('LASTEST') : '');
					$status .= "]</sup>";
					if(isset($vInfo->notSure)) {
						$tipid = uniqid("ja-tooltip-");
						$title = "++++++++<br />".JText::sprintf("WE_CAN_NOT_DETECT_WHICH_IS_A_NEWER_VERSION_BETWEEN__S_AND_S_",$obj->version, $v) . $versionsNote;
						$status .= "<sup style=\"color:#FF6600;\" id=\"{$tipid}\">[!Notice]</sup>";
						$status .= jaEMTooltips($tipid, $title);
					}
					if(isset($vInfo->changelogUrl) && !empty($vInfo->changelogUrl)) {
						$status .= ' <a href="'.$vInfo->changelogUrl.'" title="'.JText::_('SHOW_CHANGE_LOG').'" target="_blank" >'.JText::_('CHANGE_LOG').'</a>';
					}
					$status .= ' - <a href="index.php?option='.JACOMPONENT.'&view=default&task=compare&cId[]='.$extID.'&version='.$v.'" title="'.JText::_('VIEW_DIFFERENCE_BETWEEN_TWO_VERSIONS').'">'.JText::_('COMPARE').'</a>';
					$status .= ' - <a href="#" onclick="doUpgrade(\''.$extID.'\', \''.$v.'\', \'LastCheckStatus_'.$extID.'\'); return false;" title="'.JText::_('UPGARDE_TO_NEW_VERSION_NOW').'">'.JText::_('UPGRADE_NOW').'</a>';
				}
				/*if ( $more ) {
					$status .= '</div>';
				}*/
				
				if($index == 0) {
					if($jauc->isLocalMode($obj)) {
						$css = "status-normal";
						
						$tipid = uniqid("ja-tooltip-");
						$title = JText::sprintf("S_NEW_VERSIONS_ARE_STORED_AT_S_IF_YOU_HAVE_NEW_VERSION_UPLOAD_IT_OR_DO_IT_VIA_FTP", $obj->name, "<br /><strong>".$jauc->getLocalVersionsPath($obj, false) ."</strong><br />") ;
						$linkRepo = "<a id=\"{$tipid}\" class=\"ja-tips-title\" href=\"#\" title=\"\">".JText::_("REPOSITORY")."</a>";
						$status = JText::sprintf('NO_NEW_VERSION_FOUND_IN_S', $linkRepo);
						
						$script = jaEMTooltips($tipid, $title);
					} else {
						//$css = "status-lastest";
						$css = "status-normal";
						$status = JText::_("NO_NEW_VERSION_FOUND");
					}
				}
			}
			
		}
		if($jauc->isLocalMode($obj)) {
			$status .= $uploadScript;
		}
		$status = "<div class=\"{$css}\">{$status}</div>";
		if(isset($script)) {
			$status .= $script;
		}
		
		$this->storeLastCheck($obj->extId, addslashes($status));
		
		return $status;
	}
	
	// Store last check status
	function storeLastCheck($objID, $status){
		$db =& JFactory::getDBO();
		
		$query = "
			INSERT INTO #__jaem_log (ext_id, check_date, check_info)
			VALUES ('".$objID."', '".date('Y-m-d H:i:s')."', '".addslashes($status)."')
			ON DUPLICATE KEY UPDATE
				check_date = '".date('Y-m-d H:i:s')."',
				check_info = '".addslashes($status)."'";
		$db->setQuery($query);
		$db->query();
	}
	
	function getLastCheckStatus($aSettings, $extId){
		if(isset($aSettings->$extId)){
			return stripslashes($aSettings->$extId->check_info);
		}
		return '';
	}
	
	function getListExtensionSettings(){
		static $aSettings = null;
		if(is_null($aSettings)) {
			$db =& JFactory::getDBO();
			
			$query = "SELECT * FROM #__jaem_log WHERE 1";
			$db->setQuery($query);
			$rows = $db->loadObjectList();
			
			$aSettings = new stdClass();
			if(count($rows)){
				foreach($rows as $item) {
					$aSettings->{$item->ext_id} = $item;
				}
			}
		}
		return $aSettings;
	}
	
	//2. Update view
	function getDiffView() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return false;
		}
		$version 	= JRequest::getVar('version');
		
		$upgradeInfo = $jauc->buildDiff($obj, $version);
		if($upgradeInfo === false) {
			return false;
		} else {
			$obj->diffInfo = $upgradeInfo;
			return $obj;
		}
		
		/*try{
			$upgradeInfo = $jauc->buildDiff($obj, $version);
			$obj->diffInfo = $upgradeInfo;
			return $obj;
		} catch( Exception $e ) {
			JError::raiseWarning(0, $e->getMessage());
			return false;
		}*/
	}
	
	//2.1 display list of conflicted files
	function getBackupConflicted() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return false;
		}
		$folder	= JRequest::getVar('folder', ''); 
		if(empty($folder)) {
			return false;
		}
		$obj->conflictedDir = $jauc->getLocalConflictPath($obj, $folder);
		return $obj;
	}
	
	//2.3 compare conflicted files
	function getDiffFilesConflicted() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return false;
		}
		$folder 	= JRequest::getVar('folder');
		$file 	= JRequest::getVar('file');
		
		$obj->diffFolder = $folder;
		$obj->diffFile = $file;
		
		if(count($_POST)) {
			//$str1 = JRequest::getVar('srcLeft','','post','string',JREQUEST_ALLOWHTML); 
			//$str2 = JRequest::getVar('srcRight','','post','string',JREQUEST_ALLOWHTML);
			
			$diff = new jaDiffTool();
			$objLeft = $diff->buildObject(
				stripslashes(JRequest::getVar('titleLeft', '', 'post')),
				stripslashes(JRequest::getVar('fileLeft', '', 'post')),
				stripslashes($_POST['srcLeft']),
				JRequest::getInt('editabledLeft', 0, 'post'));
				
			$objRight = $diff->buildObject(
				stripslashes(JRequest::getVar('titleRight', '', 'post')),
				stripslashes(JRequest::getVar('fileRight', '', 'post')),
				stripslashes($_POST['srcRight']),
				JRequest::getInt('editabledRight', 0, 'post'));
			
			$result = $diff->compare($objLeft, $objRight);
			
			$obj->diffInfo = $result;
			return $obj;
		} else {
			$result = $jauc->buildDiffFilesConflicted($obj);
			if($result === false) {
				JError::raiseWarning(0, JText::_("FAILURED_TO_BUILD_DIFFERENCE_VIEW"));
				return false;
			} else {
				$obj->diffInfo = $result;
				return $obj;
			}
			
		}
	}
	
	//2.2 compare files
	function getDiffFiles() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return false;
		}
		$type 	= JRequest::getVar('diff_type');
		$file 	= JRequest::getVar('file');
		$version 	= JRequest::getVar('version');
		
		$obj->diffType = $type;
		$obj->diffFile = $file;
		
		if(count($_POST)) {
			$diff = new jaDiffTool();
			$objLeft = $diff->buildObject(
				stripslashes(JRequest::getVar('titleLeft', '', 'post')),
				stripslashes(JRequest::getVar('fileLeft', '', 'post')),
				stripslashes($_POST['srcLeft']),
				JRequest::getInt('editabledLeft', 0, 'post'));
				
			$objRight = $diff->buildObject(
				stripslashes(JRequest::getVar('titleRight', '', 'post')),
				stripslashes(JRequest::getVar('fileRight', '', 'post')),
				stripslashes($_POST['srcRight']),
				JRequest::getInt('editabledRight', 0, 'post'));
			
			$result = $diff->compare($objLeft, $objRight);
			
			$obj->diffInfo = $result;
			return $obj;
		} else {
			$result = $jauc->buildDiffFiles($obj, $version);
			if($result === false) {
				return false;
			} else {
				$obj->diffInfo = $result;
				return $obj;
			}
			
		}
	}
	
	//3. View change log
	function getChangeLog() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return JText::_('THIS_PRODUCT_IS_NOT_SUPPORTED');
		}
		
		$version 	= JRequest::getVar('version');
		
		$log = $jauc->getChangeLog($obj, $version);
		if($log === false) {
			return JText::_("FAIL_TO_GET_CHANGE_LOG");
		} else {
			return $log;
		}
		/*try {
			return $jauc->getChangeLog($obj, $version);
		} catch (Exception $e) {
			return $e->getMessage();
		}*/
	}
	
	//4. Do Upgrade
	function doUpgrade() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return JText::_('THIS_PRODUCT_IS_NOT_SUPPORTED');
		}

		$version 	= JRequest::getVar('version');
		
		$obj->message = JRequest::getVar('comment', '');
		
		$result = $jauc->doUpgrade($obj, $version);
		if($result === false) {
			return false;
		} else {
			$message = JText::_("YOU_HAVE_SUCCESSFULLY_UPGRADED_FROM_VERSION_FROM_VERSION_TO_VERSION_TO_VERSION_AT_TIME");
			$message = str_replace(
						array('{from_version}', '{to_version}', '{time}'), 
						array($obj->version, $version, date('d M Y, H:i:s')), 
						$message);
			$this->storeLastCheck($obj->extId, $message);
			return $version;
		}
		/*try {
			$jauc->doUpgrade($obj, $version);
		} catch (Exception $e) {
			echo $e->getMessage();
			return false;
		}*/
		return $version;
	}
	
	function getListBackupConflicted() {
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return JText::_('THIS_PRODUCT_IS_NOT_SUPPORTED');
		}
		$version 	= JRequest::getVar('version');
		
		$list = $jauc->listBackupConflicted($obj, $version);
		if($list === false) {
			return false;
		} else {
			return $list;
		}
	}
	
	
	// Listing extension recover files 
	function getListRecoveryFiles(){
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return JText::_('THIS_PRODUCT_IS_NOT_SUPPORTED');
		}
		$version 	= JRequest::getVar('version');
		
		$list = $jauc->listBackupFiles($obj, $version);
		if($list === false) {
			return false;
		} else {
			return $list;
		}
		
		/*try {
			$list = $jauc->listBackupFiles($obj, $version);
			return $list;
		} catch (Exception $e) {
			// echo $e->getMessage();
			return false;
		}*/
	}
	
	// Recovery file
	function doRecoveryFile(){
		global $jauc;
		
		$obj = $this->_getProduct();
		if($obj === false) {
			return JText::_('THIS_PRODUCT_IS_NOT_SUPPORTED');
		}
		$file 	= JRequest::getVar('file');
		
		$obj->message = JRequest::getVar('comment', '');
		
		$result = $jauc->doRecoveryFile($obj, $file);
		if($result === false) {
			echo JText::_("FAIL_TO_RECOVERY");
			return false;
		} else {
			$this->storeLastCheck($obj->extId, JText::_("YOU_ARE_SUCCESSFULLY_ROLLBACK_AT") . date('d M Y, H:i:s'));
			return $result;
		}
		
		/*try {
			$result = $jauc->doRecoveryFile($obj, $file);
			return $result;
		} catch (Exception $e) {
			echo $e->getMessage();
			return false;
		}*/
	}
	
	function getSourceCode() {
		global $jauc;
		$product = $this->_getProduct();
		$pro = $jauc->getProduct($product);
		$file = JRequest::getVar('file');
		$fileLive = $pro->getFilePath($file);
		if(JFile::exists($fileLive)) {
			$source = file_get_contents($fileLive);
			return $source;
		} else {
			return false;
		}
	}
	
	function getRemoteSourceCode() {
		global $jauc;
		$product = $this->_getProduct();
		
		$version = JRequest::getVar('version');
		$file = JRequest::getVar('file');
		return $jauc->getFileContent($product, $version, $file);
	}
	
	function &getConfigService() {
		global $jauc;
		
		$params = $this->getComponentParams();
		//get mysql variables
		if ( substr(PHP_OS,0,3) == 'WIN') {
			$db =& JFactory::getDBO();
			$query = 'SHOW VARIABLES';
			$db->setQuery($query);
			$rs = $db->loadObjectList();
			$aMysqlVariables = array();
			foreach ($rs as $row) {
				$aMysqlVariables[$row->Variable_name] = $row->Value;
			}
			$pathMysql = (isset($aMysqlVariables['basedir'])) ? $aMysqlVariables['basedir'] . 'bin'.DS.'mysql' : 'mysql';
			$pathMysqldump = (isset($aMysqlVariables['basedir'])) ? $aMysqlVariables['basedir'] . 'bin'.DS.'mysqldump' : 'mysqldump';
		} else {
			$pathMysql = 'mysql';
			$pathMysqldump = 'mysqldump';
		}
		
		//store default values if user does not save
		$missParams = array();
		if($params->get('MYSQL_PATH') == '') {
			$missParams['MYSQL_PATH'] = $pathMysql;
		}
		if($params->get('MYSQLDUMP_PATH') == '') {
			$missParams['MYSQLDUMP_PATH'] = $pathMysqldump;
		}
		if($params->get('DATA_FOLDER','') == '') {
			$missParams['DATA_FOLDER'] = "jaextmanager_data";
		}
		if(count($missParams)>0) {
			$this->storeComponentParams($missParams);
		}
		
		//
		$pathMysql 		= $params->get("MYSQL_PATH", $pathMysql);
		$pathMysqldump	= $params->get("MYSQLDUMP_PATH", $pathMysqldump);
		
		//validate settings
		jaucValidServiceSettings($params);
		//
		$params->set('MYSQL_PATH', $pathMysql);
		$params->set('MYSQLDUMP_PATH', $pathMysqldump);
		
		return $params;
	}
	
	function getComponentParams(){
		$params = &JComponentHelper::getParams( JACOMPONENT );
		return $params;
	}
	
	function storeComponentParams($data){
		$db =& JFactory::getDBO();
		$query = "SELECT params FROM #__extensions WHERE `element` = '".JACOMPONENT."'";
		$db->setQuery($query);
		$arr = $db->loadAssoc();
		$stdObject = json_decode($arr['params']);
		
		$str_save = "";
		
		foreach ($data as $k=>$v){
			$stdObject->$k = $v;
		}
		$sConfig = json_encode($stdObject);
		
		$query = "UPDATE #__extensions SET params =". $db->Quote($sConfig) ." WHERE `element` = '".JACOMPONENT."'";
		$db->setQuery($query);
		$result = $db->query();
		return $result;
	}
	
	function storeExtensionSettings($data) {
		if(is_array($data) && count($data)) {
			$db =& JFactory::getDBO();
			
			foreach ($data as $extId => $service_id) {
				$query = "
					INSERT INTO #__jaem_log
					SET 
						ext_id = ".$db->Quote($extId).",
						service_id = ".$db->Quote($service_id)."
					ON DUPLICATE KEY UPDATE
						service_id = ".$db->Quote($service_id)."
					";
				$db->setQuery($query);
				$db->query();
			}
		}
	}
}
