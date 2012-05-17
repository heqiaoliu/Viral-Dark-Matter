<?php
/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');

defined('JPATH_BASE') or die();

jimport('joomla.filesystem.file');
jimport('joomla.filesystem.folder');
jimport('joomla.filesystem.archive');
jimport('joomla.filesystem.path');

class JaextmanagerControllerServices extends JaextmanagerController
{


	function __construct($default = array())
	{
		
		parent::__construct($default);
		
		$task = JRequest::getWord('task', '');
		switch ($task) {
			case 'add':
			case 'save':
			case 'apply':
			case 'edit':
				JToolBarHelper::apply();
				JToolBarHelper::save();
				JToolBarHelper::cancel();
				break;
			default:
				JToolBarHelper::addNew();
				JToolBarHelper::deleteList();
				JToolBarHelper::makeDefault('publish');
				break;
		}
		// Register Extra tasks
		JRequest::setVar('view', 'services');
		$this->registerTask('add', 'edit');
		$this->registerTask('apply', 'save');
		$this->registerTask('publish', 'setDefault');
	}


	function display()
	{
		
		$user = JFactory::getUser();
		$task = $this->getTask();
		switch ($task) {
			case 'edit':
				JRequest::setVar('layout', 'form');
				break;
			case 'config':
				JRequest::setVar('layout', 'config');
				break;
		}
		if ($user->id == 0) {
			
			JError::raiseWarning(1001, JText::_("YOU_MUST_BE_SIGNED_IN"));
			
			$this->setRedirect(JRoute::_("index.php?option=com_user&view=login"));
			
			return;
		}
		
		parent::display();
	}


	function cancel()
	{
		$this->setRedirect('index.php?option=' . JACOMPONENT . '&view=services');
		
		return TRUE;
	}


	/**
	 * Save service settings
	 *
	 * @param array $errors
	 * @return mixed - return false if there is error, otherwise return service object
	 */
	function save(&$errors = array())
	{
		$task = $this->getTask();
		
		$model = & $this->getModel('services');
		$post = JRequest::get('post');
		
		$post['ws_name'] = JRequest::getString('ws_name', '');
		$post['ws_mode'] = JRequest::getString('ws_mode', 'remote');
		$post['ws_uri'] = JRequest::getString('ws_uri', '');
		$post['ws_user'] = JRequest::getString('ws_user', '');
		$post['ws_pass'] = JRequest::getString('ws_pass', '');
		$post['ws_default'] = JRequest::getInt('ws_default');
		
		$model->setState('request', $post);
		$row = $model->store();
		if (!isset($row->id)) {
			$errors[] = $row;
			return FALSE;
		
		}
		return $row;
	}


