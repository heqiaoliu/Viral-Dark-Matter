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

class jaExtUploader extends JObject
{
	/**
	 * Array of paths needed by the installer
	 * @var array
	 */
	var $_paths = array();

	/**
	 * The installation manifest XML object
	 * @var object
	 */
	var $_manifest = null;

	/**
	 * True if existing files can be overwritten
	 * @var boolean
	 */
	/**
	 * Important!
	 * Since some packages are not observe the standard format of joomla extension, 
	 * they can be separate to many parts 
	 * so they must be writen into local repository more than once time on each upload progress
	 */
	var $_overwrite = true;//false

	/**
	 * A database connector object
	 * @var object
	 */
	var $_db = null;

	/**
	 * Associative array of package installer handlers
	 * @var array
	 */
	var $_adapters = array();

	/**
	 * Stack of installation steps
	 * 	- Used for installation rollback
	 * @var array
	 */
	var $_stepStack = array();

	/**
	 * The output from the install/uninstall scripts
	 * @var string
	 */
	var $message = null;
	var $errMessage = null;

	/**
	 * The output from the upload scripts
	 * @var string
	 */
	var $results = array();
	
	var $_debug = false;

	/**
	 * Constructor
	 *
	 * @access protected
	 */
	function __construct()
	{
		$this->_db =& JFactory::getDBO();
	}

	/**
	 * Returns a reference to the global Installer object, only creating it
	 * if it doesn't already exist.
	 *
	 * @static
	 * @return	object	An installer object
	 * @since 1.5
	 */
	function &getInstance()
	{
		static $instance;

		if (!isset ($instance)) {
			$instance = new jaExtUploader();
		}
		return $instance;
	}

	/**
	 * Get the allow overwrite switch
	 *
	 * @access	public
	 * @return	boolean	Allow overwrite switch
	 * @since	1.5
	 */
	function getOverwrite()
	{
		return $this->_overwrite;
	}

	/**
	 * Set the allow overwrite switch
	 *
	 * @access	public
	 * @param	boolean	$state	Overwrite switch state
	 * @return	boolean	Previous value
	 * @since	1.5
	 */
	function setOverwrite($state=false)
	{
		$tmp = $this->_overwrite;
		if ($state) {
			$this->_overwrite = true;
		} else {
			$this->_overwrite = false;
		}
		return $tmp;
	}
	/**
	 * Get the database connector object
	 *
	 * @access	public
	 * @return	object	Database connector object
	 * @since	1.5
	 */
	function &getDBO()
	{
		return $this->_db;
	}
	
	/**
	 * Get the installation manifest object
	 *
	 * @access	public
	 * @return	object	Manifest object
	 * @since	1.5
	 */
	function &getManifest()
	{
		return $this->_manifest;
	}
	
	/**
	 * Get an installer path by name
	 *
	 * @access	public
	 * @param	string	$name		Path name
	 * @param	string	$default	Default value
	 * @return	string	Path
	 * @since	1.5
	 */
	function getPath($name, $default=null)
	{
		return (!empty($this->_paths[$name])) ? $this->_paths[$name] : $default;
	}

	/**
	 * Sets an installer path by name
	 *
	 * @access	public
	 * @param	string	$name	Path name
	 * @param	string	$value	Path
	 * @return	void
	 * @since	1.5
	 */
	function setPath($name, $value)
	{
		$this->_paths[$name] = $value;
	}
	
	/**
	 * !Important: must restarts an upload part before upload next extensions
	 *
	 */
	function resetPath() {
		$this->_paths = array();
	}

	/**
	 * Pushes a step onto the installer stack for rolling back steps
	 *
	 * @access	public
	 * @param	array	$step	Installer step
	 * @return	void
	 * @since	1.5
	 */
	function pushStep($step)
	{
		$this->_stepStack[] = $step;
	}
	
	/**
	 * get upload adapter for specific extension type
	 *
	 * @param (string) $name - name of extension type
	 * @return (mixed)
	 */
	function getAdapter($name) {
		if(!isset($this->_adapters[$name]) || !is_object($this->_adapters[$name])) {
			//Try to get adapter
			$file = dirname(__FILE__).DS.'adapters'.DS.strtolower($name).'.php';
			if(!JFile::exists($file)) {
				return false;
			}
			// Try to load the adapter object
			require_once($file);
			$class = 'jaExtUploader'.ucfirst($name);
			if (!class_exists($class)) {
				return false;
			}
			$adapter = new $class($this);
			$adapter->parent =& $this;
			
			$this->_adapters[$name] = $adapter;
		}
		return $this->_adapters[$name];
	}

