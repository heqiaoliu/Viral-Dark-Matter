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
// No direct access
defined('JPATH_BASE') or die();
jimport('joomla.base.adapterinstance');

class jaExtUploaderComponent extends JObject
{


	/**
	 * Constructor
	 *
	 * @access	protected
	 * @param	object	$parent	Parent object [JInstaller instance]
	 * @return	void
	 * @since	1.5
	 */
	function __construct(&$parent)
	{
		$this->parent = & $parent;
	}


	/**
	 * Custom install method for components
	 *
	 * @access	public
	 * @return	boolean	True on success
	 * @since	1.5
	 */
	function upload()
	{
		global $jauc; //JoomlArt Updater Client
		

		// Get a database connector object
		$db = $this->parent->getDbo();
		
		// Get the extension manifest object
		$this->manifest = $this->parent->getManifest();
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Manifest Document Setup Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		// Set the extensions name
		$name = strtolower(JFilterInput::getInstance()->clean((string) $this->manifest->name, 'cmd'));
		if (substr($name, 0, 4) == "com_") {
			$element = $name;
		} else {
			$element = "com_$name";
		}
		
		$this->set('name', $name);
		$this->set('element', $element);
		
		// Get the component description
		$this->parent->set('description', JText::_((string) $this->manifest->description));
		
		$jaProduct = $this->parent->buildProduct($name);
		
		if ($jaProduct !== false) {
			//path for install, we dont need it on upload to local reposiotry :)
			// Set the installation target paths
			//$this->parent->setPath('extension_site', JPath::clean(JPATH_SITE.DS.'components'.DS.$this->get('element')));
			//$this->parent->setPath('extension_administrator', JPath::clean(JPATH_ADMINISTRATOR.DS.'components'.DS.$this->get('element')));
			

			$storePath = $jauc->getLocalVersionPath($jaProduct, false);
			$this->parent->setPath('extension_site', $storePath . "site");
			$this->parent->setPath('extension_administrator', $storePath . "admin");
		} else {
			$this->parent->setResult($jaProduct, true, JText::_('NO_COMPONENT_FILE_SPECIFIED'));
			return false;
		}
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Basic Checks Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		// Make sure that we have an admin element
		if (!$this->manifest->administration) {
			JError::raiseWarning(1, JText::_('COMPONENT') . ' ' . JText::_('UPLOAD') . ': ' . JText::_('THE_XML_FILE_DID_NOT_CONTAIN_AN_ADMINISTRATION_ELEMENT'));
			return false;
		}
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Filesystem Processing Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		/*
		 * If the component site or admin directory already exists, then we will assume that the component is already
		 * installed or another component is using that directory.
		 */
		if (file_exists($storePath) && !$this->parent->getOverwrite()) {
			$this->parent->setResult($jaProduct, true, JText::sprintf('THE_VERSION_S_OF_S_IS_ALREADY_EXISTS_ON_LOCAL_REPOSITORY', $jaProduct->version, $name) . ': <br />"' . $this->parent->getPath('extension_root') . '"');
			return false;
		}
		
		// If the component site directory does not exist, lets create it
		$created = false;
		if (!file_exists($this->parent->getPath('extension_site'))) {
			if (!$created = JFolder::create($this->parent->getPath('extension_site'))) {
				$this->parent->setResult($jaProduct, true, JText::_('FAILED_TO_CREATE_DIRECTORY') . ': <br />"' . $this->parent->getPath('extension_site') . '"');
				return false;
			}
		}
		
		/*
		 * Since we created the component directory and will want to remove it if we have to roll back
		 * the installation, lets add it to the installation step stack
		 */
		/*if ($created) {
			$this->parent->pushStep(array ('type' => 'folder', 'path' => $this->parent->getPath('extension_site')));
		}*/
		
		// If the component admin directory does not exist, lets create it
		$created = false;
		if (!file_exists($this->parent->getPath('extension_administrator'))) {
			if (!$created = JFolder::create($this->parent->getPath('extension_administrator'))) {
				$this->parent->setResult($jaProduct, true, JText::_('FAILED_TO_CREATE_DIRECTORY') . ': <br />"' . $this->parent->getPath('extension_administrator') . '"');
				return false;
			}
		}
		
		/*
		 * Since we created the component admin directory and we will want to remove it if we have to roll
		 * back the installation, lets add it to the installation step stack
		 */
		/*if ($created) {
			$this->parent->pushStep(array ('type' => 'folder', 'path' => $this->parent->getPath('extension_administrator')));
		}*/
		
		// Copy site files
		if ($this->manifest->files) {
			if ($this->parent->parseFiles($this->manifest->files) === false) {
				// Install failed, rollback any changes
				$this->parent->abort();
				
				return false;
			}
		}
		// Copy admin files
		if ($this->manifest->administration->files) {
			if ($this->parent->parseFiles($this->manifest->administration->files, 1) === false) {
				// Install failed, rollback any changes
				$this->parent->abort();
				
				return false;
			}
		}
		
		// Parse optional tags
		/*$this->parent->parseMedia($this->manifest->media);
		$this->parent->parseLanguages($this->manifest->languages);
		$this->parent->parseLanguages($this->manifest->administration->languages, 1);*/
		
		// Deprecated install, remove after 1.6
		// If there is an install file, lets copy it.
		$installFile = (string) $this->manifest->installfile;
		
		if ($installFile) {
			// Make sure it hasn't already been copied (this would be an error in the xml install file)
			if (!file_exists($this->parent->getPath('extension_administrator') . DS . $installFile) || $this->parent->getOverwrite()) {
				$path['src'] = $this->parent->getPath('source') . DS . $installFile;
				$path['dest'] = $this->parent->getPath('extension_administrator') . DS . $installFile;
				
				if (!$this->parent->copyFiles(array($path))) {
					// Install failed, rollback changes
					$this->parent->abort(JText::_('JLIB_INSTALLER_ABORT_COMP_INSTALL_PHP_INSTALL'));
					
					return false;
				}
			}
			
			$this->set('install_script', $installFile);
		}
		
		// Deprecated uninstall, remove after 1.6
		// If there is an uninstall file, lets copy it.
		$uninstallFile = (string) $this->manifest->uninstallfile;
		
		if ($uninstallFile) {
			// Make sure it hasn't already been copied (this would be an error in the xml install file)
			if (!file_exists($this->parent->getPath('extension_administrator') . DS . $uninstallFile) || $this->parent->getOverwrite()) {
				$path['src'] = $this->parent->getPath('source') . DS . $uninstallFile;
				$path['dest'] = $this->parent->getPath('extension_administrator') . DS . $uninstallFile;
				
				if (!$this->parent->copyFiles(array($path))) {
					// Install failed, rollback changes
					$this->parent->abort(JText::_('JLIB_INSTALLER_ABORT_COMP_INSTALL_PHP_UNINSTALL'));
					return false;
				}
			}
		}
		
		// If there is a manifest script, lets copy it.
		if ($this->get('manifest_script')) {
			$path['src'] = $this->parent->getPath('source') . DS . $this->get('manifest_script');
			$path['dest'] = $this->parent->getPath('extension_administrator') . DS . $this->get('manifest_script');
			
			if (!file_exists($path['dest']) || $this->parent->getOverwrite()) {
				if (!$this->parent->copyFiles(array($path))) {
					// Install failed, rollback changes
					$this->parent->abort(JText::_('JLIB_INSTALLER_ABORT_COMP_INSTALL_MANIFEST'));
					
					return false;
				}
			}
		}
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Finalization and Cleanup Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		// Lastly, we will copy the manifest file to its appropriate place.
		if (!$this->parent->copyManifest()) {
			// Install failed, rollback changes
			$this->parent->setResult($jaProduct, true, JText::_('COULD_NOT_COPY_SETUP_FILE'));
			return false;
		}
		
		// Load component lang file
		/*$lang =& JFactory::getLanguage();
		$lang->load(strtolower("com_".str_replace(" ", "", $this->get('name'))));*/
		$location = dirname($this->parent->getPath('extension_administrator'));
		$this->parent->setResult($jaProduct, false, '', $location);
		
		return true;
	}
}