	/**
	 * save service settings and return data  to browser as ajax response text.
	 *
	 */
	function saveIFrame()
	{
		global $jauc;
		
		$post = JRequest::get('request', JREQUEST_ALLOWHTML);
		$number = $post['number'];
		$errors = array();
		$row = $this->save($errors);
		
		$helper = new JAFormHelpers();
		
		if (isset($row->id)) {
			$result = true;
			if ($row->ws_mode == 'remote') {
				$model = & $this->getModel('services');
				$row2 = $model->getRow2($row->id);
				$service = new stdClass();
				$service->ws_uri = $row2->ws_uri;
				$service->ws_user = $row2->ws_user;
				$service->ws_pass = $row2->ws_pass;
				
				//authenticate service account
				if ($jauc->authUser($service) == 0) {
					$result = false;
					if (!empty($service->ws_user)) {
						$objects[] = $helper->parseProperty("html", "#system-message", $helper->message(1, JText::_("WRONG_USERNAME_AND_PASSWORD_LOGIN_FAILED_PLEASE_TRY_AGAIN")));
					} else {
						$objects[] = $helper->parseProperty("html", "#system-message", $helper->message(0, JText::_("YOU_ARE_LOGGED_IN_AS_ANONYMOUS_USER")));
					}
				}
			}
			
			if ($result) {
				$id = $row->id;
				$model = & $this->getModel('services');
				
				$listItems = $model->getList(" AND t.id = '{$id}' ", "t.ws_name ASC", 0, 1);
				$item = $listItems[0];
				
				/*$reload = 0;
				 if($post['id']=='0'){
					$reload = 1;
					}*/
				$reload = 1;
				$objects[] = $helper->parseProperty("reload", "#reload" . $item->id, $reload);
				$objects[] = $helper->parseProperty("html", "#system-message", $helper->message(0, JText::_("SAVE_DATA_SUCCESSFULLY")));
				
				if (!$reload) {
					$objects[] = $helper->parseProperty("html", "#ws_name" . $item->id, $item->ws_name);
					$objects[] = $helper->parseProperty("html", "#ws_mode" . $item->id, $item->ws_mode);
					$objects[] = $helper->parseProperty("html", "#ws_uri" . $item->id, $item->ws_uri);
					$objects[] = $helper->parseProperty("html", "#ws_user" . $item->id, $item->ws_user);
					$objects[] = $helper->parseProperty("html", "#ws_pass" . $item->id, $item->ws_pass);
					
					$objects[] = $helper->parsePropertyPublish("html", "#default" . $item->id, $item->ws_default, $number);
				}
			}
		} else {
			$objects[] = $helper->parseProperty("html", "#system-message", $helper->message(1, $errors));
		}
		
		$data = "({'data':[";
		
		$data .= $helper->parse_JSON($objects);
		
		$data .= "]})";
		
		echo '
		<script type="text/javascript">
			jaFormHideIFrame();
			parseData_admin(' . $data . ');
		</script>
		';
		/*echo $data;
		 exit ();*/
	}


	function saveConfig()
	{
		if (count($_POST)) {
			$post = JRequest::get('request', JREQUEST_ALLOWHTML);
			$number = $post['number'];
			$errors = array();
			$row = $this->save($errors);
			
			$backUrl = JRequest::getVar('backUrl', '');
			if (!empty($backUrl)) {
				$backUrl = urldecode($backUrl);
				$this->setRedirect($backUrl);
			} else {
				$this->setRedirect('index.php?option=' . JACOMPONENT . '&view=services');
			}
		}
	}


	function saveorder()
	{
		$model = $this->getModel('services');
		$msg = '';
		if (!$model->saveOrder()) {
			JError::raiseWarning(1001, JText::_('ERROR_OCCURRED_DATA_NOT_SAVED'));
		} else {
			$msg = JText::_('SAVE_DATA_SUCCESSFULLY');
		}
		$this->setRedirect('index.php?option=' . JACOMPONENT . '&view=services', $msg);
	}


	/**
	 * set default service.
	 * It will be used if there is no service is specified for extension.
	 *
	 */
	function setDefault()
	{
		$model = $this->getModel('services');
		$createdate = JRequest::getInt('createdate', 0);
		if (!$model->setDefault(1)) {
			JError::raiseWarning(1001, JText::_('ERROR_OCCURRED_DATA_NOT_SAVED'));
		} else {
			$msg = JText::_('SAVE_DATA_SUCCESSFULLY');
		}
		$link = 'index.php?option=' . JACOMPONENT . '&view=services';
		if ($createdate)
			$link .= "&createdate=" . $createdate;
		$this->setRedirect($link, $msg);
	}


	/**
	 * Remove service
	 *
	 */
	function remove()
	{
		$model = $this->getModel('services');
		$cids = JRequest::getVar('cid', null, 'post', 'array');
		$error = array();
		foreach ($cids as $cid) {
			if (!$model->delete($cid))
				$error = $cid;
		}
		if (count($error) > 0) {
			$err = implode(",", $error);
			JError::raiseWarning(1001, JText::_('ERROR_OCCURRED_UNABLE_TO_DELETE_THE_ITEMS_WITH_ID') . ': ' . " [$err]");
		} else
			$msg = JText::_("DELETE_DATA_SUCCESSFULLY");
		$this->setRedirect('index.php?option=' . JACOMPONENT . '&view=services', $msg);
	}
}
?>