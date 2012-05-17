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
 
class jaExtUploaderPlugin extends JObject
{
	var $parent;
	var $manifest;


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
	 * Upload Plugin
	 *
	 * @param (object) $manifest - install file
	 * @return unknown
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
		$name = JFilterInput::clean($name->data(), 'string');
		$this->set('name', $name);
		
		// Get the component description
		$description = & $this->manifest->getElementByPath('description');
		/*if (is_a($description, 'JSimpleXMLElement')) {
			$this->parent->set('message', $description->data());
			} else {
			$this->parent->set('message', '' );
			}*/
		
		/*
		 * Backward Compatability
		 * @todo Deprecate in future version
		 */
		$type = $this->manifest->attributes('type');
		
		// Set the installation path
		$element = & $this->manifest->getElementByPath('files');
		if (is_a($element, 'JSimpleXMLElement') && count($element->children())) {
			$files = $element->children();
			foreach ($files as $file) {
				if ($file->attributes($type)) {
					$pname = $file->attributes($type);
					break;
				}
			}
		}
		$jaProduct = $this->parent->buildProduct($pname);
		
		if ($jaProduct !== false) {
			//path for install, we dont need it on upload to local reposiotry :)
			//$this->parent->setPath('extension_root', JPATH_ROOT.DS.'plugins'.DS.$group);
			$storePath = $jauc->getLocalVersionPath($jaProduct, false);
			$this->parent->setPath('extension_root', $storePath);
		} else {
			$this->parent->setResult($jaProduct, true, JText::_('NO_PLUGIN_FILE_SPECIFIED'));
			return false;
		}
		
		/**
		 * ---------------------------------------------------------------------------------------------
		 * Filesystem Processing Section
		 * ---------------------------------------------------------------------------------------------
		 */
		
		if (file_exists($this->parent->getPath('extension_root')) && !$this->parent->getOverwrite()) {
			$this->parent->setResult($jaProduct, true, JText::sprintf('THE_VERSION_S_OF_S_IS_ALREADY_EXISTS_ON_LOCAL_REPOSITORY', $jaProduct->version, $name) . ': <br />"' . $this->parent->getPath('extension_root') . '"');
			return false;
		}
		
		// If the module directory does not exist, lets create it
		$created = false;
		if (!file_exists($this->parent->getPath('extension_root'))) {
			if (!$created = JFolder::create($this->parent->getPath('extension_root'))) {
				$this->parent->setResult($jaProduct, true, JText::_('FAILED_TO_CREATE_DIRECTORY') . ': <br />"' . $this->parent->getPath('extension_root') . '"');
				return false;
			}
		}
		
		/*
		 * If we created the plugin directory and will want to remove it if we
		 * have to roll back the installation, lets add it to the installation
		 * step stack
		 */
		/*if ($created) {
			$this->parent->pushStep(array ('type' => 'folder', 'path' => $this->parent->getPath('extension_root')));
			}*/
		
		// Copy all necessary files
		if ($this->parent->parseFiles($element, -1) === false) {
			// Install failed, roll back changes
			$this->parent->abort();
			return false;
		}
		
		// Parse optional tags -- media and language files for plugins go in admin app
		/*$this->parent->parseMedia($this->manifest->getElementByPath('media'), 1);
		 $this->parent->parseLanguages($this->manifest->getElementByPath('languages'), 1);*/
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
		
		// Load plugin language file
		/*$lang =& JFactory::getLanguage();
		 $lang->load('plg_'.$group.'_'.$pname);*/
		
		$this->parent->setResult($jaProduct, false, '', $this->parent->getPath('extension_root'));
		
		return true;
	}
}
?>