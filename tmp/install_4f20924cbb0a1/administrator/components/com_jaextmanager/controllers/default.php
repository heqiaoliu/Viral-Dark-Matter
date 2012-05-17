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

class JaextmanagerControllerDefault extends JaextmanagerController {

	function __construct($default = array()) {
		parent::__construct($default);

		// Register Extra tasks
		$this->registerTask( 'back', 'back' );
		$this->registerTask( 'cancel', 'cancel' );
		$this->registerTask( 'compare', 'compare' );
		$this->registerTask( 'files_compare', 'filesCompare' );
		$this->registerTask( 'changelog', 'changelog' );
		$this->registerTask( 'checkupdate', 'checkUpdate' );
		$this->registerTask( 'upgrade', 'upgrade' );
		$this->registerTask( 'recovery', 'recovery' );
		$this->registerTask( 'rollback', 'rollback' );
		$this->registerTask( 'list_backup_conflicted', 'listBackupConflicted' );
		$this->registerTask( 'compare_conflicted', 'compareConflicted' );
		$this->registerTask( 'files_compare_conflicted', 'compareFilesConflicted' );
		$this->registerTask( 'save_file', 'saveFile' );
		$this->registerTask( 'config_service', 'configService' );
		$this->registerTask( 'config_license', 'configLicense' );
		$this->registerTask( 'config_extensions', 'configExtensions' );
		$this->registerTask( 'config_multi_extensions', 'configMultiExtensions' );
	}

	/**
   * Display the list of import bills
   */
	function display() {
		parent::display();
	}

	function back() {
		$this->setRedirect($this->getLink());
	}

	function cancel() {
		$this->setRedirect( $this->getLink(), "Action canceled" );
	}

	function checkUpdate() {
		JRequest::setVar('layout', 'checkupdate');
		parent::display();
	}
	
	function checkSettings() {
		$model = &$this->getModel('default');
		$params = $model->getComponentParams();
		
		$errors = "";
		if($params->get('MYSQL_PATH') == '') {
			$errors .= JText::_("MYSQL_PATH_IS_NOT_CONFIGED") . "<br />";
		}
		if($params->get('MYSQLDUMP_PATH') == '') {
			$errors .= JText::_("MYSQL_DUMP_PATH_IS_NOT_CONFIGED") . "<br />";
		}
		if($params->get('DATA_FOLDER','') == '') {
			$errors .= JText::_("LOCAL_REPOSITORY_PATH_IS_NOT_CONFIGED") . "<br />";
		}
		return $errors;
	}

	function upgrade() {
		if(strtoupper($_SERVER['REQUEST_METHOD']) != 'POST') {
			//$this->setRedirect($this->getLink(), JText::_("INVALID_REQUEST"));
			die(JText::_("INVALID_REQUEST"));
		}
		
		$errors = $this->checkSettings();
		if(!empty($errors)) {
			$errors = JText::_("ERRORS_OCCURED_DURING_UPGRADING_PLEASE_FIX_THEM_FIST") . "<br />" . $errors;
			die($errors);
		}
		
		$message = '';
		$model = &$this->getModel('default');
		$version = $model->doUpgrade();
		if ($version === false) {
			$message = JText::_("UPGRADE_FAILURED");
		} else {
			$message =  JText::sprintf("SUCCESSFULLY_UPGRADED_TO_VERSION_S_PLEASE_REFRESH_THIS_PAGE_TO_SEE_THE_VERSION_UPDATE", $version);
		}
		die($message);
		// $this->setRedirect($this->getLink(), $message);
	}

	function recovery() {
		JRequest::setVar('layout', 'recovery');
		parent::display();
	}
	
	function doRecovery() {
		if(strtoupper($_SERVER['REQUEST_METHOD']) != 'POST') {
			//$this->setRedirect($this->getLink(), JText::_("INVALID_REQUEST"));
			die(JText::_("INVALID_REQUEST"));
		}
		
		$errors = $this->checkSettings();
		if(!empty($errors)) {
			$errors = JText::_("ERRORS_OCCURED_DURING_ROLLING_BACK_PLEASE_FIX_THEM_FIST") . "<br />" . $errors;
			die($errors);
		}
		
		JRequest::setVar('layout', 'doRecovery');
		parent::display();
	}
	
	function compare() {
		JRequest::setVar('layout', 'diff_view');
		parent::display();
	}
	
	function filesCompare() {
		JRequest::setVar('layout', 'files_compare');
		parent::display();
	}
	
	/**CONFLICTED COMPARE & SOLVE**/
	function listBackupConflicted() {
		JRequest::setVar('layout', 'list_backup_conflicted');
		parent::display();
	}
	
	function compareConflicted() {
		JRequest::setVar('layout', 'compare_conflicted');
		parent::display();
	}
	
	function compareFilesConflicted() {
		JRequest::setVar('layout', 'files_compare_conflicted');
		parent::display();
	}
	
