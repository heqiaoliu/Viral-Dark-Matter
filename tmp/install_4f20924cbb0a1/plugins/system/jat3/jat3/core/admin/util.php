<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */

class JAT3_AdminUtil{
	var $template = '';
	
	function JAT3_AdminUtil(){
		$this->template = JAT3_AdminUtil::get_active_template();
	}
	
	function get_active_template () {
		$app = JFactory::getApplication('administrator');
		if($app->isAdmin()){
			$styleid = JRequest::getInt('id');
			$db			= JFactory::getDBO();
			$query		= 'SELECT template'
				. ' FROM #__template_styles'
				. ' WHERE id='.(int)$styleid;
			$db->setQuery($query);
			$template	= $db->loadResult();
			return strtolower($template);
		}
		else{
			return $app->getTemplate(false);
		}
	}
	
	/*
	 * Get all active templates in J1.6
	 */
	function get_active_templates() 
	{
		$db			= JFactory::getDBO();
		$query		= 'SELECT template'
			. ' FROM #__template_styles'
			. ' WHERE client_id = 0 AND home <> \'0\' ';
		$db->setQuery($query);
		$templates	= $db->loadResultArray();
		return $templates;
	}
	
	function getGeneralConfig(){
		$path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'params.ini';
		if (file_exists($path)) {
			return JFile::read($path);			
		}
		return '';
	}
	
	function getPageIds($name){
		$selections				= JHTML::_('menu.linkoptions');
		
		$components = $this->getComponents();
		
		$selections[] = JHTML::_('select.optgroup',   JText::_('Component') );
		foreach ($components as $text){
			$selections[] = JHTML::_('select.option',  $text, $text );
		}
		
		$selections	= JHTML::_('select.genericlist',   $selections, $name.'-selections[]', 'class="selections" size="15" multiple="multiple"', 'value', 'text', array(), $name.'-selections' );
		
		return $selections;
	}
	
	function getComponents()
	{
		jimport('joomla.filesystem.folder');

		// Initialise variables.
		$lang = JFactory::getLanguage();
		$list = array();

		// Get the list of components.
		$db = JFactory::getDBO();
		$db->setQuery(
			'SELECT `name`, `element` AS "option"' .
			' FROM `#__extensions`' .
			' WHERE `type` = "component"' .
			' AND `enabled` = 1' .
			' ORDER BY `name`'
		);
		$components = $db->loadResultArray();
		$list = array();
		foreach ($components as $k=>$component)
		{
			$mainFolder = JPATH_SITE.'/components/'.$component;
			if (JFolder::exists($mainFolder))
			{
				$list[] = $component;
			}
		}
		return $list;
	}
	
	function getThemes(){
		jimport('joomla.filesystem.folder');
		jimport('joomla.filesystem.file');
		
		$arr_folder = array('core', 'local');
		foreach ($arr_folder as $type){
			$path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.$type.DS.'themes';
			if(!JFolder::exists($path)){
				JFolder::create($path);
				$content = '';
				JFile::write($path.DS.'index.html', $content);
			}
			$folders[$type] = @ JFolder::folders($path);
		}
		foreach ($arr_folder as $type){
			if(isset($folders[$type])){
				sort($folders[$type]);
			}
		}
		
		return $folders;		
	}
	
	function getLayouts(){
		jimport('joomla.filesystem.folder');
		jimport('joomla.filesystem.file');

		$layouts = array();
		$file_layouts = array();
		$arr_folder = array('core', 'local');
		foreach ($arr_folder as $folder){
			$path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.$folder.DS.'etc'.DS.'layouts';
			if(!JFolder::exists($path)){
				JFolder::create($path);
				$content = '';
				JFile::write($path.DS.'index.html', $content);
			}
			
			$files = @ JFolder::files($path, '\.xml');
			if($files){
				foreach ($files as $f){
					$file_layouts[$f] = $path.DS.$f;
				}
			}
		}
		//get layouts from core
		$path = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts';
		if (!is_dir ($path)) die ($path);
		$files = @ JFolder::files($path, '\.xml');
		if($files){
			foreach ($files as $f){
				if (!isset ($file_layouts[$f])) $file_layouts[$f] = $path.DS.$f;
			}
		}		
		
		if($file_layouts){
			foreach ($file_layouts as $name=>$p){
				$layout = new stdclass();
				$path = 'etc'.DS.'layouts'.DS.$name;
				
				$file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'local'.DS.$path;
				$layout->local = null;				
				if(JFile::exists($file)){
					$layout->local = JFile::read($file). ' ';
				}
				//Get core 
				
				$file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'core'.DS.$path;
				if (!JFile::exists($file)) $file = T3Path::path(T3_BASETHEME).DS.$path;
				$layout->core = null;				
				if(JFile::exists($file)){
					$layout->core = JFile::read($file).' ';
				}
				$layouts[strtolower(substr($name,0, -4))] = $layout;
			}
		}
		return $layouts;
	}

