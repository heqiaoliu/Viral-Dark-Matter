<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
# Author: JoomlArt.com
# Websites: http://www.joomlart.com - http://www.joomlancers.com.
# ------------------------------------------------------------------------
*/ 

// No direct access
defined( '_JEXEC' ) or die( 'Restricted access' );

jimport( 'joomla.application.component.view');

/**
 * HTML View class for the JAUC Component
 *
 * @package    jauc
 */
class JaextmanagerViewDefault extends JView {
	var $num;

	function __construct( $config = array()) {
		global $option;
		$this->num = 1;
		parent::__construct( $config );
	}

	function display( $tpl = null ) {
		// Display menu
		if(! JRequest::getVar("ajax") && JRequest::getVar('tmpl') != 'component' && JRequest::getVar('viewmenu', 1) != 0){
			$file = JPATH_COMPONENT_ADMINISTRATOR.DS."views".DS."default".DS."tmpl".DS."menu_header.php";
			if(@file_exists($file))
				require_once($file);
		}
		
		// Get layout
		$layout = $this->getLayout();
		switch ($layout){
			case 'checkupdate':
				$this->displayCheckUpdate( $tpl );
				break;
			case 'diff_view':
				$this->displayDiffView( $tpl );
				break;
			case 'files_compare':
				$this->displayDiffFiles( $tpl );
				break;
			case 'files_source':
				//view source code with content get from form difference view
				$this->displaySourceFiles( $tpl );
				break;
			case 'view_source':
				//view source code with content read from file
				$this->displayViewSource( $tpl );
				break;
			case 'view_remote_source':
				//view source code with content read from remote file (or local repository file, depend on service setting of this extension)
				$this->displayViewRemoteSource( $tpl );
				break;
			case 'upgrade':
				$this->displayUpgrade( $tpl );
				break;
			case 'recovery':
				$this->displayRecovery($tpl);
				break;
			case 'doRecovery':
				$this->displayDoRecovery($tpl);
				break;
			case 'list_backup_conflicted':
				$this->displayListBackupConflicted($tpl);
				break;
			case 'compare_conflicted':
				$this->displayFilesConflicted($tpl);
				break;
			case 'files_compare_conflicted':
				$this->displayDiffFilesConflicted($tpl);
				break;
			// Config view layout
			case 'config_service':
				$this->displayConfigService($tpl);
				break;
			case 'config_license':
				$this->displayConfigLicense($tpl);
				break;
			case 'config_general':
				$this->displayConfigGeneral($tpl);
				break;
			case 'config_install':
				$this->displayConfigInstall($tpl);
				break;
			case 'config_extensions':
				$this->displayConfigExtensions($tpl);
				break;
			// Help and support
			case 'help_support':
				$this->displayHelpAndSupport($tpl);
				break;
			// Uploader
			case 'uploader':
				$this->displayUploader($tpl);
				break;
			default:
				$this->displayListItems( $tpl );
		}

		// Display footer
		if(! JRequest::getVar("ajax") && JRequest::getVar('tmpl') != 'component' && JRequest::getVar('viewmenu', 1) != 0){
			$file = JPATH_COMPONENT_ADMINISTRATOR.DS."views".DS."default".DS."tmpl".DS."menu_footer.php";
			if(@file_exists($file))
			require_once($file);
		}
	}

	function displayConfigGeneral($tpl = null){
		JToolBarHelper::save("config_general_save");
		JToolBarHelper::apply("config_general_apply");
		
		// Initialize variables
		$model 	= &$this->getModel('default');		
		$item	= &$this->get('ComponentParams');
		
		$params = new JParameter( $item->params );
				
		$this->assignRef('params', $params);
		
		parent::display( $tpl );
	}
	
	function displayConfigInstall($tpl = null){
		JToolBarHelper::save("save");
		JToolBarHelper::apply("apply");
		parent::display( $tpl );
	}
	
	function displayConfigService($tpl = null){
		JToolBarHelper::save("config_service");
		// Initialize variables
		$model 	= &$this->getModel('default');		
		$this->assignRef('params', $model->getConfigService());
		parent::display( $tpl );
	}
	
	function displayConfigLicense($tpl = null){
		JToolBarHelper::save("config_license");
		// Initialize variables
		$model 	= &$this->getModel('default');		
		$this->assignRef('params', $model->getComponentParams());
		parent::display( $tpl );
	}
	
	function displayConfigExtensions($tpl = null){
		JToolBarHelper::save("config_extensions");
		// Initialize variables
		$model 	= &$this->getModel('default');	
		$extension = $model->_getProduct();
			
		$params = $model->getComponentParams();
		$services = jaGetListServices();
		$configId = $extension->serviceKey;
		$listServices = JHTML::_ ( 'select.radiolist', $services, "params[{$configId}]", 'class="inputbox"', 'id', 'ws_name', $params->get($configId));
		$this->assignRef('listServices', $listServices);
		//print_r($services);
		$this->assignRef('configId', $configId);
		$this->assignRef('services', $services);
		$this->assignRef('params', $params);
		$this->assignRef('extension', $extension);
		parent::display( $tpl );
	}
	
