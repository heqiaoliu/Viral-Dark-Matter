<?php
/**
* @version 1.6
* @package JDownloads
* @copyright (C) 2010 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*
*/
defined( '_JEXEC' ) or die( 'Restricted access' );
Error_Reporting(E_ERROR);
ignore_user_abort( true ); 
  
function com_install() {

    $params   = JComponentHelper::getParams('com_languages');
    $frontend_lang = $params->get('site', 'en-GB');
    $language = JLanguage::getInstance($frontend_lang);

    // get language file for default layouts
    $language = &JFactory::getLanguage();
    $language->load('com_jdownloads'); 
    $database = &JFactory::getDBO();
    
    // insert the new default header, subheader and footer layouts in every layout.
    require_once(JPATH_SITE."/administrator/components/com_jdownloads/helpers/jd_layouts.php");

      //*********************************************
      // JD VERSION:
         $jd_version = '1.9.0';
         $jd_version_state = 'Stable';
         $jd_version_svn = '909'; 
      //*********************************************

      jimport('joomla.filesystem.folder');
      jimport('joomla.filesystem.file');

      define('JD_BACKEND_PATH' ,  JPATH_ROOT.DS.'administrator'.DS.'components'.DS.'com_jdownloads');
      define('JD_FRONTEND_PATH',  JPATH_ROOT.DS.'components'.DS.'com_jdownloads');
      define('JD_PLUGIN_PATH',  JPATH_ROOT.DS.'plugins'.DS.'system'.DS.'jdownloads');
      
      /*  Install / update system plugin  */
        
        JFolder::copy(JD_BACKEND_PATH.DS.'assets'.DS.'plugins'.DS.'system'.DS.'jdownloads', JD_PLUGIN_PATH, '', true);
        
        if (is_dir(JD_BACKEND_PATH.DS.'assets'.DS.'plugins')){
             JFolder::delete(JD_BACKEND_PATH.DS.'assets'.DS.'plugins');
        }
        //JFolder::delete(JD_BACKEND_PATH.DS.'assets'.DS.'plugins'.DS.'system'.DS.'language');
        //JFolder::delete(JD_BACKEND_PATH.DS.'assets'.DS.'plugins'.DS.'system');
        //JFolder::delete(JD_BACKEND_PATH.DS.'assets'.DS.'plugins');

        $query = "SELECT enabled FROM #__extensions WHERE type = 'plugin' AND name = 'plg_system_jdownloads'";
        $database->setQuery($query);
        $result = $database->loadObject();
        
        if($result == null){
            $query = 
            "INSERT INTO `#__extensions` ( `name`, `type`, `element`, `folder`, `access`, `ordering`, `enabled`, `client_id`, `checked_out`, `checked_out_time`, `params`)"
            ."\nVALUES"
            ."\n('plg_system_jdownloads', 'plugin', 'jdownloads', 'system', 1, 0, 1, 0, 0, '0000-00-00 00:00:00', '')";
            $database->setQuery($query);
            $database->query();
        } else {
            $query = 'UPDATE `#__extensions` SET `enabled` = 1 WHERE `name`="plg_system_jdownloads"';
            $database->setQuery($query);
            $database->query();
        }

      $imagepath = JURI::root().'administrator/components/com_jdownloads/images/jdownloads.jpg';
      /*  Done installing plugin   */

       
       
      ?>
      <center>
      <table width="100%" border="0">
       <tr>
          <td align="center">
            <img src="<?php echo $imagepath;?>" border="0" alt="jDownloads" /><br /><?php echo  'Version '.$jd_version.' '.$jd_version_state; ?>
          </td>
       </tr>   
       <tr>   
          <td background="E0E0E0" style="border:1px solid #999;">
            <code><b><?php echo JText::_('COM_JDOWNLOADS_INSTALL_0'); ?></b><br />
       
       <?php
        
       // exist the tables?
       $prefix = $database->getPrefix(); 
       $tablelist = $database->getTableList();
       if ( !in_array ( $prefix.'jdownloads_config', $tablelist ) ){
             echo '<p><font color="red"><big><b>'.JText::_('COM_JDOWNLOADS_INSTALL_ERROR_NO_TABLES').'</b></big></font></p>';
       } else {
       
       //********************************************************************************************
       // install component
       // *******************************************************************************************        
          
       // when a version is found, it is a update
       // ***************************************
       $is_update = false;
       $root_dir = ''; 
       $database->setQuery("SELECT setting_value FROM #__jdownloads_config WHERE setting_name = 'jd.version'");
       $version = floatval($database->loadResult());
       if ($version){
           $is_update = true;
           $database->setQuery("SELECT setting_value FROM #__jdownloads_config WHERE setting_name = 'files.uploaddir'");
           $dir = $database->loadResult();
           $root_dir = JPATH_SITE.DS.$dir.DS;
       }   
           
       //********************************************************************************************
       // install component
       // ******************************************************************************************* 
     
        // move all images dirs to joomla images dir when not exists
        $source_dir   = array();
        $message = '';
        $ok = 0;
        $create_root_ok = true;
        
        $image_root   = JPATH_SITE.'/images/jdownloads/';
        $source_root  = JPATH_SITE.'/components/com_jdownloads/assets/images/';
        $source_dir[] = 'catimages/';
        $source_dir[] = 'fileimages/';
        $source_dir[] = 'miniimages/';
        $source_dir[] = 'hotimages/';
        $source_dir[] = 'newimages/';
        $source_dir[] = 'updimages/';
        $source_dir[] = 'downloadimages/';
        $source_dir[] = 'headerimages/';    
        $source_dir[] = 'screenshots/'; 
        
        if (!is_dir($image_root)){
           if (!JFolder::create($image_root, 0755)){
               // wwwrun problems?
               echo '<font color="red">--> '.JText::_('COM_JDOWNLOADS_INSTALL_MOVE_IMAGES_CREATE_ROOT_DIR_ERROR').'</font><br />'; 
               $create_root_ok = false;     
           }    
        }       
        if ($create_root_ok){
            $error = false;
            foreach($source_dir as $source){
                $sourcedir = $source_root.$source;
                if (@is_dir($sourcedir)){ 
                    $destdir = $image_root.$source;
                    if (!is_dir($destdir)){
                        $res = moveDirs($sourcedir, $destdir, true, $message);
                        if ($message != '') {
                            // Fehler
                            echo '<font color="red">--> '.JText::_('COM_JDOWNLOADS_INSTALL_MOVE_IMAGES_ERROR').' '.$message.'</font><br />';
                            $error = true;
                            $message = '';
                        } else {
                            // ok
                            $ok ++;
                        }
                    }    
                }     
            }
       }
       if ($ok > 0){
           echo '<font color="green">--> '.$ok.' '.JText::_('COM_JDOWNLOADS_INSTALL_MOVE_IMAGES_OK').'</font><br />';     
       } else {
           if (!$error) {
               echo '<font color="green">--> '.JText::_('COM_JDOWNLOADS_INSTALL_MOVE_IMAGES_DEST_DIR_EXIST').'</font><br />';     
           } 
       }
       
       if ($create_root_ok){
            // delete pics folders when exists in /images
            foreach($source_dir as $source){ 
                if (is_dir($source_root.$source)){
                    delete_dir_and_allfiles($source_root.$source);   
                }    
            }    
       }   
        

      $sum_configs = 0;
      $query = array();

      // add data only when is not a update
      // insert default config data
      if (!$is_update){
          $query[]  = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('files.uploaddir', 'jdownloads');"."\n";  
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('global.datetime', '".JText::_('COM_JDOWNLOADS_INSTALL_DEFAULT_DATE_FORMAT')."');"."\n";  
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('files.autodetect', '1');"."\n";  
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto', '".JText::_('COM_JDOWNLOADS_SETTINGS_INSTALL_5')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.option', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.betreff', '".JText::_('COM_JDOWNLOADS_SETTINGS_INSTALL_3')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.from', '".JText::_('COM_JDOWNLOADS_SETTINGS_INSTALL_4')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.fromname', 'JDownloads');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.html', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('zipfile.prefix', 'downloads_');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('files.order', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('checkbox.top.text', '".JText::_('COM_JDOWNLOADS_SETTINGS_INSTALL_1')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('downloads.titletext', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('layouts.editor', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('licenses.editor', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('files.editor', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('categories.editor', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('info.icons.size', '20');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('cat.pic.size', '48');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('file.pic.size', '32');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('offline', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('offline.text', '".JText::_('COM_JDOWNLOADS_BACKEND_OFFLINE_MESSAGE_DEFAULT')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('system.list', '".JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_SYSTEM_DEFAULT_LIST')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('language.list', '".JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_LANGUAGE_DEFAULT_LIST')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('file.types.view', 'html,htm,txt,pdf,doc,jpg,jpeg,png,gif');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('directories.autodetect', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('mail.cloaking', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('tempfile.delete.time', '20');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('frontend.upload.active', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('allowed.upload.file.types', 'zip,rar');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('allowed.upload.file.size', '2048');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('upload.access', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('files.per.side', '10');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('upload.form.text','".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_FRONTEND_UPLOADS_FORM_TEXT_LAYOUT')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('jd.header.title', 'Downloads');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('files.per.side.be', '15');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('last.log.message', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('last.restore.log', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('show.header.catlist', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('anti.leech', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('direct.download', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('days.is.file.new', '15');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('picname.is.file.new', 'blue.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('loads.is.file.hot', '100');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('picname.is.file.hot', 'red.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('download.pic.details', 'download_blue.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('upload.auto.publish', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('cats.order', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('autopublish.founded.files', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('all.files.autodetect', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('file.types.autodetect', 'zip,rar,exe,pdf,doc,gif,jpg,png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('jcomments.active', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.defaultlayout','".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NAME')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.show_hot', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.show_new', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.enable_plugin', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.show_jdfiledisabled', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.layout_disabled','".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NAME')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.show_downloadtitle', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.offline_title','".JText::_('COM_JDOWNLOADS_FRONTEND_SETTINGS_FILEPLUGIN_OFFLINE_FILETITLE')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fileplugin.offline_descr','".JText::_('COM_JDOWNLOADS_FRONTEND_SETTINGS_FILEPLUGIN_DESCRIPTION')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('cat.pic.default.filename','folder.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('file.pic.default.filename','zip.png');"."\n";
          
          foreach ($query as $data){
                $database->SetQuery($data);
                $database->query();
          }      
          unset($query);
          
          $query[]  = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('jd.version','$jd_version');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('jd.version.state','$jd_version_state');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('jd.version.svn','$jd_version_svn');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.upload', '".JText::_('COM_JDOWNLOADS_SETTINGS_INSTALL_5' )."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.option.upload', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.betreff.upload', '".JText::_('COM_JDOWNLOADS_SETTINGS_INSTALL_6' )."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.from.upload', '".JText::_('COM_JDOWNLOADS_SETTINGS_INSTALL_4' )."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.fromname.upload', 'jDownloads');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.html.upload', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.template.upload', '".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_GLOBAL_MAIL_UPLOAD_TEMPLATE' )."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.template.download', '".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_MAIL_DEFAULT' )."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('download.pic.mirror_1', 'mirror_blue1.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('download.pic.mirror_2', 'mirror_blue2.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('picname.is.file.updated', 'green.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('days.is.file.updated', '15');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('thumbnail.size.width', '100');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('thumbnail.size.height', '100');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('thumbnail.view.placeholder', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('thumbnail.view.placeholder.in.lists', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('option.navigate.bottom', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('option.navigate.top', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.category.info', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('save.monitoring.log', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.subheader', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.detailsite', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('check.leeching', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('allowed.leeching.sites', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('block.referer.is.empty', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.author', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.author.url', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.release', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.price', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.license', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.language', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.system', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.pic.upload', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.desc.long', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('mp3.player.config', 'loop=0;showvolume=1;showstop=1;bgcolor1=006699;bgcolor2=66CCFF');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('mp3.view.id3.info', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.php.script.for.download', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('mp3.info.layout', '".$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_ID3TAG."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('google.adsense.active', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('google.adsense.code', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('countdown.active', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('countdown.start.value', '15');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('countdown.text', '".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_WAITING_NOTE_TEXT')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.extern.file', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.select.file', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fe.upload.view.desc.short', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fix.upload.filename.blanks', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fix.upload.filename.uppercase', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('fix.upload.filename.specials', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.report.download.link', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('send.mailto.report', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('download.pic.files', 'download2.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.sum.jcomments', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('be.new.files.order.first', '1');"."\n";
          
          foreach ($query as $data){
                $database->SetQuery($data);
                $database->query();
          }      
          unset($query);

          $query[]  = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('downloads.footer.text', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.back.button', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('create.auto.cat.dir', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('reset.counters', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('report.link.only.regged', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.ratings', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('rating.only.for.regged', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.also.download.link.text', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('auto.file.short.description', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('auto.file.short.description.value', '200');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.jom.comment', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.lightbox.function', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.alphauserpoints', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.alphauserpoints.with.price.field', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('user.can.download.file.when.zero.points', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('user.message.when.zero.points', '".JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_FE_MESSAGE_NO_DOWNLOAD')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('limited.download.number.per.day', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('limited.download.reached.message', '".JText::_('COM_JDOWNLOADS_FE_MESSAGE_AMOUNT_FILES_LIMIT')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('download.pic.plugin', 'download2.png');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('plugin.auto.file.short.description', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('plugin.auto.file.short.description.value', '200');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('view.sort.order', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('activate.general.plugin.support', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('activate.download.log', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('categories.per.side', '5');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('upload.access.group', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('redirect.after.download', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.tabs.type', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('additional.tab.title.1', '".JText::_('COM_JDOWNLOADS_FE_TAB_CUSTOM_TITLE')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('additional.tab.title.2', '".JText::_('COM_JDOWNLOADS_FE_TAB_CUSTOM_TITLE')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('additional.tab.title.3', '".JText::_('COM_JDOWNLOADS_FE_TAB_CUSTOM_TITLE')."');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('remove.field.title.when.empty', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.download.title.as.download.link', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.1.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.2.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.3.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.4.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.5.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.6.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.7.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.8.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.9.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.10.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.11.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.12.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.13.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.14.title', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.1.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.2.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.3.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.4.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.5.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.6.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.7.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.8.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.9.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('custom.field.10.values', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('group.can.edit.fe', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('uploader.can.edit.fe', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.sef.with.file.titles', '1');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.general.plugin.support.only.for.descriptions', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('com', '');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('use.blocking.list', '0');"."\n";
          $blocking_list = file_get_contents ( JPATH_SITE.'/administrator/components/com_jdownloads/assets/blacklist.txt' );
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('blocking.list', '$blocking_list');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('remove.empty.tags', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('create.pdf.thumbs', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('create.pdf.thumbs.by.scan', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('pdf.thumb.height', '200');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('pdf.thumb.width', '200');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('pdf.thumb.pic.height', '400');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('pdf.thumb.pic.width', '400');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('pdf.thumb.image.type', 'GIF');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('create.auto.thumbs.from.pics', '0');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('create.auto.thumbs.from.pics.image.height', '400');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('create.auto.thumbs.from.pics.image.width', '400');"."\n";
          $query[] = "INSERT INTO ".$database->nameQuote('#__jdownloads_config')." (setting_name, setting_value) VALUES ('create.auto.thumbs.from.pics.by.scan', '0');"."\n";
          
          $sum_configs = 196;
          foreach ($query as $data){
                $database->SetQuery($data);
                $database->query();
          }      
          unset($query);           
      
          echo "<font color='green'>--> ".$sum_configs." ".JText::_('COM_JDOWNLOADS_INSTALL_2')."</font><br />";
      
          // Change tables when necessesary      
          $sum_added_fields = 0;
          /* $prefix = $database->getPrefix();
          $tables = array( $prefix.'jdownloads_templates' );
          $result = $database->getTableFields($tables);
          if (!$result[$prefix.'jdownloads_templates']['template_header_text']){
             $database->SetQuery("ALTER TABLE #__jdownloads_templates ADD template_header_text LONGTEXT NOT NULL AFTER template_typ");
             if ($database->query()) {
                 $sum_added_fields++;
             }    
          } */
               
          echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_1_2')."</font><br />";

          // write default layouts in database      
          $sum_layouts = 9;

          // categories
          $cat_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_CATS_DEFAULT);
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_CATS_DEFAULT_NAME')."', 1, '".$cat_layout."', 1, 1)");
          $database->query();

          // files
          $file_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT);
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NAME')."', 2, '".$file_layout."', 0, 1)");
          $database->query();
           
          // summary
          $summary_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_SUMMARY_DEFAULT);
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NAME')."', 3, '".$summary_layout."', 0, 1)");
          $database->query();

          // download details 
          $detail_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_DETAILS_DEFAULT);
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_DETAILS_DEFAULT_NAME')."', 5, '$detail_layout', 1, 1)");
          $database->query();
          
          // layout for download details with tabs
          $detail_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_DETAILS_DEFAULT_WITH_TABS);
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_DETAILS_WITH_TABS_TITLE')."', 5, '$detail_layout', '0', 1)");
          $database->query();
                
          // Simple layout with Checkboxes for files
          $file_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_1); 
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked, note, checkbox_off, symbol_off)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_1_NAME')." 1.4', 2, '".$file_layout."', 0, 1, '', 0, 1)");
          $database->query();
                
          // Simple layout without Checkboxes for files
          $file_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_2); 
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked, note, checkbox_off, symbol_off)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_2_NAME')." 1.4', 2, '".$file_layout."', 1, 1, '', 1, 1)");
          $database->query();
          
          // New simple files list layout (build 906)
          $file_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_3); 
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked, note, checkbox_off, symbol_off)  VALUES ('".$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_3_NAME."', 2, '".$file_layout."', 0, 1, '', 1, 1)");
          $database->query();
                
          // new  categories layout with 4 columns
          $file_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_CATS_COL_DEFAULT); 
          $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked, note, cols)  VALUES ('".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_CATS_COL_TITLE')."', 1, '".$file_layout."', 0, 1, '".JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_CATS_COL_NOTE')."', 4)");
          $database->query();
        
          // cat layouts
          $database->setQuery("UPDATE #__jdownloads_templates SET template_header_text = '$cats_header', template_subheader_text = '$cats_subheader', template_footer_text = '$cats_footer' WHERE template_typ = '1' AND template_header_text = ''");
          $database->query();
          // file layouts
          $database->setQuery("UPDATE #__jdownloads_templates SET template_header_text = '$files_header', template_subheader_text = '$files_subheader', template_footer_text = '$files_footer' WHERE template_typ = '2' AND template_header_text = ''");
          $database->query();
          //details layouts
          $database->setQuery("UPDATE #__jdownloads_templates SET template_header_text = '$details_header', template_subheader_text = '$details_subheader', template_footer_text = '$details_footer' WHERE template_typ = '5' AND template_header_text = ''");
          $database->query();
          // summary layouts
          $database->setQuery("UPDATE #__jdownloads_templates SET template_header_text = '$summary_header', template_subheader_text = '$summary_subheader', template_footer_text = '$summary_footer' WHERE template_typ = '3' AND template_header_text = ''");
          $database->query();
        
          echo "<font color='green'>--> ".$sum_layouts." ".JText::_('COM_JDOWNLOADS_INSTALL_4')."</font><br />";
      
          // Write default licenses in database      
  
          $lic_total = (int)JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE_TOTAL');
          $sum_licenses = 7;

          $database->setQuery("INSERT INTO #__jdownloads_license (license_title, license_text, license_url)  VALUES ('".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE1_TITLE')."', '".''."', '".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE1_URL')."')");
          $database->query();

          $database->setQuery("INSERT INTO #__jdownloads_license (license_title, license_text, license_url)  VALUES ('".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE2_TITLE')."', '".''."', '".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE2_URL')."')");
          $database->query();
          
          $database->setQuery("INSERT INTO #__jdownloads_license (license_title, license_text, license_url)  VALUES ('".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE3_TITLE')."', '".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE3_TEXT')."', '".''."')");
          $database->query();
  
          $database->setQuery("INSERT INTO #__jdownloads_license (license_title, license_text, license_url)  VALUES ('".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE4_TITLE')."', '".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE4_TEXT')."', '".''."')");
          $database->query();

          $database->setQuery("INSERT INTO #__jdownloads_license (license_title, license_text, license_url)  VALUES ('".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE5_TITLE')."', '".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE5_TEXT')."', '".''."')");
          $database->query();

          $database->setQuery("INSERT INTO #__jdownloads_license (license_title, license_text, license_url)  VALUES ('".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE6_TITLE')."', '".''."', '".''."')");
          $database->query();

          $database->setQuery("INSERT INTO #__jdownloads_license (license_title, license_text, license_url)  VALUES ('".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE7_TITLE')."', '".''."', '".JText::_('COM_JDOWNLOADS_SETTINGS_LICENSE7_URL')."')");
          $database->query();

          echo "<font color='green'>--> ".$sum_licenses." ".JText::_('COM_JDOWNLOADS_INSTALL_6')."</font><br />";

          
      } else {
          
          // jD exists and this is only a update!
          // set new values
          $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '$jd_version' WHERE setting_name = 'jd.version'");  
          $database->query();
          $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '$jd_version_state' WHERE setting_name = 'jd.version.state'");  
          $database->query();
          $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '$jd_version_svn' WHERE setting_name = 'jd.version.svn'");  
          $database->query();
          
          
          if ($sum_configs == 0) {
              echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_1')."</font><br />";
          } else {
              echo "<font color='green'>--> ".$sum_configs." ".JText::_('COM_JDOWNLOADS_INSTALL_2')."</font><br />";
          }
          
          if ($sum_added_fields == 0) {
              echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_1_2')."</font><br />";
          } else {
              echo "<font color='green'>--> ".$sum_added_fields." ".JText::_('COM_JDOWNLOADS_INSTALL_2_2')."</font><br />";        
          }
          
          // add newer layouts when not exists
          $database->setQuery("SELECT * FROM #__jdownloads_templates WHERE template_typ = '2' AND locked = '1'  AND  template_name ='".$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_3_NAME."'");
          $temp = $database->loadResult();
          if (!$temp) {
              $file_layout = stripslashes($COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_3); 
              $database->setQuery("INSERT INTO #__jdownloads_templates (template_name, template_typ, template_text, template_active, locked, note, checkbox_off, symbol_off)  VALUES ('".$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_3_NAME."', 2, '".$file_layout."', 0, 1, '', 1, 1)");
              $database->query();
              $sum_layouts++;
              $database->setQuery("UPDATE #__jdownloads_templates SET template_header_text = '$files_header', template_subheader_text = '$files_subheader', template_footer_text = '$files_footer' WHERE template_typ = '2' AND template_header_text = ''");
              $database->query();
          }
          
          if ($sum_layouts == 0) {
              echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_3')."</font><br />";
          } else {
              echo "<font color='green'>--> ".$sum_layouts." ".JText::_('COM_JDOWNLOADS_INSTALL_4')."</font><br />";
          }

          if ($sum_licenses == 0) {
              echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_5')."</font><br />";
          } else {
              echo "<font color='green'>--> ".$sum_licenses." ".JText::_('COM_JDOWNLOADS_INSTALL_6')."</font><br />";
          }

      }    
        

      // final checks
      
      // Checked if exist joomfish - if yes, move the files
      // removed for this release - joomfish is not ready for J1.6/1.7
      /*  if (@is_dir(JPATH_SITE.'/administrator/components/com_joomfish/contentelements')){
            $fishresult = 1;
            @rename( JPATH_SITE."/administrator/components/com_jdownloads/assets/joomfish/jdownloads_cats.xml", JPATH_SITE."/administrator/components/com_joomfish/contentelements/jdownloads_cats.xml");
            @rename( JPATH_SITE."/administrator/components/com_jdownloads/assets/joomfish/jdownloads_config.xml", JPATH_SITE."/administrator/components/com_joomfish/contentelements/jdownloads_config.xml");
            @rename( JPATH_SITE."/administrator/components/com_jdownloads/assets/joomfish/jdownloads_files.xml", JPATH_SITE."/administrator/components/com_joomfish/contentelements/jdownloads_files.xml");
            @rename( JPATH_SITE."/administrator/components/com_jdownloads/assets/joomfish/jdownloads_layouts.xml", JPATH_SITE."/administrator/components/com_joomfish/contentelements/jdownloads_layouts.xml");
            @rmdir ( JPATH_SITE."/administrator/components/com_jdownloads/assets/joomfish"); 
        } else { 
            $fishresult = 0;
        }  
    	    
	    if ($fishresult) {
		    echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_17')." ".JPATH_SITE.'/administrator/components/com_joomfish/contentelements'.'</font><br />';
	    } else {
            echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_18')." ".JPATH_SITE.'/administrator/components/com_jdownloads/joomfish'.'<br />'.JText::_('COM_JDOWNLOADS_INSTALL_19').'</font><br />';
        }    	
        */

        // Checked default directories 

        // downloads
        if ($is_update){
            $dir_exist = is_dir($root_dir);
        
            if($dir_exist) {
               if (is_writable($root_dir)) {
                   // copy index.html to the new folder
                   if (!JFile::exists($root_dir.'index.html')){
                       $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', $root_dir.'index.html');
                   }    
                   echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_7')."</font><br />";
               } else {
                  echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_INSTALL_8')."</strong></font><br />";
               }
            } else {
                if ($makedir = JFolder::create($root_dir, 0755)){
                   // copy index.html to the new folder
                   if (!JFile::exists($root_dir.'index.html')){
                       $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', $root_dir.'index.html');
                   }
                    echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_9')."<br />";
                } else {
                     echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_INSTALL_10')."</strong></font><br />";
                }
            }
            $root_dir_path = $root_dir;
        } else {
            $dir_exist = is_dir(JPATH_SITE.DS."jdownloads");
            if($dir_exist) {
                if (is_writable(JPATH_SITE.DS."jdownloads")) {
                   // copy index.html to the new folder
                   if (!JFile::exists(JPATH_SITE.DS."jdownloads".DS.'index.html')){
                       $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', JPATH_SITE.DS."jdownloads".DS.'index.html');
                   }
                    echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_7')."</font><br />";
                } else {
                    echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_INSTALL_8')."</strong></font><br />";
                }
            } else {
                if ($makedir =  JFolder::create(JPATH_SITE.DS."jdownloads".DS, 0755)) {
			       // copy index.html to the new folder
                   if (!JFile::exists(JPATH_SITE.DS."jdownloads".DS.'index.html')){
                       $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', JPATH_SITE.DS."jdownloads".DS.'index.html');
                   }
                    echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_9')."<br />";
		        } else {
		 	        echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_INSTALL_10')."</strong></font><br />";
		        }
            }
            $root_dir_path = JPATH_SITE.DS."jdownloads".DS;
        }
        // tempzipfiles
        $dir_existzip = is_dir($root_dir_path."tempzipfiles");

        if($dir_existzip) {
           if (is_writable($root_dir_path."tempzipfiles")) {
               // copy index.html to the new folder
               if (!JFile::exists($root_dir_path."tempzipfiles".DS.'index.html')){
                   $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', $root_dir_path."tempzipfiles".DS.'index.html');
               }
               echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_11')."</font><br />";
           } else {
               echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_INSTALL_12')."</strong></font><br />";
           }
        } else {
            if ($makedir = JFolder::create($root_dir_path."tempzipfiles".DS, 0755)) {
    			// copy index.html to the new folder
               if (!JFile::exists($root_dir_path."tempzipfiles".DS.'index.html')){
                   $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', $root_dir_path."tempzipfiles".DS.'index.html');
               }
                echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_INSTALL_13')."<br />";
		    } else {
		 	echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_INSTALL_14')."</strong></font><br />";
		    }
		 }

        // beispieldaten speichern - wenn neuinstallation
        if ($root_dir == '' && !$is_update){
            $dir_exist = is_dir(JPATH_SITE."/jdownloads");
            if($dir_exist) {
                if (is_writable(JPATH_SITE."/jdownloads")) {      
                     if (!is_dir(JPATH_SITE."/jdownloads/".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT'))){
                        // daten speichern
                        // dirs für cats
                        $makdir = JFolder::create(JPATH_SITE.DS."jdownloads".DS.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT').DS, 0755);
                        $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', JPATH_SITE.DS."jdownloads".DS.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT').DS.'index.html');
                        $makdir = JFolder::create(JPATH_SITE.DS."jdownloads".DS.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT').DS.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_SUB').DS, 0755);
                        $index_copied = JFile::copy(JPATH_COMPONENT_ADMINISTRATOR.DS.'index.html', JPATH_SITE.DS."jdownloads".DS.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT').DS.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_SUB').DS.'index.html');
                        // cat erstellen in db
                        if ($makdir) {
                            $database->setQuery("INSERT INTO #__jdownloads_cats (cat_title, cat_description, cat_dir, parent_id, cat_pic, published)  VALUES ('".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_NAME_ROOT')."', '".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_NAME_TEXT')."', '".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT')."', 0, 'joomla.png', 1)");
                            $database->query();
                            $database->setQuery("INSERT INTO #__jdownloads_cats (cat_title, cat_description, cat_dir, parent_id, cat_pic, published)  VALUES ('".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_NAME_SUB')."', '".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_NAME_TEXT')."', '".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT').'/'.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_SUB')."', 1, 'joomla.png', 1)");
                            $database->query();
                            // file kopieren nach catdir
                            $source_path = JPATH_SITE."/administrator/components/com_jdownloads/assets/mod_jdownloads_top_1.5.zip";
                            $dest_path = JPATH_SITE.'/jdownloads/'.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_ROOT').'/'.JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CAT_FOLDER_SUB').'/mod_jdownloads_top_1.5.zip'; 
                            JFile::copy($source_path, $dest_path);
                            // downloads erstellen
                            $database->setQuery("INSERT INTO #__jdownloads_files (`file_id`, `file_title`, `description`, `description_long`, `file_pic`, `price`, `release`, `language`, `system`, `license`, `url_license`, `size`, `date_added`, `url_download`, `url_home`, `author`, `url_author`, `created_by`, `created_mail`, `modified_by`, `modified_date`, `downloads`, `cat_id`, `ordering`, `published`, `checked_out`, `checked_out_time`) VALUES (NULL, '".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_FILE_NAME')."', '".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_FILE_NAME_TEXT')."', '".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_FILE_NAME_TEXT')."', 'joomla.png', '', '1.0', '2', '1', '1', '', '1.92 KB', '".date('Y-m-d H:i:s')."', 'mod_jdownloads_top_1.5.zip', 'www.jDownloads.com', 'Arno Betz', 'info@jDownloads.com', 'Installer', '', '', '0000-00-00 00:00:00', '0', '2', '0', '1', '0', '0000-00-00 00:00:00')");
                            $database->query();
                            checkAlias();
                            echo "<font color='green'>--> ".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CREATE_OK')."<br />";
                        }
                        checkAlias();
                     } else {
                        // daten existieren schon
                        echo "<font color='green'> ".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_EXISTS')."</font><br />";
                     } 
                } else {
                    // fehlermeldung: daten konnten nicht gespeichert werden
                    echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CREATE_ERROR')."</strong></font><br />";
                }    
            } else {
                // fehlermeldung: daten konnten nicht gespeichert werden
                echo "<font color='red'><strong>--> ".JText::_('COM_JDOWNLOADS_SAMPLE_DATA_CREATE_ERROR')."</strong></font><br />";
            }
                
        }    
        
        
        echo "<font color='#FF6600'><strong>--> ".JText::_('COM_JDOWNLOADS_INSTALL_DB_TIP')."</strong></font><br />";
        ?>

		<br />
   		<font color="green"><b><?php echo JText::_('COM_JDOWNLOADS_INSTALL_15'); ?></b></font><br />
  		</code>
        </td>
        </tr>
        </table>
        <a href="index.php?option=com_jdownloads"><big><strong><?php echo JText::_('COM_JDOWNLOADS_INSTALL_16'); ?></strong></big></a><br /><br />
        </center>
        <?php
    
  }  
}

