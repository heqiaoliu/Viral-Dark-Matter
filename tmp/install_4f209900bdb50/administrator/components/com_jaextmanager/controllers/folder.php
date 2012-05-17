<?php
/**
 * @desc Modify from component Media Manager of Joomla
 *
 */

// Check to ensure this file is included in Joomla!
defined('_JEXEC') or die( 'Restricted access' );

jimport('joomla.filesystem.file');
jimport('joomla.filesystem.folder');

/**
 * Weblinks Weblink Controller
 *
 * @package		Joomla
 * @subpackage	Media
 * @since 1.5
 */
class JaextmanagerControllerFolder extends JaextmanagerController
{

	/**
	 * Deletes paths from the current path
	 *
	 * @param string $listFolder The image directory to delete a file from
	 * @since 1.5
	 */
	function delete()
	{
		$mainframe = JFactory::getApplication('administrator');

		JRequest::checkToken('request') or jexit( 'Invalid Token' );

		// Set FTP credentials, if given
		jimport('joomla.client.helper');
		JClientHelper::setCredentialsFromRequest('ftp');

		// Get some data from the request
		$tmpl	= JRequest::getCmd( 'tmpl' );
		$paths	= JRequest::getVar( 'rm', array(), '', 'array' );
		$folder = JRequest::getVar( 'folder', '', '', 'path');

		// Initialize variables
		$msg = array();
		$ret = true;

		if (count($paths)) {
			foreach ($paths as $path)
			{
				if ($path !== JFile::makeSafe($path)) {
					JError::raiseWarning(100, JText::_('UNABLE_TO_DELETE').htmlspecialchars($path, ENT_COMPAT, 'UTF-8').' '.JText::_('WARNDIRNAME'));
					continue;
				}

				$fullPath = JPath::clean(JA_WORKING_DATA_FOLDER.DS.$folder.DS.$path);
				if (JFile::exists($fullPath)) {
					$ret |= !JFile::delete($fullPath);
				} else if (JFolder::exists($fullPath)) {
					$files = JFolder::files($fullPath, '.', true);
					$canDelete = true;
					foreach ($files as $file) {
						if ($file != 'index.html') {
							$canDelete = false;
						}
					}
					if ($canDelete) {
						$ret |= !JFolder::delete($fullPath);
					} else {
						//allow remove folder not empty on local repository
						$ret2 = JFolder::delete($fullPath);
						$ret |= !$ret2;
						if($ret2 == false) {
							JError::raiseWarning(100, JText::_('UNABLE_TO_DELETE').$fullPath);
						}
					}
				}
			}
		}
		if ($ret) {
			JError::raiseNotice(200, JText::_('SUCCESSFULLY_DELETE_A_SELETED_ITEMS'));
		}
		if ($tmpl == 'component') {
			// We are inside the iframe
			$mainframe->redirect('index.php?option='.JACOMPONENT.'&view=repolist&folder='.$folder.'&tmpl=component');
		} else {
			$mainframe->redirect('index.php?option='.JACOMPONENT.'&view=repolist&folder='.$folder);
		}
	}

	/**
	 * Create a folder
	 *
	 * @param string $path Path of the folder to create
	 * @since 1.5
	 */
	function create()
	{
		$mainframe = JFactory::getApplication('administrator');

		// Check for request forgeries
		JRequest::checkToken() or jexit( 'Invalid Token' );

		// Set FTP credentials, if given
		jimport('joomla.client.helper');
		JClientHelper::setCredentialsFromRequest('ftp');

		$folder			= JRequest::getCmd( 'foldername', '');
		$folderCheck	= JRequest::getVar( 'foldername', null, '', 'string', JREQUEST_ALLOWRAW);
		$parent			= JRequest::getVar( 'folderbase', '', '', 'path' );

		JRequest::setVar('folder', $parent);

		if (($folderCheck !== null) && ($folder !== $folderCheck)) {
			$mainframe->redirect('index.php?option='.JACOMPONENT.'&view=repolist&folder='.$parent, JText::_('WARNDIRNAME'));
		}

		if (strlen($folder) > 0) {
			$path = JPath::clean(JA_WORKING_DATA_FOLDER.DS.$parent.DS.$folder);
			if (!JFolder::exists($path) && !JFile::exists($path))
			{
				jimport('joomla.filesystem.*');
				JFolder::create($path);
				$content = "<html>\n<body bgcolor=\"#FFFFFF\">\n</body>\n</html>";
				JFile::write($path.DS."index.html", $content);
			}
			JRequest::setVar('folder', ($parent) ? $parent.'/'.$folder : $folder);
		}
		$mainframe->redirect('index.php?option='.JACOMPONENT.'&view=repolist&folder='.$parent);
	}
}
