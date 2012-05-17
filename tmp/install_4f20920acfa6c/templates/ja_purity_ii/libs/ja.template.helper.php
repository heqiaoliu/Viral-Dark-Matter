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


define ('JA_TOOL_COLOR', 'ja_color');
define ('JA_TOOL_SCREEN', 'ja_screen');
define ('JA_TOOL_FONT', 'ja_font');
define ('JA_TOOL_MENU', 'ja_menu');

require_once (dirname(__FILE__).DS.'ja.obj.extendable.php');

class JATemplateHelper extends ObjectExtendable {
	function JATemplateHelper ($template, $_params_cookie=null) {
		$helper = new JATemplateHelper1 ($template, $_params_cookie);
		$this->_extend (array($template, $helper));
	}
	
	function &getInstance($template=null, $_params_cookie=null)
	{
		static $instance;

		if (!isset( $instance )) {
			$instance = new JATemplateHelper ($template, $_params_cookie);
		}
		
		return $instance;
	}
	
	function display ($layout) {
		$this->_load ($layout);
	}
	
	function _load ($layout) {
		if (($layoutpath = $this->layout_exists ($layout))) {
			include ($layoutpath);
		}
	}

	function _display ($layout) {
		$tmplTools = JATemplateHelper::getInstance();
		$tmplTools->display ($layout);
	}
	
	function loadBlock ($name) {
		$this->_load ('blocks'.DS.$name);
	}	
	
	//Override template countModules function: prevent empty count.
	function countModules ($modules) {
		if ($this->isContentEdit()) return 0;
		$_tpl = $this->_tpl;
		return $modules?$_tpl->countModules ($modules):0;
	}
	
}

class JATemplateHelper1 {
	var $_params_cookie = null; //Params will store in cookie for user select. Default: store all params
	var $_tpl = null;
	var $template = '';
	var $_positions = null;
	var $_colwidth = null;
	var $_basewidth = 10;

	function JATemplateHelper1 ($template, $_params_cookie=null) {
		//$this->_extend ($template);
		
		$this->_tpl = $template;
		$this->template = $template->template;

		if(!$_params_cookie) {
			$this->_params_cookie = $this->_tpl->params->toArray();
		} else {
			foreach ($_params_cookie as $k) {
				$this->_params_cookie[$k] = $this->_tpl->params->get($k);
			}
		}
		$this->getUserSetting();

		$this->_colwidth = array();
		$this->_positions = array();
	}
	
	function addParamCookie ($_params_cookie) {
		if (!is_array($_params_cookie)) $_params_cookie = array($_params_cookie);
		$tpl = $this->_tpl;
		foreach ($_params_cookie as $k) {
			$this->_params_cookie[$k] = $tpl->params->get($k);
		}
		$this->getUserSetting();
	}
	
	function &getInstance1($template=null, $_params_cookie=null)
	{
		static $instance;

		if (!isset( $instance )) {
			$instance = new JATemplateHelper1 ($template, $_params_cookie);
		}
		
		return $instance;
	}
	
	function getUserSetting(){
		$exp = time() + 60*60*24*355;
		if (isset($_COOKIE[$this->template.'_tpl']) && $_COOKIE[$this->template.'_tpl'] == $this->template){
			foreach($this->_params_cookie as $k=>$v) {
				$kc = $this->template."_".$k;
				if (JRequest::getVar($k, null, 'GET') !== null) {
					$v = preg_replace('/[\x00-\x1F\x7F<>;\/\"\'%()]/', '', JRequest::getString($k, '', 'GET'));
					setcookie ($kc, $v, $exp, '/');
				}else{
					if (isset($_COOKIE[$kc])){
						$v = $_COOKIE[$kc];
					}
				}
				$this->setParam($k, $v);
			}

		}else{
			setcookie ($this->template.'_tpl', $this->template, $exp, '/');
		}
		return $this;
	}

	function getParam ($param, $default='', $raw=false) {
		if (isset($this->_params_cookie[$param])) {
			if ($raw) return $this->_params_cookie[$param];
			else return preg_replace('/[\x00-\x1F\x7F<>;\/\"\'%()]/', '', $this->_params_cookie[$param]);
		}
		if ($raw) $this->_tpl->params->get($param, $default);
		return preg_replace('/[\x00-\x1F\x7F<>;\/\"\'%()]/', '', $this->_tpl->params->get($param, $default));
	}