function checkAlias(){
    $database = &JFactory::getDBO(); 
    // check alias field
    $database->setQuery("SELECT cat_id, cat_title, cat_alias FROM #__jdownloads_cats WHERE cat_alias = ''");
    $cats = $database->loadObjectList();
    if ($cats){
        foreach ($cats as $cat){
            $cat->cat_alias = $cat->cat_title;
            $cat->cat_alias = JFilterOutput::stringURLSafe($cat->cat_alias);
            if(trim(str_replace('-','',$cat->cat_alias)) == '') {
                $datenow =& JFactory::getDate();
                $cat->cat_alias = $datenow->toFormat("%Y-%m-%d-%H-%M-%S");
            }
            $database->setQuery("UPDATE #__jdownloads_cats SET cat_alias = '$cat->cat_alias' WHERE cat_id = '$cat->cat_id'");  
            $database->query();                                             
        }    
    }
    $database->setQuery("SELECT file_id, file_title, file_alias FROM #__jdownloads_files WHERE file_alias = ''");
    $files = $database->loadObjectList();
    if ($files){
        foreach ($files as $file){
            $file->file_alias = $file->file_title;
            $file->file_alias = JFilterOutput::stringURLSafe($file->file_alias);
            if(trim(str_replace('-','',$file->file_alias)) == '') {
                $datenow =& JFactory::getDate();
                $file->file_alias = $datenow->toFormat("%Y-%m-%d-%H-%M-%S");
            }
            $database->setQuery("UPDATE #__jdownloads_files SET file_alias = '$file->file_alias' WHERE file_id = '$file->file_id'");  
            $database->query();                                             
        }    
    }   
}    