	function displayHelpAndSupport($tpl = null){
		parent::display( $tpl );
	}


	/**
   * Display List of items
   */
	function displayListItems( $tpl = null ) {
		global $mainframe, $option, $jauc;

		/*
		* Set toolbar items for the page
		*/
		
		$services = jaGetListServices();
		foreach ($services as $service) {
			JToolBarHelper::custom('config_extensions_'.$service->id, 'default', 'default', $service->ws_name, true);
		}
		JToolBarHelper::custom('checkupdate', 'preview', 'preview', JText::_('CHECK_UPDATE'), true);
		JToolBarHelper::custom('recovery', 'restore', 'restore', JText::_('ROLLBACK'), true);
		// JToolBarHelper::preferences(JACOMPONENT);
		JToolBarHelper::help('screen.jauc');

		$model = &$this->getModel('default');
		
		//$components = &$this->get("components");
		$listExtensions = $model->getListExtensions();
		$state    		= $this->get('State');
		$pagination 	= $model->getPagination();
		
		$boxType = JHTML::_( 'select.genericlist', $model->getListExtensionType(), 'extionsion_type', 'class="inputbox"', 'value', 'text', JRequest::getVar( 'extionsion_type') );

		//$this->assignRef('components',   $components);
		$this->assignRef('services',  $services);
		$this->assignRef('listExtensions',  $listExtensions);
		$this->assignRef('pagination',  $pagination);
		$this->assignRef('boxType',  $boxType);

		$this->assignRef('comUri', $this->get("comUri"));

		parent::display( $tpl );
	}

	/**
   * Display Check Upgrade layout
   */
	function displayCheckUpdate( $tpl = null ) {
		global $option;

		// Toolbar
		JToolBarHelper::cancel();

		$model = &$this->getModel('default');
		die($model->getNewVersions());
	}

	/**
   * Display Upgrade layout
   */
	function displayUpgrade( $tpl = null ) {
		global $option;

		// Toolbar
		JToolBarHelper::back();

		$model = &$this->getModel();
		$components = $model->upgradeComponent();
		$pagination = &$this->get('Pagination');

		$this->assignRef('pagination',  $pagination);
		$this->assignRef("components", $components);

		parent::display($tpl);
	}

	function displayRecovery($tpl = null) {
		// Toolbar
		$model = &$this->getModel();
		$obj = $model->_getProduct('default');
		
		$model = &$this->getModel();
		$listRecoveryFiles = &$this->get("ListRecoveryFiles");		
		if($listRecoveryFiles){
			$this->assignRef("obj", $obj);
			$this->assignRef("listRecoveryFiles", $listRecoveryFiles);
	
			parent::display($tpl);
		}else {
			echo JText::_("BACKUP_FILES_NOT_FOUND");
		}
		exit();
	}
	
	function displayDoRecovery($tpl = null) {
		// Toolbar
		$cIds = JRequest::getVar('cId', array(), '', 'array');
		$cIds = $cIds[0];
		
		$model = &$this->getModel();
		$versionRollback = $model->doRecoveryFile();
		if($versionRollback !== false){
			echo JText::sprintf("SUCCESSFULLY_ROLLBACKED_TO_VERSION_S_PLEASE_REFRESH_THIS_PAGE_TO_SEE_THE_VERSION_UPDATE", $versionRollback);
		} else {
			echo JText::_("BACKUP_FILE_NOT_FOUND");
		}
		exit();
	}
	
	function displayListBackupConflicted($tpl = null) {
		// Toolbar
		
		$model = &$this->getModel('default');
		$product = $model->_getProduct();
		if($product === false) {
			echo JText::_("EXTENSION_NOT_FOUND");
			exit();
		}
		$listConflicted = &$this->get("ListBackupConflicted");		
		
		if($listConflicted){
			
			foreach ($listConflicted as $folder){
				$link = sprintf("?option=%s&view=default&task=compare_conflicted&cId[]=%s&folder=%s", JACOMPONENT, $product->extId, $folder['name']);
				
				echo $folder['title'].' - 
					 <a href="'.$link.'" title="'.JText::_("COMPARE_WITH_FILES_AT_THIS_POINT").'">
					'.JText::_("VIEW_YOUR_CONFLICTED_FILES").'
					</a>
					'.(isset($folder['comment']) ? '['.$folder['comment'].']' : '').'
					<br />';
			}
		}else {
			echo JText::_("DO_NOT_HAVE_ANY_CONFLICTED_BACKUP_FOLDER");
		}
		exit();
	}
	
	function displayFilesConflicted($tpl = null) {
		global $options;

		// Toolbar
		JToolBarHelper::back();

		$model = &$this->getModel('default');
		$obj = $model->getBackupConflicted();
		
		if($obj !== false) {
			$this->assignRef('obj', $obj);
	
			parent::display($tpl);
		}
	}
	