	function setParam ($param, $value) {
		$this->_params_cookie[$param] = $value;
	}

	function getCurrentURL(){
		$cururl = JRequest::getURI();
		/*if(($pos = strpos($cururl, "index.php"))!== false){
			$cururl = substr($cururl,$pos);
		}*/
		$cururl =  JRoute::_($cururl, true, 0);
		return $cururl;
	}

	function genToolMenu($_array_tools=null, $imgext = 'gif'){
		if(!is_array($_array_tools)) $_array_tools = array($_array_tools);
		if(!$_array_tools) $_array_tools = array_keys($this->_params_cookie);
		if (in_array(JA_TOOL_FONT, $_array_tools)){//show font tools
		?>
		<ul class="ja-usertools-font">
	      <li><img style="cursor: pointer;" title="<?php echo JText::_('Increase font size');?>" src="<?php echo $this->templateurl();?>/images/user-increase.<?php echo $imgext;?>" alt="<?php echo JText::_('Increase font size');?>" id="ja-tool-increase" onclick="switchFontSize('<?php echo $this->template."_".JA_TOOL_FONT;?>','inc'); return false;" /></li>
		  <li><img style="cursor: pointer;" title="<?php echo JText::_('Default font size');?>" src="<?php echo $this->templateurl();?>/images/user-reset.<?php echo $imgext;?>" alt="<?php echo JText::_('Default font size');?>" id="ja-tool-reset" onclick="switchFontSize('<?php echo $this->template."_".JA_TOOL_FONT;?>',<?php echo $this->_tpl->params->get(JA_TOOL_FONT);?>); return false;" /></li>
		  <li><img style="cursor: pointer;" title="<?php echo JText::_('Decrease font size');?>" src="<?php echo $this->templateurl();?>/images/user-decrease.<?php echo $imgext;?>" alt="<?php echo JText::_('Decrease font size');?>" id="ja-tool-decrease" onclick="switchFontSize('<?php echo $this->template."_".JA_TOOL_FONT;?>','dec'); return false;" /></li>
		</ul>
		<script type="text/javascript">var CurrentFontSize=parseInt('<?php echo $this->getParam(JA_TOOL_FONT);?>');</script>
		<?php
		}
	}

	function getCurrentMenuIndex(){
		$Itemid = JRequest::getInt( 'Itemid');
		$database		=& JFactory::getDBO();
		$id = $Itemid;
		$menutype = 'mainmenu';
		$ordering = '0';
		while (1){
			$sql = "select parent, menutype, ordering from #__menu where id = $id limit 1";
			$database->setQuery($sql);
			$row = null;
			$row = $database->loadObject();
			if ($row) {
				$menutype = $row->menutype;
				$ordering = $row->ordering;
				if ($row->parent > 0)
				{
					$id = $row->parent;
				}else break;
			}else break;
		}

		$user	=& JFactory::getUser();
		if (isset($user))
		{
			$aid = $user->get('aid', 0);
			$sql = "SELECT count(*) FROM #__menu AS m"
			. "\nWHERE menutype='". $menutype ."' AND published='1' AND access <= '$aid' AND parent=0 and ordering < $ordering";
		} else {
			$sql = "SELECT count(*) FROM #__menu AS m"
			. "\nWHERE menutype='". $menutype ."' AND published='1' AND parent=0 and ordering < $ordering";
		}
		$database->setQuery($sql);

		return $database->loadResult();
	}

