<?php
/**
 * ------------------------------------------------------------------------
 * JA Extensions Manager
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */
// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );
 
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
		$db = & $this->parent->getDBO();
		
		// Get the extension manifest object
		$manifest = & $this->parent->getManifest();
		$this->manifest = & $manifest->document;
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Manifest Document Setup Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		// Set the extensions name
		$name = & $this->manifest->getElementByPath('name');
		$name = JFilterInput::clean($name->data(), 'cmd');
		$this->set('name', $name);
		
		// Get the component description
		$description = & $this->manifest->getElementByPath('description');
		/*if (is_a($description, 'JSimpleXMLElement')) {
			$this->parent->set('message', $description->data());
			} else {
			$this->parent->set('message', '' );
			}*/
		
		// Get some important manifest elements
		$this->adminElement = & $this->manifest->getElementByPath('administration');
		$this->installElement = & $this->manifest->getElementByPath('install');
		$this->uninstallElement = & $this->manifest->getElementByPath('uninstall');
		
		$cname = strtolower("com_" . str_replace(" ", "", $this->get('name')));
		
		$jaProduct = $this->parent->buildProduct($cname);
		
		if ($jaProduct !== false) {
			//path for install, we dont need it on upload to local reposiotry :)
			// Set the installation target paths
			//$this->parent->setPath('extension_site', JPath::clean(JPATH_SITE.DS."components".DS.strtolower("com_".str_replace(" ", "", $this->get('name')))));
			//$this->parent->setPath('extension_administrator', JPath::clean(JPATH_ADMINISTRATOR.DS."components".DS.strtolower("com_".str_replace(" ", "", $this->get('name')))));
			

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
		if (!is_a($this->adminElement, 'JSimpleXMLElement')) {
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
		
		// Find files to copy
		foreach ($this->manifest->children() as $child) {
			if (is_a($child, 'JSimpleXMLElement') && $child->name() == 'files') {
				if ($this->parent->parseFiles($child) === false) {
					// Install failed, rollback any changes
					$this->parent->abort();
					return false;
				}
			}
		}
		
		foreach ($this->adminElement->children() as $child) {
			if (is_a($child, 'JSimpleXMLElement') && $child->name() == 'files') {
				if ($this->parent->parseFiles($child, 1) === false) {
					// Install failed, rollback any changes
					$this->parent->abort();
					return false;
				}
			}
		}
		
		// Parse optional tags
		/*$this->parent->parseMedia($this->manifest->getElementByPath('media'));
		 $this->parent->parseLanguages($this->manifest->getElementByPath('languages'));
		 $this->parent->parseLanguages($this->manifest->getElementByPath('administration/languages'), 1);*/
		
		// Parse deprecated tags
		/*$this->parent->parseFiles($this->manifest->getElementByPath('images'));
		 $this->parent->parseFiles($this->manifest->getElementByPath('administration/images'), 1);*/
		
		// If there is an install file, lets copy it.
		$installScriptElement = & $this->manifest->getElementByPath('installfile');
		if (is_a($installScriptElement, 'JSimpleXMLElement')) {
			// check if it actually has a value
			$installScriptFilename = $installScriptElement->data();
			if (empty($installScriptFilename)) {
				//if(JDEBUG) JError::raiseWarning(43, JText::sprintf('BLANKSCRIPTELEMENT', JText::_('INSTALL')));
				$this->parent->setResult($jaProduct, true, JText::sprintf('BLANKSCRIPTELEMENT', JText::_('INSTALL')));
				//return false;
			} else {
				// Make sure it hasn't already been copied (this would be an error in the xml install file)
				// Only copy over an existing file when upgrading components
				if (!file_exists($this->parent->getPath('extension_administrator') . DS . $installScriptFilename) || $this->parent->getOverwrite()) {
					$path['src'] = $this->parent->getPath('source') . DS . $installScriptFilename;
					$path['dest'] = $this->parent->getPath('extension_administrator') . DS . $installScriptFilename;
					if (file_exists($path['src']) && file_exists(dirname($path['dest']))) {
						if (!$this->parent->copyFiles(array($path))) {
							// Install failed, rollback changes
							$this->parent->setResult($jaProduct, true, JText::_('COULD_NOT_COPY_PHP_INSTALL_FILE'));
							//return false;
						}
					} else if (JDEBUG) {
						//JError::raiseWarning(42, JText::sprintf('INVALIDINSTALLFILE', JText::_('INSTALL')));
						$this->parent->setResult($jaProduct, true, JText::sprintf('INVALIDINSTALLFILE', JText::_('INSTALL')));
						//return false;
					}
				}
				$this->set('install.script', $installScriptFilename);
			}
		}
		
		// If there is an uninstall file, lets copy it.
		$uninstallScriptElement = & $this->manifest->getElementByPath('uninstallfile');
		if (is_a($uninstallScriptElement, 'JSimpleXMLElement')) {
			// check it actually has a value
			$uninstallScriptFilename = $uninstallScriptElement->data();
			if (empty($uninstallScriptFilename)) {
				// display a warning when we're in debug mode
				//if(JDEBUG) JError::raiseWarning(43, JText::sprintf('BLANKSCRIPTELEMENT', JText::_('UNINSTALL')));
				$this->parent->setResult($jaProduct, true, JText::sprintf('BLANKSCRIPTELEMENT', JText::_('UNINSTALL')));
				//return false;
			} else {
				// Make sure it hasn't already been copied (this would be an error in the xml install file)
				// Only copy over an existing file when upgrading components
				if (!file_exists($this->parent->getPath('extension_administrator') . DS . $uninstallScriptFilename) || $this->parent->getOverwrite()) {
					$path['src'] = $this->parent->getPath('source') . DS . $uninstallScriptFilename;
					$path['dest'] = $this->parent->getPath('extension_administrator') . DS . $uninstallScriptFilename;
					if (file_exists($path['src']) && file_exists(dirname($path['dest']))) {
						if (!$this->parent->copyFiles(array($path))) {
							// Install failed, rollback changes
							$this->parent->setResult($jaProduct, true, JText::_('COULD_NOT_COPY_PHP_UNINSTALL_FILE'));
							//return false;
						}
					} else if (JDEBUG) {
						//JError::raiseWarning(42, JText::sprintf('INVALIDINSTALLFILE', JText::_('UNINSTALL')));
						$this->parent->setResult($jaProduct, true, JText::sprintf('INVALIDINSTALLFILE', JText::_('UNINSTALL')));
						//return false;
					}
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
