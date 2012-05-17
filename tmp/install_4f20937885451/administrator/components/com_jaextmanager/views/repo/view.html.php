<?php
/**
 * @desc Modify from component Media Manager of Joomla
 *
 */

// Check to ensure this file is included in Joomla!
defined('_JEXEC') or die( 'Restricted access' );

jimport( 'joomla.application.component.view');

/**
 * HTML View class for the Media component
 *
 * @static
 * @package		Joomla
 * @subpackage	Media
 * @since 1.0
 */
class JaextmanagerViewRepo extends JView
{
	function display($tpl = null)
	{
		global $mainframe;

		$config =& JComponentHelper::getParams(JACOMPONENT);

		//$style = $mainframe->getUserStateFromRequest('media.list.layout', 'layout', 'details', 'word');
		$style = "details";

		$listStyle = "
			<ul id=\"submenu\">
				<li><a title=\"\" href=\"index.php?option=".JACOMPONENT."&extionsion_type=&search=\"> ".JText::_("EXTENSIONS_MANAGER")."</a></li>
				<li><a title=\"\" href=\"index.php?option=".JACOMPONENT."&view=services\"> ".JText::_("SERVICES_MANAGER")."</a></li>
				<li><a title=\"\" class=\"active\" href=\"index.php?option=".JACOMPONENT."&view=repo\"> ".JText::_("REPOSITORY_MANAGER")."</a></li>
				<li><a title=\"\" href=\"index.php?option=".JACOMPONENT."&view=default&layout=config_service\"> ".JText::_("CONFIGURATIONS")."</a></li>
				<li><a title=\"\" href=\"index.php?option=".JACOMPONENT."&view=default&layout=help_support\"> ".JText::_("HELP_AND_SUPPORT")."</a></li>
			</ul>
		";

		$document =& JFactory::getDocument();
		$document->setBuffer($listStyle, 'modules', 'submenu');

		JHTML::_('behavior.mootools');
		$document->addScript('components/'.JACOMPONENT.'/assets/repo_manager/repomanager.js');
		$document->addStyleSheet('components/'.JACOMPONENT.'/assets/repo_manager/repomanager.css');

		JHTML::_('behavior.modal');
		$document->addScriptDeclaration("
		window.addEvent('domready', function() {
			document.preview = SqueezeBox;
		});");

		JHTML::script('mootree.js');
		JHTML::stylesheet('mootree.css');

		if ($config->get('enable_flash', 0)) {
			JHTML::_('behavior.uploader', 'file-upload', array('onAllComplete' => 'function(){ MediaManager.refreshFrame(); }'));
		}

		if(DS == '\\')
		{
			$base = str_replace(DS,"\\\\",JA_WORKING_DATA_FOLDER);
		} else {
			$base = JA_WORKING_DATA_FOLDER;
		}

		$js = "
			var basepath = '".$base."';
			var viewstyle = '".$style."';
		" ;
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
		
		$user =& JFactory::getUser();
		$this->assignRef('user', $user);

		// Set the toolbar
		$this->_setToolBar();

		parent::display($tpl);
		echo JHTML::_('behavior.keepalive');
	}

	function _setToolBar()
	{
		// Get the toolbar object instance
		$bar =& JToolBar::getInstance('toolbar');

		// Set the titlebar text
		JToolBarHelper::title( JText::_('JOOMLART_EXTENSIONS_MANAGER' ), 'generic');
		
		// Add a upload button
		$title = JText::_('UPLOAD');
		$dhtml = "<a href=\"#\" onclick=\"jaOpenUploader(); return false;\" class=\"toolbar\">
					<span class=\"icon-32-upload\" title=\"$title\" type=\"Custom\"></span>
					$title</a>";
		$bar->appendButton( 'Custom', $dhtml, 'upload' );

		// Add a delete button
		$title = JText::_('DELETE');
		$dhtml = "<a href=\"#\" onclick=\"multiDelete(); return false;\" class=\"toolbar\">
					<span class=\"icon-32-delete\" title=\"$title\" type=\"Custom\"></span>
					$title</a>";
		$bar->appendButton( 'Custom', $dhtml, 'delete' );

		// Add a popup configuration button
		JToolBarHelper::help( 'screen.mediamanager' );
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
