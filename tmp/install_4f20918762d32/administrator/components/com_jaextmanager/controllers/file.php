<?php
/**
 * @desc Modify from component Media Manager of Joomla
 *
 */

// Check to ensure this file is included in Joomla!
defined('_JEXEC') or die('Restricted access');

jimport('joomla.filesystem.file');
jimport('joomla.filesystem.folder');

/**
 * Weblinks Weblink Controller
 *
 * @package		Joomla
 * @subpackage	Weblinks
 * @since 1.5
 */
class JaextmanagerControllerFile extends JaextmanagerController
{


	/**
	 * Upload a file
	 *
	 * @since 1.5
	 */
	function upload()
	{
		// Initialise variables.
		$mainframe = JFactory::getApplication('administrator');
		
		// Check for request forgeries
		JRequest::checkToken('request') or jexit('Invalid Token');
		
		$file = JRequest::getVar('Filedata', '', 'files', 'array');
		$folder = JRequest::getVar('folder', '', '', 'path');
		$format = JRequest::getVar('format', 'html', '', 'cmd');
		$return = JRequest::getVar('return-url', null, 'post', 'base64');
		$err = null;
		
		// Set FTP credentials, if given
		jimport('joomla.client.helper');
		JClientHelper::setCredentialsFromRequest('ftp');
		
		// Make the filename safe
		jimport('joomla.filesystem.file');
		$file['name'] = JFile::makeSafe($file['name']);
		
		if (isset($file['name'])) {
			$filepath = JPath::clean(JA_WORKING_DATA_FOLDER . DS . $folder . DS . strtolower($file['name']));
			
			if (!RepoHelper::canUpload($file, $err)) {
				if ($format == 'json') {
					jimport('joomla.error.log');
					$log = &JLog::getInstance('upload.error.php');
					$log->addEntry(array('comment' => 'Invalid: ' . $filepath . ': ' . $err));
					header('HTTP/1.0 415 Unsupported Media Type');
					jexit('Error. Unsupported Media Type!');
				} else {
					JError::raiseNotice(100, JText::_($err));
					// REDIRECT
					if ($return) {
						$mainframe->redirect(base64_decode($return) . '&folder=' . $folder);
					}
					return;
				}
			}
			
			if (JFile::exists($filepath)) {
				if ($format == 'json') {
					jimport('joomla.error.log');
					$log = &JLog::getInstance('upload.error.php');
					$log->addEntry(array('comment' => 'File already exists: ' . $filepath));
					header('HTTP/1.0 409 Conflict');
					jexit('Error. File already exists');
				} else {
					JError::raiseNotice(100, JText::_('ERROR_FILE_ALREADY_EXISTS'));
					// REDIRECT
					if ($return) {
						$mainframe->redirect(base64_decode($return) . '&folder=' . $folder);
					}
					return;
				}
			}
			
			if (!JFile::upload($file['tmp_name'], $filepath)) {
				if ($format == 'json') {
					jimport('joomla.error.log');
					$log = &JLog::getInstance('upload.error.php');
					$log->addEntry(array('comment' => 'Cannot upload: ' . $filepath));
					header('HTTP/1.0 400 Bad Request');
					jexit('Error. Unable to upload file');
				} else {
					JError::raiseWarning(100, JText::_('ERROR_UNABLE_TO_UPLOAD_FILE'));
					// REDIRECT
					if ($return) {
						$mainframe->redirect(base64_decode($return) . '&folder=' . $folder);
					}
					return;
				}
			} else {
				if ($format == 'json') {
					jimport('joomla.error.log');
					$log = &JLog::getInstance();
					$log->addEntry(array('comment' => $folder));
					jexit('Upload complete');
				} else {
					$mainframe->enqueueMessage(JText::_('UPLOAD_COMPLETE'));
					// REDIRECT
					if ($return) {
						$mainframe->redirect(base64_decode($return) . '&folder=' . $folder);
					}
					return;
				}
			}
		} else {
			$mainframe->redirect('index.php', 'Invalid Request', 'error');
		}
	}


	/**
	 * Deletes paths from the current path
	 *
	 * @param string $listFolder The image directory to delete a file from
	 * @since 1.5
	 */
	function delete()
	{
		$mainframe = JFactory::getApplication('administrator');
		
		JRequest::checkToken('request') or jexit('Invalid Token');
		
		// Set FTP credentials, if given
		jimport('joomla.client.helper');
		JClientHelper::setCredentialsFromRequest('ftp');
		
		// Get some data from the request
		$tmpl = JRequest::getCmd('tmpl');
		$paths = JRequest::getVar('rm', array(), '', 'array');
		$folder = JRequest::getVar('folder', '', '', 'path');
		
		// Initialize variables
		$msg = array();
		$ret = true;
		
		if (count($paths)) {
			foreach ($paths as $path) {
				if ($path !== JFile::makeSafe($path)) {
					JError::raiseWarning(100, JText::_('UNABLE_TO_DELETE') . htmlspecialchars($path, ENT_COMPAT, 'UTF-8') . ' ' . JText::_('WARNFILENAME'));
					continue;
				}
				
				$fullPath = JPath::clean(JA_WORKING_DATA_FOLDER . DS . $folder . DS . $path);
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
						if ($ret2 == false) {
							JError::raiseWarning(100, JText::_('UNABLE_TO_DELETE') . $fullPath);
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
			$mainframe->redirect('index.php?option=' . JACOMPONENT . '&view=repolist&folder=' . $folder . '&tmpl=component');
		} else {
			$mainframe->redirect('index.php?option=' . JACOMPONENT . '&view=repolist&folder=' . $folder);
		}
	}


	function download()
	{
		$mainframe = JFactory::getApplication('administrator');
		
		JRequest::checkToken('request') or jexit('Invalid Token');
		
		// Set FTP credentials, if given
		jimport('joomla.client.helper');
		JClientHelper::setCredentialsFromRequest('ftp');
		
		// Get some data from the request
		$tmpl = JRequest::getCmd('tmpl');
		$paths = JRequest::getVar('rm', array(), '', 'array');
		$folder = JRequest::getVar('folder', '', '', 'path');
		
		// Initialize variables
		$msg = array();
		$ret = true;
		
		if (count($paths)) {
			foreach ($paths as $path) {
				$fullPath = JPath::clean(JA_WORKING_DATA_FOLDER . DS . $folder . DS . $path);
				if (JFile::exists($fullPath) && JFile::getExt($fullPath) == 'zip') {
					// Set headers
					header("Cache-Control: public");
					header("Content-Description: File Transfer");
					header("Content-Disposition: attachment; filename=$fullPath");
					header("Content-Type: application/zip");
					header("Content-Transfer-Encoding: binary");
					// Read the file from disk
					readfile($fullPath);
					exit();
				}
			}
		}
		if ($tmpl == 'component') {
			// We are inside the iframe
			$mainframe->redirect('index.php?option=' . JACOMPONENT . '&view=repolist&folder=' . $folder . '&tmpl=component');
		} else {
			$mainframe->redirect('index.php?option=' . JACOMPONENT . '&view=repolist&folder=' . $folder);
		}
	}
}