	function saveFile() {
		$side = JRequest::getVar('side', '');
		$side = strtolower($side);
		$backUrl = JRequest::getVar('backUrl', $this->getLink());
		$sameContent = JRequest::getInt('sameContent', 0);
		
		$message = "";
		if(count($_POST) && ($side == 'left' || $side == 'right')) {
			$sideUpper = ucfirst($side);
			$file = $_POST['file' . $sideUpper];
			$file = FileSystemHelper::clean($file);
			
			$otherSide = $side == 'left' ? 'right' : 'left';
			$otherSideUpper = ucfirst($otherSide);
			$otherSideEditabled = JRequest::getInt("editabled" . $otherSideUpper, 0);
			$fileOther = $_POST['file' . $otherSideUpper];
			if(!$otherSideEditabled && $sameContent && JFile::exists($fileOther)) {
				//if compared side is not editabled
				//and two sides is the same content
				//therefore, content of this side is the same with original content of compared side
				$copyBinary = true;
			}
			
			if(JFile::exists($file)) {
				if($copyBinary) {
					JFile::copy($fileOther, $file);
				} elseif (isset($_POST['src' . $sideUpper])) {
					$src = html_entity_decode($_POST['src' . $sideUpper]);
					JFile::write($file, $src);
				}
				
				$message = JText::sprintf("SUCCESS_WROTE_TO_FILE_S", $file);
			} else {
				$message = JText::_("CONTENT_IS_NOT_WROTE_BECAUSE_MISSING_SOME_INFORMATION");
			}
			/*echo "<pre>";
			print_r($_POST);
			echo "</pre>";
			die();*/
		}
		$this->setRedirect($backUrl, $message);
	}
	/**/
	function changelog() {
		$message = '';
		$model = &$this->getModel('default');
		$log = $model->getChangeLog();
		echo nl2br($log);
		die();
	}
	
	function configService(){
		$model = &$this->getModel('default');
		
		$data = JRequest::getVar('params', array());
		$param = $model->storeComponentParams($data);
		
		$msg = JText::_('YOUR_SETTING_IS_SUCCESSFULLY_SAVED');
		$this->setRedirect( "index.php?option=".JACOMPONENT."&view=default&layout=".JRequest::getVar("layout"), $msg );
	}
	
	function configLicense(){
		$model = &$this->getModel('default');
		
		$data = JRequest::getVar('params', array());
		$param = $model->storeComponentParams($data);
		//
		$msg = JText::_('YOUR_SETTING_IS_SUCCESSFULLY_SAVED');
		$this->setRedirect( "index.php?option=".JACOMPONENT."&view=default&layout=".JRequest::getVar("layout"), $msg );
	}
	
	function configExtensions() {
		$model = &$this->getModel('default');
		
		$data = JRequest::getVar('params', array());
		$result = $model->storeExtensionSettings($data);
		
		$pro = $model->_getProduct();
		//
		$helper = new JAFormHelpers();
		if($result !== false) {
			$reload = 0;
			$number = 0;
			$objects [] = $helper->parseProperty ( "reload", "#reload", $reload );
			if(!$reload){
				$objects [] = $helper->parseProperty ( "html", "#system-message", $helper->message ( 0, JText::_('YOUR_SETTING_IS_SUCCESSFULLY_SAVED', true) ) );
				$serviceName = JRequest::getVar("service-name-" . $data[$pro->extId]);
				$objects [] = $helper->parseProperty ( "html", "#config" . $pro->extId, $serviceName, $number );
			}
			
		} else {
			$objects [] = $helper->parseProperty ( "html", "#system-message", $helper->message ( 1, JText::_('YOUR_SETTING_IS_UNSUCCESSFULLY_SAVED', true) ) );
		}

		$data = "({'data':[";

		$data .= $helper->parse_JSON ( $objects );

		$data .= "]})";

		echo $data;
		exit ();
	}
	
	function configMultiExtensions() {
		$model = &$this->getModel('default');
		$cId = JRequest::getVar('cId', array(), '', 'array');
		$service_id = JRequest::getVar('service_id');
		
		if($service_id && count($cId)) {
			$data = array();
			
			foreach ($cId as $extKey) {
				$data[$extKey] = $service_id;
			}
			$result = $model->storeExtensionSettings($data);
			if($result !== false) {
				$msg = JText::_('YOUR_SETTING_IS_SUCCESSFULLY_SAVED');
			} else {
				$msg = JText::_('YOUR_SETTING_IS_UNSUCCESSFULLY_SAVED');
			}
		}
		$this->setRedirect( "index.php?option=".JACOMPONENT."&view=default&extionsion_type=".JRequest::getVar("extionsion_type")."&search=".JRequest::getVar("search"), $msg );
	}
	
	function doUpload() {
		$model = $this->getModel ( 'uploader' );
		$result = $model->upload();
		
		JRequest::setVar('uploadResult', $result, 'post');
		JRequest::setVar('layout', 'uploader');
		parent::display();
	}
}
