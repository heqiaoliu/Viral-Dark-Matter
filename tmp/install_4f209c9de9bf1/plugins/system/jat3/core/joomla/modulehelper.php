<?php
/**
 * @package     JAT3 Framework
 * @version     1.2.0
 *
 * @authors     Stephen Brandon <stephen@brandonitconsulting.co.uk>
 *              Peter van Westen <peter@nonumber.nl>
 *              Khanh Le Huy <khanhlh@joomsolutions.com>
 * @copyright   Copyright (C) 2010 -  All Rights Reserved
 *              Brandon IT Consulting (http://www.metamodpro.com)
 *              NoNumber! (http://www.nonumber.nl)
 *              JoomlArt (http://www.joomlart.com)
 * @license     http://www.gnu.org/licenses/gpl-2.0.html GNU/GPL
 */

/**
 * BASE ON JOOMLA CORE FILE:
 * /libraries/joomla/application/module/helper.php
 */

/**
* @version		$Id: helper.php 10707 2008-08-21 09:52:47Z eddieajau $
* @package		Joomla.Framework
* @subpackage	Application
* @copyright	Copyright (C) 2005 - 2008 Open Source Matters. All rights reserved.
* @license		GNU/GPL, see LICENSE.php
* Joomla! is free software. This version may have been modified pursuant
* to the GNU General Public License, and as distributed it includes or
* is derivative of works licensed under the GNU General Public License or
* other free or open source software licenses.
* See COPYRIGHT.php for copyright notices and details.
*/

// Check to ensure this file is within the rest of the framework
defined('JPATH_BASE') or die();

// Import library dependencies
jimport('joomla.application.component.helper');

/**
 * Module helper class
 *
 * @static
 * @package		Joomla.Framework
 * @subpackage	Application
 * @since		1.5
 */
class JModuleHelper
{
	/**
	 * Get module by name (real, eg 'Breadcrumbs' or folder, eg 'mod_breadcrumbs')
	 *
	 * @access	public
	 * @param	string 	$name	The name of the module
	 * @param	string	$title	The title of the module, optional
	 * @return	object	The Module object
	 */
	function &getModule($name, $title = null )
	{
		$result		= null;
		$modules	=& JModuleHelper::_load();
		$total		= count($modules);
		for ($i = 0; $i < $total; $i++)
		{
			// Match the name of the module
			if ($modules[$i]->name == $name)
			{
				// Match the title if we're looking for a specific instance of the module
				if ( ! $title || $modules[$i]->title == $title )
				{
					$result =& $modules[$i];
					break;	// Found it
				}
			}
		}

		// if we didn't find it, and the name is mod_something, create a dummy object
		if (is_null( $result ) && substr( $name, 0, 4 ) == 'mod_')
		{
			$result				= new stdClass;
			$result->id			= 0;
			$result->title		= '';
			$result->module		= $name;
			$result->position	= '';
			$result->content	= '';
			$result->showtitle	= 0;
			$result->control	= '';
			$result->params		= null;
			$result->user		= 0;
		}

		return $result;
	}

	/**
	 * Get modules by position
	 *
	 * @access public
	 * @param string 	$position	The position of the module
	 * @return array	An array of module objects
	 */
	function &getModules($position)
	{
		$position	= strtolower( $position );
		$result		= array();

		$modules =& JModuleHelper::_load();

		$total = count($modules);
		for($i = 0; $i < $total; $i++) {
			if($modules[$i]->position == $position) {
				$result[] =& $modules[$i];
			}
		}
		unset( $modules );

		if(count($result) == 0) {
			if(JRequest::getBool('tp')) {
				$result[0] = JModuleHelper::getModule( 'mod_'.$position );
				$result[0]->title = $position;
				$result[0]->content = $position;
				$result[0]->position = $position;
			}
		}

		return $result;
	}

	/**
	 * Checks if a module is enabled
	 *
	 * @access	public
	 * @param   string 	$module	The module name
	 * @return	boolean
	 */
	function isEnabled( $module )
	{
		$result = &JModuleHelper::getModule( $module);
		return (!is_null($result));
	}

