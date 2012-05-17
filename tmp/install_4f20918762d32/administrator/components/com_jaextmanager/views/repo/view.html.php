<?php
/**
 * @version		$Id: view.html.php 17858 2010-06-23 17:54:28Z eddieajau $
 * @copyright	Copyright (C) 2005 - 2010 Open Source Matters, Inc. All rights reserved.
 * @license		GNU General Public License version 2 or later; see LICENSE.txt
 */

// No direct access
defined('_JEXEC') or die();

jimport('joomla.application.component.view');

/**
 * HTML View class for the Media component
 *
 * @package		Joomla.Administrator
 * @subpackage	com_media
 * @since 1.0
 */
class JaextmanagerViewRepo extends JView
{


	function display($tpl = null)
	{
		// Initialise variables.
		$app = JFactory::getApplication();
		
		$config = JComponentHelper::getParams(JACOMPONENT);
		
		//$style = $app->getUserStateFromRequest('media.list.layout', 'layout', 'details', 'word');
		$style = "details";
		
		$document = & JFactory::getDocument();
		$document->setBuffer($this->loadTemplate('navigation'), 'modules', 'submenu');
		
		JHtml::_('behavior.framework', true);
		
		$assets = JURI::root() . 'administrator/components/' . JACOMPONENT . '/assets/';
		
		JHTML::_('script', $assets . 'repo_manager/' . 'repomanager.js', false, true);
		JHTML::_('stylesheet', $assets . 'repo_manager/' . 'repomanager.css', false, true);
		
		JHTML::_('behavior.modal', 'a.modal');
		$document->addScriptDeclaration("
		window.addEvent('domready', function() {
			document.preview = SqueezeBox;
		});");
		
		JHTML::_('script', 'system/mootree.js', true, true, false, false);
		JHTML::_('stylesheet', 'system/mootree.css', array(), true);
		
		if ($config->get('enable_flash', 0)) {
			JHTML::_('behavior.uploader', 'file-upload', array('onAllComplete' => 'function(){ MediaManager.refreshFrame(); }'));
		}
		
		if (DS == '\\') {
			$base = str_replace(DS, "\\\\", JA_WORKING_DATA_FOLDER);
		} else {
			$base = JA_WORKING_DATA_FOLDER;
		}
		
		$js = "
			var basepath = '" . $base . "';
			var viewstyle = '" . $style . "';
		";
		$document->addScriptDeclaration($js);
		
		/*
		 * Display form for FTP credentials?
		 * Don't set them here, as there are other functions called before this one if there is any file write operation
		 */
		jimport('joomla.client.helper');
		$ftp = !JClientHelper::hasCredentials('ftp');
		
		$this->assignRef('session', JFactory::getSession());
		$this->assignRef('config', $config);
		$this->assignRef('state', $this->get('state'));
		$this->assign('require_ftp', $ftp);
		$this->assign('folders_id', ' id="media-tree"');
		$this->assign('folders', $this->get('folderTree'));
		
		// Set the toolbar
		$this->addToolbar();
		
		parent::display($tpl);
		echo JHtml::_('behavior.keepalive');
	}


	/**
	 * Add the page title and toolbar.
	 *
	 * @since	1.6
	 */
	protected function addToolbar()
	{
		// Get the toolbar object instance
		$bar = & JToolBar::getInstance('toolbar');
		
		// Set the titlebar text
		JToolBarHelper::title(JText::_('JOOMLART_EXTENSIONS_MANAGER'), 'generic');
		
		// Add a upload button
		$title = JText::_('UPLOAD');
		$dhtml = "<a href=\"#\" onclick=\"jaOpenUploader(); return false;\" class=\"toolbar\">
					<span class=\"icon-32-upload\" title=\"$title\" type=\"Custom\"></span>
					$title</a>";
		$bar->appendButton('Custom', $dhtml, 'upload');
		
		// Add a delete button
		$title = JText::_('DELETE');
		$dhtml = "<a href=\"#\" onclick=\"multiDelete(); return false;\" class=\"toolbar\">
					<span class=\"icon-32-delete\" title=\"$title\" type=\"Custom\"></span>
					$title</a>";
		$bar->appendButton('Custom', $dhtml, 'delete');
		//JToolBarHelper::divider();
	//JToolBarHelper::preferences(JACOMPONENT, 450, 800, 'JToolbar_Options', '', 'window.location.reload()');
	}


	function getFolderLevel($folder)
	{
		$this->folders_id = null;
		$txt = null;
		if (isset($folder['children']) && count($folder['children'])) {
			$tmp = $this->folders;
			$this->folders = $folder;
			$txt = $this->loadTemplate('folders');
			$this->folders = $tmp;
		}
		return $txt;
	}
}