	/**
	 * Upload abort is no need rollback to previous steps like install
	 *
	 * @param unknown_type $msg
	 * @param unknown_type $type
	 */
	function abort($msg=null, $type=null)
	{
		$this->errMessage .= $msg . "<br /><br />";
	}

	
	function upload($packagePath = null) {
		$this->message = "";
		$this->errMessage = "";
		$this->resetResult();
		
		$xmlfiles = JFolder::files($packagePath, '.xml$', true, true);
		if (!empty($xmlfiles)) {
			$result = true;
			foreach ($xmlfiles as $file) {
				$manifest = $this->_isManifest($file);
				if(!is_null($manifest)) {
					//upload extension depend on $manifest
					// Set the manifest object and path
					$this->_manifest =& $manifest;
					$this->setPath('manifest', $file);

					// Set the installation source path to that of the manifest file
					$this->setPath('source', dirname($file));
					$result &= $this->uploadItems();
				}
			}
			return $this->getResults();
		} else {
			return false;
		}
	}
	
	/**
	 * Upload item (extension) of package
	 * Prepare for upload: this method sets the upload directory, finds
	 * and checks the installation file and verifies the installation type
	 *
	 * @access public
	 * @return boolean True on success
	 * @since 1.0
	 */
	function uploadItems()
	{
		// Load the adapter(s) for the install manifest
		$root =& $this->_manifest->document;
		$type = $root->attributes('type');
		$version	= $root->attributes('version');
		$rootName	= $root->name();
		$config		= &JFactory::getConfig();

		// Needed for legacy reasons ... to be deprecated in next minor release
		if ($type == 'mambot') {
			$type = 'plugin';
		}
		
		/*
		 * LEGACY CHECK
		 */
		if ((version_compare($version, '1.5', '<') || $rootName == 'mosinstall') && !$config->getValue('config.legacy')) {
			$this->abort(JText::_('MUSTENABLELEGACY'));
			return false;
		}
		
		// Lazy load the adapter
		$adapter = $this->getAdapter($type);
		if($adapter === false) {
			//$this->abort(JText::_('INVALID_JOOMLA_EXTENSIONS'));
			return false;
		} else {
			return $adapter->upload();
		}
	}
	
	/**
	 * build product object with JoomlArt Format from $manifest
	 *
	 */
	function buildProduct($pname)
	{
		$manifest =& $this->_manifest->document;
		
		$type 		= $manifest->attributes('type');
		$group 		= $manifest->attributes('group');
		$version 	= $manifest->getElementByPath('version');
		$version 	= JFilterInput::clean($version->data(), 'cmd');
		
		$name 		= $manifest->getElementByPath('name');
		$name 		= JFilterInput::clean($name->data(), 'string');
		
		if (!empty ($pname) && !empty($type)) {
			
			$jaProduct = new stdClass();
			$jaProduct->coreVersion = 'j15';
			$jaProduct->extKey = $pname;
			$jaProduct->name = $name;
			$jaProduct->group = $group;
			$jaProduct->version = $version;
			$jaProduct->type = $type;
			return $jaProduct;
		} else {
			return false;
		}
	}
	/**
	 * Method to parse through a files element of the installation manifest and take appropriate
	 * action.
	 *
	 * @access	public
	 * @param	object	$element 	The xml node to process
	 * @param	int		$cid		Application ID of application to install to
	 * @return	boolean	True on success
	 * @since	1.5
	 */
	function parseFiles($element, $cid=0)
	{
		// Initialize variables
		$copyfiles = array ();

		// Get the client info
		jimport('joomla.application.helper');
		$client =& JApplicationHelper::getClientInfo($cid);

		if (!is_a($element, 'JSimpleXMLElement') || !count($element->children())) {
			// Either the tag does not exist or has no children therefore we return zero files processed.
			return 0;
		}

		// Get the array of file nodes to process
		$files = $element->children();
		if (count($files) == 0) {
			// No files to process
			return 0;
		}

		/*
		 * Here we set the folder we are going to remove the files from.
		 */
		if ($client) {
			$pathname = 'extension_'.$client->name;
			$destination = $this->getPath($pathname);
		} else {
			$pathname = 'extension_root';
			$destination = $this->getPath($pathname);
		}

		/*
		 * Here we set the folder we are going to copy the files from.
		 *
		 * Does the element have a folder attribute?
		 *
		 * If so this indicates that the files are in a subdirectory of the source
		 * folder and we should append the folder attribute to the source path when
		 * copying files.
		 */
		if ($folder = $element->attributes('folder')) {
			$source = $this->getPath('source').DS.$folder;
		} else {
			$source = $this->getPath('source');
		}

		// Process each file in the $files array (children of $tagName).
		foreach ($files as $file)
		{
			$path['src']	= $source.DS.$file->data();
			$path['dest']	= $destination.DS.$file->data();

			// Is this path a file or folder?
			$path['type']	= ( $file->name() == 'folder') ? 'folder' : 'file';

			/*
			 * Before we can add a file to the copyfiles array we need to ensure
			 * that the folder we are copying our file to exits and if it doesn't,
			 * we need to create it.
			 */
			if (basename($path['dest']) != $path['dest']) {
				$newdir = dirname($path['dest']);

				if (!JFolder::create($newdir)) {
					JError::raiseWarning(1, 'JInstaller::install: '.JText::_('FAILED_TO_CREATE_DIRECTORY').' "'.$newdir.'"');
					return false;
				}
			}

			// Add the file to the copyfiles array
			$copyfiles[] = $path;
		}

		return $this->copyFiles($copyfiles);
	}
	