	function renderModule( $module, $attribs = array() )
	{
		static $chrome;

		$mainframe =& JFactory::getApplication();
		$option	= JRequest::getCmd( 'option' );

		$scope = $mainframe->scope; //record the scope
		$mainframe->scope = $module->module;  //set scope to component name

		// Handle legacy globals if enabled
		if ($mainframe->getCfg('legacy'))
		{
			// Include legacy globals
			global $my, $database, $acl, $mosConfig_absolute_path;

			// Get the task variable for local scope
			$task = JRequest::getString('task');

			// For backwards compatibility extract the config vars as globals
			$registry =& JFactory::getConfig();
			foreach (get_object_vars($registry->toObject()) as $k => $v) {
				$name = 'mosConfig_'.$k;
				$$name = $v;
			}
			$contentConfig = &JComponentHelper::getParams( 'com_content' );
			foreach (get_object_vars($contentConfig->toObject()) as $k => $v)
			{
				$name = 'mosConfig_'.$k;
				$$name = $v;
			}
			$usersConfig = &JComponentHelper::getParams( 'com_users' );
			foreach (get_object_vars($usersConfig->toObject()) as $k => $v)
			{
				$name = 'mosConfig_'.$k;
				$$name = $v;
			}
		}

		// Get module parameters
		$params = new JParameter( $module->params );

		// Get module path
		$module->module = preg_replace('/[^A-Z0-9_\.-]/i', '', $module->module);
		$path = JPATH_BASE.DS.'modules'.DS.$module->module.DS.$module->module.'.php';

		// Load the module
		if (!$module->user && file_exists( $path ) && empty($module->content))
		{
			$lang =& JFactory::getLanguage();
			$lang->load($module->module);

			$content = '';
			ob_start();
			require $path;
			$module->content = ob_get_contents().$content;
			ob_end_clean();
		}

		// Load the module chrome functions
		if (!$chrome) {
			$chrome = array();
		}

		require_once JPATH_BASE.DS.'templates'.DS.'system'.DS.'html'.DS.'modules.php';
		$chromePath = JPATH_BASE.DS.'templates'.DS.$mainframe->getTemplate().DS.'html'.DS.'modules.php';
		if (!isset( $chrome[$chromePath]))
		{
			if (file_exists($chromePath)) {
				require_once $chromePath;
			}
			$chrome[$chromePath] = true;
		}

		//make sure a style is set
		if(!isset($attribs['style'])) {
			$attribs['style'] = 'none';
		}

		//dynamically add outline style
		if(JRequest::getBool('tp')) {
			$attribs['style'] .= ' outline';
		}

		// Do 3rd party stuff to manipulate module content
		// onRenderModule is allowed to alter the $module, $attribs
		// and may return a boolean.
		// true=remove, any other value = keep.
		// $result holds an array of booleans, 1 from each plugin.
		// we ditch the module if any of them = true.
		$result = $mainframe->triggerEvent( 'onRenderModule', array( &$module, &$attribs ) );
		if ( array_search( true, $result, true ) !== false ) {
			return '';
		}

		foreach(explode(' ', $attribs['style']) as $style)
		{
			$chromeMethod = 'modChrome_'.$style;

			// Apply chrome and render module
			if (function_exists($chromeMethod))
			{
				$module->style = $attribs['style'];

				ob_start();
				$chromeMethod($module, $params, $attribs);
				$module->content = ob_get_contents();
				ob_end_clean();
			}
		}

		$mainframe->scope = $scope; //revert the scope

		return $module->content;
	}

	/**
	 * Get the path to a layout for a module
	 *
	 * @static
	 * @param	string	$module	The name of the module
	 * @param	string	$layout	The name of the module layout
	 * @return	string	The path to the module layout
	 * @since	1.5
	 */
	function getLayoutPath($module, $layout = 'default')
	{
		$mainframe =& JFactory::getApplication();

		// Build the template and base path for the layout
		$tPath = JPATH_BASE.DS.'templates'.DS.$mainframe->getTemplate().DS.'html'.DS.$module.DS.$layout.'.php';
		$bPath = JPATH_BASE.DS.'modules'.DS.$module.DS.'tmpl'.DS.$layout.'.php';

		// Do 3rd party stuff to detect layout path for the module
		// onGetLayoutPath should return the path to the $layout of $module or false
		// $results holds an array of results returned from plugins, 1 from each plugin.
		// if a path to the $layout is found and it is a file, return that path
		$result = $mainframe->triggerEvent( 'onGetLayoutPath', array( $module, $layout ) );
		if (is_array($result)) {
			foreach ($result as $path) {
				if ($path !== false && is_file ($path)) return $path;
			}
		}
		
		// If the template has a layout override use it
		if (file_exists($tPath)) {
			return $tPath;
		} else {
			return $bPath;
		}
	}