	function buildHTML_Layout($value, $name){
		$layouts = $this->getLayouts();
		
		$element = array();
		$element[] = JHTML::_('select.option',  '-1', JText::_('disabled'));
		if(!in_array($value, $layouts)) $value = 'default';
		if($layouts){
			foreach ($layouts as $layout=>$content){
				$element[] = JHTML::_('select.option',  $layout, $layout );
			}
		}
		$layoutHTML	= JHTML::_('select.genericlist',   $element, "params[$name]", 'class="inputbox jat3-el-layouts"', 'value', 'text', $value );
		return $layoutHTML;
	}
	
	function getProfiles(){
		jimport('joomla.filesystem.folder');
		jimport('joomla.filesystem.file');

		$profiles = array();
		$file_profiles = array();
		$arr_folder = array('core', 'local');
		foreach ($arr_folder as $folder){
			$path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.$folder.DS.'etc'.DS.'profiles';
			if(!JFolder::exists($path)){
				JFolder::create($path);
				$content = '';
				JFile::write($path.DS.'index.html', $content);
			}
			
			$files = @ JFolder::files($path, '\.ini');
			if($files){
				foreach ($files as $f){
					$file_profiles[$f] = $path.DS.$f;
				}
			}
		}
		
		if($file_profiles){
			foreach ($file_profiles as $name=>$p){
				$dparams = array();
				if ($name == 'default.ini') {
					$xmlpath = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'templateDetails.xml';
					$xml = & JFactory::getXMLParser('Simple');
	
					if ($xml->loadFile($xmlpath))
					{
						if ($params = & $xml->document->params) {
							foreach ($params as $param)
							{
								foreach ($param->children() as $p) {
									if ($p->attributes('name') && isset($p->_attributes['default']))
										$dparams [$p->attributes('name')] = $p->attributes('default');
								}
							}
						}
					}				
				}
				$profile = new stdclass();
				$path = 'etc'.DS.'profiles'.DS.$name;
				
				$file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'local'.DS.$path;
				$profile->local = null;				
				if(JFile::exists($file)){
					$params = new JParameter(JFile::read($file));
					$profile->local = array_merge ($dparams, $params->toArray());
				}
				$file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'core'.DS.$path;
				$profile->core = null;				
				if(JFile::exists($file)){
					$params = new JParameter(JFile::read($file));
					$profile->core = array_merge ($dparams, $params->toArray());
				}
				$profiles[strtolower(substr($name,0, -4))] = $profile;
			}
		}
		if(!$profiles){
			$profile = new stdclass();
			$profile->core =  '  ';
			$profile->local =  null;
			$profiles['default'] = $profile;
		}
		return $profiles;
	}
		
	
	function getTemplateVersion($template){	
		$version = '';
		$name = '';
		$path = JPATH_SITE.DS.'templates'.DS.$template.DS.'templateDetails.xml';
		if(!file_exists($path)){
			return JText::_('Not information about the version of this template');
		}
		$xml = & JFactory::getXMLParser('Simple');
		
		
		if ($xml->loadFile($path))
		{
			$temp_info = & $xml->document;
			if(isset($temp_info->_children) && count($temp_info->_children)){
				foreach ($temp_info->_children as $node){
					if($version && $name) break;
					if($node->_name=='version'){
						$version = $node->_data;
					}
					elseif($node->_name == 'name'){
						$name = $node->_data;
					}
				}
			}
			
		}
		if(!$version) $version = '1.0.0';
		return $version;
	}
	
	function unpackzip($p_filename)
	{		
		// Path to the archive
		$archivename = $p_filename;

		// Temporary folder to extract the archive into
		$tmpdir = '';

		// Clean the paths to use for archive extraction
		$extractdir = JPath::clean(dirname($p_filename));
		$archivename = JPath::clean($archivename);

		// do the unpacking of the archive
		$result = JArchive::extract( $archivename, $extractdir);

		if ( $result === false ) {
			return false;
		}
		return true;
	}
	