	/**
	 * Method to parse the parameters of an extension, build the INI
	 * string for it's default parameters, and return the INI string.
	 *
	 * @access	public
	 * @return	string	INI string of parameter values
	 * @since	1.5
	 */
	function getParams()
	{
		// Get the manifest document root element
		$root = & $this->_manifest->document;

		// Get the element of the tag names
		$element =& $root->getElementByPath('params');
		if (!is_a($element, 'JSimpleXMLElement') || !count($element->children())) {
			// Either the tag does not exist or has no children therefore we return zero files processed.
			return null;
		}

		// Get the array of parameter nodes to process
		$params = $element->children();
		if (count($params) == 0) {
			// No params to process
			return null;
		}

		// Process each parameter in the $params array.
		$ini = null;
		foreach ($params as $param) {
			if (!$name = $param->attributes('name')) {
				continue;
			}

			if (!$value = $param->attributes('default')) {
				continue;
			}

			$ini .= $name."=".$value."\n";
		}
		return $ini;
	}
	/**
	 * Copy files from source directory to the target directory
	 *
	 * @access	public
	 * @param	array $files array with filenames
	 * @param	boolean $overwrite True if existing files can be replaced
	 * @return	boolean True on success
	 * @since	1.5
	 */
	function copyFiles($files, $overwrite=null)
	{
		/*
		 * To allow for manual override on the overwriting flag, we check to see if
		 * the $overwrite flag was set and is a boolean value.  If not, use the object
		 * allowOverwrite flag.
		 */
		if (is_null($overwrite) || !is_bool($overwrite)) {
			$overwrite = $this->_overwrite;
		}

		/*
		 * $files must be an array of filenames.  Verify that it is an array with
		 * at least one file to copy.
		 */
		if (is_array($files) && count($files) > 0)
		{
			foreach ($files as $file)
			{
				// Get the source and destination paths
				$filesource	= JPath::clean($file['src']);
				$filedest	= JPath::clean($file['dest']);
				$filetype	= array_key_exists('type', $file) ? $file['type'] : 'file';

				if (!file_exists($filesource)) {
					/*
					 * The source file does not exist.  Nothing to copy so set an error
					 * and return false.
					 */
					JError::raiseWarning(1, 'JInstaller::install: '.JText::sprintf('FILE_DOES_NOT_EXIST', $filesource));
					return false;
				} elseif (file_exists($filedest) && !$overwrite) {

						/*
						 * It's okay if the manifest already exists
						 */
						if ($this->getPath( 'manifest' ) == $filesource) {
							continue;
						}

						/*
						 * The destination file already exists and the overwrite flag is false.
						 * Set an error and return false.
						 */
						JError::raiseWarning(1, 'JInstaller::install: '.JText::sprintf('WARNSAME', $filedest));
						return false;
				} else {

					// Copy the folder or file to the new location.
					if ( $filetype == 'folder') {

						if (!(JFolder::copy($filesource, $filedest, null, $overwrite))) {
							JError::raiseWarning(1, 'JInstaller::install: '.JText::sprintf('FAILED_TO_COPY_FOLDER_TO', $filesource, $filedest));
							return false;
						}

						$step = array ('type' => 'folder', 'path' => $filedest);
					} else {

						if (!(JFile::copy($filesource, $filedest))) {
							JError::raiseWarning(1, 'JInstaller::install: '.JText::sprintf('FAILED_TO_COPY_FILE_TO', $filesource, $filedest));
							return false;
						}

						$step = array ('type' => 'file', 'path' => $filedest);
					}

					/*
					 * Since we copied a file/folder, we want to add it to the installation step stack so that
					 * in case we have to roll back the installation we can remove the files copied.
					 */
					$this->_stepStack[] = $step;
				}
			}
		} else {

			/*
			 * The $files variable was either not an array or an empty array
			 */
			return false;
		}
		return count($files);
	}

