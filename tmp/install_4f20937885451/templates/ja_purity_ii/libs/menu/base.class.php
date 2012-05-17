<?php
/*
#------------------------------------------------------------------------
  T3 Framework for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/


defined('_JEXEC') or die('Restricted access');

if (!defined ('_JA_BASE_MENU_CLASS')) {
	define ('_JA_BASE_MENU_CLASS', 1);

	class JAMenuBase extends JObject{
		var $_params = null;
		var $children = null;
		var $open = null;
		var $items = null;
		var $Itemid = 0;
		var $showSeparatedSub = false;
		var $_tmpl = null;

		function __construct( &$params ){
			global $Itemid;
			$this->_params = $params;
			$this->Itemid = $Itemid;
			//$this->loadMenu();
		}

		function createParameterObject($param, $path='', $type='menu') {
			 return new JParameter($param, $path);			
		}

		function getPageTitle ($params) {
			return $params->get ('page_title');
			
		}
		
		function  loadMenu(){
    	    
			$user =& JFactory::getUser();
			$children = array ();
			$aid = $user->get('aid', 0);
			// Get Menu Items
			$items = &JSite::getMenu();
			$rows = $items->getItems('menutype', $this->getParam('menutype'));
			if(!count($rows)) 
				$rows = $items->getItems('menutype', 'mainmenu');
			if(!count($rows)) return;
    	    // first pass - collect children
    	    $cacheIndex = array();
 		    $this->items = array();
   	    	foreach ($rows as $index => $v) {
				$v->name = str_replace ('&', '&amp;', str_replace ('&amp;', '&', $v->name));
    		    if ($v->access <= $aid) {
    			    $pt = $v->parent;
    			    $list = @ $children[$pt] ? $children[$pt] : array ();
					
					$v->megaparams = $this->parseTitle ($v->name);
					$v->megaparams->set('class', str_replace (',', ' ', $v->megaparams->get('class', '')));
    			    $v->name = trim($v->megaparams->get('title'));
					//Load params added by plugin
					$vparams = new JParameter ($v->params);
					
					//get mega params
					$megaparams = $vparams->toObject();
					if ($megaparams) {
						foreach (get_object_vars($megaparams) as $mega_name=>$mega_value) {
							if (preg_match ('/mega_(.+)/', $mega_name, $matches)) {								
								if ($matches[1] == 'colxw') {
						    		if (preg_match_all ('/([^\s]+)=([^\s]+)/', $mega_value, $colwmatches)) {
										for ($i=0;$i<count($colwmatches[0]);$i++) {
											$v->megaparams->set ($colwmatches[1][$i],$colwmatches[2][$i]);
										}
						    		}
								} else {
									if (is_array($mega_value)) $mega_value = implode (',', $mega_value);
									$v->megaparams->set ($matches[1], $mega_value);
								}
							}
						}
					}					
					
					//reset cols for group item
					if ($v->megaparams->get('group')) $v->megaparams->set('cols', 1);
					
					if ($this->getParam('megamenu')) {
						$modules = $this->loadModules ($v->megaparams);
						//Update title: clear title if not show
						if (!$v->megaparams->get ('showtitle', 1)) $v->name = '';
						//if ($v->name == 'FAQ') {print_r ($v->megaparams);exit;}
						if ($modules && count($modules)>0) {
							$v->content = "";
							$total = count($modules);
							$cols =  min($v->megaparams->get('cols'), $total);
						
							for ($col=0;$col<$cols;$col++) {
								$pos = ($col == 0 ) ? 'first' : (($col == $cols-1) ? 'last' :'');
								if ($cols > 1) $v->content .= $this->beginSubMenuModules($v->id, 1, $pos, $col, true);
								$i = $col;
								while ($i<$total) {
									$mod = $modules[$i];
									$i += $cols;
									$mod_params = new JParameter($mod->params);
									$v->content .= JModuleHelper::renderModule($mod, array('style'=>$v->megaparams->get('style','jaxhtml')));
								}
								if ($cols > 1) $v->content .= $this->endSubMenuModules($v->id, 1, true);
							}
						
							$v->cols = $cols;
						
							$v->content = trim($v->content);
							$this->items[$v->id] = $v;
						}
					}
					
					switch ($v->type)
					{
						case 'separator' :
							$v->url = '#';
							break;
						case 'url' :
							if ((strpos($v->link, 'index.php?') !== false) && (strpos($v->link, 'Itemid=') === false)) {
								$v->url = $v->link.'&amp;Itemid='.$v->id;
							} else {
								$v->url = $v->link;
							}
							break;

						default :
							$router = JSite::getRouter();
							$v->url = $router->getMode() == JROUTER_MODE_SEF ? 'index.php?Itemid='.$v->id : $v->link.'&Itemid='.$v->id;
							break;

					}
					// Handle SSL links
					$iParams = $this->createParameterObject($v->params);
					$iSecure = $iParams->def('secure', 0);
					if ($v->home == 1) {
						$v->url = JURI::base();
					} elseif (strcasecmp(substr($v->url, 0, 4), 'http') && (strpos($v->link, 'index.php?') !== false)) {
						$v->url = JRoute::_($v->url, true, $iSecure);
					} else {
						$v->url = str_replace('&', '&amp;', $v->url);
					}
					//calculate menu column
					if (!isset($v->clssfx)) {
						$v->clssfx = $iParams->get('pageclass_sfx', '');
						if ($v->megaparams->get('cols')) {
							$v->cols = $v->megaparams->get('cols');							
							$v->col = array();
							for ($i=0;$i<$v->cols;$i++) {
								if ($v->megaparams->get("col$i")) $v->col[$i]=$v->megaparams->get("col$i");
							}
						}
					}
					
					$v->_idx = count($list);									
					array_push($list, $v);
    			    $children[$pt] = $list;
					$cacheIndex[$v->id] = $index;
					$this->items[$v->id] = $v;
    		    }
    	    }
    	    
            $this->children = $children;
    	    
            //unset item load module but no content
    	    foreach ($this->items as $v) {
    	    	if (($v->megaparams->get('modid') || $v->megaparams->get('modname') || $v->megaparams->get('modpos'))
    	    		 && !isset($this->children[$v->id]) && (!isset($v->content) || !$v->content)) {
    	    		$this->remove_item($this->items[$v->id]);
    	    		unset($this->items[$v->id]);
    	    	}
    	    }

    	    // second pass - collect 'open' menus
    	    $open = array (
    		    $this->Itemid
    	    );
    	    $count = 20; // maximum levels - to prevent runaway loop
    	    $id = $this->Itemid;

    	    while (-- $count)
    	    {
    		    if (isset($cacheIndex[$id])) {
    			    $index = $cacheIndex[$id];
    			    if (isset ($rows[$index]) && $rows[$index]->parent > 0) {
    				    $id = $rows[$index]->parent;
    				    $open[] = $id;
    			    } else {
    				    break;
    			    }
    		    }
    	    }
            $this->open = $open;
		   // $this->items = $rows;
	    }
	    
		function remove_item ($item) {
			$result = array();
			foreach ($this->children[$item->parent] as $o) {
				if ($o->id != $item->id) {
					$result[] = $o;
				}
			}
			$this->children[$item->parent] = $result;
		}
				
	    function parseTitle ($title) {
	    	//replace escape character
	    	$title = str_replace (array('\\[','\\]'), array('%open%', '%close%'), $title);
	    	$regex = '/([^\[]*)\[([^\]]*)\](.*)$/';
	    	if (preg_match ($regex, $title, $matches)) {
	    		$title = $matches[1];
	    		$params = $matches[2];
	    		$desc = $matches[3];
	    	} else {
	    		$title = $title;
	    		$params = '';
	    		$desc = '';
	    	}
	    	$title = str_replace (array('%open%', '%close%'), array('[',']'), $title);
	    	$desc = str_replace (array('%open%', '%close%'), array('[',']'), $desc);
	    	$result = new JParameter('');
	    	$result->set('title', trim($title));
	    	$result->set('desc', trim($desc));
	    	if ($params) {
	    		if (preg_match_all ('/([^\s]+)=([^\s]+)/', $params, $matches)) {
					for ($i=0;$i<count($matches[0]);$i++) {
						$result->set ($matches[1][$i],$matches[2][$i]);
					}
	    		}
	    	}
	    	return $result;
	    }
	    
	    function loadModules($params) {
		    //Load module
		    $modules = array();
		    switch ($params->get ('subcontent')) {
		    	case 'mod':
		    		$ids = preg_split ('/,/', $params->get ('subcontent-mod-modules',''));
					foreach ($ids as $id) {
						if ($module=$this->getModule ($id)) $modules[] = $module;
					}
					return $modules;
		    		break;
		    	case 'pos':
		    		$poses = preg_split ('/,/', $params->get ('subcontent-pos-positions',''));
					foreach ($poses as $pos) {
						$modules = array_merge ($modules, $this->getModules ($pos));
					}
					return $modules;
		    		break;
		    	default:
		    		return $this->loadModules_ ($params); //load as old method
		    }
		    return null;
	    }
	    
	    function loadModules_($params) {
		    //Load module
		    $modules = array();
			if (($modid = $params->get('modid'))) {
				$ids = preg_split ('/,/', $modid);
				foreach ($ids as $id) {
					if ($module=$this->getModule ($id)) $modules[] = $module;
				}
				return $modules;
			} 
			
			if (($modname = $params->get('modname'))) {
				$names = preg_split ('/,/', $modname);
				foreach ($names as $name) {
					if (($module=$this->getModule (0, $name))) $modules[] = $module;
				}
				return $modules;
			}
			
			if (($modpos = $params->get('modpos'))) {
				$poses = preg_split ('/,/', $modpos);
				foreach ($poses as $pos) {
					$modules = array_merge ($modules, $this->getModules ($pos));
				}
				return $modules;
			}
			return null;
	    }
	    
		function getModules ($position) {
			return JModuleHelper::getModules ($position);
		}

		function getModule ($id=0, $name='') {
			$result		= null;
			$modules	=& JModuleHelper::_load();
			$total		= count($modules);
			for ($i = 0; $i < $total; $i++)
			{
				// Match the name of the module
				if ($modules[$i]->id == $id || $modules[$i]->name == $name)
				{
					return $modules[$i];
				}
			}
			return null;
		}
		function genMenuItem($item, $level = 0, $pos = '', $ret = 0)
		{
			$data = '';
			$tmp = $item;

			// Print a link if it exists
			$active = $this->genClass ($tmp, $level, $pos);

			$id='id="menu' . $tmp->id . '"';
			$iParams = new JParameter ( $item->params );
			$itembg = '';
			if ($this->getParam('menu_images') && $iParams->get('menu_image') && $iParams->get('menu_image') != -1) {
				if ($this->getParam('menu_background')) {
					$itembg = 'style="background-image:url('.JURI::base().'/images/stories/'.$iParams->get('menu_image').');"';
					$txt = '<span class="menu-title">' . $tmp->name . '</span>';
				} else {
					$txt = '<span class="menu-image"><img src="'.JURI::base().'/images/stories/'.$iParams->get('menu_image').'" alt="'.$tmp->name.'" title="'.$tmp->name.'" /></span><span class="menu-title">' . $tmp->name . '</span>';
				}
			} else {
				$txt = '<span class="menu-title">' . $tmp->name . '</span>';
			}
			//Add page title to item
			if ($tmp->megaparams->get('desc')) {
				$txt .= '<span class="menu-desc">'. $tmp->megaparams->get('desc').'</span>';
			}
			
			if (isset ($itembg) && $itembg) {
				$txt = "<span class=\"has-image\" $itembg>".$txt."</span>";
			}
			$title = "title=\"$tmp->name\"";
			
			if ($tmp->type == 'menulink')
			{
				$menu = &JSite::getMenu();
				$alias_item = clone($menu->getItem($tmp->query['Itemid']));
				if (!$alias_item) {
					return false;
				} else {
					$tmp->url = $alias_item->link;
				}
			}
			if ($tmp->name) {
				if ($tmp->type == 'separator')
				{
					$data = '<a href="#" '.$active.' '.$id.' '.$title.'>'.$txt.'</a>';				
				} else {
					if ($tmp->url != null)
					{
						switch ($tmp->browserNav)
						{
							default:
							case 0:
								// _top
								$data = '<a href="'.$tmp->url.'" '.$active.' '.$id.' '.$title.'>'.$txt.'</a>';
								break;
							case 1:
								// _blank
								$data = '<a href="'.$tmp->url.'" target="_blank" '.$active.' '.$id.' '.$title.'>'.$txt.'</a>';
								break;
							case 2:
								// window.open
								$attribs = 'toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes,'.$this->getParam('window_open');
		  
								// hrm...this is a bit dickey
								$link = str_replace('index.php', 'index2.php', $tmp->url);
								$data = '<a href="'.$link.'" onclick="window.open(this.href,\'targetWindow\',\''.$attribs.'\');return false;" '.$active.' '.$id.' '.$title.'>'.$txt.'</a>';
								break;
						}
					} else {
						$data = '<a '.$active.' '.$id.' '.$title.'>'.$txt.'</a>';
					}
				}
			}
			
			//for megamenu
			if ($this->getParam ('megamenu')) {
				//For group
				if ($tmp->megaparams->get('group') && $data)
					$data = "<div class=\"group-title\">$data</div>";
				
				if (isset($item->content) && $item->content) {
					if ($item->megaparams->get('group')){
						$data .= "<div class=\"group-content\">{$item->content}</div>";
					}else{
						$data .= $this->beginMenuItems($item->id, $level+1, true);
						$data .= $item->content;
						$data .= $this->endMenuItems($item->id, $level+1, true);
					}
				}
			}
			
			if ($ret) return $data; else echo $data;				
		}

		function getParam($paramName, $default=null){
			return $this->_params->get($paramName, $default);
		}

		function setParam($paramName, $paramValue){
			return $this->_params->set($paramName, $paramValue);
		}

		function beginMenu($startlevel=0, $endlevel = 10){
			echo "<div>";
		}
		function endMenu($startlevel=0, $endlevel = 10){
			echo "</div>";
		}

		function beginMenuItems($pid=0, $level=0){
			echo "<ul>";
		}
		function endMenuItems($pid=0, $level=0){
			echo "</ul>";
		}
		function beginSubMenuItems($pid=0, $level=0, $pos='', $i, $return = false){
			//for megamenu menu
		}
		function endSubMenuItems($pid=0, $level=0, $return = false){
			//for megamenu menu
		}

		function beginMenuItem($mitem=null, $level = 0, $pos = ''){
			$active = $this->genClass ($mitem, $level, $pos);
			echo "<li $active>";
		}
		function endMenuItem($mitem=null, $level = 0, $pos = ''){
			echo "</li>";
		}

		function genClass ($mitem, $level, $pos) {
			$iParams = new JParameter ( $mitem->params );
			$active = in_array($mitem->id, $this->open);
			$cls = ($level?"":"menu-item{$mitem->_idx}"). ($active?" active":"").($pos?" $pos-item":"");
			if (@$this->children[$mitem->id] && $level < $this->getParam ('endlevel')) $cls .= " haschild";
			return $cls?"class=\"$cls\"":"";
		}

		function hasSubMenu($level) {
			$pid = $this->getParentId ($level);
			if (!$pid) return false;
			return $this->hasSubItems ($pid);
		}
		function hasSubItems($id){
			if (@$this->children[$id]) return true;
			return false;
		}
		function genMenu($startlevel=0, $endlevel = -1){
			$this->setParam('startlevel', $startlevel);
			$this->setParam('endlevel', $endlevel==-1?10:$endlevel);
			$this->beginMenu($startlevel, $endlevel);

			if ($this->getParam('startlevel') == 0) {
				//First level
				$this->genMenuItems (0, 0);
			}else{
				//Sub level
				$pid = $this->getParentId($this->getParam('startlevel'));
				if ($pid)
				$this->genMenuItems ($pid, $this->getParam('startlevel'));
			}
			$this->endMenu($startlevel, $endlevel);
		}

		/*
		 $pid: parent id
		 $level: menu level
		 $pos: position of parent
		 */

		function genMenuItems($pid, $level) {
			if (@$this->children[$pid]) {
				//Detect description. If some items have description, must generate empty description for other items
				$hasDesc = false;
				foreach ($this->children[$pid] as $row) {
					if ($row->megaparams->get('desc')) {
						$hasDesc = true;
						break;
					}
				}
				if ($hasDesc) {
					//Update empty description with a space - &nbsp;
					foreach ($this->children[$pid] as $row) {
						if (!$row->megaparams->get('desc')) {
							$row->megaparams->set('desc', '&nbsp;');
						}
					}
				}
				
				$j = 0;
				$cols = $pid && $this->getParam('megamenu') && isset($this->items[$pid]) && isset($this->items[$pid]->cols) && $this->items[$pid]->cols ? $this->items[$pid]->cols : 1;				
				$total = count ($this->children[$pid]);
				$tmp = $pid?$this->items[$pid]:new stdclass();
				if ($cols > 1) {
					$fixitems = count($tmp->col);
					if ($fixitems < $cols) {
						$fixitem = array_sum($tmp->col);
						$leftitem = $total-$fixitem;
						$items = ceil ($leftitem/($cols-$fixitems));
						for ($m=0;$m<$cols && $leftitem > 0;$m++) {
							if (!isset($tmp->col[$m]) || !$tmp->col[$m]) { 
								if ($leftitem > $items) {
									$tmp->col[$m] = $items;
									$leftitem -= $items;
								} else {
									$tmp->col[$m] = $leftitem;
									$leftitem = 0;
								}
							}
						}
						
						$cols = count ($tmp->col);
						$tmp->cols = $cols;
					}
				} else {
					$tmp->col = array($total);
				}
				
				$this->beginMenuItems($pid, $level);
				for ($col=0;$col<$cols && $j<$total;$col++) {
					$pos = ($col == 0 ) ? 'first' : (($col == $cols-1) ? 'last' :'');
					$this->beginSubMenuItems($pid, $level, $pos, $col);
					$i = 0;
					while ($i < $tmp->col[$col] && $j<$total) {
					//foreach ($this->children[$pid] as $row) {
						$row = $this->children[$pid][$j];
						$pos = ($i == 0 ) ? 'first' : (($i == count($this->children[$pid])-1) ? 'last' :'');

						$this->beginMenuItem($row, $level, $pos);
						$this->genMenuItem( $row, $level, $pos);

						// show menu with menu expanded - submenus visible
						
						if ($this->getParam('megamenu') && $row->megaparams->get('group')) $this->genMenuItems( $row->id, $level ); //not increase level
						else if ($level < $this->getParam('endlevel')) $this->genMenuItems( $row->id, $level+1 );

						$this->endMenuItem($row, $level, $pos);
						$j++;$i++;
					}
					$this->endSubMenuItems($pid, $level);
				}
				$this->endMenuItems($pid, $level);
			}
		}

		function indentText($level, $text) {
			echo "\n";
			for ($i=0;$i<$level;++$i) echo "   ";
			echo $text;
		}

		function getParentId ($level) {
			if (!$level || (count($this->open) < $level)) return 0;
			return $this->open[count($this->open)-$level];
		}

		function getParentText ($level) {
			$pid = $this->getParentId ($level);
			if ($pid) {
				return $this->items[$pid]->name;
			}else return "";
		}

		function genMenuHead () {
			if (isset($this->_css) && $this->_css) {
				echo "<link href=\"{$this->_css}\" rel=\"stylesheet\" type=\"text/css\" />";			
			}
			if (isset($this->_js) && $this->_js) {
				echo "<script src=\"{$this->_js}\" language=\"javascript\" type=\"text/javascript\"></script>";
			}
		}
	}
}