	function getThemeinfo($theme_info_path){	
		$data = array();	
		
		$xml = & JFactory::getXMLParser('Simple');
		
		if ($xml->loadFile($theme_info_path))
		{
			$theme_info = & $xml->document;
			if(isset($theme_info->_children) && count($theme_info->_children)){
				foreach ($theme_info->_children as $node){
					$data[$node->_name] = $node->_data;
				}
			}
			
		}
		return $data;
	}
	
	function buildHTML_Positions($name){
		$positions = $this->getPositions();
		$positionsHTML = '';
		$element = array();
		if($positions){
			foreach ($positions as $p){
				$element[] = JHTML::_('select.option',  $p, $p );
			}		
		}
		$positionsHTML	= JHTML::_('select.genericlist',   $element, $name.'-positions[]', 'class="inputbox" size="15" ondblclick="jaclass_'.$name.'.select_position(this)"', 'value', 'text', array(), $name.'-positions' );
		return $positionsHTML;
	}
	
		
	function getPositions()
	{
		jimport('joomla.filesystem.folder');

		$client =& JApplicationHelper::getClientInfo(0);
		if ($client === false) {
			return false;
		}

		//Get the database object
		$db	=& JFactory::getDBO();

		// template assignment filter
		$query = 'SELECT DISTINCT(template) AS text, template AS value'.
				' FROM #__templates_menu' .
				' WHERE client_id = '.(int) $client->id;
		$db->setQuery( $query );
		$templates = $db->loadObjectList();

		// Get a list of all module positions as set in the database
		$query = 'SELECT DISTINCT(position)'.
				' FROM #__modules' .
				' WHERE client_id = '.(int) $client->id;
		$db->setQuery( $query );
		$positions = $db->loadResultArray();
		$positions = (is_array($positions)) ? $positions : array();

		// Get a list of all template xml files for a given application

		// Get the xml parser first
		for ($i = 0, $n = count($templates); $i < $n; $i++ )
		{
			$path = $client->path.DS.'templates'.DS.$templates[$i]->value;

			$xml =& JFactory::getXMLParser('Simple');
			if ($xml->loadFile($path.DS.'templateDetails.xml'))
			{
				$p =& $xml->document->getElementByPath('positions');
				if (is_a($p, 'JSimpleXMLElement') && count($p->children()))
				{
					foreach ($p->children() as $child)
					{
						if (!in_array($child->data(), $positions)) {
							$positions[] = $child->data();
						}
					}
				}
			}
		}

		if(defined('_JLEGACY') && _JLEGACY == '1.0')
		{
			$positions[] = 'left';
			$positions[] = 'right';
			$positions[] = 'top';
			$positions[] = 'bottom';
			$positions[] = 'inset';
			$positions[] = 'banner';
			$positions[] = 'header';
			$positions[] = 'footer';
			$positions[] = 'newsflash';
			$positions[] = 'legals';
			$positions[] = 'pathway';
			$positions[] = 'breadcrumb';
			$positions[] = 'user1';
			$positions[] = 'user2';
			$positions[] = 'user3';
			$positions[] = 'user4';
			$positions[] = 'user5';
			$positions[] = 'user6';
			$positions[] = 'user7';
			$positions[] = 'user8';
			$positions[] = 'user9';
			$positions[] = 'advert1';
			$positions[] = 'advert2';
			$positions[] = 'advert3';
			$positions[] = 'debug';
			$positions[] = 'syndicate';
		}

		$positions = array_unique($positions);
		sort($positions);

		return $positions;
	}
	
	
	function isSetColwidth($block=''){
		if(in_array($block, array('left1', 'left2', 'right1', 'right2', 'inset1', 'inset2'))){
			return true;
		}
		return false;
	}

	function checkexistExtensinsManagement(){
		$db = JFactory::getDBO();
		$query =" SELECT Count(*) FROM #__extensions as c WHERE c.name='com_jaextmanager' and c.type='component' and c.`client_id`=0 and c.enabled=1";
		$db->setQuery($query);	
		return $db->loadResult();
	}
	
	function getDatabaseValue(){
		$db =& JFactory::getDBO();
		$id = JRequest::getVar ( 'cid', 0, '', 'array' );
		$id = ( int ) $id [0];
		if($id == "") $id = 0;
		$query = "SELECT * FROM #__menu WHERE id = '".$id."'";
		$db->setQuery($query);
		return $db->loadObject();
	}
	