	/**
	 * Method to parse through a files element of the installation manifest and remove
	 * the files that were installed
	 *
	 * @access	public
	 * @param	object	$element 	The xml node to process
	 * @param	int		$cid		Application ID of application to remove from
	 * @return	boolean	True on success
	 * @since	1.5
	 */
	function removeFiles($element, $cid=0)
	{
		// Initialize variables
		$removefiles = array ();
		$retval = true;

		// Get the client info
		jimport('joomla.application.helper');
		$client =& JApplicationHelper::getClientInfo($cid);

		if (!is_a($element, 'JSimpleXMLElement') || !count($element->children())) {
			// Either the tag does not exist or has no children therefore we return zero files processed.
			return true;
		}

		// Get the array of file nodes to process
		$files = $element->children();
		if (count($files) == 0) {
			// No files to process
			return true;
		}

		/*
		 * Here we set the folder we are going to remove the files from.  There are a few
		 * special cases that need to be considered for certain reserved tags.
		 */
		switch ($element->name())
		{
			case 'media':
				if ($element->attributes('destination')) {
					$folder = $element->attributes('destination');
				} else {
					$folder = '';
				}
				$source = $client->path.DS.'media'.DS.$folder;
				break;

			case 'languages':
				$source = $client->path.DS.'language';
				break;

			default:
				if ($client) {
					$pathname = 'extension_'.$client->name;
					$source = $this->getPath($pathname);
				} else {
					$pathname = 'extension_root';
					$source = $this->getPath($pathname);
				}
				break;
		}

		// Process each file in the $files array (children of $tagName).
		foreach ($files as $file)
		{
			/*
			 * If the file is a language, we must handle it differently.  Language files
			 * go in a subdirectory based on the language code, ie.
			 *
			 * 		<language tag="en_US">en_US.mycomponent.ini</language>
			 *
			 * would go in the en_US subdirectory of the languages directory.
			 */
			if ($file->name() == 'language' && $file->attributes('tag') != '') {
				$path = $source.DS.$file->attributes('tag').DS.basename($file->data());

				// If the language folder is not present, then the core pack hasn't been installed... ignore
				if (!JFolder::exists(dirname($path))) {
					continue;
				}
			} else {
				$path = $source.DS.$file->data();
			}

			/*
			 * Actually delete the files/folders
			 */
			if (JFolder::exists($path)) {
				$val = JFolder::delete($path);
			} else {
				$val = JFile::delete($path);
			}

			if ($val === false) {
				$retval = false;
			}
		}

		return $retval;
	}
	