	function calSpotlight ($spotlight, $totalwidth=100, $specialwidth=0, $special='first') {

		/********************************************
		$spotlight = array ('position1', 'position2',...)
		*********************************************/
		$modules = array();
		$modules_s = array();
		foreach ($spotlight as $position) {
			if( $this->_tpl->countModules ($position) ){
				$modules_s[] = $position;
			}
			$modules[$position] = array('class'=>'-full','width'=>$totalwidth.'%');
		}

		if (!count($modules_s)) return null;
		if ($specialwidth) {
			if (count($modules_s)>1) {
				$width = round(($totalwidth-$specialwidth)/(count($modules_s)-1),1) . "%";
				$specialwidth = $specialwidth . "%";
			}else{
				$specialwidth = $totalwidth . "%";
			}
		}else{
			$width = (round($totalwidth/(count($modules_s)),2)) . "%";
			$specialwidth = $width;
		}

		if (count ($modules_s) > 1){
			$modules[$modules_s[0]]['class'] = "-left";
			$modules[$modules_s[0]]['width'] = ($special=='left')?$specialwidth:$width;
			$modules[$modules_s[count ($modules_s) - 1]]['class'] = "-right";
			$modules[$modules_s[count ($modules_s) - 1]]['width'] = ($special=='right')?$specialwidth:$width;
			for ($i=1; $i<count ($modules_s) - 1; $i++){
				$modules[$modules_s[$i]]['class'] = "-center";
				$modules[$modules_s[$i]]['width'] = $width;
			}
		}
		return $modules;
	}	

	function isIE6 () {
		$msie='/msie\s(5\.[5-9]|[6]\.[0-9]*).*(win)/i';
		return isset($_SERVER['HTTP_USER_AGENT']) &&
			preg_match($msie,$_SERVER['HTTP_USER_AGENT']) &&
			!preg_match('/opera/i',$_SERVER['HTTP_USER_AGENT']);
	}
	
	function isIE () {
		$msie='/msie/i';
		return isset($_SERVER['HTTP_USER_AGENT']) &&
			preg_match($msie,$_SERVER['HTTP_USER_AGENT']) &&
			!preg_match('/opera/i',$_SERVER['HTTP_USER_AGENT']);
	}

	function isOP () {
		return isset($_SERVER['HTTP_USER_AGENT']) &&
			preg_match('/opera/i',$_SERVER['HTTP_USER_AGENT']);
	}


	function getRandomImage ($img_folder) {
		if (!is_dir ($img_folder)) return '';
		$imglist=array();

		mt_srand((double)microtime()*1000);

		//use the directory class
		$imgs = dir($img_folder);

		//read all files from the  directory, checks if are images and ads them to a list (see below how to display flash banners)
		while ($file = $imgs->read()) {
			if (eregi("gif", $file) || eregi("jpg", $file) || eregi("png", $file))
				$imglist[] = $file;
		}
		closedir($imgs->handle);

		if(!count($imglist)) return '';

		//generate a random number between 0 and the number of images
		$random = mt_rand(0, count($imglist)-1);
		$image = $imglist[$random];

		return $image;
	}

	function isFrontPage(){
		return (JRequest::getCmd( 'view' ) == 'frontpage') ;
	}
	
	function isContentEdit() {
		return (JRequest::getCmd( 'option' )=='com_content' && JRequest::getCmd( 'view' ) == 'article' && (JRequest::getCmd( 'task' ) == 'edit' || JRequest::getCmd( 'layout' ) == 'form'));
	}

	function sitename() {
		$config = new JConfig();
		return $config->sitename;
	}

	function browser () {
		$agent = $_SERVER['HTTP_USER_AGENT'];
		if ( strpos($agent, 'Gecko') )
		{
		   if ( strpos($agent, 'Netscape') )
		   {
		     $browser = 'NS';
		   }
		   else if ( strpos($agent, 'Firefox') )
		   {
		     $browser = 'FF';
		   }
		   else
		   {
		     $browser = 'Moz';
		   }
		}
		else if ( strpos($agent, 'MSIE') && !preg_match('/opera/i',$agent) )
		{
			 $msie='/msie\s(7|8\.[0-9]).*(win)/i';
		   	 if (preg_match($msie,$agent)) $browser = 'IE7';
		   	 else $browser = 'IE6';
		}
		else if ( preg_match('/opera/i',$agent) )
		{
		     $browser = 'OPE';
		}
		else
		{
		   $browser = 'Others';
		}
		return $browser;
	}

	function baseurl(){
		return JURI::base();
	}

	function templateurl(){
		return JURI::base()."templates/".$this->template;
	}

	function basepath(){
		return JPATH_SITE;
	}