	function getSystemParams($xmlstring){		
		// Initialize variables
		$params	= null;
		$item	= $this->getDatabaseValue();
		if(isset($item->params)) {
			$params = new JParameter( $item->params );
			//update value to make it compatible with old parameter
			if (!$params->get ('mega_subcontent_mod_modules','') && $params->get ('mega_subcontent-mod-modules')) {
				$params->set ('mega_subcontent_mod_modules', $params->get ('mega_subcontent-mod-modules'));
			}
			if (!$params->get ('mega_subcontent_pos_positions','') && $params->get ('mega_subcontent-pos-positions')) {
				$params->set ('mega_subcontent_pos_positions', $params->get ('mega_subcontent-pos-positions'));
			}
		} else
			$params = new JParameter( "" );
		$xml =& JFactory::getXMLParser('Simple');
		if ($xml->loadString($xmlstring)) {
			$document =& $xml->document;
			$params->setXML($document->getElementByPath('state/params'));
		}
		return $params->render('params');
		
	}
	
	/**
	 * Popup prepare content method
	 *
	 * @param 	string		The body string content.
	 */
	function replaceContent( $bodyContent ){
		// Build HTML params area
		$xmlFile = T3Path::path(T3_CORE) . DS . 'params' . DS ."jatoolbar.xml";
		if(! file_exists($xmlFile) ){
			return $bodyContent;
		}
		$str = "";
		
		$configform = JForm::getInstance('params', $xmlFile, array('control' => 'jform'));
		
		$fieldSets = $configform->getFieldsets('params');
		$html = '';
		foreach ($fieldSets as $name => $fieldSet){
			$html .= '<div class="panel">
				<h3 id="jatoolbar-page" class="jpane-toggler title">
					<a href="#"><span>'.JText::_($fieldSet->label).'</span></a>
				</h3>';
			
			$html .= '
				<div class="jpane-slider content">	
					<fieldset class="panelform">';
			if (isset($fieldSet->description) && trim($fieldSet->description)){
				$html .= '<div class="block-des">'.JText::_($fieldSet->description).'</div>';
			}
			$html .= '	<ul class="adminformlist">';
			
							foreach ($configform->getFieldset($name) as $field) {								
								$html .= '<li>';
									$html .= $field->label;
									$html .= $field->input;
								$html .= '</li>';
							}
						$html .= '</ul>
					</fieldset>
				</div>
			</div>';
		}
		
		preg_match_all("/<div class=\"panel\">([\s\S]*?)<\/div>/i", $bodyContent, $arr);
		
		$bodyContent = str_replace($arr[0][count($arr[0])-1].'</div>', $arr[0][count($arr[0])-1].'</div>'.$html, $bodyContent);
		
		return $bodyContent;				
	}
	
	
	function curl_getdata($URL, $req) {
		$proxy = JRequest::getVar('enable_proxy', 0);
		if($proxy){
			$proxy_address 	= JRequest::getVar('proxy_address', '');
			$proxy_port 	= JRequest::getVar('proxy_port', '');
			$proxystr 		= "$proxy_address:$proxy_port";
			$proxy_user 	= JRequest::getVar('proxy_user', '');
			$proxy_pass 	= JRequest::getVar('proxy_pass', '');
			$proxyUserPass 	= "$proxy_user:$proxy_pass";
			$proxyType 		= JRequest::getVar('proxy_type', 'CURLPROXY_HTTP');		
		}
		
		$ch = curl_init ();
		curl_setopt ( $ch, CURLOPT_SSL_VERIFYPEER, FALSE );
		curl_setopt ( $ch, CURLOPT_URL, $URL );
		curl_setopt ( $ch, CURLOPT_TIMEOUT, 10 );
		curl_setopt ( $ch, CURLOPT_POST, TRUE );
		curl_setopt ( $ch, CURLOPT_POSTFIELDS, $req );
		curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
		
		if($proxy){
			curl_setopt($ch, CURLOPT_PROXY, $proxystr);
			curl_setopt($ch, CURLOPT_PROXYTYPE, $proxyType);
			curl_setopt($ch, CURLOPT_PROXYUSERPWD, $proxyUserPass);
		}
		
		$result = curl_exec ( $ch );
		curl_close ( $ch );
		return $result;
	}
	