	/**
	 * Copies the installation manifest file to the extension folder in the given client
	 *
	 * @access	public
	 * @param	int		$cid	Where to copy the installfile [optional: defaults to 1 (admin)]
	 * @return	boolean	True on success, False on error
	 * @since	1.5
	 */
	function copyManifest($cid=1)
	{
		// Get the client info
		jimport('joomla.application.helper');
		$client =& JApplicationHelper::getClientInfo($cid);

		$path['src'] = $this->getPath('manifest');

		if ($client) {
			$pathname = 'extension_'.$client->name;
			$path['dest']  = $this->getPath($pathname).DS.basename($this->getPath('manifest'));
		} else {
			$pathname = 'extension_root';
			$path['dest']  = $this->getPath($pathname).DS.basename($this->getPath('manifest'));
		}
		return $this->copyFiles(array ($path), true);
	}

	/**
	 * Is the xml file a valid Joomla installation manifest file
	 *
	 * @access	private
	 * @param	string	$file	An xmlfile path to check
	 * @return	mixed	A JSimpleXML document, or null if the file failed to parse
	 * @since	1.5
	 */
	function &_isManifest($file)
	{
		// Initialize variables
		$null	= null;
		$xml	=& JFactory::getXMLParser('Simple');

		// If we cannot load the xml file return null
		if (!$xml->loadFile($file)) {
			// Free up xml parser memory and return null
			unset ($xml);
			return $null;
		}

		/*
		 * Check for a valid XML root tag.
		 * @todo: Remove backwards compatability in a future version
		 * Should be 'install', but for backward compatability we will accept 'mosinstall'.
		 */
		$root =& $xml->document;
		if (!is_object($root) || ($root->name() != 'install' && $root->name() != 'mosinstall')) {
			// Free up xml parser memory and return null
			unset ($xml);
			return $null;
		} else {
			
			$element = & $xml->document->name[0];
			$name = $element ? $element->data() : '';
			if(!$name) {
				unset ($xml);
				return $null;
			}
		}

		// Valid manifest file return the object
		return $xml;
	}
	
	/**
	 * set status of extension uploading progress
	 *
	 * @param (object) $ext - extension information
	 * @param (boolean) $error 
	 * @param (string) $message
	 * @param (string) $location - the location where extension is uploaded to
	 */
	function setResult($ext, $error = false, $message = '', $location = '') {
		$error = (!$error) ? 0 : 1;
		$this->results[] = array(
							'ext' => $ext,
							'error' => $error,
							'message' => $message,
							'location' => $location);
	}
	
	function resetResult() {
		$this->results = array();
	}
	
	function getResults() {
		$result = "";
		if(count($this->results) > 0) {
			$result .= "
			<table class=\"ja-uc-child\">
		      <tr>
		        <th width=\"30\"> </th>
		        <th width=\"150\">".JText::_("EXTENSION_NAME")."</th>
		        <th>".JText::_("TYPE")."</th>
		        <th>".JText::_("VERSION")."</th>
		        <th>".JText::_("RESULT")."</th>
		      </tr>";
			foreach ($this->results as $item) {
				$error = intval($item['error']);
				$ext = $item['ext'];
				if(!$error) {
					$css = "upload-success";
					
					$relLocation = substr($item['location'], strlen(JA_WORKING_DATA_FOLDER));
					$relLocation = FileSystemHelper::clean($relLocation, "/");
					$url = "index.php?option=com_jaextmanager&view=repo&folder={$relLocation}";
					$linkRepo = " <a href=\"{$url}\" onclick=\"opener.location='{$url}'; return false;\" target=\"_parent\" title=\"".addslashes($item['location'])."\">".JText::_("REPOSITORY")."</a>";
					
					$message = JText::sprintf('THE_S_S__VESION_S_IS_SUCCESSFULLY_UPLOADED_TO_LOCAL_REPOSITORY', $ext->type, $ext->name, $ext->version);
					$message .= JText::sprintf('GO_TO_S_TO_SEE_THE_UPLOADED_FILES_OF_THIS_EXTENSIONS', $linkRepo);
					
				} else {
					$css = "upload-error";
					$message = $item["message"];
				}
				
				$result .= "
			      <tr class=\"".$css."\">
			        <td class=\"icon\"> </td>
			        <td><span title=\"".$ext->extKey."\">".$ext->name."</span></td>
			        <td>".$ext->type."</td>
			        <td>".$ext->version."</td>
			        <td>".$message."</td>
			      </tr>";
			}
			$result .= "</table>";
		}
		return $result;
	}
	
	function printResults() {
		echo $this->getResults();
	}
	
	function debug() {
		return $this->_debug;
	}
}
?>