	function templatepath(){
		return $this->basepath().DS."templates".DS.$this->template;
	}
		
	function getLayout () {
		global $Itemid, $option;
		
		if (($mobile = $this->mobile_device_detect_layout())) {
			
			// if agent is Iphone
			if( $mobile == 'iphone' ) {
				$iphone = $this->_tpl->params->get ( 'iphone_layout', $mobile );
				if ( $iphone != -1 && $this->layout_exists ($iphone) ) { 
					return $iphone;
				}
			} 
			// Other Handheld device
			$handheld = $this->_tpl->params->get ( 'other_handheld_layout', 'handheld' );
			if ( $handheld !=- 1 && $this->layout_exists ($handheld)) {
				return $handheld;
			}
	
			// auto dectect and choose layout with this device
			if (($mobile = $this->mobile_device_detect())) {
				if ($this->layout_exists ($mobile)) return $mobile;
				if ($this->layout_exists ('handheld')) return 'handheld';
			}
		}
		
		$page_layouts = $this->_tpl->params->get ('page_layouts');		
		$page_layouts = str_replace ("<br />", "\n", $page_layouts);		
		$playouts = new JParameter ($page_layouts);
		
		$layout = $playouts->get($Itemid);
		if ($this->layout_exists ($layout)) return $layout;
		
		$layout = $playouts->get($option);
		if ($this->layout_exists ($layout)) return $layout;
		
		$layout = $this->getParam ('main_layout', 'default');
		if ($this->layout_exists ($layout)) return $layout;
		
		if ($this->layout_exists ('default')) return 'default';
		return null;
	}
	
	function getMenuType () {
		global $Itemid, $option;
		
		if ($this->mobile_device_detect_layout()) {
			$mobile = $this->getLayout ();
			if (is_file(dirname(__FILE__).DS.'menu'.DS."$mobile.class.php")) $menutype = $mobile;
			else $menutype = 'handheld';
			return $menutype;
		}
		
		$page_menus = $this->_tpl->params->get ('page_menus');
		$page_menus = str_replace ("<br />", "\n", $page_menus);
		$pmenus = new JParameter ($page_menus);	
		
		$menutype = $pmenus->get($Itemid);
		if (is_file(dirname(__FILE__).DS.'menu'.DS."$menutype.class.php")) return $menutype;
		
		$menutype = $pmenus->get($option);
		if (is_file(dirname(__FILE__).DS.'menu'.DS."$menutype.class.php")) return $menutype;
		
		$menutype = $this->getParam(JA_TOOL_MENU, 'css');
		if (is_file(dirname(__FILE__).DS.'menu'.DS."$menutype.class.php")) return $menutype;
		return 'css';
	}
	
	function mobile_device_detect () {
		require_once ('mobile_device_detect.php');
		//bypass special browser:
		$special = array('jigs', 'w3c ', 'w3c-', 'w3c_');		
		if (in_array(strtolower(substr($_SERVER['HTTP_USER_AGENT'],0,4)), $special)) return false;
		return mobile_device_detect('iphone','android','opera','blackberry','palm','windows');
	}
	
	function mobile_device_detect_layout () {
		$ui = $this->getParam('ui');
		return $ui=='desktop'?false:(($ui=='mobile' && !$this->mobile_device_detect())?'iphone':$this->mobile_device_detect());
	}
			
	function layout_exists ($layout) {
		$layoutpath = $this->templatepath().DS.'layouts';
		if(is_file ($layoutpath.DS.$layout.'.php')) return $layoutpath.DS.$layout.'.php';
		return false;
	}

	function loadMenu ($params = null, $menutype = 'css') {
		static $jamenu;
		if (!isset($jamenu)) {
			$file = dirname(__FILE__).DS.'menu'.DS."$menutype.class.php";
			if (!is_file ($file)) return null;
			require_once ($file);
			$menuclass = "JAMenu{$menutype}";
			$jamenu = new $menuclass ($params);
			//assign template object
			$jamenu->_tmpl = $this;
			//load menu
			$jamenu->loadMenu();
			//check css/js file
			$file = $this->templatepath().DS.'css'.DS.'menu'.DS."$menutype.css";
			if (is_file ($file)) $jamenu->_css = $this->templateurl()."/css/menu/$menutype.css";
			$file = $this->templatepath().DS.'js'.DS.'menu'.DS."$menutype.js";
			if (is_file ($file)) $jamenu->_js = $this->templateurl()."/js/menu/$menutype.js";
		}
		return $jamenu;
	}
	
