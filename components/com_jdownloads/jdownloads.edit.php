<?php
/**
* @version 1.5
* @package JDownloads
* @copyright (C) 2009 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*/

defined( '_JEXEC' ) or die( 'Restricted access' );

require_once(JPATH_COMPONENT.'/jdownloads.edit.html.php'); 


function editFile($option, $cid){
 global $mainframe, $jlistConfig, $Itemid;

    $user      = &JFactory::getUser();
    $app       = &JFactory::getApplication();
    $database  = &JFactory::getDBO();
    $document  = &JFactory::getDocument();
    $uri       = &JFactory::getURI();
    $uri       = $uri->toString();
    $action    = JRoute::_('index.php?option='.$option.'&Itemid='.$Itemid.'&view=save&cid='.$cid, false);
    $editor =& JFactory::getEditor();
    $editor2 =& JFactory::getEditor();
    $params = array( 'smilies'=> '0' ,
                 'style'  => '1' ,  
                 'layer'  => '0' , 
                 'table'  => '0' ,
                 'clear_entities'=>'0'
                 );
 
    
    $session = JFactory::getSession();
    $session_data = $session->get('jd_edit_user'); 
    
  if (isset($session_data) && $session_data[id] == $user->id && $session_data[file_id] == $cid){
      
    // for tooltip
    JHTML::_('behavior.tooltip');
    // for datepicker
    JHTML::_('behavior.calendar');

    $row = new jlist_files( $database );
    $row->load( $cid );
    
    // fail if checked out not by 'me'
    if ($row->isCheckedOut( $user->get('id') )) {
        $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), JText::_('COM_JDOWNLOADS_FE_FILESEDIT_CHECKED_OUT_MSG'), 'error' ); 
    }
    $row->checkout( $user->get('id') );
    // build system listbox
    $file_system = array();
    $file_sys_values = explode(',' , $jlistConfig['system.list']);
    for ($i=0; $i < count($file_sys_values); $i++) {
        $file_system[] = JHTML::_('select.option',  $i, $file_sys_values[$i] );
    }
    $listbox_system = JHTML::_('select.genericlist', $file_system, 'system', 'class="inputbox" size="1"', 'value', 'text', $row->system );

    // build language listbox
    $file_language = array();
    $file_lang_values = explode(',' , $jlistConfig['language.list']);
    for ($i=0; $i < count($file_lang_values); $i++) {
        $file_language[] = JHTML::_('select.option',  $i, $file_lang_values[$i] );
    }
    $listbox_language = JHTML::_('select.genericlist', $file_language, 'language', 'class="inputbox" size="1"', 'value', 'text', $row->language );

    // get licenses array and build listbox with licenses
    $licenses = array();
    $licenses[] = JHTML::_('select.option', '0', JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_LICENSES_LIST') );
    $database->setQuery( "SELECT id AS value, license_title AS text FROM #__jdownloads_license" );
    $licenses = array_merge( $licenses, $database->loadObjectList() );

    // symbol list for files
    $file_pic_dir = '/images/jdownloads/fileimages/'; 
    $file_pic_dir_path = JURI::base().'images/jdownloads/fileimages/';
    $pic_files = JFolder::files( JPATH_SITE.$file_pic_dir );
    $file_pic_list[] = JHTML::_('select.option', '', JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_FRONTEND_FPIC_TEXT'));
    foreach ($pic_files as $file) {
        if (eregi( "gif|jpg|png", $file )) {
            $file_pic_list[] = JHTML::_('select.option', $file );
        }
    }
    $inputbox_pic = JHTML::_('select.genericlist', $file_pic_list, 'file_pic', "class=\"inputbox\" size=\"1\""
  . " onchange=\"javascript:if (document.editForm.file_pic.options[selectedIndex].value!='') {document.imagelib.src='$file_pic_dir_path' + document.editForm.file_pic.options[selectedIndex].value} else {document.imagelib.src=''}\"", 'value', 'text', $row->file_pic );

    $yesno = array();
    $yesno[] = JHTML::_('select.option', '0', JText::_('COM_JDOWNLOADS_FE_NO'));
    $yesno[] = JHTML::_('select.option', '1', JText::_('COM_JDOWNLOADS_FE_YES'));
    $confirm = JHTML::_('select.genericlist', $yesno, "license_agree", 'size="1" class="inputbox"', 'value', 'text', $row->license_agree );

    $update = JHTML::_('select.genericlist', $yesno, "update", 'size="1" class="inputbox"', 'value', 'text', $row->update_active );

    // get custom field
    $custom_arr = existsCustomFieldsTitlesX();
    $x = 0;
    if (count($custom_arr)){
        foreach ($custom_arr[0] as $custom){
             if ($custom < 6){
                 $x++;
               if ($custom == 1){
                 $select_box = array();
                 $select_box_values = explode(',' , $jlistConfig["custom.field.1.values"]);
                 $select_box[0] = JHTML::_('select.option',  0, JText::_('COM_JDOWNLOADS_BACKEND_FILE_EDIT_SELECT_TITLE'));
                 for ($i=0; $i < count($select_box_values); $i++) {
                    $select_box[] = JHTML::_('select.option',  $i+1, $select_box_values[$i] );
                 }
                 $select_box_1 = JHTML::_('select.genericlist',  $select_box, 'custom_field_1', 'class="inputbox" size="1"',  'value', 'text', $row->custom_field_1 );
                 $all_custom_arr[] = $select_box_1;
                 $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
               }     
               if ($custom == 2){                                     
                 $select_box = array();
                 $select_box_values = explode(',' , $jlistConfig["custom.field.2.values"]);
                 $select_box[0] = JHTML::_('select.option',  0, JText::_('COM_JDOWNLOADS_BACKEND_FILE_EDIT_SELECT_TITLE'));
                 for ($i=0; $i < count($select_box_values); $i++) {
                    $select_box[] = JHTML::_('select.option',  $i+1, $select_box_values[$i] );
                 }
                 $select_box_1 = JHTML::_('select.genericlist',  $select_box, 'custom_field_2', 'class="inputbox" size="1"',  'value', 'text', $row->custom_field_2 );
                 $all_custom_arr[] = $select_box_1;
                 $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
               }
               if ($custom == 3){
                 $select_box = array();
                 $select_box_values = explode(',' , $jlistConfig["custom.field.3.values"]);
                 $select_box[0] = JHTML::_('select.option',  0, JText::_('COM_JDOWNLOADS_BACKEND_FILE_EDIT_SELECT_TITLE'));
                 for ($i=0; $i < count($select_box_values); $i++) {
                    $select_box[] = JHTML::_('select.option',  $i+1, $select_box_values[$i] );
                 }
                 $select_box_1 = JHTML::_('select.genericlist',  $select_box, 'custom_field_3', 'class="inputbox" size="1"',  'value', 'text', $row->custom_field_3 );
                 $all_custom_arr[] = $select_box_1;
                 $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
               }
               if ($custom == 4){
                 $select_box = array();
                 $select_box_values = explode(',' , $jlistConfig["custom.field.4.values"]);
                 $select_box[0] = JHTML::_('select.option',  0, JText::_('COM_JDOWNLOADS_BACKEND_FILE_EDIT_SELECT_TITLE'));
                 for ($i=0; $i < count($select_box_values); $i++) {
                    $select_box[] = JHTML::_('select.option',  $i+1, $select_box_values[$i] );
                 }
                 $select_box_1 = JHTML::_('select.genericlist',  $select_box, 'custom_field_4', 'class="inputbox" size="1"',  'value', 'text', $row->custom_field_4 );
                 $all_custom_arr[] = $select_box_1;
                 $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
               }
               if ($custom == 5){
                 $select_box = array();
                 $select_box_values = explode(',' , $jlistConfig["custom.field.5.values"]);
                 $select_box[0] = JHTML::_('select.option',  0, JText::_('COM_JDOWNLOADS_BACKEND_FILE_EDIT_SELECT_TITLE'));
                 for ($i=0; $i < count($select_box_values); $i++) {
                    $select_box[] = JHTML::_('select.option',  $i+1, $select_box_values[$i] );
                 }
                 $select_box_1 = JHTML::_('select.genericlist',  $select_box, 'custom_field_5', 'class="inputbox" size="1"',  'value', 'text', $row->custom_field_5 );
                 $all_custom_arr[] = $select_box_1;
                 $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
               }                                                                 
                    
             } elseif ($custom < 11){      
               
               // create the input fields 
                  if ($custom == 6){  
                    if (!$row->custom_field_6) $row->custom_field_6 = $jlistConfig["custom.field.6.values"];
                    $input_field = '<input name="custom_field_6" value="'.htmlspecialchars($row->custom_field_6).'" size="60" maxlength="255"/>';
                    $all_custom_arr[] = $input_field;
                    $custom_titles_arr[] = $custom_arr[1][$custom-1];                       
                  }
                  if ($custom == 7){  
                    if (!$row->custom_field_7) $row->custom_field_7 = $jlistConfig["custom.field.7.values"];
                    $input_field = '<input name="custom_field_7" value="'.htmlspecialchars($row->custom_field_7).'" size="60" maxlength="255"/>';
                    $all_custom_arr[] = $input_field;
                    $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  } 
                  if ($custom == 8){  
                    if (!$row->custom_field_8) $row->custom_field_8 = $jlistConfig["custom.field.8.values"];
                    $input_field = '<input name="custom_field_8" value="'.htmlspecialchars($row->custom_field_8).'" size="60" maxlength="255"/>';
                    $all_custom_arr[] = $input_field;
                    $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  } 
                  if ($custom == 9){  
                    if (!$row->custom_field_9) $row->custom_field_9 = $jlistConfig["custom.field.9.values"];
                    $input_field = '<input name="custom_field_9" value="'.htmlspecialchars($row->custom_field_9).'" size="60" maxlength="255"/>';
                    $all_custom_arr[] = $input_field;
                    $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  } 
                  if ($custom == 10){  
                    if (!$row->custom_field_10) $row->custom_field_10 = $jlistConfig["custom.field.10.values"];
                    $input_field = '<input name="custom_field_10" value="'.htmlspecialchars($row->custom_field_10).'" size="60" maxlength="255"/>';
                    $all_custom_arr[] = $input_field;
                    $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  }   
              } elseif ($custom < 13){
                  // date fields                  
                  if ($custom == 11){
                      $input_field = '<input name="custom_field_11" id="custom_field_11" value="'.$row->custom_field_11.'" size="15"/>';
                      $input_field .='<input name="reset" type="reset" class="button" onclick="return showCalendar(\'custom_field_11\', \'%Y-%m-%d\')" value="..." />'; 
                      $all_custom_arr[] = $input_field;
                      $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  }                
                  if ($custom == 12){
                      $input_field = '<input name="custom_field_12" id="custom_field_12" value="'.$row->custom_field_12.'" size="15"/>';
                      $input_field .='<input name="reset" type="reset" class="button" onclick="return showCalendar(\'custom_field_12\', \'%Y-%m-%d\')" value="..." />'; 
                      $all_custom_arr[] = $input_field;
                      $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  }
              
              } else {
                  // text fields
                  if ($custom == 13){  
                      if ($jlistConfig['files.editor'] == "1") {
                          $input_field = $editor->display( 'custom_field_13',  @$row->custom_field_13 , '400', '300', '50', '5', false, '' ) ;
                      } else {
                          $input_field = '<textarea name="custom_field_13" rows="10" cols="45">'.htmlspecialchars($row->custom_field_13).'</textarea>';
                      }
                      $all_custom_arr[] = $input_field;
                      $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  }
                  if ($custom == 14){  
                      if ($jlistConfig['files.editor'] == "1") {
                          $input_field = $editor2->display( 'custom_field_14',  @$row->custom_field_14 , '400', '300', '50', '5', false, '' ) ;
                      } else {
                          $input_field = '<textarea name="custom_field_14" rows="10" cols="45">'.htmlspecialchars($row->custom_field_14).'</textarea>';
                      }
                      $all_custom_arr[] = $input_field;
                      $custom_titles_arr[] = $custom_arr[1][$custom-1];                    
                  }
              } 
           }  
    }      
    
    $breadcrumbs =& $mainframe->getPathWay();
    $breadcrumbs->addItem(JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_TITLE'), JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=viewdownload&cid='.$cid));    
    
    jlist_HTML2::editFile($option, $row, $licenses, $inputbox_pic, $listbox_system, $listbox_language, $action, $publish, $confirm, $update, $all_custom_arr, $custom_arr, $custom_titles_arr);       
  } else {
       if (!$user->id) {
            $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
       } else {
            echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
            exit();  
       }             
  }  
    
}