	/**
	 * Load published modules
	 *
	 * @access	private
	 * @return	array
	 */
	function &_load()
	{
		$mainframe =& JFactory::getApplication();
		$Itemid = JRequest::getInt( 'Itemid', 0 ); // now default to 0

		static $modules;

		if (isset($modules)) {
			return $modules;
		}

		$user	=& JFactory::getUser();
		$db		=& JFactory::getDBO();

		$aid	= $user->get('aid', 0);
		$client = $mainframe->getClientId();

		$modules	= array();

		$extra = null;
		$extra->select = 'm.*';
		$extra->join = ' LEFT JOIN #__modules_menu AS mm ON mm.moduleid = m.id';
		$extra->where = ( $client == 0 ) ? ' AND ( mm.menuid = '. (int) $Itemid .' OR mm.menuid = 0 )' : ''; // now rely on $client instead of $Itemid to make the switch
		$extra->orderby = 'm.position, m.ordering';

		// Do 3rd party stuff to change query extras
		$mainframe->triggerEvent( 'onCreateModuleQuery', array( &$extra ) );

		$query = 'SELECT '.$extra->select
			.' FROM #__modules as m'
			.$extra->join
			.' WHERE m.published = 1'
			.' AND m.access '.( defined( '_JACL' ) ? 'IN ( '.$user->get( 'jaclplus', '0' ).' )' : '<= '. (int) $aid )
			.' AND m.client_id = '. (int) $client
			.$extra->where
			.' ORDER BY '.$extra->orderby;
		$db->setQuery( $query );

		if (null === ($modules = $db->loadObjectList())) {
			JError::raiseWarning( 'SOME_ERROR_CODE', JText::_( 'Error Loading Modules' ) . $db->getErrorMsg());
			return false;
		}

		$total = count($modules);
		for($i = 0; $i < $total; $i++)
		{
			//determine if this is a custom module
			$file					= $modules[$i]->module;
			$custom 				= substr( $file, 0, 4 ) == 'mod_' ?  0 : 1;
			$modules[$i]->user  	= $custom;
			// CHECK: custom module name is given by the title field, otherwise it's just 'om' ??
			$modules[$i]->name		= $custom ? $modules[$i]->title : substr( $file, 4 );
			$modules[$i]->style		= null;
			$modules[$i]->position	= strtolower($modules[$i]->position);
		}

		// Do 3rd party stuff to manipulate module array.
		// Any plugins using this architecture may make alterations to the referenced $modules array.
		// To remove items you can do unset($modules[n]) or $modules[n]->published = false.

		// "onPrepareModuleList" may alter or add $modules, and does not need to return anything.
		// This should be used for module addition/deletion that the user would expect to happen at an
		// early stage.
		$mainframe->triggerEvent( 'onPrepareModuleList', array( &$modules ) );

		// "onAlterModuleList" may alter or add $modules, and does not need to return anything.
		$mainframe->triggerEvent( 'onAlterModuleList', array( &$modules ) );

		// "onPostProcessModuleList" allows a plugin to perform actions like parameter changes
		// on the completed list of modules and is guaranteed to occur *after*
		// the earlier plugins.
		$mainframe->triggerEvent( 'onPostProcessModuleList', array( &$modules ) );

		// Remove any that were marked as disabled during the preceding steps
		foreach ( $modules as $id => $module ) {
			if ( !isset( $module->published ) || $module->published == 0 ) {
				unset( $modules[$id] );
			}
		}

		// Make sure the array is a straight forward array (with no gaps in key numbering)
		$modules = array_values( $modules );

		return $modules;
	}
}