	function displayDiffFilesConflicted($tpl = null) {
		$model = &$this->getModel('default');
		$obj = $model->getDiffFilesConflicted();
		
		if($obj !== false) {
			$this->assignRef('obj', $obj);
	
			parent::display($tpl);
		}
	}
	
	function displayUploader($tpl = null) {
		$paths = new stdClass();
		$paths->first = '';

		$this->assignRef('paths', $paths);
		$this->assignRef('state', $this->get('state'));
		$this->assignRef('uploadResult', JRequest::getVar('uploadResult', '', 'post', 'none', JREQUEST_ALLOWRAW));

		parent::display($tpl);
	}
	
	function displayDiffView($tpl = null) {
		global $options;

		// Toolbar
		JToolBarHelper::apply("upgrade", "Upgrade");
		JToolBarHelper::cancel();

		$model = &$this->getModel('default');
		$obj = $model->getDiffView();
		
		if($obj !== false) {
			$this->assignRef('obj', $obj);
	
			parent::display($tpl);
		} else {
			//JError::raiseWarning(0, JText::_("FAILURED_TO_BUILD_DIFFERENCE_VIEW"));
			
			$product = $model->_getProduct();
			$message = JText::sprintf("YOUR_ACCOUNT_SEEM_DOES_NOT_HAVE_ENOUGH_PERMISSION_TO_TAKE_THIS_ACTION_PLEASE_CONTACT_S_FOR_MORE_INFORMATION_OR_USE_ANOTHER_ACCOUNT", $product->ws_name);
			$this->displayLoginBox($product, $message);
		}
	}
	
	function displayDiffFiles($tpl = null) {
		
		$model = &$this->getModel('default');
		$obj = $model->getDiffFiles();
		
		if($obj !== false) {
			$this->assignRef('obj', $obj);
	
			parent::display($tpl);
		} else {
			//JError::raiseWarning(0, JText::_("FAILURED_TO_BUILD_DIFFERENCE_VIEW"));
			
			$product = $model->_getProduct();
			$message = JText::sprintf("YOUR_ACCOUNT_SEEM_DOES_NOT_HAVE_ENOUGH_PERMISSION_TO_TAKE_THIS_ACTION_PLEASE_CONTACT_S_FOR_MORE_INFORMATION_OR_USE_ANOTHER_ACCOUNT", $product->ws_name);
			$this->displayLoginBox($product, $message);
		}
	}
	
	function displayLoginBox($obj, $message, $messageType = "message") {
		global $mainframe;
		$backUrl = JURI::current() ."?". $_SERVER['QUERY_STRING'];
		$backUrl = urlencode($backUrl);
		$url = "index.php?tmpl=component&option=".JACOMPONENT."&view=services&viewmenu=0&task=config&cid[]=".$obj->ws_id."&number=1&backUrl=".$backUrl;
		$mainframe->redirect( $url, $message, $messageType );
	}
	
	function displaySourceFiles($tpl = null) {
		parent::display($tpl);
	}
	
	function displayViewSource($tpl = null) {
		$model = &$this->getModel('default');
		$source = $model->getSourceCode();
		if($source !== false) {
			$source = htmlentities($source);
			$this->assignRef('source', $source);
			parent::display($tpl);
		} else {
			JError::raiseWarning(100, JText::_("CAN_NOT_OPEN_THIS_FILE"));
		}
	}
	
	function displayViewRemoteSource($tpl = null) {
		$model = &$this->getModel('default');
		$source = $model->getRemoteSourceCode();
		if($source !== false) {
			$source = htmlentities($source);
			$this->assignRef('source', $source);
			parent::display($tpl);
		} else {
			//JError::raiseWarning(100, JText::_("CAN_NOT_OPEN_THIS_FILE"));
			$product = $model->_getProduct();
			$message = JText::sprintf("YOUR_ACCOUNT_SEEM_DOES_NOT_HAVE_ENOUGH_PERMISSION_TO_TAKE_THIS_ACTION_PLEASE_CONTACT_S_FOR_MORE_INFORMATION_OR_USE_ANOTHER_ACCOUNT", $product->ws_name);
			$this->displayLoginBox($product, $message);
		}
	}
	
	function nicetime($date){
		if(empty($date)) {
			return "No date provided";
		}
	   
		$periods         = array("second", "minute", "hour", "day", "week", "month", "year", "decade");
		$lengths         = array("60","60","24","7","4.35","12","10");
	   
		$now             = time();
		$unix_date       = strtotime($date);
	   
		// check validity of date
		if(empty($unix_date)) {   
			return false;//Bad date
		}
	
		// is it future date or past date
		if($now > $unix_date) {   
			$difference     = $now - $unix_date;
			$tense         = "ago";
		} else {
			$difference     = $unix_date - $now;
			$tense         = "from now";
		}
		
		for($j = 0; $difference >= $lengths[$j] && $j < count($lengths)-1; $j++) {
			$difference /= $lengths[$j];
		}
	   
		$difference = round($difference);
	   
		if($difference != 1) {
			$periods[$j].= "s";
		}
		
		return "$difference $periods[$j] {$tense}";
	}
}