// Kopiert alle dirs inkl. subdirs und files nach $dest
// und löscht abscchliessend das $source dir
function moveDirs($source, $dest, $recursive = true, $message) {
    jimport('joomla.filesystem.file');
    $error = false;
    if (!is_dir($dest)) { 
        JFolder::create($dest);
      } 
    $handle = @opendir($source);
    if(!$handle) {
        $message = JText::_('COM_JDOWNLOADS_INSTALL_MOVE_IMAGES_COPY_ERROR');
        return $message;
    }
    while ($file = @readdir ($handle)) {
        if (eregi("^\.{1,2}$",$file)) {
            continue;
        }
        if(!$recursive && $source != $source.$file."/") {
            if(is_dir($source.$file))
                continue;
        }
        if(is_dir($source.$file)) {
            moveDirs($source.$file."/", $dest.$file."/", $recursive, $message);
        } else {
            if (!JFile::copy($source.$file, $dest.$file)) {
                $error = true;
            }
        }
    }
    @closedir($handle);
    // $source löschen wenn KEIN error
    if (!$error) {
        $res = delete_dir_and_allfiles ($source);    
        if ($res) {
            $message = JText::_('COM_JDOWNLOADS_INSTALL_MOVE_IMAGES_DEL_AFTER_COPY_ERROR');        
        }
    } else {
        $message = JText::_('COM_JDOWNLOADS_INSTALL_MOVE_IMAGES_COPY_ERROR');
    }
    return $message;
} 

