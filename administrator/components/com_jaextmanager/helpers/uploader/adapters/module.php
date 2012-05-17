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

/**
 * Module uploader
 *
 */
class jaExtUploaderModule extends JObject
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
	 * Custom install method
	 *
	 * @access	public
	 * @return	boolean	True on success
	 * @since	1.5
	 */
	function upload()
	{
		//JoomlArt Updater Client
		global $jauc;
		
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
		$name = (string) $this->manifest->name;
		$name = JFilterInput::getInstance()->clean($name, 'string');
		$this->set('name', $name);
		
		// Get the component description
		$description = (string) $this->manifest->description;
		/*if ($description) {
			$this->parent->set('message', JText::_($description));
		}
		else {
			$this->parent->set('message', '');
		}*/
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Target Application Section
		 * ---------------------------------------------------------------------------------------------
		 */
		// Get the target application
		/*if ($cname = (string)$this->manifest->attributes()->client)
		{
			// Attempt to map the client to a base path
			jimport('joomla.application.helper');
			$client = JApplicationHelper::getClientInfo($cname, true);
			if ($client === false)
			{
				$this->parent->abort(JText::sprintf('JLIB_INSTALLER_ABORT_MOD_UNKNOWN_CLIENT', JText::_('JLIB_INSTALLER_'.$this->route), $client->name));
				return false;
			}
			$basePath = $client->path;
			$clientId = $client->id;
		}
		else
		{
			// No client attribute was found so we assume the site as the client
			$cname = 'site';
			$basePath = JPATH_SITE;
			$clientId = 0;
		}*/
		
		// Set the installation path
		$element = '';
		if (count($this->manifest->files->children())) {
			foreach ($this->manifest->files->children() as $file) {
				if ((string) $file->attributes()->module) {
					$element = (string) $file->attributes()->module;
					$this->set('element', $element);
					break;
				}
			}
		}
		if (!empty($element)) {
			//$this->parent->setPath('extension_root', $basePath.DS.'modules'.DS.$element);
		} else {
			$this->parent->abort(JText::sprintf('JLIB_INSTALLER_ABORT_MOD_INSTALL_NOFILE', JText::_('JLIB_INSTALLER_' . $this->route)));
			return false;
		}
		
		$jaProduct = $this->parent->buildProduct($element);
		
		if ($jaProduct !== false) {
			//path for install, we dont need it on upload to local reposiotry :)
			//$this->parent->setPath('extension_root', $basePath.DS.'modules'.DS.$mname);
			$storePath = $jauc->getLocalVersionPath($jaProduct, false);
			$this->parent->setPath('extension_root', $storePath);
		} else {
			$this->parent->setResult($jaProduct, true, JText::_('NO_MODULE_FILE_SPECIFIED'));
			return false;
		}
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Filesystem Processing Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		/*
		 * If the module directory already exists, then we will assume that the
		 * module is already installed or another module is using that
		 * directory.
		 */
		if (file_exists($this->parent->getPath('extension_root')) && !$this->parent->getOverwrite()) {
			$this->parent->setResult($jaProduct, true, JText::sprintf('THE_VERSION_S_OF_S_IS_ALREADY_EXISTS_ON_LOCAL_REPOSITORY', $jaProduct->version, $name) . ': <br />"' . $this->parent->getPath('extension_root') . '"');
			return false;
		}
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Filesystem Processing Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		// If the module directory does not exist, lets create it
		$created = false;
		if (!file_exists($this->parent->getPath('extension_root'))) {
			if (!$created = JFolder::create($this->parent->getPath('extension_root'))) {
				$this->parent->abort(JText::sprintf('JLIB_INSTALLER_ABORT_MOD_INSTALL_CREATE_DIRECTORY', JText::_('JLIB_INSTALLER_' . $this->route), $this->parent->getPath('extension_root')));
				return false;
			}
		}
		
		/*
		 * Since we created the module directory and will want to remove it if
		 * we have to roll back the installation, lets add it to the
		 * installation step stack
		 */
		/*if ($created) {
			$this->parent->pushStep(array ('type' => 'folder', 'path' => $this->parent->getPath('extension_root')));
		}*/
		
		// Copy all necessary files
		if ($this->parent->parseFiles($this->manifest->files, -1) === false) {
			// Install failed, roll back changes
			$this->parent->abort();
			return false;
		}
		
		// Parse optional tags
		/*$this->parent->parseMedia($this->manifest->media, $clientId);
		$this->parent->parseLanguages($this->manifest->languages, $clientId);*/
		
		// Parse deprecated tags
		$this->parent->parseFiles($this->manifest->images, -1);
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Finalization and Cleanup Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		// Lastly, we will copy the manifest file to its appropriate place.
		if (!$this->parent->copyManifest(-1)) {
			// Install failed, rollback changes
			$this->parent->setResult($jaProduct, true, JText::_('COULD_NOT_COPY_SETUP_FILE'));
			return false;
		}
		
		// Load module language file
		/*$lang =& JFactory::getLanguage();
		$lang->load($row->module, JPATH_BASE.DS.'..');*/
		
		$this->parent->setResult($jaProduct, false, '', $this->parent->getPath('extension_root'));
		return true;
	}
}