function saveFile($option, $cid){
    global $mainframe, $jlistConfig, $Itemid;
    
    JRequest::checkToken( 'request' ) or jexit( 'Invalid Token' );
    
    $user      = &JFactory::getUser();
    $database  = &JFactory::getDBO();
    $document  = &JFactory::getDocument();
    $app = &JFactory::getApplication();
    jimport('joomla.filesystem.file');
    
    $session = JFactory::getSession();
    $session_data = $session->get('jd_edit_user'); 
    $allowed_file_types = strtolower($jlistConfig['allowed.upload.file.types']).','.strtoupper($jlistConfig['allowed.upload.file.types']);
    
    if (isset($session_data) && $session_data[id] == $user->id && $session_data[file_id] == $cid){     
       // is delete button clicked?
       $delete = $database->getEscaped (JRequest::getInt('deletefile', 0 ));
       if ($delete) {
           // delete the complete download 
           // get first the filename
           $database->setQuery("SELECT url_download, cat_id FROM #__jdownloads_files WHERE file_id = '$cid'");
           $file_data = $database->loadObject();
           $database->setQuery("DELETE FROM #__jdownloads_files WHERE file_id = '$cid'");
           if (!$database->query()) {
               // error - redirect to download
              $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), JText::_('COM_JDOWNLOADS_FE_FILESEDIT_DELETE_DOWNLOAD_ERROR'), 'error'); 
           } else {
               // ok - delete also the file
               if ($file_data->url_download){
                   $database->setQuery("SELECT cat_dir FROM #__jdownloads_cats WHERE cat_id = '$file_data->cat_id'");
                   $catdir = $database->loadResult();
                   $file_url = JPATH_SITE.DS.$jlistConfig['files.uploaddir'].DS.$catdir.DS.$file_data->url_download;
                   if (!JFile::delete($file_url)){
                       // error - redirect to category
                       $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewcategory&catid='.$file_data->cat_id.'&Itemid='.$Itemid, false), JText::_('COM_JDOWNLOADS_FE_FILESEDIT_DELETE_DOWNLOAD_FILE_ERROR'), 'error'); 
                   }    
               }    
               // OK!
               $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewcategory&catid='.$file_data->cat_id.'&Itemid='.$Itemid, false), JText::_('COM_JDOWNLOADS_FE_FILESEDIT_DELETE_DOWNLOAD_OK_MSG')); 
           }
      } else {
        // save the data
       $row = new jlist_files($database);
       // bind it to the table
       if (!$row -> bind($_POST)) {
            echo "<script> alert('"
            .$row -> getError()
            ."'); window.history.go(-1); </script>\n";
            exit();
       }
       $row->published = 1;
       $row->modified_date = JHTML::_('date', 'now','Y-m-d H:i:s'); 
       $row->modified_by = $user->get('username');
       $row->modified_id = $user->get('id');
       $row->description      = JRequest::getVar( 'description', '', 'post', 'string', JREQUEST_ALLOWHTML );
       $row->description_long = JRequest::getVar( 'description_long', '', 'post', 'string', JREQUEST_ALLOWHTML );  
       
       $upload_dir = '/images/jdownloads/screenshots/'; 
       $pic_types = 'gif|jpg|png';
       $max_file_size = $jlistConfig['allowed.upload.file.size'] * 1024 ;
       
       $old_file =         $database->getEscaped (JRequest::getString('url_download_old', '' ));
       $extern_file_old =  $database->getEscaped (JRequest::getString('extern_file_old', '' ));    
       $file_upload  =     JArrayHelper::getValue($_FILES,'file_upload',array('tmp_name'=>''));
       $pic_upload  =      JArrayHelper::getValue($_FILES,'pic_upload',array('tmp_name'=>''));
       $pic_upload2  =     JArrayHelper::getValue($_FILES,'pic_upload2',array('tmp_name'=>''));
       $pic_upload3  =     JArrayHelper::getValue($_FILES,'pic_upload3',array('tmp_name'=>''));
       $catid           =  JRequest::getInt('cat_id', 0 ); 
       $row->extern_file = $database->getEscaped (JRequest::getString('extern_file', '' ));       
       $row->file_alias =  $database->getEscaped (JRequest::getString('file_alias', '' ));
       $row->file_title =  $database->getEscaped (JRequest::getString('file_title', '' ));
       $row->release    =  $database->getEscaped (JRequest::getString('release', '' ));
       $row->price      =  $database->getEscaped (JRequest::getString('price', '' ));
       $row->url_home   =  $database->getEscaped (JRequest::getString('url_home', '' ));
       $row->author     =  $database->getEscaped (JRequest::getString('author', '' ));
       $row->url_author =  $database->getEscaped (JRequest::getString('url_author', '' ));
       $row->metadesc   =  $database->getEscaped (strip_tags(JRequest::getVar('metadesc', '', 'post', 'string' )));     
       $row->metakey    =  $database->getEscaped (strip_tags(JRequest::getVar('metakey', '', 'post', 'string' )));
       $row->mirror_1   =  $database->getEscaped (JRequest::getString('mirror_1', '' ));
       $row->mirror_2   =  $database->getEscaped (JRequest::getString('mirror_2', '' ));
       $row->update_active   =  JRequest::getInt('update', 0 );      
       $row->license_agree   =  JRequest::getInt('license_agree', 0 );
       $row->license         =  JRequest::getInt('license', 0 );
       if ($row->license_agree && !$row->license) $row->license_agree = 0;
       
       $row->custom_field_1 = $database->getEscaped (JRequest::getInt('custom_field_1', 0 ));
       $row->custom_field_2 = $database->getEscaped (JRequest::getInt('custom_field_2', 0 ));
       $row->custom_field_3 = $database->getEscaped (JRequest::getInt('custom_field_3', 0 ));
       $row->custom_field_4 = $database->getEscaped (JRequest::getInt('custom_field_4', 0 ));
       $row->custom_field_5 = $database->getEscaped (JRequest::getInt('custom_field_5', 0 ));
       $row->custom_field_6 = $database->getEscaped (JRequest::getVar( 'custom_field_6', '', 'post', 'string', JREQUEST_ALLOWHTML ));
       $row->custom_field_7 = $database->getEscaped (JRequest::getVar( 'custom_field_7', '', 'post', 'string', JREQUEST_ALLOWHTML ));
       $row->custom_field_8 = $database->getEscaped (JRequest::getVar( 'custom_field_8', '', 'post', 'string', JREQUEST_ALLOWHTML ));
       $row->custom_field_9 = $database->getEscaped (JRequest::getVar( 'custom_field_9', '', 'post', 'string', JREQUEST_ALLOWHTML ));
       $row->custom_field_10 = $database->getEscaped (JRequest::getVar( 'custom_field_10', '', 'post', 'string', JREQUEST_ALLOWHTML ));
       $row->custom_field_11 = $database->getEscaped (JRequest::getString('custom_field_11', '' ));
       $row->custom_field_12 = $database->getEscaped (JRequest::getString('custom_field_12', '' ));
       $row->custom_field_13 = JRequest::getVar( 'custom_field_13', '', 'post', 'string', JREQUEST_ALLOWHTML );
       $row->custom_field_14 = JRequest::getVar( 'custom_field_14', '', 'post', 'string', JREQUEST_ALLOWHTML );
       
       // build file alias
       $file_alias = $row->file_title;
       $file_alias = JFilterOutput::stringURLSafe($file_alias);
       if (trim(str_replace('-','',$file_alias)) == '') {
           $datenow =& JFactory::getDate();
           $file_alias = $datenow->toFormat("%Y-%m-%d-%H-%M-%S");
       }
       $row->file_alias = $file_alias;
       
       // check file extensions
       if ($file_upload['tmp_name'] != '') { 
          $filetype = strtolower(substr(strrchr($file_upload['name'], '.'), 1));
          $file_types = trim($allowed_file_types);
          $file_types = str_replace(',', '|', $file_types);
          if (!eregi( $file_types, $filetype ) || stristr($file_upload['name'], '.php.')){
              $file_upload['tmp_name'] = '';
              $msg = JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_ERROR_FILETYPE');
              $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), $msg, 'error'); 
          }
          // check filesize
          if ($file_upload['size'] > $max_file_size) {
              $file_upload['tmp_name'] = '';
              $msg = JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_ERROR_FILESIZE');
              $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), $msg, 'error');
          }               
       }
            
       if($pic_upload['tmp_name']!=''){
          $pictype = strtolower(substr(strrchr($pic_upload['name'],"."),1)); 
          if (eregi( $pictype, $pic_types )) {
             // replace special chars in filename
             $pic_filename = checkFileName($pic_upload['name']);
             $only_name = substr($pic_filename, 0, strrpos($pic_filename, '.'));
             $file_extension = strrchr($pic_filename,".");
             $num = 0;
             while (is_file(JPATH_SITE.$upload_dir.$pic_filename)){
                    $pic_filename = $only_name.'_'.$num++.$file_extension;
                    if ($num > 5000) break; 
             }
             $target_path =  JPATH_SITE.$upload_dir.$pic_filename;
             if(@move_uploaded_file($pic_upload['tmp_name'], $target_path)) {
                  // set chmod
                  @chmod($target_path, 0655);
                  // create thumb
                  create_new_thumb($target_path);
                  $row->thumbnail = basename($target_path);
             }      
          }             
       } 
       //pic upload bearbeiten
            if($pic_upload2['tmp_name']!=''){
              $pictype = strtolower(substr(strrchr($pic_upload2['name'],"."),1)); 
              if (eregi( $pictype, $pic_types )) {
                 // replace special chars in filename
                $pic_filename = checkFileName($pic_upload2['name']);
                $only_name = substr($pic_filename, 0, strrpos($pic_filename, '.'));
                $file_extension = strrchr($pic_filename,".");
                $num = 0;
                while (is_file(JPATH_SITE.$upload_dir.$pic_filename)){
                    $pic_filename = $only_name.$num++.$file_extension;
                    if ($num > 5000) break; 
                }
                $target_path =  JPATH_SITE.$upload_dir.$pic_filename;
                if(@move_uploaded_file($pic_upload2['tmp_name'], $target_path)) {
                     // set chmod
                     @chmod($target_path, 0655);
                     // create thumb
                     create_new_thumb($target_path);
                     $row->thumbnail2 = basename($target_path);
                }      
              }             
            }
             
            //pic upload bearbeiten
            if($pic_upload3['tmp_name']!=''){
              $pictype = strtolower(substr(strrchr($pic_upload3['name'],"."),1)); 
              if (eregi( $pictype, $pic_types )) {
                 // replace special chars in filename
                $pic_filename = checkFileName($pic_upload3['name']);
                $only_name = substr($pic_filename, 0, strrpos($pic_filename, '.'));
                $file_extension = strrchr($pic_filename,".");
                $num = 0;
                while (is_file(JPATH_SITE.$upload_dir.$pic_filename)){
                    $pic_filename = $only_name.$num++.$file_extension;
                    if ($num > 5000) break; 
                }
                $target_path =  JPATH_SITE.$upload_dir.$pic_filename;
                if(@move_uploaded_file($pic_upload3['tmp_name'], $target_path)) {
                     // set chmod
                     @chmod($target_path, 0655);
                     // create thumb
                     create_new_thumb($target_path);
                     $row->thumbnail3 = basename($target_path);
                }      
              }             
            }      
       
       // check extern file link or local file
       if ($extern_file_old == '' && $row->extern_file != ''){
           // user has changed the download typ - so remove the file in url_download
           if ($old_file){
               $database->setQuery("SELECT cat_dir FROM #__jdownloads_cats WHERE cat_id = '$catid'");
               $catdir = $database->loadResult();
               $file_url = JPATH_SITE.DS.$jlistConfig['files.uploaddir'].DS.$catdir.DS.$old_file;
               if (!JFile::delete($file_url)){
                   // error - redirect to category
                   $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), JText::_('COM_JDOWNLOADS_FE_FILESEDIT_DELETE_DOWNLOAD_FILE_ERROR2'), 'error');
               }
          }
       } else {   
          if ($old_file == '' && $file_upload['tmp_name'] != ''){
              $row->extern_file = '';
          }    
       }
       
       //file update 
       if ($file_upload['tmp_name']!=''){
           // replace special chars in filename
           $filename_new = checkFileName($file_upload['name']);
           $database->setQuery("SELECT cat_dir FROM #__jdownloads_cats WHERE cat_id = '$catid'");
           $catdir = $database->loadResult();
           $upload_dir = DS.$jlistConfig['files.uploaddir'].DS.$catdir.DS;
           $only_name = substr($filename_new, 0, strrpos($filename_new, '.'));
           $file_extension = strtolower(strrchr($filename_new,"."));
           $num = 0;
           while (is_file(JPATH_SITE.$upload_dir.$filename_new)){
                  $filename_new = $only_name.$num++.$file_extension;
                  if ($num > 5000) break; 
           }
           $dir_and_filename = str_replace('/'.$jlistConfig['files.uploaddir'].'/', '', $upload_dir.$filename_new);
           $target_path = JPATH_SITE.$upload_dir.$filename_new;

           if(@move_uploaded_file($file_upload['tmp_name'], $target_path)) {
               // first delete the old file when exists
               if ($old_file){
                   $database->setQuery("SELECT cat_dir FROM #__jdownloads_cats WHERE cat_id = '$catid'");
                   $catdir = $database->loadResult();
                   $file_url = JPATH_SITE.DS.$jlistConfig['files.uploaddir'].DS.$catdir.DS.$old_file;
                   if (!JFile::delete($file_url)){
                       // error - redirect to category
                        $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), JText::_('COM_JDOWNLOADS_FE_FILESEDIT_DELETE_OLD_FILE_ERROR'), 'error');
                   }
               }
               // create thumbs from pdf
                if ($jlistConfig['create.pdf.thumbs'] && $file_extension == '.pdf'){
                   $thumb_path = JPATH_SITE.'/images/jdownloads/screenshots/thumbnails/';
                   $screenshot_path = JPATH_SITE.'/images/jdownloads/screenshots/';
                   $pdf_tumb_name = create_new_pdf_thumb($target_path, $only_name, $thumb_path, $screenshot_path);
                   if ($pdf_tumb_name){
                       // add thumb file name to thumbnail data field
                       if ($row->thumbnail == ''){
                            $row->thumbnail = $pdf_tumb_name;
                       } elseif ($row->thumbnail2 == '') {
                            $row->thumbnail2 = $pdf_tumb_name;  
                       } else {
                             $row->thumbnail3 = $pdf_tumb_name;  
                       }   
                   }    
                }
                
               // create auto thumb when extension is a pic
                if ($jlistConfig['create.auto.thumbs.from.pics'] && ($file_extension == '.gif' || $file_extension == '.png' || $file_extension == '.jpg')){
                      $thumb_created = create_new_thumb($target_path);       
                      if ($thumb_created){
                          // add thumb file name to thumbnail data field
                           if ($row->thumbnail == ''){
                                $row->thumbnail = $filename_new;
                           } elseif ($row->thumbnail2 == '') {
                                $row->thumbnail2 = $filename_new;  
                           } else {
                                 $row->thumbnail3 = $filename_new;  
                           }
                      }
                      // create new big image for full view
                      $image_created = create_new_image($target_path);
                } 
               
               $row->size = fsize($target_path);
               $url_download = basename($target_path);
               $file_extension = strtolower(substr(strrchr($url_download,"."),1));
               $filepfad = JPATH_SITE.'/images/jdownloads/fileimages/'.$file_extension.'.png';
               if(file_exists(JPATH_SITE.'/images/jdownloads/fileimages/'.$file_extension.'.png')){
                  $row->file_pic = $file_extension.'.png';
               } else {
                  $row->file_pic = $jlistConfig['file.pic.default.filename'];
               }
               $row->url_download = $url_download;                    
               
               // send email wenn aktiviert
               if ($jlistConfig['send.mailto.option.upload']){
                   sendMailUploads($user->name, $user->email, $row->url_download, $row->file_title, $row->description);   
               }    
           } else {
               // error
                $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), $msg, 'error');
           }    
       }
              
       // store it in the db
       if (!$row -> store()) {
            echo "<script> alert('"
                .$row -> getError()
                ."'); window.history.go(-1); </script>\n";
            exit();
       } else {
         if(!$row->file_id) $row->file_id = mysql_insert_id();
       }
       $row->checkin();
       
       $app->redirect(JRoute::_('index.php?option='.$option.'&view=viewdownload&catid='.$row->cat_id.'&cid='.$cid.'&Itemid='.$Itemid, false), JText::_('COM_JDOWNLOADS_FE_FILESEDIT_SAVED_SUCCESSFUL_MSG'));
      }  // end save data
    } else {
        // no access
        if (!$user->id) {
            $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
        } else {
            echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
            exit();  
        }  
    }
}


?>