	function hasSubmenu () {
		$jamenu = $this->loadMenu();
		if ($jamenu && $jamenu->hasSubMenu (1) && $jamenu->showSeparatedSub ) return true;
		return false;
	}

	function getSectionId ($catid) {
		$db 	=& JFactory::getDBO();
		$query = "SELECT section FROM #__categories WHERE id=$catid;";
		$db->setQuery($query);
		return $db->loadResult();
	}

	function getThemeForSection () {
		//get the most parent menu id
		$query = "select params from #__modules where `module`='mod_janews2'";
		$database		=& JFactory::getDBO();
		$database->setQuery($query);
		$params = new JParameter($database->loadResult());
		$sections = $params->get('sections', '');
		if (!$sections) return '';
		
		global $Itemid;
		$mid = $Itemid;
		$pid = $mid;
		$menu = &JSite::getMenu();

		if(!$menu) return;    
		while ($pid) {
		  $mid = $pid;
		  $pmenu = $menu->getItem($mid);
		  $pid = $pmenu?$pmenu->parent:0;
		}
		//Get menu item
		$menuitem = $menu->getItem($mid);
		//parse link
		$urls = parse_url($menuitem->link);
		$querystring = $urls['query'];
		$output = null;
		parse_str ($querystring,$output);
		$sectionid = 0;
		if($output['view']=='section'){
			$sectionid = $output['id'];
		}
		else if($output['view']=='category'){
			$catid = $output['id'];
			$sectionid = $this->getSectionId($catid);
		}
		
		if($sectionid) {
			$sectionids = preg_split('/[\n,]|<br \/>/', $sections);
			for ($i = 0; $i < count($sectionids); $i++) {
			  $temp = preg_split('/:/',$sectionids[$i]);
			  if(isset($temp[0]) && $temp[0]==$sectionid) {
			  return isset($temp[1])? '-'.trim($temp[1]):'';
			}
		  }
		}
		return '';
	}	
	
	function getLastUpdate(){
		$db	 = &JFactory::getDBO();
		$query = 'SELECT created FROM #__content a ORDER BY created DESC LIMIT 1';
		$db->setQuery($query);
		$data = $db->loadObject();
		if( $data->created ){  //return gmdate( 'h:i:s A', strtotime($data->created) ) .' GMT ';
			 $date =& JFactory::getDate(strtotime($data->created));
			 $user =& JFactory::getUser();
   			 $tz = $user->getParam('timezone');
   			 $sec =$date->toUNIX();   //set the date time to second
   			 return gmdate("h:i:s A", $sec+$tz).' GMT';
		}
		return ;
	}

	function countModules ($modules) {
		if ($this->isContentEdit()) return 0;
		$_tpl = $this->_tpl;
		return $modules?$_tpl->countModules ($modules):0;
		//return $modules?$this->_tpl->countModules ($modules):0;
	}
	