	function socket_getdata($host, $path, $req) {
		$header = "POST $path HTTP/1.0\r\n";
		$header .= "Host: " . $host . "\r\n";
		$header .= "Content-Type: application/x-www-form-urlencoded\r\n";
		$header .= "User-Agent:      Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1) Gecko/20061010 Firefox/2.0\r\n";
		$header .= "Content-Length: " . strlen ( $req ) . "\r\n\r\n";
		$header .= $req;
		set_time_limit(500);
		$fp = @fsockopen ( $host, 80, $errno, $errstr, 500 );
		if (! $fp)
			return;
		@fwrite ( $fp, $header );
		$data = '';
		$i = 0;
		do {
			$header .= @fread ( $fp, 1 );
		} while ( ! preg_match ( '/\\r\\n\\r\\n$/', $header ) );
		
		while ( ! @feof ( $fp ) ) {
			$data .= @fgets ( $fp, 128 );
		}
		fclose ( $fp );
		return $data;
	}
	
	function checkCondition(){
		return (JRequest::getCmd ( 'option', '' ) == 'com_templates' && JRequest::getCmd ( 'layout' ) == 'edit'  && JRequest::getCmd ( 'view' ) == 'style');
	}
	
	function checkCondition_for_Menu(){
		return false;	
	}
	
	function checkPermission(){
		$app = JFactory::getApplication();
		$user = JFactory::getUser ();
		return ($user->id > 0 && $app->isAdmin());
	}
	
	function loadStyle(){
		if (JRequest::getCmd ( 'option', '' ) == 'com_templates' && JRequest::getCmd ( 'layout' ) == 'edit'  && JRequest::getCmd ( 'view' ) == 'style') {																			
			$path = JURI::root() . 'plugins/system/jat3/jat3/core/';				
			JHTML::stylesheet ( $path. 'admin/assets/css/ja.tabs.css' );
			JHTML::stylesheet ( $path. 'admin/assets/css/jat3.css');
			JHTML::stylesheet ( $path. 'admin/assets/tooltips/style.css' );
			JHTML::stylesheet ( $path. 'element/assets/css/japaramhelper.css' );
		}
	}	
	
	function loadScipt(){
		if (JRequest::getCmd ( 'option', '' ) == 'com_templates' && JRequest::getCmd ( 'layout' ) == 'edit'  && JRequest::getCmd ( 'view' ) == 'style') {																			
			$path = JURI::root() . 'plugins/system/jat3/jat3/core/';				
			
			JHtml::_('behavior.mootools');
			JHTML::script ( $path. 'admin/assets/js/ja_tabs.js');
			JHTML::script ( $path. 'admin/assets/js/jat3.js' );
			//JHTML::script ( $path. 'admin/assets/js/swfobject.js');
			JHTML::script ( $path. 'admin/assets/js/ja.moo.extends.js' );
			JHTML::script ( $path. 'admin/assets/js/japageidsettings.js' );
			JHTML::script ( $path. 'admin/assets/js/ja.upload.js' );
			JHTML::script ( $path. 'element/assets/js/japaramhelper.js');
			//JHTML::script ( $path. 'admin/assets/js/firebug-lite-debug.js' );
			JHTML::_ ( 'behavior.modal' );
		
		}
	}
	
	function show_button_clearCache(){		
		?>
		<script type="text/javascript">
			window.addEvent('load', function(){
				if($('module-status')!=null){
					$('module-status').setStyle('background', 'none');
					var request = {'a':'hong'};
					var span = new Element('span', {'class':'ja-t3-clearcache', 'style':'background: url(<?php echo JURI::root()?>plugins/system/jat3/jat3/core/admin/assets/images/ja.png) no-repeat'}).injectTop($('module-status'));
					var bttclear = new Element('a', {
										'href':'javascript:void(0)',
										'events': {
											'click': function(){
												var linkurl = 'index.php?jat3action=clearCache&jat3type=plugin';
												new Request({url: linkurl, method:'post', 
													onSuccess: function(result){
															alert(result);
													}
												}).send();
											}
										} 
									}).inject(span);
					bttclear.set('text', 'JAT3 Clean Cache');
				}
			})
			
		</script>		
		<?php
	}
}

if(!function_exists('json_decode')){
	if(!class_exists('Services_JSON')){
		t3_import('core/libs/JSON');
	}
	
	function json_decode($str){
		//make a new json parser
		$json = new Services_JSON;
		return $json->decode($str);
	}
	
}

if(!function_exists('json_encode')){
	if(!class_exists('Services_JSON')){
		t3_import('core/libs/JSON');
	}
	
	function json_encode($var){
		//make a new json parser
		$json = new Services_JSON;
		return $json->encode($var);
	}
	
}

?>