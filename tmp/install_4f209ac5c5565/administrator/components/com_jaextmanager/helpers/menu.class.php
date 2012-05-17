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

defined('_VALID_MOS') or defined('_JEXEC') or die('Restricted access');

if (!defined('_JA_BASE_MENU_CLASS')) {
	define('_JA_BASE_MENU_CLASS', 1);
	
	class JAMenu
	{
		var $_menu = null;
		var $_activeMenu = null;


		function _menu()
		{
			$menu = new JAMenu();
			$menu->_loadMenu();
			$menu->genMenuId($menu->_menu);
			$menu->genMenuItems($menu->_menu);
		}


		function _loadMenu()
		{
			$xmlfile = dirname(__FILE__) . DS . 'menu.xml';
			
			$xml = new JSimpleXML();
			$xml->loadFile($xmlfile);
			if (!$xml->document) {
				echo "Cannot load menu xml: $xmlfile";
				return;
			}
			$this->_menu = $xml->document;
			//include the dynamic menu
		//include (dirname(__FILE__).DS.'dynamic_menu.php');
		}


		function genMenuId(& $item)
		{
			$temp = array();
			foreach ($item->children() as $child) {
				$child->parent = $item;
				$child->menuId = '';
				$child->menuId = md5($this->getlink($child) . $this->gettitle($child));
				if (isset($child->menuId) && isset($_GET['menuId']) && ($child->menuId == $_GET['menuId'])) {
					$this->_activeMenu[] = $child->menuId;
					$this->updateActiveMenu($child);
				}
				$this->genMenuId($child);
				$temp[] = $child;
			}
			$item->_children = $temp;
		}


		function updateActiveMenu($item)
		{
			if (isset($item->parent->menuId) && $item->parent->menuId != "") {
				$this->_activeMenu[] = $item->parent->menuId;
				$this->updateActiveMenu($item->parent);
			}
		}


		function addItem($parentname, $attrs)
		{
			if ($parentname)
				$parent = $this->findElementByAttribute($this->_menu, 'name', $parentname);
			else
				$parent = $this->_menu;
			
			if ($parent) {
				$parent->addChild('item', $attrs);
			}
		}


		function findElementByAttribute($item, $attr, $value)
		{
			if (strtolower($item->attributes($attr)) == strtolower($value))
				return $item;
			foreach ($item->children() as $child) {
				if (($found = $this->findElementByAttribute($child, $attr, $value)))
					return $found;
			}
			return null;
		}


		function genMenuItems($menu)
		{
			//print_r ($menu->children());
			if (!$menu || !$menu->children())
				return;
			
			$this->beginMenuItems($menu);
			$i = 0;
			foreach ($menu->children() as $item) {
				if ($item->name() != 'item')
					continue;
				if ($i++ == 0) {
					$item->addAttribute('first', true);
				}
				
				$this->beginMenuItem($item);
				$this->genMenuItem($item);
				
				// show menu with menu expanded - submenus visible
				$this->genMenuItems($item);
				
				$this->endMenuItem($item);
			
			}
			$this->endMenuItems($menu);
		}


		function genMenuItem($item)
		{
			echo "
			<a href=\"" . $this->getlink($item) . "\" " . $this->getclass($item) . " title=\"\">
				<span>" . JText::_($this->gettitle($item)) . "</span>
			</a>
			";
		}


		function beginMenuItems()
		{
			echo "<ul>";
		}


		function endMenuItems()
		{
			echo "</ul>";
		}


		function beginMenuItem($item = null)
		{
			echo "<li " . $this->getclass($item) . ">";
		}


		function endMenuItem($mitem = null)
		{
			echo "</li>";
		}


		function getclass($item)
		{
			$cls = $item->attributes('class');
			if ($item->attributes('first')) {
				$cls .= ' first';
			}
			if (count($item->children())) {
				$cls .= ' havechild';
			}
			if (is_array($this->_activeMenu)) {
				if (in_array($item->menuId, $this->_activeMenu)) {
					$cls .= ' active opened';
				}
			}
			
			$cls = trim($cls) ? 'class="' . trim($cls) . '"' : '';
			return $cls;
		}


		function getlink($item)
		{
			$link = $item->attributes('link');
			if (!isset($item->menuId))
				$item->menuId = 0;
			if ($link != "") {
				$link .= "&amp;menuId=" . $item->menuId;
			} else {
				$link = "menuId=" . $item->menuId;
			}
			return "index.php?$link";
		}


		function gettitle($item)
		{
			return $item->attributes('title');
		}
		/*
		 $pid: parent id
		 $level: menu level
		 $pos: position of parent
		 */
	}
}
?>
