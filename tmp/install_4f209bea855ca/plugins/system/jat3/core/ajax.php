<?php
/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');

jimport('joomla.filesystem.file');
class JAT3_Ajax{
	
	function installTheme(){
		
		jimport('joomla.filesystem.folder');
		jimport('joomla.filesystem.file');
		jimport('joomla.filesystem.archive');
		jimport('joomla.filesystem.path');	
		
		$template = JRequest::getCmd('template');		
		$path = JPATH_SITE.DS.'templates'.DS.$template;
		if(!$template || !JFolder::exists($path)){
			?>
			<script type="text/javascript">
				window.document.errorUpload('<span class="err" style="color:red"><?php echo JText::_('Template not define.')?></span>');
			 </script>
			<?php
		}
		
		global $mainframe;
		
		if (isset($_FILES['install_package']['name']) && $_FILES['install_package']['size']>0 && $_FILES['install_package']['tmp_name']!=''){
			
			require_once dirname(__FILE__).DS.'admin'.DS.'util.php';
			
			$result = $this->_UploadTheme($template, $path);	
					
			if(!is_array($result)){?>
					<script type="text/javascript">
						window.parent.errorUpload('<span class="err" style="color:red"><?php echo $result?></span>');						
					 </script>
			<?php
			}	
			else{
				$util = new JAT3_AdminUtil();
				$themes = $util->getThemes($template);
				?>				
					<script type="text/javascript">
						window.parent.stopUpload(<?php echo count($themes['local'])?>, '<?php echo $result['name']?>', '<?php echo @$result['version']?>', '<?php echo @$result['creationdate']?>', '<?php echo @$result['author']?>', '<?php echo $template?>');
					</script>
					
			<?php	
			}	
			exit;
			
		}
		else{
			?>				
				<script type="text/javascript">
					window.parent.errorUpload('<span class="err" style="color:red"><?php echo JText::_('Uploaded file does not exist.')?></span>');				
				</script>
					
			<?php	
			exit;
		}
	}
	
	function removeTheme(){
		$theme = JRequest::getCmd('theme', '');
		$template = JRequest::getCmd('template', '');
		if(!$theme || !$template){
			echo JText::_('Invalid info.');
			exit;
		}		
		$path = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'themes'.DS.$theme;
		if(!file_exists($path)){
			echo sprintf(JText::_('Theme %s not found.'), $path);
			exit;
		}
		
		jimport('joomla.filesystem.folder');
		if(!@ JFolder::delete($path)){
			echo sprintf(JText::_('Failed to delete theme %s', $theme));
			exit;
		}
		exit;
	}
	
	function _UploadTheme($template, $path){						

		$path_temp = dirname(JPATH_BASE).DS."tmp".DS.'jat3'.time().DS;
		if (!is_dir($path_temp)) {
			@ JFolder::create($path_temp);			
		}
		
		$directory = $_FILES['install_package']['name'];
		
		$tmp_dest = $path_temp .$directory;

		$userfile = $_FILES['install_package'];
		
		// Build the appropriate paths
		$tmp_src	= $userfile['tmp_name'];
		
		// 
		$uploaded = JFile::upload($tmp_src, $tmp_dest);
		
		if(!$uploaded) {
			return JText::_('Upload false');
		}
		
		// Unpack the downloaded package file
		$package = JAT3_AdminUtil::unpackzip($tmp_dest);
		if(!$package){
			return JText::_('Package error.');
		}

		//delete zip file
		JFile::delete($tmp_dest);
		
		$folder_uploaded = @ JFolder::folders($path_temp);
		$files_uploaded  = @ JFolder::files($path_temp);
		
		$theme_info_path = '';
		if($files_uploaded){
			foreach ($files_uploaded as $file){
				if($file=='info.xml'){
					$theme_info_path = $path_temp.$file;
					break;
				} 
			}
		}
		elseif(isset($folder_uploaded[0])){
			$files = @ JFolder::files($path_temp.DS.$folder_uploaded[0]);
			foreach ($files as $file){
				if($file=='info.xml'){
					$theme_info_path = $path_temp.$folder_uploaded[0].DS.$file;
					break;
				} 
			}
		}
		
		if (!JFile::exists($theme_info_path)){
			return  JText::_('File info.xml not found!');			
		}
		
		$data = JAT3_AdminUtil::getThemeinfo($theme_info_path, true);
		
		if(!isset($data['name']) || !$data['name']){
			return JText::_('Theme name is not defined!');
		}
		
		$data['name'] = str_replace(' ', '_', $data['name']);
		$path .= DS.'local'.DS.'themes'.DS.$data['name'];
		$path = JPath::clean($path);
		
		$arr_spec = array('@', '#', '~', '$', '&', '(', ')', '^', );
		foreach($arr_spec as $what) {
	        if(($pos = strpos($data['name'], $what))!==false){
	        	return JText::_('Theme name invalid!');
	        }
	    }
	    
		if(JFolder::exists($path)){
			return sprintf(JText::_('Theme "%s" already exists.'), $data['name']);
		}		
		
		if($files_uploaded){
			$filedest = $path_temp;
		}
		elseif(isset($folder_uploaded[0])){
			$filedest = $path_temp.DS.$folder_uploaded[0];
		}
		$result = @ JFolder::move($filedest, $path);
		
		if ((is_bool($result) && !$result) || (is_string($result) && $result!='') ) {
			return sprintf(JText::_('Failed to move folder "%s"'), $data['name']);
		}
		
		return $data;
	}