// delete_dir_and_allfiles - rekursiv löschen
// Rueckgabewerte:
//    0 - ok
//   -1 - kein Verzeichnis
//   -2 - Fehler beim Loeschen
//   -3 - Ein Eintrag war keine Datei/Verzeichnis/Link

function delete_dir_and_allfiles ($path) {
    jimport('joomla.filesystem.folder');
    jimport('joomla.filesystem.file');

    if (!is_dir ($path)) {
        return -1;
    }
    $dir = @opendir ($path);
    if (!$dir) {
        return -2;
    }
    while (($entry = @readdir($dir)) !== false) {
        if ($entry == '.' || $entry == '..') continue;
        if (is_dir ($path.'/'.$entry)) {
            $res = delete_dir_and_allfiles ($path.'/'.$entry);
            // manage errors
            if ($res == -1) {
                @closedir ($dir); 
                return -2; 
            } else if ($res == -2) {
                @closedir ($dir); 
                return -2; 
            } else if ($res == -3) {
                @closedir ($dir); 
                return -3; 
            } else if ($res != 0) { 
                @closedir ($dir); 
                return -2; 
            }
        } else if (is_file ($path.'/'.$entry) || is_link ($path.'/'.$entry)) {
            // delete file
            $res = JFile::delete($path.'/'.$entry);
            if (!$res) {
                @closedir ($dir);
                return -2; 
            }
        } else {
            @closedir ($dir);
            return -3;
        }
    }
    @closedir ($dir);
    // delete dir
    $res = JFolder::delete($path);
    if (!$res) {
        return -2;
    }
    return 0;
}

?>