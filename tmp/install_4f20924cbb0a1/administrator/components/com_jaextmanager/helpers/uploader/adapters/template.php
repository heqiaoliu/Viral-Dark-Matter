<?php
/*
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
*/ 
// No direct access
defined('JPATH_BASE') or die;

jimport('joomla.installer.extension');
jimport('joomla.base.adapterinstance');

/**
 * Template uploader
 */
class jaExtUploaderTemplate extends JObject
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
		$this->parent =& $parent;
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
		global $jauc; //JoomlArt Updater Client
		$xml = $this->parent->getManifest();

		// Get the client application target
		/*if ($cname = (string)$xml->attributes()->client)
		{
			// Attempt to map the client to a base path
			jimport('joomla.application.helper');
			$client = JApplicationHelper::getClientInfo($cname, true);
			if ($client === false) {
				$this->parent->abort(JText::sprintf('JLIB_INSTALLER_ABORT_TPL_INSTALL_UNKNOWN_CLIENT', $cname));
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

		// Set the extensions name
		$name = JFilterInput::getInstance()->clean((string)$xml->name, 'cmd');

		$element = strtolower(str_replace(" ", "_", $name));
		$this->set('name', $name);
		$this->set('element',$element);
		$jaProduct = $this->parent->buildProduct($element);
		
		if ($jaProduct !== false) {
			//path for install, we dont need it on upload to local reposiotry :)
			// Set the template root path
			//$this->parent->setPath('extension_root', $basePath.DS.'templates'.DS.strtolower(str_replace(" ", "_", $this->get('name'))));
			$storePath = $jauc->getLocalVersionPath($jaProduct, false);
			$this->parent->setPath('extension_root', $storePath);
		} else {
			$this->parent->setResult($jaProduct, true, JText::_('NO_TEMPLATE_FILE_SPECIFIED'));
			return false;
		}

		/*
		 * If the template directory already exists, then we will assume that the template is already
		 * installed or another template is using that directory.
		 */
		if (file_exists($this->parent->getPath('extension_root')) && !$this->parent->getOverwrite())
		{
			JError::raiseWarning(100, JText::sprintf('JLIB_INSTALLER_ABORT_TPL_INSTALL_ANOTHER_TEMPLATE_USING_DIRECTORY', $this->parent->getPath('extension_root')));
			return false;
		}

		// If the template directory does not exist, lets create it
		$created = false;
		if (!file_exists($this->parent->getPath('extension_root')))
		{
			if (!$created = JFolder::create($this->parent->getPath('extension_root')))
			{
				$this->parent->abort(JText::sprintf('JLIB_INSTALLER_ABORT_TPL_INSTALL_FAILED_CREATE_DIRECTORY', $this->parent->getPath('extension_root')));
				return false;
			}
		}

		// If we created the template directory and will want to remove it if we have to roll back
		// the installation, lets add it to the installation step stack
		/*if ($created) {
			$this->parent->pushStep(array ('type' => 'folder', 'path' => $this->parent->getPath('extension_root')));
		}*/

		// Copy all the necessary files
		if ($this->parent->parseFiles($xml->files, -1) === false)
		{
			// Install failed, rollback changes
			$this->parent->abort();
			return false;
		}
		if ($this->parent->parseFiles($xml->images, -1) === false)
		{
			// Install failed, rollback changes
			$this->parent->abort();
			return false;
		}
		if ($this->parent->parseFiles($xml->css, -1) === false)
		{
			// Install failed, rollback changes
			$this->parent->abort();
			return false;
		}

		// Parse optional tags
		/*$this->parent->parseFiles($xml->media, $clientId);
		$this->parent->parseLanguages($xml->languages, $clientId);*/

		// Get the template description
		//$this->parent->set('message', JText::_((string)$xml->description));

		// Lastly, we will copy the manifest file to its appropriate place.
		if (!$this->parent->copyManifest(-1))
		{
			// Install failed, rollback changes
			$this->parent->abort(JText::_('JLIB_INSTALLER_ABORT_TPL_INSTALL_COPY_SETUP'));
			return false;
		}

		// Load template language file
		/*$lang =& JFactory::getLanguage();
		$lang->load('tpl_'.$name);*/
		
		$this->parent->setResult($jaProduct, false, '', $this->parent->getPath('extension_root'));

		return true;
	}
}