	function resetLayout(){
		t3_import('core/admin/util');
		
		// Initialize some variables
		
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		
		$template = JRequest::getCmd('template');
		$layout = JRequest::getCmd('layout');
		$errors = array();
		$result = array();
		if(!$template || !$layout){
			$result['error'] = JText::_('Operation Failed').': '.JText::_('No template or layout specified.');
			echo json_encode($result);
			exit;
		}
				
		$file = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'layouts'.DS.strtolower($layout).'.xml';
		$return = false;
		if(file_exists($file)){					
			$return = JFile::delete($file);
		}
		if(!$return){
			$errors[] = JText::_('Operation Failed').': '.JText::sprintf('Failed to delete file.', $file);
		}
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = sprintf(JText::_('RESET %s LAYOUT SUCCESSFULLY'), $layout); 	
			$result['layout'] = $layout;	
			$result['reset'] = true;	
		}		
		
		echo json_encode($result);
		exit;	
	}
	
	function renameLayout(){
		t3_import('core/admin/util');
		
		// Initialize some variables
		
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		
		$template = JRequest::getCmd('template');
		$current_layout = JRequest::getCmd('current_layout');		
		$new_layout = JRequest::getCmd('new_layout');
		$errors = array();
		$result = array();
		if(!$template || !$current_layout || !$new_layout){
			$result['error'] = JText::_('No template specified or Layout name contains space or special chracters.');
			echo json_encode($result);
			exit;
		}
				
		$src = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'layouts'.DS.strtolower($current_layout).'.xml';
		$dest = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'layouts'.DS.strtolower($new_layout).'.xml';		
		if (!@ rename($src, $dest)) {
			$errors[] =  JText::_('Rename failed');
		}
						
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = sprintf(JText::_('RENAME %s LAYOUT SUCCESSFULLY'), $current_layout); 	
			$result['layout'] = $new_layout;
			$result['layoutolder'] = $current_layout;
			$result['type'] = 'rename';
		}		
		
		echo json_encode($result);
		exit;	
	}
	
	function deleteLayout(){
		t3_import('core/admin/util');
		
		// Initialize some variables
		
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		
		$template = JRequest::getCmd('template');
		$layout = JRequest::getCmd('layout');
		$errors = array();
		$result = array();
		if(!$template || !$layout){
			$result['error'] = JText::_('Operation Failed').': '.JText::_('No template or layout specified.');
			echo json_encode($result);
			exit;
		}
				
		$src = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'layouts'.DS.strtolower($layout).'.xml';
		if(file_exists($src)){
			if(!JFile::delete($src)){
				$errors[] = JText::_('Operation Failed').': '.JText::sprintf('Failed to delete file.', $src);
			}
		}
		
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = sprintf(JText::_('DELETE %s LAYOUT SUCCESSFULLY'), $layout); 	
			$result['layout'] = $layout;	
			$result['type'] = 'delete';	
		}		
		
		echo json_encode($result);
		exit;	
	}
	
	function saveLayout(){
		global $mainframe;
		t3_import('core/admin/util');
		
		// Initialize some variables
		
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		//$json = JRequest::getVar('json');
		$json = JRequest::getString('json', '', 'default', 2);
		$data = json_decode($json);
		$data = $data && isset($data->xml) ? $data->xml : "";
		$data = str_replace (array("\\n","\\t"), array("\n", "\t"), $data).' ';
		$data = str_replace ('\\', '', $data);
				
		$template = JRequest::getCmd('template');
		$layout = JRequest::getCmd('layout');
		$errors = array();
		$result = array();
		if(!$template || !$layout){
			$result['error'] = JText::_('No template specified or Layout name contains space or special chracters.');
			echo json_encode($result);
			exit;
		}
		
		// Set FTP credentials, if given
		jimport('joomla.client.helper');		
		
		JClientHelper::setCredentialsFromRequest('ftp');
		$ftp = JClientHelper::getCredentials('ftp');
		
		$file = T3Path::path(T3_TEMPLATE_LOCAL).DS.'etc'.DS.'layouts'.DS.strtolower($layout).'.xml';
		$file_core = T3Path::path(T3_TEMPLATE_CORE).DS.'etc'.DS.'layouts'.DS.strtolower($layout).'.xml';
		//get layouts from core
		$file_base = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.strtolower($layout).'.xml';
		
		if(file_exists($file) || file_exists($file_core) || file_exists($file_base)){
			$result['type'] = 'edit';
		}
		else{
			$result['type'] = 'new';
		}
		
		if(JFile::exists($file)){
			
			@chmod($file, 0777);
		}
		$return = JFile::write($file, $data);
		
		// Try to make the params file unwriteable
		if (!$ftp['enabled'] && JPath::isOwner($file) && !JPath::setPermissions($file, '0644')) {
			$errors[] = sprintf(JText::_('Could not make the %s file unwritable'), $file);
		}
		if(!$return){
			$errors[] = JText::_('Operation Failed').': '.JText::sprintf('Failed to open file for writing.', $file);
		}
		
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			if($result['type'] == 'new'){
				$result['successful'] = sprintf(JText::_('Layout %s was successfully created!'), $layout);
			}
			else{
				$result['successful'] = sprintf(JText::_('SAVE %s LAYOUT SUCCESSFULLY'), $layout);
			} 	
			$result['layout'] = $layout;	
		}		
		
		echo json_encode($result);
		exit;			
	}
	
	function updateGfont() {
		// Check template exists
		$template = JRequest::getCmd('template');
		if (!$template) {
			$result['error'] = JText::_('No template specified');
			echo json_encode($result);
			exit;			
		}
		// Set & check path gfonts.xml 
		$path = JPATH_SITE.DS.T3_TEMPLATE_LOCAL.DS.'etc'.DS.'gfonts.xml';
		$path = str_replace(DS, "/", $path);
		
		t3_import('core/libs/html_parser');
		// Get content from google font website
		$url = 'http://www.google.com/webfonts';
		$content = @file_get_contents($url);
		if ($content === false) {
			$result['error'] = JText::_("Can not get font from google font website");
		}
		// Get font list
		$html = new simple_html_dom;
		$html->load($content, true);
		$subsets = $html->find('.nav li a');
		// Write to file gfonts.xml
		$data = '';  
		$tab = "\t";
		foreach($subsets as $subset) {
			// Build url
			$font_url = $url . '?sort=alpha&subset=' . trim($subset->text());
			// Crawl font
			$content = @file_get_contents($font_url);
			if ($content !== false) {
				unset($html);
				$html = new simple_html_dom;
				$html->load($content, true);
				$elements = $html->find('.preview');
				if (count($elements) > 0) {
					// Parse xml file
					$data .= $tab."<group name=\"{$subset->text()}\">\n";
					foreach($elements as $element) {
						$name = preg_replace('#\(.*\)#','', $element->text());
						$data .= $tab.$tab."<font>" . trim($name) . "</font>\n";
					}
					$data .= $tab."</group>\n";
				}
			}
		}
		// Check & write data
		if (!empty($data)) {
			$data = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root>\n" . $data . "</root>";
			$length = file_put_contents($path, $data);
			if ($length === false) {
				$result['error'] = JText::_("Can not write gfonts.xml into local folder");
				echo json_encode($result);
				exit;
			}
		}
		// Successful message
		$result['successful'] = JText::_("Update gfont complete. Click OK to reload page.");
	
		echo json_encode($result);
		exit;
	}
	
	function renameProfile(){
		t3_import('core/admin/util');
		
		// Initialize some variables
		
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		
		$template = JRequest::getCmd('template');
		$current_profile = JRequest::getCmd('current_profile');		
		$new_profile = JRequest::getCmd('new_profile');
		$errors = array();
		$result = array();
		if(!$template || !$current_profile || !$new_profile){
			$result['error'] = JText::_('No template specified or Profile name contains space or special chracters.');
			echo json_encode($result);
			exit;
		}
				
		$src = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'profiles'.DS.strtolower($current_profile).'.ini';
		$dest = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'profiles'.DS.strtolower($new_profile).'.ini';
		if(file_exists($src)){		
			if (!@ rename($src, $dest)) {
				$errors[] =  JText::_('Rename failed');
			}
		}
						
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = sprintf(JText::_('RENAME %s PROFILE SUCCESSFULLY'), $current_profile); 	
			$result['profile'] = $new_profile;
			$result['profileolder'] = $current_profile;
			$result['type'] = 'rename';
		}		
		
		echo json_encode($result);
		exit;	
	}
	
	function deleteProfile(){
		t3_import('core/admin/util');
		
		// Initialize some variables
		
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		
		$template = JRequest::getCmd('template');
		$profile = JRequest::getCmd('profile');
		$errors = array();
		$result = array();
		if(!$template || !$profile){
			$result['error'] = JText::_('Operation Failed').': '.JText::_('No template or profile specified.');
			echo json_encode($result);
			exit;
		}
				
		$src = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'profiles'.DS.strtolower($profile).'.ini';
		if(file_exists($src)){
			if(!JFile::delete($src)){
				$errors[] = JText::_('Operation Failed').': '.JText::sprintf('Failed to delete file.', $src);
			}
		}
		
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = sprintf(JText::_('DELETE %s PROFILE SUCCESSFULLY'), $profile); 	
			$result['profile'] = $profile;	
			$result['type'] = 'delete';	
		}		
		
		echo json_encode($result);
		exit;	
	}

	function resetProfile(){
		t3_import('core/admin/util');
		
		// Initialize some variables
		
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		
		$template = JRequest::getCmd('template');
		$profile = JRequest::getCmd('profile');
		$errors = array();
		$result = array();
		if(!$template || !$profile){
			$result['error'] = JText::_('Operation Failed').': '.JText::_('No template or profile specified.');
			echo json_encode($result);
			exit;
		}
				
		$file = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'profiles'.DS.$profile.'.ini';
		$return = false;
		if(file_exists($file)){
			$return = JFile::delete($file);
		}
		if(!$return){
			$errors[] = JText::_('Operation Failed').': '.JText::sprintf('Failed to delete file.', $file);
		}
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = sprintf(JText::_('RESET %s PROFILE SUCCESSFULLY'), $profile); 	
			$result['profile'] = $profile;	
			$result['reset'] = true;
			$result['type'] = 'reset';		
		}		
		
		echo json_encode($result);
		exit;	
	}
	
	
	function saveProfile($profile='', $post=null){
		global $mainframe;
		t3_import('core/admin/util');
		
		// Initialize some variables
		$db			 = & JFactory::getDBO();
				
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
		if (!$post) {		
			$json = JRequest::getVar('json');
			$json = str_replace (array("\\n","\\t"), array("\n", "\t"), $json);
			$json = str_replace ('\\', '', $json);
			$post = json_decode($json);
		}
		$template = JRequest::getCmd('template');
		if (!$profile) $profile = JRequest::getCmd('profile');
		
		$result = array();
		if(!$template || !$profile){
			$result['error'] = JText::_('No template specified or Profile name contains space or special chracters.');
			echo json_encode($result);
			exit;
		}
		// Set FTP credentials, if given
		jimport('joomla.client.helper');
		JClientHelper::setCredentialsFromRequest('ftp');
		$ftp = JClientHelper::getCredentials('ftp');
		
		$errors = array();
		
		$file = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'profiles'.DS.$profile.'.ini';
			
		$params = new JParameter('');
		if(isset($post)){
			foreach ($post as $k=>$v){
				$params->set($k, $v);
			}
		}
		$data = $params->toString();
		if(JFile::exists($file)){
			@chmod($file, 0777);
		}
		$return = JFile::write($file, $data);
							
		// Try to make the params file unwriteable
		if (!$ftp['enabled'] && JPath::isOwner($file) && !JPath::setPermissions($file, '0644')) {
			$errors[] = sprintf(JText::_('Could not make the %s file unwritable'), $file);
		}
		if(!$return){
			$errors[] = JText::_('Operation Failed').': '.JText::sprintf('Failed to open file for writing.', $file);
		}
		
					
		
		if (JRequest::getCmd('jat3action') != 'saveProfile') return $errors;
		
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = sprintf(JText::_('SAVE %s PROFILE SUCCESSFULLY'), $profile);
			$result['profile'] = $profile;
			$result['type'] = 'new';
		}
		
		echo json_encode($result);
		exit;
	}

	function saveGeneral($post=null){
		global $mainframe;
		t3_import('core/admin/util');
		
		// Initialize some variables
		$db			 = & JFactory::getDBO();
				
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		
		if (!$post) {
			$json = JRequest::getVar('json');
			$json = str_replace (array("\\n","\\t"), array("\n", "\t"), $json);
			$json = str_replace ('\\', '', $json);
			$post = json_decode($json);
		}
		
		$template = JRequest::getCmd('template');
		
		$result = array();
		if(!$template){
			$result['error'] = JText::_('Operation Failed').': '.JText::_('No template specified.');
			echo json_encode($result);
			exit;
		}
		// Set FTP credentials, if given
		jimport('joomla.client.helper');
		JClientHelper::setCredentialsFromRequest('ftp');
		$ftp = JClientHelper::getCredentials('ftp');
		
		$errors = array();
		
		if($post){
			
			if(isset($post)){
				$file = $client->path.DS.'templates'.DS.$template.DS.'params.ini';
				
				$params = new JParameter('');
				foreach ($post as $k=>$v){
					$v = str_replace (array("\\n","\\t"), array("\n", "\t"), $v);
					$v = str_replace ('\\', '', $v);
					$params->set($k, $v);
				}
				$data = $params->toString();
				
				if(JFile::exists($file)){
					@chmod($file, 0777);
				}
				$return = JFile::write($file, $data);
									
				// Try to make the params file unwriteable
				if (!$ftp['enabled'] && JPath::isOwner($file) && !JPath::setPermissions($file, '0644')) {
					$errors[] = sprintf(JText::_('Could not make the %s file unwritable'), $file);
				}
				if(!$return){
					$errors[] = JText::_('Operation Failed').': '.JText::sprintf('Failed to open file for writing.', $file);
				}
			}
		}
		
		if (JRequest::getCmd('jat3action') != 'saveGeneral') return $errors;
		
		if($errors){
			$result['error'] = implode('<br/>', $errors);
		}
		else{
			$result['successful'] = JText::_('SAVE DATA SUCCESSFULLY'); 			
		}
		
		echo json_encode($result);
		exit;
	}
	
	function saveData(){
		global $mainframe;
		t3_import('core/admin/util');
		
		// Initialize some variables
		$db			 = & JFactory::getDBO();
				
		$client		=& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));		
		$template = JRequest::getCmd('template');
		$menus		= JRequest::getVar('selections');
		if($menus){
			$menus = explode(',', $menus);
		}		
		$default	= JRequest::getBool('default');
		
		$result = array();
		if(!$template){
			$result['error'] = JText::_('Operation Failed').': '.JText::_('No template specified.');
			echo json_encode($result);
			exit;
		}
		
		// Reset all existing assignments
		$query = 'DELETE FROM #__templates_menu' .
				' WHERE client_id = 0' .
				' AND template = '.$db->Quote( $template );
		$db->setQuery($query);
		$db->query();

		if ($default) {
			$menus = array( 0 );
		}
		
		if (is_array($menus)) {
			foreach ($menus as $menuid)
			{
				// If 'None' is not in array
				if ((int) $menuid >= 0)
				{
					// check if there is already a template assigned to this menu item
					$query = 'DELETE FROM #__templates_menu' .
							' WHERE client_id = 0' .
							' AND menuid = '.(int) $menuid;
					$db->setQuery($query);
					$db->query();
	
					$query = 'INSERT INTO #__templates_menu' .
							' SET client_id = 0, template = '. $db->Quote( $template ) .', menuid = '.(int) $menuid;
					$db->setQuery($query);
					$db->query();
				}
			}
		}
		//Check and save general, profiles information
		$json = JRequest::getVar('json');
		$json = str_replace('amp;amp;amp;amp;', '&', $json);
		$json = json_decode($json);
		//$result['json'] = print_r ($json, true);
		$error_msg = '';
		$success_msg =  JText::_('SAVE DATA SUCCESSFULLY');
		if (isset ($json->generalconfigdata) && $json->generalconfigdata) {
			$error = $this->saveGeneral ($json->generalconfigdata);
			if (count($error)) {
				$success_msg = '';
				$error_msg .= JText::_('Save general error')."<br /><p class=\"msg\">".explode('<br />', $error)."</p>";
				$result['generalconfigdata'] = 0; 
			} else {
				$success_msg .= "<p class=\"msg\">".JText::_('Save general successfully')."</p>"; 
				$result['generalconfigdata'] = 1; 
			}
		}
		
		if (isset ($json->profiles) && $json->profiles) {
			$result['profiles'] = array();
			foreach ($json->profiles as $p=>$profile) {
				$error = $this->saveProfile ($p, $profile);
				if (count($error)) {
					$success_msg = '';
					$error_msg .= sprintf(JText::_('Save profile %s error'), $p)."<br /><p class=\"msg\">".implode('<br />', $error)."</p>";
					$result['profiles'][$p] = 0; 
				} else {
					$success_msg .= "<p class=\"msg\">".sprintf(JText::_('Save profile %s successfully'), $p)."</p>"; 
					$result['profiles'][$p] = 1; 
				}
			}
		}
		
		$result['successful'] = $success_msg;
		$result['error'] = $error_msg;
		echo json_encode($result);
		exit;	
	}

	function updateAdditionalInfo(){				
		
		$template = JRequest::getCmd('template');
		if(!$template) exit;

		$host = 'www.joomlart.com';
		$path = "/jatc/getinfo.php";
		$req = 'template=' . $template;		
		
		$URL = "$host$path";
		
		require_once dirname(__FILE__).DS.'admin'.DS.'util.php';
		if (! function_exists ( 'curl_version' )) {
			if (! ini_get ( 'allow_url_fopen' )) {
				echo  JText::_ ( 'Sorry, but your server does not currently support open method. Please contact the network administrator system for help.' );
				exit;
			} else {
				$result = JAT3_AdminUtil::socket_getdata ( $host, $path, $req );
			}
		} else {
			$result = JAT3_AdminUtil::curl_getdata ( $URL, $req );
		}
		
		echo $result;exit;
	}

	function clearCache(){
		//clean cache
		t3_import('core/cache');
		T3Cache::clean(10);	//clear all cache
		
		echo JText::_('T3 Cache is cleaned!');
		exit;	
	}
}
?>