	function definePosition ($positions) {
		$this->_positions = $positions;
		//parse layout
		$this->_colwidth = array();
		//Left
		$l = $l1 = $l2 = 0;
		$left1 = $this->getPositionName ('left1');
		$left2 = $this->getPositionName ('left2');
		$mt = $this->getPositionName ('left-mass-top');
		$mb = $this->getPositionName ('left-mass-bottom');
		if ($this->countModules ("$mt") || $this->countModules ("$mb") || ($this->countModules ("$left1") && $this->countModules ("$left2"))) {
			$l = 2;
			$l1 = $this->getColumnBasedWidth ('left1');
			$l2 = $this->getColumnBasedWidth ('left2');
		} else if ($this->countModules("$left1")) {
			$l = 1;
			$l1 = $this->getColumnBasedWidth ('left1');
		} else if ($this->countModules("$left2")) {
			$l = 1;
			$l2 = $this->getColumnBasedWidth ('left2');
		}
		$cls_l = $l?"l$l":"";
		$l = $l1 + $l2;
		
		//right
		$r = $r1 = $r2 = 0;
		$right1 = $this->getPositionName ('right1');
		$right2 = $this->getPositionName ('right2');
		$mt = $this->getPositionName ('right-mass-top');
		$mb = $this->getPositionName ('right-mass-bottom');
		if ($this->countModules ("$mt") || $this->countModules ("$mb") || ($this->countModules ("$right1") && $this->countModules ("$right2"))) {
			$r = 2;
			$r1 = $this->getColumnBasedWidth ('right1');
			$r2 = $this->getColumnBasedWidth ('right2');
		} else if ($this->countModules("$right1")) {
			$r = 1;
			$r1 = $this->getColumnBasedWidth ('right1');
		} else if ($this->countModules("$right2")) {
			$r = 1;
			$r2 = $this->getColumnBasedWidth ('right2');
		}
		$cls_r = $r?"r$r":"";
		$r = $r1 + $r2;
		
		//inset
		$inset1 = $this->getPositionName ('inset1');
		$inset2 = $this->getPositionName ('inset2');		
		$i1=$i2=0;
		if ($this->countModules("$inset1")) $i1 = $this->getColumnBasedWidth ('inset1');
		if ($this->countModules("$inset2")) $i2 = $this->getColumnBasedWidth ('inset2');

		//width
		$this->_colwidth ['r'] = $r;
		if ($r) {
			$this->_colwidth ['r1'] = round($r1 * 100 / $r);
			$this->_colwidth ['r2'] = 100 - $this->_colwidth ['r1'];
		}
		$this->_colwidth ['mw'] = 100 - $r;
		$m = 100 - $l -$r;
		$this->_colwidth ['l'] = ($l + $m)?round($l * 100 / ($l + $m)):0;
		if ($l) {
			$this->_colwidth ['l1'] = round($l1 * 100 / $l);
			$this->_colwidth ['l2'] = 100 - $this->_colwidth ['l1'];
		}
		$this->_colwidth ['m'] = 100 - $this->_colwidth ['l'];
		
		$c = $m - $i1 - $i2;
		$this->_colwidth ['i2'] = round($i2 * 100 / $m);
		$this->_colwidth ['cw'] = 100 - $this->_colwidth ['i2'];
		$this->_colwidth ['i1'] = ($c+$i1)?round($i1 * 100 / ($c+$i1)):0;
		$this->_colwidth ['c'] = 100 - $this->_colwidth ['i1'];
		
		$cls_li = $this->countModules ($inset1)?'l1':'';
		$cls_ri = $this->countModules ($inset2)?'r1':'';
		
		$this->_colwidth ['cls_w'] = ($cls_l || $cls_r)?"ja-$cls_l$cls_r":"";
		$this->_colwidth ['cls_m'] = ($cls_li || $cls_ri)?"ja-$cls_li$cls_ri":"";
		$this->_colwidth ['cls_l'] = $this->countModules ("$left1 && $left2")?"ja-l2":($this->countModules ("$left1 || $left2")?"ja-l1":"");
		$this->_colwidth ['cls_r'] = $this->countModules ("$right1 && $right2")?"ja-r2":($this->countModules ("$right1 || $right2")?"ja-r1":"");
	}
	
	function customwidth ($name, $width) {
		if (!isset ($this->_customwidth)) $this->_customwidth = array();
		$this->_customwidth [$name] = $width;
	}
	
	function getColumnBasedWidth ($name) {
		if ($this->isContentEdit()) return 0;
		return (isset ($this->_customwidth) && isset ($this->_customwidth[$name]) && $this->_customwidth[$name]) ? $this->_customwidth[$name]:$this->_basewidth;
	}
	
	function getPositionName ($name) {
		if (isset ($this->_positions[$name])) return trim($this->_positions[$name]);
		return '';
	}	
	
	function hasPosition ($name) {
		return $this->countModules ($this->getPositionName ($name));
	}	
		
	function getColumnWidth ($name) {
		if (isset($this->_colwidth [$name])) return $this->_colwidth [$name];
		return null;
	}	
}

make_object_extendable ('JATemplateHelper');