<?php
/**
* @version 1.5
* @package JDownloads
* @copyright (C) 2009 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*
*/

defined( '_JEXEC' ) or die( 'Restricted access-php' );

Error_Reporting(E_ERROR);
clearstatcache();
session_start();

    jimport( 'joomla.application.component.view');
    $database = &JFactory::getDBO();
    $jconfig = new JConfig();
   
    
	global $Itemid, $mainframe;   
    global $id, $limit, $limitstart, $site_aktuell, $catid, $cid, $task, $view, $pop, $jlistConfig, $jlistTemplates, $page_title; 
    global $cat_link_itemids, $upload_link_itemid, $search_link_itemid, $root_itemid;    
    
	$mainframe = JFactory::getApplication();
    $Itemid = JRequest::getInt('Itemid');
    
    jimport( 'joomla.html.parameter' ); 

    $document =& JFactory::getDocument();
    $params    = &$mainframe->getParams();
    
	$GLOBALS['_VERSION']	= new JVersion();
	$version				= $GLOBALS['_VERSION']->getShortVersion();
		
    $params2   = JComponentHelper::getParams('com_languages');
    $frontend_lang = $params2->get('site', 'en-GB');
    $language = JLanguage::getInstance($frontend_lang);
    
    require_once( JPATH_COMPONENT_SITE.DS.'jdownloads.html.php' ); 
    require_once( JPATH_COMPONENT_SITE.DS.'jdownloads.class.php' );
	//require_once(ELPATH.'/../../includes/pageNavigation.php');

	$id = (int)JArrayHelper::getValue( $_REQUEST, 'cid', array(0));
	if (!is_array( $id)) {
         $id = array(0);
    }
    $cid = $id;
    
    $GLOBALS['jlistConfig'] = buildjlistConfig();
    $GLOBALS['jlistTemplates'] = getTemplates();
    
    // search for root menu item to use
    $sql = 'SELECT id FROM #__menu WHERE link = ' . $database->Quote("index.php?option=com_jdownloads&view=viewcategories"). ' AND published = 1' ;
    $database->setQuery($sql);
    $root_itemid = $database->loadResult();
    if (!$root_itemid) $root_itemid = $Itemid;

    // Page Title
    $menus    = &JSite::getMenu();
    $menu    = $menus->getActive();

    // because the application sets a default page title, we need to get it
    // right from the menu item itself
    if (is_object( $menu )) {
        $menu_params = new JParameter( $menu->params );
        $x = $menu_params->get( 'page_title');
        if (!$menu_params->get( 'page_title')) {
            $params->set('page_title', $jlistConfig['jd.header.title']);
        }
    } else {
        $params->set('page_title', $jlistConfig['jd.header.title']);
    }
    
    if ($params->get('page_title')){
        $document->setTitle( $params->get( 'page_title' ) );
    } else {
        if ($menu_params && $menu_params->get( 'page_title')){
          if ($menu_params->get( 'page_title')){ 
            $document->setTitle( $menu_params->get( 'page_title'));
          }
        }      
    }    
    $page_title =  $document->getTitle( 'title');
    
    // get all published single category menu links
    $database->setQuery("SELECT id, link from #__menu WHERE link LIKE 'index.php?option=com_jdownloads&view=viewcategory&catid%' AND published = 1");
    $cat_link_itemids = $database->loadAssocList();
    if ($cat_link_itemids){
        for ($i=0; $i < count($cat_link_itemids); $i++){
             $cat_link_itemids[$i][catid] = substr( strrchr ( $cat_link_itemids[$i][link], '=' ), 1);
        }    
    }
    // get upload link itemid when exists
    $database->setQuery("SELECT id from #__menu WHERE link = 'index.php?option=com_jdownloads&view=upload' AND published = 1");    
    $upload_link_itemid = $database->loadResult();

    // get search link itemid when exists
    $database->setQuery("SELECT id from #__menu WHERE link = 'index.php?option=com_jdownloads&view=search' AND published = 1");    
    $search_link_itemid = $database->loadResult();

    $pop 			= intval( JArrayHelper::getValue( $_REQUEST, 'pop', 0 ) );
	$task 			= JRequest::getCmd( 'task' );
    $view           = JRequest::getCmd(  'view' );
	$cid 			= (int)JArrayHelper::getValue($_REQUEST, 'cid', array());
    $catid          = (int)JArrayHelper::getValue($_REQUEST, 'catid', 0);
    
	$limit        = intval($jlistConfig['files.per.side']);
	$limitstart   = intval( JRequest::getInt( 'limitstart', 0 ) );
    $site_aktuell = intval( JRequest::getInt( 'site', 1 ) );
    

    
    // AUP integration
    if ($jlistConfig['use.alphauserpoints']){
        $api_AUP = JPATH_SITE.DS.'components'.DS.'com_alphauserpoints'.DS.'helper.php';
        if (file_exists($api_AUP)){
            require_once ($api_AUP);
        }
    }            
    
    if ($task && !$view) $view = $task;
        
switch ($view) {

	   case 'upload':
		    viewUpload($option,$view);
	        break;
	   
	   case 'summary':
		    Summary($option);
		    break;

	   case 'finish':
		    finish($option);
		    break;

       case 'viewcategory':
       case 'category':
    		showOneCategory($option,$cid);
	       	break;

       case 'viewdownload':
       case 'view.download':            
       case 'download':                        
            showDownload($option,$cid);               
            break;

    /* case 'download':
            download($option,$cid);               
            break;
    */                   
       case 'search':
            showSearchForm($option,$cid);
            break;            
            
       case 'searchresult':
            showSearchResult($option,$cid);
            break;
            
       case 'report':
            reportDownload($option,$cid);
            break;
            
       case 'viewcategories':
	   case 'categories':       
     		showCats($option,$cid);
            break;

       case 'editor.insert.file':
            editorInsertFile('com_jdownloads');
            break;
            
       case 'edit':
            require_once(JPATH_COMPONENT.'/jdownloads.edit.php');
            editFile($option, $cid);
            break; 
            
       case 'save':
            require_once(JPATH_COMPONENT.'/jdownloads.edit.php');
            saveFile($option, $cid);
            break; 
               
	   default: showCats($option,$cid);
            break;
}

// show summary
function Summary($option){
	global $jlistConfig, $Itemid, $mainframe;
    //$session = JFactory::getSession();
    //$session->set('jd_sec_check', 1);
    
    $app = &JFactory::getApplication();
    $user = &JFactory::getUser();
    $user_access = checkAccess_JD();
    $users_access =  (int)substr($user_access, 0, 1);
    
    $database = &JFactory::getDBO();
    // AUP support
    $sum_aup_points = 0;
    $extern_site = false;
    $open_in_blank_page = false;
    $marked_files_id = array();
    $has_licenses = false;
    $must_confirm = false;
    $license_text = '';
    // get file-id from the marked files - when used
    $marked_files_id = JArrayHelper::getValue( $_POST, 'cb_arr', array(0));
    for($i=0,$n=count($marked_files_id);$i<$n;$i++){
        $marked_files_id[$i] = intval($marked_files_id[$i]);
    }
    // get file id
    $fileid = intval(JArrayHelper::getValue( $_REQUEST, 'cid', 0 ));
    // get cat id
    $catid = intval(JArrayHelper::getValue( $_REQUEST, 'catid', 0 ));
    
    // get groups access
    $user_is_in_groups = getUserGroupsX();
    $user_is_in_groups_arr = explode(',', $user_is_in_groups);
    
    // check access for manual url manipulation - fix
    $database->setQuery('SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '.$catid);
    $cat = $database->loadObject();
    $access[0] = (int)substr($cat->cat_access, 0, 1);
    $access[1] = (int)substr($cat->cat_access, 1, 1); 
    
    if ($users_access < $access[1] || !$cat){
        if (!in_array($cat->cat_group_access, $user_is_in_groups_arr)){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            }    
        }    
    }
    
    $breadcrumbs =& $mainframe->getPathWay();
    if ($catid){
        $breadcrumbs = createPathway($catid, $breadcrumbs, $option);
        $breadcrumbs->addItem($cat->cat_title, JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$catid));     
    }
    if ($fileid){
        $database->setQuery("SELECT * FROM #__jdownloads_files WHERE published = 1 AND file_id = '$fileid' AND cat_id = '$catid'");
        if (!$file = $database->loadObject()){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            } 
        }    
        $breadcrumbs->addItem($file->file_title, JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=viewdownload&amp;catid='.$catid.'&amp;cid='.$fileid));
        
    }
    $breadcrumbs->addItem(JText::_('COM_JDOWNLOADS_FRONTEND_HEADER_SUMMARY_TITLE'), '');    
    
    // is mirror file ?
    $is_mirror =  intval(JArrayHelper::getValue( $_REQUEST, 'm', 0 ));
 
    // when exists - no checkbox was used
    if ($fileid){
        $direktlink = true;
        $id_text = $fileid;        
        $filename = JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=finish&amp;cid='.$fileid.'&amp;catid='.$catid.'&amp;m='.$is_mirror);
        if ($file->license && $file->license_agree) $must_confirm = true;
        $download_link = $filename;
        $file_title = ' - '.$file->file_title;       
    }    
        
    // move in text for view the files list
    $anz = 0;
    if (!$id_text){
        $anz = count($marked_files_id);
        if ( $anz > 1 ){
           $id_text = implode(',', $marked_files_id);
        } else {
           $id_text = $marked_files_id[0];
        }
    }

    // get filetitle and release for mail and summary
    $mail_files_arr = array();
    $mail_files = "<div><ul>";
    $database->setQuery("SELECT * FROM #__jdownloads_files WHERE published = 1 AND file_id IN ($id_text) ");
    if (!$mail_files_arr = $database->loadObjectList()){
         // jump to login
         if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
         } 
    }    
    
    if ($jlistConfig['use.alphauserpoints']){
        // get standard points value from AUP
        $database->setQuery("SELECT points FROM #__alpha_userpoints_rules WHERE published = 1 AND plugin_function = 'plgaup_jdownloads_user_download'");
        $aup_default_points = (int)$database->loadResult(); 
    }    
     
    for ($i=0; $i<count($mail_files_arr); $i++) {

       // build sum of aup points
       if ($jlistConfig['use.alphauserpoints']){
          if ($jlistConfig['use.alphauserpoints.with.price.field']){
              $sum_aup_points = $sum_aup_points + (int)$mail_files_arr[$i]->price;
          } else {
              $sum_aup_points += $aup_default_points;
          }    
       }

       // get license name
       if ($mail_files_arr[$i]->license > 0){  
           if ($mail_files_arr[$i]->license && $mail_files_arr[$i]->license_agree) $must_confirm = true;
           $lic = $mail_files_arr[$i]->license;
           $has_licenses = true;
           $database->setQuery("SELECT * FROM #__jdownloads_license WHERE id = '$lic'");
           $license = $database->loadObject(); 
           if ($must_confirm) $license_text = stripslashes($license->license_text);
           if ($license->license_url){
               // add license link
               // a little pic for extern links
               $extern_url_pic = '<img src="'.JURI::base().'components/com_jdownloads/assets/images/link_extern.gif" alt="" />';
               $mail_files .= "<div><li><b>".$mail_files_arr[$i]->file_title.' '.$mail_files_arr[$i]->release.'&nbsp;&nbsp;&nbsp;</b>'.JText::_('COM_JDOWNLOADS_FE_DETAILS_LICENSE_TITLE').': <b><a href="'.$license->license_url.'" target="_blank">'.$license->license_title.'</a> '.$extern_url_pic.' &nbsp;&nbsp;&nbsp;</b>'.JText::_('COM_JDOWNLOADS_FE_DETAILS_FILESIZE_TITLE').': <b>'.$mail_files_arr[$i]->size.'</b></li></div>';
           } else {
               $mail_files .= "<div><li><b>".$mail_files_arr[$i]->file_title.' '.$mail_files_arr[$i]->release.'&nbsp;&nbsp;&nbsp;</b>'.JText::_('COM_JDOWNLOADS_FE_DETAILS_LICENSE_TITLE').': <b>'.$license->license_title.'&nbsp;&nbsp;&nbsp;</b>'.JText::_('COM_JDOWNLOADS_FE_DETAILS_FILESIZE_TITLE').': <b>'.$mail_files_arr[$i]->size.'</b></li></div>';
           }   
       } else {
           $mail_files .= "<div><li><b>".$mail_files_arr[$i]->file_title.' '.$mail_files_arr[$i]->release.'&nbsp;&nbsp;&nbsp;</b>'.JText::_('COM_JDOWNLOADS_FE_DETAILS_FILESIZE_TITLE').': <b>'.$mail_files_arr[$i]->size.'</b></li></div>';
       }     
    }
    $mail_files .= "</ul></div>";
    
    // set flag when link must opened in a new browser window 
    if (!$is_mirror && $i == 1 && $mail_files_arr[0]->extern_site){
        $extern_site = true;    
    }
    if ($is_mirror == 1 && $i == 1 && $mail_files_arr[0]->extern_site_mirror_1){
        $extern_site = true;    
    }
    if ($is_mirror == 2 && $i == 1 && $mail_files_arr[0]->extern_site_mirror_2){
        $extern_site = true;    
    }
    // get file extension  when only one file selected - set flag when link must opened in a new browser window 
    if (count($marked_files_id) == 1 && $mail_files_arr[0]->url_download) {
        $view_types = array();
        $view_types = explode(',', $jlistConfig['file.types.view']);
        $fileextension = strtolower(substr(strrchr($mail_files_arr[0]->url_download,"."),1));
        if (in_array($fileextension, $view_types)){
            $open_in_blank_page = true;
        }
    }
        
    // when mass download with checkboxes
    if (!$direktlink){ 
        // more as one file is selected - zip it in a temp file
        $download_verz = JURI::base().$jlistConfig['files.uploaddir'].'/';
        $zip_verz = JPATH_SITE.'/'.$jlistConfig['files.uploaddir'].'/';
        if (count($marked_files_id) > 1) {
            // build random value for zip filename
            if (empty($user_random_id)){
                $user_random_id = buildRandomID();
            }
            $zip=new ss_zip();
            for ($i=0; $i<count($marked_files_id); $i++) {
                // get file url
                $database->setQuery("SELECT url_download, cat_id, file_title FROM #__jdownloads_files WHERE file_id = '".(int)$marked_files_id[$i]."'");
                $file_data = $database->loadObject();
                $filename = $file_data->url_download;
                $file_title = $file_title.' - '.$file_data->file_title;
                $cat_id = $file_data->cat_id; 
                $database->setQuery("SELECT cat_dir FROM #__jdownloads_cats WHERE cat_id = '$cat_id'");
                $cat_dir = $database->loadResult();
                $cat_dir = $cat_dir.'/'; 
                $zip->add_file($zip_verz.$cat_dir.$filename, $filename);
            }
            $zip->archive(); // return the ZIP
            $zip->save($zip_verz."tempzipfiles/".$jlistConfig['zipfile.prefix'].$user_random_id.".zip");
            $zip_size = fsize($zip_verz."tempzipfiles/".$jlistConfig['zipfile.prefix'].$user_random_id.".zip");
            $zip_file_info = JText::_('COM_JDOWNLOADS_FRONTEND_SUMMARY_ZIP_FILESIZE').': <b>'.$zip_size.'</b>';
            
            // delete older zip files
            $del_ok = deleteOldFile($zip_verz."tempzipfiles/");
            $filename = $download_verz."tempzipfiles/".$jlistConfig['zipfile.prefix'].$user_random_id.".zip";
            $download_link = JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=finish&catid='.$cat_id.'&list='.$id_text.'&amp;user='.$user_random_id); 
        } else {
            // only one file selected
            $database->setQuery("SELECT cat_id, file_title FROM #__jdownloads_files WHERE file_id = '".(int)$marked_files_id[0]."'");
            $cat_id = $database->loadObject();
            $filename = JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=finish&cid='.(int)$marked_files_id[0].'&catid='.$cat_id->cat_id);
            $download_link = $filename;
            $file_title = ' - '.$cat_id->file_title;
        }
    }
    $sum_aup_points = ABS($sum_aup_points);            
    jlist_HTML::Summary($option, $marked_files_id, $mail_files, $filename, $download_link, $del_ok, $extern_site, $sum_aup_points, $has_licenses, $open_in_blank_page, $must_confirm, $license_text, $zip_file_info, $file_title);
}

// finish and start the download
function finish($option){
	global $mainframe, $jlistConfig, $mail_files, $Itemid;
   
   $app = &JFactory::getApplication();
   $user = &JFactory::getUser();
   $coreUserGroups = $user->getAuthorisedGroups();
   $user_access = checkAccess_JD();
   $users_access =  (int)substr($user_access, 0, 1);
   
   
   $database = &JFactory::getDBO();
   $extern = false;
   $extern_site = false;
   $can_download = false;
   $price = '';
    
   // anti lecching
   $url = JURI::base( false );
   list($remove,$stuff2)=split('//',$url,2);
   list($domain,$stuff2)=split('/',$stuff2,2); 
   $domain = str_replace('www.', '', $domain); 
   
   $refr=getenv("HTTP_REFERER");
   list($remove,$stuff)=split('//',$refr,2);
   list($home,$stuff)=split('/',$stuff,2);
   $home = str_replace('www.', '', $home); 
   
   // check leeching
   $blocking = false; 
   if ($home != $domain) {
       $allowed_urls = explode(',' , $jlistConfig['allowed.leeching.sites']);
       if ($jlistConfig['check.leeching']) {
           if ($jlistConfig['block.referer.is.empty']) {
               if (!$refr) {
                   $blocking = true;
               }
           } else {
               if  (!$refr){
                   $blocking = false;
               }    
           }    
           
           if (in_array($home,$allowed_urls)) {
              $blocking = false;
           } else {
             $blocking = true;        
           }  
       } 
   }

   // check blacklist
   if ($jlistConfig['use.blocking.list'] && $jlistConfig['blocking.list'] != '') {
       $user_ip = getRealIp();
       if (stristr($jlistConfig['blocking.list'], $user_ip)){
           $blocking = true;
       }    
   }
  
    if ($blocking) {
        // leeching message
        echo '<div align ="center"><br /><b><font color="red">'.JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE').'</font></b><br /></div>';
        echo '<div align ="center"><br />'.JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE2').'<br /></div>';
    
    } else {
    
    // get file id
    $fileid = intval(JArrayHelper::getValue( $_REQUEST, 'cid', 0 ));
    // get cat id
    $catid = intval(JArrayHelper::getValue( $_REQUEST, 'catid', 0 ));
    
    $is_mirror = intval(JArrayHelper::getValue( $_REQUEST, 'm', 0 ));
    
    // get groups access
    $user_is_in_groups = getUserGroupsX();
    $user_is_in_groups_arr = explode(',', $user_is_in_groups);    
    
    // check access for manually url manipulation - fix
    $database->setQuery('SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '.$catid);
    $cat = $database->loadObject();
    
    $access[0] = (int)substr($cat->cat_access, 0, 1);
    $access[1] = (int)substr($cat->cat_access, 1, 1);
    
    if ($users_access < $access[1] || !$cat){
        if (!in_array($cat->cat_group_access, $user_is_in_groups_arr)){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            }    
        }    
    }

    // set page for the redirect after download button click
    if (!$Itemid){
        $database->setQuery("SELECT id from #__menu WHERE link = 'index.php?option=com_jdownloads&view=viewcategories' and published = 1");
        $Itemid = $database->loadResult();
    }   
    $redirect_to = JRoute::_( "index.php?option=com_jdownloads&Itemid=".$Itemid."&view=viewcategory&catid=".$catid); 
    
    // get AUP user points
    $api_AUP = JPATH_SITE.DS.'components'.DS.'com_alphauserpoints'.DS.'helper.php';
    if (file_exists($api_AUP)){
        require_once ($api_AUP);
        $profil = AlphaUserPointsHelper:: getUserInfo('', $user->id);
    }
    if ($jlistConfig['use.alphauserpoints']){
        // get standard points value from AUP
        $database->setQuery("SELECT points FROM #__alpha_userpoints_rules WHERE published = 1 AND plugin_function = 'plgaup_jdownloads_user_download'");
        $aup_fix_points = (int)$database->loadResult();
        $aup_fix_points = abs($aup_fix_points);
    }    
    
    // files liste holen wenn mhr als ein download markiert
    $files = $database->getEscaped (JRequest::getString('list', '' ));
    $files_arr = explode(',', $files);
    if ($files){
        // sammeldownload
        $user_random_id = intval(JRequest::getString('user', 0 ));
        $download_verz = JPATH_SITE.'/'.$jlistConfig['files.uploaddir'].'/'; 
        $filename = $download_verz.'tempzipfiles/'.$jlistConfig['zipfile.prefix'].$user_random_id.'.zip'; 
        $filename_direct = JURI::base().$jlistConfig['files.uploaddir'].'/tempzipfiles/'.$jlistConfig['zipfile.prefix'].$user_random_id.'.zip';
        // check whether direct access
        $database->setQuery('SELECT file_id, file_title FROM #__jdownloads_files WHERE published = 1 AND file_id IN ('.$files.')');
        if (!$rows = $database->loadObjectList()){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            } 
        }    

        // add AUP points
        if ($jlistConfig['use.alphauserpoints']){
            if ($jlistConfig['use.alphauserpoints.with.price.field']){
                $database->setQuery("SELECT SUM(price) FROM #__jdownloads_files WHERE file_id IN ($files)");
                $sum_points = (int)$database->loadResult();
                if ($profil->points >= $sum_points){
                    foreach($rows as $aup_data){
                        $database->setQuery("SELECT price FROM #__jdownloads_files WHERE file_id = '$aup_data->file_id'");
                        if ($price = (int)$database->loadResult()){
                            $can_download = setAUPPointsDownloads($user->id, $aup_data->file_title, $aup_data->file_id, $price);
                        }
                    }
                }
            
            } else {
                // use fix points
                $sum_points = $aup_fix_points * count($files_arr);
                if ($profil->points >= $sum_points){
                    foreach($rows as $aup_data){
                        $can_download = setAUPPointsDownloads($user->id, $aup_data->file_title, $aup_data->file_id, 0);
                    }
                } else {
                    $can_download = false;
                }    
            }
       
        } else {
            // no AUP active
            $can_download = true;
        }
        if ($jlistConfig['user.can.download.file.when.zero.points'] && $user->id){
            $can_download = true;
        }    
        if (!$can_download){
            $aup_no_points = '<div style="text-align:center" class="jd_div_aup_message">'.stripslashes($jlistConfig['user.message.when.zero.points']).'</div>'. 
            '<div style="text-align:center" class="jd_div_aup_message">'.JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_FE_MESSAGE_NO_DOWNLOAD_POINTS').' '.(int)$profil->points.'<br />'.JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_FE_MESSAGE_NO_DOWNLOAD_NEEDED').' '.JText::_($sum_points).'</div>'.
            '<div style="text-align:left" class="back_button"><a href="javascript:history.go(-1)">'.JText::_('COM_JDOWNLOADS_FRONTEND_BACK_BUTTON').'</a></div>';
            echo $aup_no_points;
        }
        // download limits
        // check the log - can user download the file?
        $may_download = false;
        foreach ($files_arr as $file){
            $may_download = checkLog($file, $user);
        }    
        if (!$may_download){
            // download not possible
            $datenow =& JFactory::getDate(); 
            $date = $datenow->toFormat("%Y-%m-%d %H:%m");
            $back .= '<div style="text-align:left" class="back_button"><a href="javascript:history.go(-1)">'.JText::_('COM_JDOWNLOADS_FRONTEND_BACK_BUTTON').'</a></div>'; 
            echo '<div style="text-align:center" class="jd_limit_reached_message">'.stripslashes($jlistConfig['limited.download.reached.message']).' '.$date.'</div>'.$back;         
        }
        
    } else {
        // einzelner download
        // check whether direct access
        $database->setQuery("SELECT file_title FROM #__jdownloads_files WHERE published = 1 AND file_id = '$fileid' AND cat_id = '$catid'");
        if (!$ok = $database->loadResult()){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            } 
        }    
        
        // download limits
        // check the log - can user download the file?
        $may_download = false;
        $may_download = checkLog($fileid, $user);
        if (!$may_download){
            // download not possible
            $datenow =& JFactory::getDate(); 
            $date = $datenow->toFormat("%Y-%m-%d %H:%m");
            $back .= '<div style="text-align:left" class="back_button"><a href="javascript:history.go(-1)">'.JText::_('COM_JDOWNLOADS_FRONTEND_BACK_BUTTON').'</a></div>'; 
            echo '<div style="text-align:center" class="jd_limit_reached_message">'.stripslashes($jlistConfig['limited.download.reached.message']).' '.$date.'</div>'.$back;         
        } else {        

           // get filename and build path
           if (!$is_mirror){
               $database->setQuery("SELECT url_download FROM #__jdownloads_files WHERE file_id = '".(int)$fileid."'");
               $file_url = $database->loadResult();
               if ($file_url){
                   $database->setQuery("SELECT cat_dir FROM #__jdownloads_cats WHERE cat_id = '".(int)$catid."'");
                   $cat_dir = $database->loadResult();
                   $filename = JPATH_SITE.'/'.$jlistConfig['files.uploaddir'].'/'.$cat_dir.'/'.$file_url;
                   $filename_direct = JURI::base().$jlistConfig['files.uploaddir'].'/'.$cat_dir.'/'.$file_url;        
               } else {
                   $database->setQuery("SELECT * FROM #__jdownloads_files WHERE file_id = '".(int)$fileid."'");
                   $result = $database->loadObjectlist();
                   $filename = $result[0]->extern_file; 
                   if ($result[0]->extern_site){
                       $extern_site = true;
                   }
                   $extern = true;
               }
           } else {
             // is mirror 
             $database->setQuery("SELECT * FROM #__jdownloads_files WHERE file_id = '".(int)$fileid."'");
             $result = $database->loadObjectlist();
             if ($is_mirror == 1){
                 $filename = $result[0]->mirror_1; 
                 if ($result[0]->extern_site_mirror_1){
                     $extern_site = true;
                 }
             } else {
                 $filename = $result[0]->mirror_2; 
                 if ($result[0]->extern_site_mirror_2){
                     $extern_site = true;
                 }
             }
             $extern = true;    
           }      
           // AUP integration
           if ($jlistConfig['use.alphauserpoints.with.price.field'] && $jlistConfig['use.alphauserpoints']){
               $database->setQuery("SELECT price FROM #__jdownloads_files WHERE file_id = '".(int)$fileid."'");
               $price = (int)$database->loadResult();
           } else {
               if ($jlistConfig['use.alphauserpoints']){
                   $price = $aup_fix_points;
               }        
           }    
            
           $can_download = setAUPPointsDownload($user->id, $ok, $fileid, $price);
           if ($jlistConfig['user.can.download.file.when.zero.points'] && $user->id){
               $can_download = true;
           }    
           if (!$can_download){
               // get AUP user data
               $profil = AlphaUserPointsHelper:: getUserInfo ( '', $user->id );
               $aup_no_points = '<div style="text-align:center" class="jd_div_aup_message">'.stripslashes($jlistConfig['user.message.when.zero.points']).'</div>'.
               '<div style="text-align:center" class="jd_div_aup_message">'.JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_FE_MESSAGE_NO_DOWNLOAD_POINTS').' '.(int)$profil->points.'<br />'.JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_FE_MESSAGE_NO_DOWNLOAD_NEEDED').' '.JText::_($price).'</div>'. 
               '<div style="text-align:left" class="back_button"><a href="javascript:history.go(-1)">'.JText::_('COM_JDOWNLOADS_FRONTEND_BACK_BUTTON').'</a></div>';
               echo $aup_no_points;
           } 
        }   
    }    
    // run download
    if ($can_download && $may_download){
        // send mail
        if ($jlistConfig['send.mailto.option'] == '1') {
            if ($fileid){
                sendMail($fileid);  
            } else {
                sendMail($files);               
            }    
        }
        // give uploader AUP points when is set on
        if ($jlistConfig['use.alphauserpoints']){
            setAUPPointsDownloaderToUploader($fileid, $files);  
        }
        
        // update downloads hits
        if ($files){
            $database->setQuery('UPDATE #__jdownloads_files SET downloads=downloads+1 WHERE file_id IN ('.$files.')'); 
            $database->query();    
        } else {
            if ($fileid){
                $database->setQuery("UPDATE #__jdownloads_files SET downloads=downloads+1 WHERE file_id = '".(int)$fileid."'");
                $database->query();
            }    
        }
            
	    // start download
        $x = download($filename, $filename_direct, $extern, $extern_site, $redirect_to);
    }    
    if ($x == 2) {
        // files not exists
        echo '<div align ="center"><br /><b><font color="#990000">'.JText::_('COM_JDOWNLOADS_FRONTEND_FILE_NOT_FOUND_MESSAGE').'</font></b><br /><br /></div>';         
    }
  }    
}

// download starten
function download($file, $filename_direct, $extern, $extern_site, $redirect_to){
     global $jlistConfig, $mainframe;

    $app = &JFactory::getApplication(); 
    
    $view_types = array();
    $view_types = explode(',', $jlistConfig['file.types.view']); 
    clearstatcache(); 
    // existiert file - wenn nicht error
    if (!$extern){
        if (!file_exists($file)) { 
            return 2;
        } else {
            $len = filesize($file);
        }    
    } else {   
         $len = urlfilesize($file); 
    }
    
    // if url go to other website - open it in a new browser window
    if ($extern_site){
        echo "<script>document.location.href='$file';</script>\n";  
        exit;   
    }    
    
    // if set the option for direct link to the file
    if (!$jlistConfig['use.php.script.for.download']){
        if (empty($filename_direct)) {
            $app->redirect($file);
        } else {
            $app->redirect($filename_direct);
        }
    } else {    
        $filename = basename($file);
        $file_extension = strtolower(substr(strrchr($filename,"."),1));
        $ctype = datei_mime($file_extension);
        ob_end_clean();
        // needed for MS IE - otherwise content disposition is not used?
        if (ini_get('zlib.output_compression')){
            ini_set('zlib.output_compression', 'Off');
        }
        
        header("Cache-Control: public, must-revalidate");
        header('Cache-Control: pre-check=0, post-check=0, max-age=0');
        // header("Pragma: no-cache");  // Problems with MS IE
        header("Expires: 0"); 
        header("Content-Description: File Transfer");
        header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
        header("Content-Type: " . $ctype);
        header("Content-Length: ".(string)$len);
        if (!in_array($file_extension, $view_types)){
            header('Content-Disposition: attachment; filename="'.$filename.'"');
        } else {
          // view file in browser
          header('Content-Disposition: inline; filename="'.$filename.'"');
        }   
        header("Content-Transfer-Encoding: binary\n");
        // redirect to category when it is set the time
        if (intval($jlistConfig['redirect.after.download']) > 0){ 
            header( "refresh:".$jlistConfig['redirect.after.download']."; url=".$redirect_to );
        }    
        
        // set_time_limit doesn't work in safe mode
        if (!ini_get('safe_mode')){ 
            @set_time_limit(0);
        }
        @readfile($file);
    }
    exit;
}

function datei_mime($filetype) {
    
    switch ($filetype) {
        case "ez":  $mime="application/andrew-inset"; break;
        case "hqx": $mime="application/mac-binhex40"; break;
        case "cpt": $mime="application/mac-compactpro"; break;
        case "doc": $mime="application/msword"; break;
        case "bin": $mime="application/octet-stream"; break;
        case "dms": $mime="application/octet-stream"; break;
        case "lha": $mime="application/octet-stream"; break;
        case "lzh": $mime="application/octet-stream"; break;
        case "exe": $mime="application/octet-stream"; break;
        case "class": $mime="application/octet-stream"; break;
        case "dll": $mime="application/octet-stream"; break;
        case "oda": $mime="application/oda"; break;
        case "pdf": $mime="application/pdf"; break;
        case "ai":  $mime="application/postscript"; break;
        case "eps": $mime="application/postscript"; break;
        case "ps":  $mime="application/postscript"; break;
        case "xls": $mime="application/vnd.ms-excel"; break;
        case "ppt": $mime="application/vnd.ms-powerpoint"; break;
        case "wbxml": $mime="application/vnd.wap.wbxml"; break;
        case "wmlc": $mime="application/vnd.wap.wmlc"; break;
        case "wmlsc": $mime="application/vnd.wap.wmlscriptc"; break;
        case "vcd": $mime="application/x-cdlink"; break;
        case "pgn": $mime="application/x-chess-pgn"; break;
        case "csh": $mime="application/x-csh"; break;
        case "dvi": $mime="application/x-dvi"; break;
        case "spl": $mime="application/x-futuresplash"; break;
        case "gtar": $mime="application/x-gtar"; break;
        case "hdf": $mime="application/x-hdf"; break;
        case "js":  $mime="application/x-javascript"; break;
        case "nc":  $mime="application/x-netcdf"; break;
        case "cdf": $mime="application/x-netcdf"; break;
        case "swf": $mime="application/x-shockwave-flash"; break;
        case "tar": $mime="application/x-tar"; break;
        case "tcl": $mime="application/x-tcl"; break;
        case "tex": $mime="application/x-tex"; break;
        case "texinfo": $mime="application/x-texinfo"; break;
        case "texi": $mime="application/x-texinfo"; break;
        case "t":   $mime="application/x-troff"; break;
        case "tr":  $mime="application/x-troff"; break;
        case "roff": $mime="application/x-troff"; break;
        case "man": $mime="application/x-troff-man"; break;
        case "me":  $mime="application/x-troff-me"; break;
        case "ms":  $mime="application/x-troff-ms"; break;
        case "ustar": $mime="application/x-ustar"; break;
        case "src": $mime="application/x-wais-source"; break;
        case "zip": $mime="application/x-zip"; break;
        case "au":  $mime="audio/basic"; break;
        case "snd": $mime="audio/basic"; break;
        case "mid": $mime="audio/midi"; break;
        case "midi": $mime="audio/midi"; break;
        case "kar": $mime="audio/midi"; break;
        case "mpga": $mime="audio/mpeg"; break;
        case "mp2": $mime="audio/mpeg"; break;
        case "mp3": $mime="audio/mpeg"; break;
        case "aif": $mime="audio/x-aiff"; break;
        case "aiff": $mime="audio/x-aiff"; break;
        case "aifc": $mime="audio/x-aiff"; break;
        case "m3u": $mime="audio/x-mpegurl"; break;
        case "ram": $mime="audio/x-pn-realaudio"; break;
        case "rm":  $mime="audio/x-pn-realaudio"; break;
        case "rpm": $mime="audio/x-pn-realaudio-plugin"; break;
        case "ra":  $mime="audio/x-realaudio"; break;
        case "wav": $mime="audio/x-wav"; break;
        case "pdb": $mime="chemical/x-pdb"; break;
        case "xyz": $mime="chemical/x-xyz"; break;
        case "bmp": $mime="image/bmp"; break;
        case "gif": $mime="image/gif"; break;
        case "ief": $mime="image/ief"; break;
        case "jpeg": $mime="image/jpeg"; break;
        case "jpg": $mime="image/jpeg"; break;
        case "jpe": $mime="image/jpeg"; break;
        case "png": $mime="image/png"; break;
        case "tiff": $mime="image/tiff"; break;
        case "tif": $mime="image/tiff"; break;
        case "wbmp": $mime="image/vnd.wap.wbmp"; break;
        case "ras": $mime="image/x-cmu-raster"; break;
        case "pnm": $mime="image/x-portable-anymap"; break;
        case "pbm": $mime="image/x-portable-bitmap"; break;
        case "pgm": $mime="image/x-portable-graymap"; break;
        case "ppm": $mime="image/x-portable-pixmap"; break;
        case "rgb": $mime="image/x-rgb"; break;
        case "xbm": $mime="image/x-xbitmap"; break;
        case "xpm": $mime="image/x-xpixmap"; break;
        case "xwd": $mime="image/x-xwindowdump"; break;
        case "msh": $mime="model/mesh"; break;
        case "mesh": $mime="model/mesh"; break;
        case "silo": $mime="model/mesh"; break;
        case "wrl": $mime="model/vrml"; break;
        case "vrml": $mime="model/vrml"; break;
        case "css": $mime="text/css"; break;
        case "asc": $mime="text/plain"; break;
        case "txt": $mime="text/plain"; break;
        case "gpg": $mime="text/plain"; break;
        case "rtx": $mime="text/richtext"; break;
        case "rtf": $mime="text/rtf"; break;
        case "wml": $mime="text/vnd.wap.wml"; break;
        case "wmls": $mime="text/vnd.wap.wmlscript"; break;
        case "etx": $mime="text/x-setext"; break;
        case "xsl": $mime="text/xml"; break;
        case "flv": $mime="video/x-flv"; break;
        case "mpeg": $mime="video/mpeg"; break;
        case "mpg": $mime="video/mpeg"; break;
        case "mpe": $mime="video/mpeg"; break;
        case "qt":  $mime="video/quicktime"; break;
        case "mov": $mime="video/quicktime"; break;
        case "mxu": $mime="video/vnd.mpegurl"; break;
        case "avi": $mime="video/x-msvideo"; break;
        case "movie": $mime="video/x-sgi-movie"; break;
        case "asf": $mime="video/x-ms-asf"; break;
        case "asx": $mime="video/x-ms-asf"; break;
        case "wm":  $mime="video/x-ms-wm"; break;
        case "wmv": $mime="video/x-ms-wmv"; break;
        case "wvx": $mime="video/x-ms-wvx"; break;
        case "ice": $mime="x-conference/x-cooltalk"; break;
        case "rar": $mime="application/x-rar"; break;
        default:    $mime="application/octet-stream"; break; 
    }
    return $mime;
}


// frontend upload form anzeigen
function viewUpload($option, $view){
    global $Itemid, $mainframe;
    $database = &JFactory::getDBO();
  
    // view only when category exist
    $database->SetQuery('SELECT COUNT(*) FROM #__jdownloads_cats WHERE published = 1');
    $cat_sum = $database->loadResult();
    if (!$cat_sum) {
       echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_ERROR_NO_CATS_EXIST');             
       
    } else { 
        $breadcrumbs =& $mainframe->getPathWay();
        $breadcrumbs->addItem(JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PAGE_TITLE'), JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=upload'));
               
		jlist_HTML::viewUpload($option, $view);
    }
}

// show only one category
function showOneCategory($option, $cid) {
    global $mainframe, $limit, $limitstart, $site_aktuell, $jlistConfig, $Itemid, $jlistTemplates;

    JHTML::_('behavior.modal');
    $breadcrumbs =& $mainframe->getPathWay();
    $database = &JFactory::getDBO();
    $app = &JFactory::getApplication();   
    $catid = (int)JRequest::getString('catid', 0);
    $user = &JFactory::getUser();
   
    $access = checkAccess_JD();
    if ($user->id > 0){
        $user_is_in_groups = getUserGroupsX();
    } else {
        $user_is_in_groups = 0;
    }    
    $user_groups = '';   
    if ($user_is_in_groups) $user_groups = "AND cat_group_access IN ($user_is_in_groups)";
    
    // cat laden
	if ($user_is_in_groups){
        $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '$catid' AND ( cat_access <= '$access' OR cat_group_access IN ($user_is_in_groups))");
    } else {
        $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '$catid' AND cat_access <= '$access'");
    }    
    if (!$cat = $database->loadObjectList()){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            } 
    }
	if ($cat[0]->cat_access == '99'){
        // access only for groups and admins
        if (!$user_is_in_groups && !$access == '99'){
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            }      
        }    
        if (!$access == '99'){
            $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '$catid' $user_groups "); 
            if (!$cat = $database->loadObjectList()){
                // jump to login
                if (!$user->id) {
                    $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
                } else {
                    echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                    exit();  
                } 
            }
        }    
    }    

    // actualise pathway 
    $breadcrumbs = createPathway($catid, $breadcrumbs, $option);
    $breadcrumbs->addItem($cat[0]->cat_title, '');
    
    if(empty($cat)){
		$cat[0] = new jlist_cats($database);
		$cat[0]->cat_id = 0;
		$cat[0]->cat_title = JText::_('COM_JDOWNLOADS_FRONTEND_NOCAT');
    } else {
            // load subcats 
            if ($user_is_in_groups) $user_groups = "OR cat_group_access IN ($user_is_in_groups)"; 
            
            // sort order as set in config
            $cat_sort_field = 'ordering';
            $cat_sort = '';
            if ($jlistConfig['cats.order'] == 1) {
                $cat_sort_field = 'cat_title';
            }
            if ($jlistConfig['cats.order'] == 2) {
                $cat_sort_field = 'cat_title';
                $cat_sort = 'DESC';
            }    
            
            $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE parent_id = '$catid' AND published = 1 AND (cat_access <= '$access' $user_groups) ORDER BY $cat_sort_field $cat_sort");
            $subs = $database->loadObjectList();
        
            if ($subs) {
                $sum_subcats = array();
                $sum_subfiles = array();
                
                foreach($subs as $sub){
                    // summe für subcats und files der einzel cat holen
                    $files = 0;
                    $subcats = 0;
                    $database->setQuery("SELECT COUNT(*) FROM #__jdownloads_files WHERE cat_id = '$sub->cat_id' AND published = 1");
                    $sum = $database->loadResult();
                    $files = $files + $sum;
                    infos($sub->cat_id, $subcats, $files, $access, $user_groups);
                    $sum_subfiles[] = $files;
                    $sum_subcats[] = $subcats;
                }         
            }    

        // anzahl files ermitteln
        $database->setQuery("SELECT COUNT(*) FROM #__jdownloads_files WHERE cat_id = '$catid' AND published = 1");
        $total = $database->loadResult();

        if ( $total <= $limit ) {
            $limitstart = 0;
        }
        $sum_pages = ceil($total / $limit);
    
        // manipulation ungültiger werte abblocken
        if ($site_aktuell > $sum_pages || $limitstart > $total || $limitstart < 0){
            $limitstart = 0;
            $site_aktuell = 1; 
        }         

        // create page navigation
        jimport('joomla.html.pagination'); 
        $pageNav = new JPagination( $total, $limitstart, $limit ); 

        // load files in order by config 
        $order = $database->getEscaped(JRequest::getString('order',''));
        $dir   = $database->getEscaped(JRequest::getString('dir', ''));            
        $files = array();
        $files = getSortedFiles($catid, $limitstart, $limit, $order, $dir);
        $dir = $files[dir];
        unset($files['dir']);        
    }

    $columns = (int)$jlistTemplates[1][0]->cols;
     
    jlist_HTML::showOneCategory($option, $cat, $subs, $files, $catid, $total, $sum_pages, $limit, $limitstart, $sum_subcats, $sum_subfiles, $site_aktuell,
                                $access, $columns, $pageNav, $order, $dir);
}                                                                                              

// einzelnen download mit detaillierten infos anzeigen
function showDownload($option,$cid){
   global $mainframe, $jlistConfig, $Itemid;

    //$session = JFactory::getSession();
    //$session->set('jd_sec_check', 1); 

   JHTML::_('behavior.modal'); 
   $database = &JFactory::getDBO();
   $app = &JFactory::getApplication(); 
   $user = &JFactory::getUser();
   $coreUserGroups = $user->getAuthorisedGroups();
   
   $database->setQuery('SELECT * FROM #__jdownloads_files WHERE published = 1 AND file_id = '.(int)$cid);
   if (!$file = $database->loadObject()){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            } 
   } 
   
    $access = checkAccess_JD();
    if ($user->id > 0){
        $user_is_in_groups = getUserGroupsX();
    } else {
        $user_is_in_groups = 0;
    } 
    $user_groups = '';   
    $user_can_edit = false;
    
    if ($user_is_in_groups) $user_groups = "AND cat_group_access IN ($user_is_in_groups)";
    
    // cat laden
    if ($user_is_in_groups){
        $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '$file->cat_id' AND ( cat_access <= '$access' OR cat_group_access IN ($user_is_in_groups))"); 
    } else {   
        $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '$file->cat_id' AND cat_access <= '$access'"); 
    }
    if (!$cat = $database->loadObject()){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            } 
    }
    if ($cat->cat_access == '99' && !$access == '99'){
        // access only for groups
        if (!$user_is_in_groups){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            }      
        }    
        $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '$file->cat_id' $user_groups "); 
        if (!$cat = $database->loadObject()){
            // jump to login
            if (!$user->id) {
                $app->redirect(JRoute::_('index.php?option=com_users&view=login'));
            } else {
                echo "<script> alert('".JText::_('COM_JDOWNLOADS_FRONTEND_ANTILEECH_MESSAGE')."'); window.history.go(-1); </script>\n";
                exit();  
            } 
        }
    }     
   

  // $access = checkAccess_JD();
   $access = array();
   $access[0] = (int)substr($cat->cat_access, 0, 1);
   $access[1] = (int)substr($cat->cat_access, 1, 1);

   // check edit link access                                                                                 
   if ($user->id > 0){
      if (($user->id == $file->submitted_by && $jlistConfig['uploader.can.edit.fe'] == '1') || (in_array(8,$coreUserGroups)) || (in_array(7,$coreUserGroups))){
          $user_can_edit = true;
      } else {   
          $user_can_edit = getUserEditGroup();
      }
   }
         
   if ($user_can_edit){
       $session_data = array('id' => $user->id, 'file_id' => $file->file_id);
       $session = JFactory::getSession();
       $session->set('jd_edit_user', $session_data);
       
       $edit_pic = '<img src="'.JURI::base().'components/com_jdownloads/assets/images/edit.png" title="'.JText::_('COM_JDOWNLOADS_BACKEND_TOOLBAR_EDIT').'" alt="'.JText::_('COM_JDOWNLOADS_BACKEND_TOOLBAR_EDIT').'" />';   
       $edit_link = ' <a href="'.JRoute::_('index.php?option='.$option.'&Itemid='.$Itemid.'&view=edit&cid='.$file->file_id, false).'" rel="nofollow">'.$edit_pic.'</a>';
   } else {
       $edit_link = '';
   }    
   
   $breadcrumbs =& $mainframe->getPathWay();
   $breadcrumbs = createPathway($file->cat_id, $breadcrumbs, $option);
   $breadcrumbs->addItem($cat->cat_title, JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$cat->cat_id, false));
   $breadcrumbs->addItem($file->file_title, '' ); 
   
   jlist_HTML::showDownload($option, $file, $cat, $access, $edit_link, $user_can_edit);   
}  
// show only categories
function showCats($option,$cid){
	global $jlistConfig, $limit, $limitstart, $site_aktuell, $mainframe, $jlistTemplates;
    
    $user = &JFactory::getUser();
    JHTML::_('behavior.modal');
    $limit = intval($jlistConfig['categories.per.side']);
    $database = &JFactory::getDBO(); 
	$breadcrumbs = $mainframe->getPathWay();
    // access
    $access = checkAccess_JD();
    // get groups access
    if ($user->id > 0){
        $user_is_in_groups = getUserGroupsX();
    } else {
        $user_is_in_groups = 0;
    } 
    
    if(is_array($cid)) $cid = 0;
	$parent_id = (int)JArrayHelper::getValue($_REQUEST,'parent_id',0);
	$where = '';
    $user_groups = '';
	
    if($cid) $where = ' AND cat_id='.$cid;
    if ($user_is_in_groups) $user_groups = "OR cat_group_access IN ($user_is_in_groups)"; 
	$database->SetQuery( "SELECT count(*)"
						. "\nFROM #__jdownloads_cats "
						. "\nWHERE published = 1 AND parent_id = 0 AND (cat_access <= '$access' $user_groups)"
						);
  	$total = $database->loadResult();
    if ( $total <= $limit ) {
        $limitstart = 0;
    }
  	$sum_pages = ceil($total / $limit);
    
    // manipulation ungültiger werte abblocken
    if ($site_aktuell > $sum_pages || $limitstart > $total || $limitstart < 0){
       $limitstart = 0;
       $site_aktuell = 1; 
    } 
    
    // reihenfolge wie in optionen gesetzt
    $cat_sort_field = 'ordering';
    $cat_sort = '';
    if ($jlistConfig['cats.order'] == 1) {
        $cat_sort_field = 'cat_title';
    }
    if ($jlistConfig['cats.order'] == 2) {
        $cat_sort_field = 'cat_title';
        $cat_sort = 'DESC';
    }    

    $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published = 1".$where." AND parent_id = 0 AND (cat_access <= '$access' $user_groups) ORDER BY $cat_sort_field $cat_sort LIMIT $limitstart, $limit");
    $cats = $database->loadObjectList();

    // create pgae navigation
    jimport('joomla.html.pagination'); 
    $pageNav = new JPagination( $total, $limitstart, $limit ); 

	if(empty($cats)){
		$cats[0] = new jlist_cats($database);
		$cats[0]->cat_id = 0;
		$cats[0]->cat_title = JText::_('COM_JDOWNLOADS_FRONTEND_NOCAT');
        $no_cats = true;
	} else {
        // gesamt download infos holen...
        $no_cats = false;
        $catlist = array();
        $query = "SELECT cat_id AS id, parent_id AS parent, cat_title AS name FROM #__jdownloads_cats WHERE published = 1 AND (cat_access <= '$access' $user_groups)";
        $database->setQuery( $query );
        $catlist = $database->loadObjectList();
        
        // gesamtanzahl cats inkl. subcats 
        $sum_all_cats = count($catlist);
         
        $sub_cats = array();
        $sub_files = array();  
        
        // summe für subcats und files der einzel cat holen
        foreach($cats as $cat){
            $files = 0;
            $subcats = 0;
            $database->setQuery("SELECT COUNT(*) FROM #__jdownloads_files WHERE published = 1 AND cat_id = '$cat->cat_id'");
            $sum = $database->loadResult();
            $files = $files + $sum;
            infos($cat->cat_id, $subcats, $files, $access, $user_groups);
            $sub_files[] = $files;
            $sub_cats[] = $subcats;
        }    
    } 
    $columns = (int)$jlistTemplates[1][0]->cols;
    if ($columns > 1 && strpos($jlistTemplates[1][0]->template_text, '{cat_title1}')){   
 	    jlist_HTML::showCatswithColumns($option, $cats, $total, $sum_pages, $limit, $limitstart, $site_aktuell, $sub_cats, $sub_files, $sum_all_cats, $columns, $no_cats, $pageNav);
    } else {   
        jlist_HTML::showCats($option, $cats, $total, $sum_pages, $limit, $limitstart, $site_aktuell, $sub_cats, $sub_files, $sum_all_cats, $no_cats, $pageNav);
    }    
}

function showSearchForm($option,$cid){
    global $mainframe;
    
   $breadcrumbs =& $mainframe->getPathWay();
   $breadcrumbs->addItem(JText::_('COM_JDOWNLOADS_FRONTEND_SEARCH_TITLE'), JRoute::_('index.php?option='.$option));
    
    jlist_HTML::showSearchForm($option);
}    
            
function showSearchResult($option,$cid){
   global $mainframe, $Itemid;
                                                                                                      
   $breadcrumbs =& $mainframe->getPathWay();
   $breadcrumbs->addItem(JText::_('COM_JDOWNLOADS_FRONTEND_SEARCH_TITLE'), JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=search'));
   $breadcrumbs->addItem(JText::_('COM_JDOWNLOADS_FRONTEND_SEARCH_RESULT_TITLE'),'');
    
    jlist_HTML::showSearchResult($option);
}

/**
 * send mail to admin if config set
 */
function sendMail($files){
    global $jlistConfig;
    
    $user = &JFactory::getUser();
    $database = &JFactory::getDBO();
    $config =& JFactory::getConfig();
    $mailfrom = $config->getValue( 'mailfrom' );
    $mailfromname = $config->getValue( 'fromname' );
    
    // get filetitle and release for mail and summary
    $mail_files_arr = array();
    $mail_files = "<div><ul>";
    $database->setQuery("SELECT * FROM #__jdownloads_files WHERE file_id IN ($files) ");
    $mail_files_arr = $database->loadObjectList();
    
    for ($i=0; $i<count($mail_files_arr); $i++) {
       if ($mail_files_arr[$i]->license > 0){
           // get license name
           $lic = $mail_files_arr[$i]->license;
           $database->setQuery("SELECT license_title FROM #__jdownloads_license WHERE id = '$lic'");
           $lic_title = $database->loadResult(); 
           $mail_files .= "<div><li>".$mail_files_arr[$i]->file_title.' '.$mail_files_arr[$i]->release.'&nbsp;&nbsp;&nbsp;'.JText::_('COM_JDOWNLOADS_FE_DETAILS_LICENSE_TITLE').': '.$lic_title.'&nbsp;&nbsp;&nbsp;'.JText::_('COM_JDOWNLOADS_FE_DETAILS_FILESIZE_TITLE').': '.$mail_files_arr[$i]->size.'</li></div>';
       } else {
           $mail_files .= "<div><li>".$mail_files_arr[$i]->file_title.' '.$mail_files_arr[$i]->release.'&nbsp;&nbsp;&nbsp;'.JText::_('COM_JDOWNLOADS_FE_DETAILS_FILESIZE_TITLE').': '.$mail_files_arr[$i]->size.'</li></div>';
       }  
    }
    $mail_files .= "</ul></div>";
 
    // get IP
    $ip = getRealIp();

    // date and time
    $timestamp = time();
    $date_time = date($jlistConfig['global.datetime'], $timestamp);

    $user_downloads = '<br />';

    // get user
    if ($user->get('id') == 0) {
       $user_name = JText::_('COM_JDOWNLOADS_MAIL_DOWNLOADER_NAME_VISITOR');
       $user_group = JText::_('COM_JDOWNLOADS_MAIL_DOWNLOADER_GROUP');
    } else {
       $user_name = $user->get('username');
       //$user_group = $user->get('usertype');
       $user_email = $user->get('email');
    }

    $jlistConfig['send.mailto'] = str_replace(' ', '', $jlistConfig['send.mailto']);
    $empfaenger = explode(';', $jlistConfig['send.mailto']);
    $betreff = $jlistConfig['send.mailto.betreff'];
    $html_format = true;

    $text = "";
    $text = stripslashes($jlistConfig['send.mailto.template.download']);
    $text = str_replace('{file_list}', $mail_files, $text);
    $text = str_replace('{ip_address}', $ip, $text);
    $text = str_replace('{user_name}', $user_name, $text);
    $text = str_replace('{user_group}', $user_group, $text);
    $text = str_replace('{date_time}', $date_time, $text);
    $text = str_replace('{user_email}', $user_email, $text);
    if (!$jlistConfig['send.mailto.html']){
        $html_format = false;
        $text = strip_tags($text);
    }
    $first_adress = array_shift($empfaenger);
    $success = JUtility::sendMail($mailfrom, $mailfromname, $first_adress, $betreff, $text, $html_format, null, $empfaenger);
}    

function sendMailUploads($name, $mail, $url_download, $filetitle, $description){
    global $jlistConfig;

    $config =& JFactory::getConfig();
    $mailfrom = $config->getValue( 'mailfrom' );
    $mailfromname = $config->getValue( 'fromname' );

    $database = &JFactory::getDBO(); 
    // get IP
    $ip = getRealIp();
    // date and time
    $timestamp = time();
    $date_time = date($jlistConfig['global.datetime'], $timestamp);

    $jlistConfig['send.mailto.upload'] = str_replace(' ', '', $jlistConfig['send.mailto.upload']);
    $empfaenger = explode(';', $jlistConfig['send.mailto.upload']);
    $betreff = $jlistConfig['send.mailto.betreff.upload'];
    $html_format = true;

    $text = "";
    $text = stripslashes($jlistConfig['send.mailto.template.upload']);
    $text = str_replace('{name}', $name, $text);
    $text = str_replace('{ip}', $ip, $text);
    $text = str_replace('{mail}', $mail, $text);
    $text = str_replace('{file_title}', $filetitle, $text);
    $text = str_replace('{file_name}', $url_download, $text);
    $text = str_replace('{date}', $date_time, $text);
    $text = str_replace('{description}', $description, $text);
    if (!$jlistConfig['send.mailto.html.upload']){
        $html_format = false;
        $text = strip_tags($text);
    }
    $first_adress = array_shift($empfaenger);
    $success = JUtility::sendMail($mailfrom, $mailfromname, $first_adress, $betreff, $text, $html_format, null, $empfaenger);
}      

/**
 * Builds configuration variable
 * @return jlistConfig
 */
function buildjlistConfig(){
	$database = &JFactory::getDBO();

	$jlistConfig = array();
	$database->setQuery("SELECT id, setting_name, setting_value FROM #__jdownloads_config");
	$jlistConfigObj = $database->loadObjectList();
	if(!empty($jlistConfigObj)){
		foreach ($jlistConfigObj as $jlistConfigRow){
			$jlistConfig[$jlistConfigRow->setting_name] = $jlistConfigRow->setting_value;
		}
	}
	return $jlistConfig;
}

/**
 * Build random downloader User-ID
 */
function buildRandomID(){
   mt_srand((double)microtime()*1000000);
   mt_getrandmax();
   $random_id = mt_rand();
   return $random_id;
}

/* Alle Dateien in "tempzipfiles" löschen
/  die älter als der in config angegebenen zeit sind
*/

function deleteOldFile($dir){
	global $jlistConfig;
    jimport('joomla.filesystem.file');
	
   $del_ok = false;
   $time = gettimeofday();
   foreach (glob($dir."*.*") as $datei) {
      if ( $time[sec] - date(filemtime($datei)) >= ($jlistConfig['tempfile.delete.time'] * 60) )
           $del_ok = JFile::delete($datei);
      }
    return $del_ok;
}

// Get active templates text
// @return jlistTemplates

function getTemplates(){
	$database = &JFactory::getDBO();

    $templates_values = array();

    for ($i=1;$i<6;$i++) {
	   $database->setQuery("SELECT * FROM #__jdownloads_templates WHERE template_typ = '$i' AND template_active = 1");
       $templates_values[$i] = $database->loadObjectList();
       // ist leer, kein layout aktiviert. versuchen standard zu aktivieren, sonst meldung
       if (empty($templates_values[$i])){
           $database->setQuery("SELECT id FROM #__jdownloads_templates WHERE template_typ = '$i' AND locked = 1");
           $id = $database->loadResultArray(0);
           if ($id){
                $database->setQuery("UPDATE #__jdownloads_templates SET template_active = 1 WHERE id = $id[0]");
                $result = $database->query();
                $database->setQuery("SELECT * FROM #__jdownloads_templates WHERE template_typ = '$i' AND template_active = 1");
                $templates_values[$i] = $database->loadObjectList();
           }
       }    
    }
    return $templates_values;
}

// get files in sortorder (see config)
function getSortedFiles($catid, $limitstart, $limit, $order, $dir) {
    global $jlistConfig;
    $database = &JFactory::getDBO();

  if (!$order || $order == 'default'){   
    switch ($jlistConfig['files.order']) {
    case '0':
        if (!$dir) $dir = 'asc';
        $database->setQuery("SELECT * FROM #__jdownloads_files WHERE cat_id = '$catid' AND published = 1 ORDER BY ordering ".$dir." LIMIT $limitstart, $limit");
        break;

    case '1':
        if (!$dir) $dir = 'desc';
        $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.date_added ".$dir." LIMIT $limitstart, $limit");
        break;

    case '2':
        if (!$dir) $dir = 'asc';
        $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.date_added ".$dir." LIMIT $limitstart, $limit");
        break;

    case '3':
        if (!$dir) $dir = 'asc';
        $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.file_title ".$dir." LIMIT $limitstart, $limit");
        break;

    case '4':
        if (!$dir) $dir = 'desc';
        $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.file_title ".$dir." LIMIT $limitstart, $limit");
        break;
    
    case '5':
        if (!$dir) $dir = 'desc';
        $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.update_active ".$dir.", a.modified_date ".$dir.", a.date_added ".$dir." LIMIT $limitstart, $limit");
        break;
    }
  } else {
      if ($order == 'name'){ 
          $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.file_title ".$dir." LIMIT $limitstart, $limit");
      } 
      if ($order == 'date'){ 
          $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.date_added ".$dir." LIMIT $limitstart, $limit");
      }
      if ($order == 'hits'){ 
          $database->setQuery("SELECT a.* FROM #__jdownloads_files AS a WHERE a.cat_id = '$catid' AND a.published = 1 ORDER BY a.downloads ".$dir." LIMIT $limitstart, $limit");
      }       
  }  
    $files = $database->loadObjectList();
    $files[dir] = $dir;
    return $files;
}

function fsize($file) {
        $a = array("B", "KB", "MB", "GB", "TB", "PB");

        $pos = 0;
        $size = filesize($file);
        while ($size >= 1024) {
                $size /= 1024;
                $pos++;
        }

        return round($size,2)." ".$a[$pos];
}

// build comp header
function makeHeader($header, $compo_text, $is_showcats, $is_one_cat, $sum_subs, $is_detail, $is_search, $is_upload, $is_summary,  $is_finish, $sum_pages, $limit, $total, $limitstart, $site_aktuell, $pageNav, $order, $dir) {
	global $jlistConfig, $jlistTemplates, $Itemid, $page_title, $cat_link_itemids, $upload_link_itemid, $search_link_itemid, $root_itemid;
    
	$user = &JFactory::getUser();
    $aid = max ($user->getAuthorisedViewLevels()); 
	$database = &JFactory::getDBO();

    // set correct link IDs
    if (!$upload_link_itemid) $upload_link_itemid = $root_itemid;
    if (!$search_link_itemid) $search_link_itemid = $root_itemid;
   
    // Anzeige 1 von 0 verhindern
    if ($sum_pages == 0){
        $sum_pages = 1;
    }    
    
    // get templates for header
    if ($is_summary){
        $header = $jlistTemplates[3][0]->template_header_text;
        $subheader = $jlistTemplates[3][0]->template_subheader_text;
    } elseif ($is_detail || $is_search || $is_upload){
        $header = $jlistTemplates[5][0]->template_header_text;
        if (!$is_search && !$is_upload){
            $subheader = $jlistTemplates[5][0]->template_subheader_text;        
        }    
    } elseif ($is_one_cat){
        $header = $jlistTemplates[2][0]->template_header_text;
        $subheader = $jlistTemplates[2][0]->template_subheader_text;
    } else {
        // show all cats / overview
        $header = $jlistTemplates[1][0]->template_header_text;
        $subheader = $jlistTemplates[1][0]->template_subheader_text;
    }        
    
	// compo title
    $header = str_replace('{component_title}',$page_title, $header);
    
	// components description
	if ($compo_text && $jlistConfig['downloads.titletext'] != '') {
        $header_text = stripslashes($jlistConfig['downloads.titletext']);
		if ($jlistConfig['google.adsense.active'] && $jlistConfig['google.adsense.code'] != ''){
            $header_text = str_replace( '{google_adsense}', stripslashes($jlistConfig['google.adsense.code']), $header_text);
        } else {
            $header_text = str_replace( '{google_adsense}', '', $header_text);
        }   
        $header .= $header_text;
	}	

    // home link
    $home_link = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$root_itemid).'">'.'<img src="'.JURI::base().'components/com_jdownloads/assets/images/home_fe.png" width="32" height="32" border="0" alt="" /></a> <a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$root_itemid).'">'.JText::_('COM_JDOWNLOADS_FRONTEND_HOME_LINKTEXT').'</a>';
    // insert search link
    $search_link = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$search_link_itemid.'&amp;view=search').'">'.'<img src="'.JURI::base().'components/com_jdownloads/assets/images/search.png" width="32" height="32" border="0" alt="" /></a> <a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$search_link_itemid.'&amp;view=search').'">'.JText::_('COM_JDOWNLOADS_FRONTEND_SEARCH_LINKTEXT').'</a>';
    // insert frontend upload link if active
    $upload_link = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$upload_link_itemid.'&amp;view=upload').'">'.'<img src="'.JURI::base().'components/com_jdownloads/assets/images/upload.png" width="32" height="32" border="0" alt="" /></a> <a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$upload_link_itemid.'&amp;view=upload').'">'.JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_LINKTEXT').'</a>';

    $header = str_replace('{home_link}', $home_link, $header);
    $header = str_replace('{search_link}', $search_link, $header);
    if ($jlistConfig['frontend.upload.active']) {
        $header = str_replace('{upload_link}', $upload_link, $header);
    } else {
        $header = str_replace('{upload_link}', '', $header);
    }    
    // create upper link
    $catid = intval(JArrayHelper::getValue($_REQUEST, 'catid', 0));
    // exists a single category menu link for it? 
    if ($cat_link_itemids){  
        $cat_itemid = '';
        for ($i2=0; $i2 < count($cat_link_itemids); $i2++) {
             if ($cat_link_itemids[$i2][catid] == $catid){
                 $cat_itemid = $cat_link_itemids[$i2][id];
             }     
        }
    }   
    if (!$cat_itemid){
        // use global itemid when no single link exists
        $cat_itemid = $Itemid;
    }
    
    
    if ($is_detail){
            $upper_url = JRoute::_("index.php?option=com_jdownloads&Itemid=".$cat_itemid."&view=viewcategory&catid=".$catid);
            $header = str_replace('{upper_link}', '<a href="'.$upper_url.'">'.'<img src="'.JURI::base().'components/com_jdownloads/assets/images/upper.png" width="32" height="32" border="0" alt="" /></a> <a href="'.$upper_url.'">'.JText::_('COM_JDOWNLOADS_FRONTEND_HEADER_UPPER_LINKTEXT').'</a>', $header);
    } else {   
        $database->setQuery("SELECT parent_id FROM #__jdownloads_cats WHERE cat_id = '$catid'");
        $parent_cat_id = $database->loadResult();
        if ($parent_cat_id){
            if ($cat_link_itemids){  
                $cat_itemid = '';
                for ($i2=0; $i2 < count($cat_link_itemids); $i2++) {
                    if ($cat_link_itemids[$i2][catid] == $parent_cat_id){
                        $cat_itemid = $cat_link_itemids[$i2][id];
                    }     
                }
            }   
            if (!$cat_itemid){
                // use global itemid when no single link exists
                $cat_itemid = $Itemid;
            }
            $upper_url = JRoute::_("index.php?option=com_jdownloads&Itemid=".$cat_itemid."&view=viewcategory&catid=".$parent_cat_id);
            $header = str_replace('{upper_link}', '<a href="'.$upper_url.'">'.'<img src="'.JURI::base().'components/com_jdownloads/assets/images/upper.png" width="32" height="32" border="0" alt="" /></a> <a href="'.$upper_url.'">'.JText::_('COM_JDOWNLOADS_FRONTEND_HEADER_UPPER_LINKTEXT').'</a>', $header);
        } else {
            if ($is_one_cat){
                $upper_url = JRoute::_("index.php?option=com_jdownloads&Itemid=".$root_itemid."&view=viewcategories");
                $header = str_replace('{upper_link}', '<a href="'.$upper_url.'">'.'<img src="'.JURI::base().'components/com_jdownloads/assets/images/upper.png" width="32" height="32" border="0" alt="" /></a> <a href="'.$upper_url.'">'.JText::_('COM_JDOWNLOADS_FRONTEND_HEADER_UPPER_LINKTEXT').'</a>', $header);
            } else {
              $header = str_replace('{upper_link}', '', $header);
            }  
        }    
    }
    
    // create category listbox and viewed it when it is activated in configuration
    if ($jlistConfig['show.header.catlist']){
        $catlistid = intval(JArrayHelper::getValue($_REQUEST, 'catid', 0));
		$access = checkAccess_JD();
        // get groups access
        if ($user->id > 0){
            $user_is_in_groups = getUserGroupsX();
        } else {
            $user_is_in_groups = 0;
        } 
        
        $user_groups = '';
        if ($user_is_in_groups) $user_groups = "OR cat_group_access IN ($user_is_in_groups)";
        
        $src_list = array();
        $root_url = '';
        $url = array();
        // reihenfolge wie in optionen gesetzt
        $cat_sort_field = 'ordering';
        $cat_sort = '';
        if ($jlistConfig['cats.order'] == 1) {
            $cat_sort_field = 'cat_title';
        }
        if ($jlistConfig['cats.order'] == 2) {
            $cat_sort_field = 'cat_title';
            $cat_sort = 'DESC';
        }   
		$query = "SELECT cat_id AS id, parent_id AS parent, cat_title AS title FROM #__jdownloads_cats WHERE published = 1 AND (cat_access <= '$access' $user_groups) ORDER BY $cat_sort_field $cat_sort";
		$database->setQuery( $query );
		$src_list = $database->loadObjectList();
        $query = "SELECT cat_id AS id, parent_id AS parent, cat_title AS title FROM #__jdownloads_cats WHERE published = 1 AND (cat_access <= '$access' $user_groups) ORDER BY cat_id";
        $database->setQuery( $query );
        $src_for_url_list = $database->loadObjectList();
        $max_cat_id = $src_for_url_list[count($src_for_url_list)-1]->id;
        $x = 0;
        // create array with all sef url's for listbox
        for ($i=0; $i < $max_cat_id; $i++){ 
            if ($src_for_url_list[$x]->id == ($i+1)){
                // exists a single category menu link for it? 
                if ($cat_link_itemids){  
                    $cat_itemid = '';
                    for ($i2=0; $i2 < count($cat_link_itemids); $i2++) {
                         if ($cat_link_itemids[$i2][catid] == $src_for_url_list[$x]->id){
                             $cat_itemid = $cat_link_itemids[$i2][id];
                         }     
                    }
                }    
                if (!$cat_itemid){
                    // use global itemid when no single link exists
                    $cat_itemid = $root_itemid;
                }                
                
                $url[$src_for_url_list[$x]->id] = JRoute::_("index.php?option=com_jdownloads&Itemid=".$cat_itemid."&view=viewcategory&catid=".$src_for_url_list[$x]->id);
                $x++;
            } else {
                $url[$i+1] = 'null';                        
            }    
        }
        $url = implode(',',$url);
        $root_url = JRoute::_("index.php?option=com_jdownloads&Itemid=".$root_itemid);    
		$preload = array();
		$preload[] = JHTML::_('select.option', '0', JText::_('COM_JDOWNLOADS_FRONTEND_HEADER_CATLIST_TITLE') );
		$selected = array();
		$selected[] = JHTML::_('select.option', $catlistid );
    	// TODO: treeSelectList must changed with makeoption and selectlist
        $cat_listbox = treeSelectList( $src_list, 0, $preload, 'cat_list',
                 'class="inputbox" size="1" onchange="gocat(\''.$root_url.'\',\''.$url.'\')"', 'value', 'text', $selected );
		$header = str_replace('{category_listbox}', '<form name="go_cat" id="go_cat" action="" method="post">'.$cat_listbox.'</form>', $header);         
    } else {
        $header = str_replace('{category_listbox}', '', $header);         
    }
    
    // Subheader !!
    if ($jlistConfig['view.subheader']) {
        if ($is_showcats) {
           if ($jlistConfig['option.navigate.top']){
                $page_navi_links   = $pageNav->getPagesLinks(); 
                if ($page_navi_links){
                    $page_navi_pages   = $pageNav->getPagesCounter();
                    $page_navi_counter = $pageNav->getResultsCounter(); 
                    $page_limit_box    = $pageNav->getLimitBox();  
                }   
                $subheader = str_replace('{subheader_title}', JText::_('COM_JDOWNLOADS_FRONTEND_SUBTITLE_OVER_CATLIST'), $subheader);
                $subheader = str_replace('{page_navigation}', $page_navi_links, $subheader);
                $subheader = str_replace('{page_navigation_results_counter}', $page_navi_counter, $subheader);
                $subheader = str_replace('{page_navigation_pages_counter}', $page_navi_pages, $subheader);
                $subheader = str_replace('{count_of_sub_categories}', JText::_('COM_JDOWNLOADS_FRONTEND_SUBHEADER_NUMBER_OF_CATS_TITLE').': '.$total, $subheader);
           } else {
                $subheader = str_replace('{subheader_title}', JText::_('COM_JDOWNLOADS_FRONTEND_SUBTITLE_OVER_CATLIST'), $subheader);
                $subheader = str_replace('{page_navigation}', '', $subheader);
                $subheader = str_replace('{page_navigation_results_counter}', '', $subheader);
                $subheader = str_replace('{page_navigation_pages_counter}', '', $subheader);                
                $subheader = str_replace('{count_of_sub_categories}', JText::_('COM_JDOWNLOADS_FRONTEND_SUBHEADER_NUMBER_OF_CATS_TITLE').': '.$total, $subheader);
           }
        }
        
        if ($is_one_cat) {
            $catid = intval(JArrayHelper::getValue($_REQUEST, 'catid', 0));
            $database->setQuery("SELECT cat_title, cat_id, parent_id FROM #__jdownloads_cats WHERE cat_id = '$catid'");
            $title = $database->loadObject();
            // if ($title->parent_id){
                // $titles = getParentsCatsTitles($title->parent_id).' / '.$title->cat_title;
            // } else {
                $titles = $title->cat_title;
            // } 
            
            // summe subcats nur anzeigen wenn vorhanden
            if ($sum_subs == 0){
                $einf ='';
            } else {
                $einf = JText::_('COM_JDOWNLOADS_FRONTEND_SUBHEADER_NUMBER_OF_SUBCATS_TITLE').': '.$sum_subs;
            }

           if ($jlistConfig['option.navigate.top']){
                $page_navi_links   = $pageNav->getPagesLinks(); 
                if ($page_navi_links){
                    $page_navi_pages   = $pageNav->getPagesCounter();
                    $page_navi_counter = $pageNav->getResultsCounter(); 
                    $page_limit_box    = $pageNav->getLimitBox();  
                }    
                $subheader = str_replace('{subheader_title}', JText::_('COM_JDOWNLOADS_FRONTEND_SUBTITLE_OVER_ONE_CAT').': '.$titles, $subheader);
                $subheader = str_replace('{page_navigation}', $page_navi_links, $subheader);
                $subheader = str_replace('{page_navigation_results_counter}', $page_navi_counter, $subheader);
                $subheader = str_replace('{page_navigation_pages_counter}', $page_navi_pages, $subheader);                
                $subheader = str_replace('{count_of_sub_categories}', $einf, $subheader);                
           } else {
                $subheader = str_replace('{subheader_title}', JText::_('COM_JDOWNLOADS_FRONTEND_SUBTITLE_OVER_ONE_CAT').': '.$titles, $subheader);
                $subheader = str_replace('{page_navigation}', '', $subheader);
                $subheader = str_replace('{page_navigation_results_counter}', '', $subheader);
                $subheader = str_replace('{page_navigation_pages_counter}', '', $subheader);                
                $subheader = str_replace('{count_of_sub_categories}', $einf, $subheader);                
           }
           
           // create sort order bar
           if ($jlistConfig['view.sort.order'] && $total > 1){
               if($order == 'default' || $order == ''){
                   $sort_default = JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_DEFAULT').' | ';
               } else {
                   $sort_default = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$catid.'&amp;limitstart='.$limitstart.'&amp;order=default&amp;dir=asc').'">'.JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_DEFAULT').'</a> | ';                   
               }
               if($order != 'name'){
                  $sort_name = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$catid.'&amp;limitstart='.$limitstart.'&amp;order=name&amp;dir=asc').'">'.JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_NAME').'</a> | ';
               } else {
                  $sort_name = JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_NAME').' | ';
               }   
               if($order != 'date'){
                   $sort_date = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$catid.'&amp;limitstart='.$limitstart.'&amp;order=date&amp;dir=asc').'">'.JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_DATE').'</a> | ';
               } else {
                  $sort_date = JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_DATE').' | ';
               }   
               if($order != 'hits'){
                   $sort_hits = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$catid.'&amp;limitstart='.$limitstart.'&amp;order=hits&amp;dir=asc').'">'.JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_HITS').'</a> | ';
               } else {
                  $sort_hits = JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_HITS').' | ';
               }
                    
               if ($dir == 'asc' || $dir == ''){
                   $sort_direction = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$catid.'&amp;limitstart='.$limitstart.'&amp;order='.$order.'&amp;dir=desc').'">['.JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_DESC').'</a>]';
               } else{
                   $sort_direction = '<a href="'.JRoute::_('index.php?option=com_jdownloads&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$catid.'&amp;limitstart='.$limitstart.'&amp;order='.$order.'&amp;dir=asc').'">['.JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_ASC').'</a>]';
               }    
               $order_bar = JText::_('COM_JDOWNLOADS_FE_SORT_ORDER_TITLE').' '.$sort_default.$sort_name.$sort_date.$sort_hits.' '.$sort_direction;
               $subheader = str_replace('{sort_order}', $order_bar, $subheader);
           } else {   
               $subheader = str_replace('{sort_order}', '', $subheader);          
           }    
          
        }    
    }    
    // remove this placeholder when it is used not for files layout
    $subheader = str_replace('{sort_order}', '', $subheader); 
    $header .= $subheader;
    
    if ($is_detail) {
        $header = str_replace('{detail_title}', JText::_('COM_JDOWNLOADS_FRONTEND_SUBTITLE_OVER_DETAIL'), $header); 
    }                

    if ($is_search) {
        $header .= '<table class="jd_cat_subheader" width="100%"><tr><td><b> '.JText::_('COM_JDOWNLOADS_FRONTEND_SEARCH_LINKTEXT').' </b></td><td width="30%" align="right"> </td></tr></table>'; 
    }
        
    if ($is_upload) {
        $header .= '<table class="jd_cat_subheader" width="100%"><tr><td><b> '.JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PAGE_TITLE').' </b></td><td width="30%" align="right"> </td></tr></table>'; 
    }        
        
    if ($is_summary) {
        $header = str_replace('{summary_title}', JText::_('COM_JDOWNLOADS_FRONTEND_HEADER_SUMMARY_TITLE'), $header); 
    }         
        
    if ($is_finish) {
        $header .= '<table class="jd_cat_subheader" width="100%"><tr><td> '.JText::_('COM_JDOWNLOADS_FRONTEND_HEADER_FINISH_TITLE').' </td><td width="30%" align="right"> </td></tr></table>'; 
    }
        
    if ( !$jlistConfig['offline'] ) {
            return $header;
        } else {
            if ($aid == 3) {
                return $header;     
            } else {
                $header = '<div class="componentheading">'.$jlistConfig['jd.header.title'].'</div>';
                // components description
                if ($compo_text && $jlistConfig['downloads.titletext'] != '') {
                    $header .= $jlistConfig['downloads.titletext'];
                }
                return $header;    
            }
        }             
}

// build comp footer
function makeFooter($make_back_button, $is_showcats, $is_one_cat, $sum_pages, $limit, $limitstart, $site_aktuell, $pageNav, $is_summary, $is_detail) {
    global $Itemid, $jlistConfig, $jlistTemplates;
    $database = &JFactory::getDBO();
    $config =& JFactory::getConfig();
    $secret = $config->getValue( 'secret' );
    
	
    // get templates for footer
    if ($is_summary){
        $footer = $jlistTemplates[3][0]->template_footer_text;
    } elseif ($is_detail){
        $footer = $jlistTemplates[5][0]->template_footer_text;
    } elseif ($is_one_cat){
        $footer = $jlistTemplates[2][0]->template_footer_text;
    } else {
        // show all cats / overview
        $footer = $jlistTemplates[1][0]->template_footer_text;
    }
    
    // view page navigation bottom
    if ($jlistConfig['option.navigate.bottom']){ 
       if ($is_showcats || $is_one_cat) {
           $page_navi_links   = $pageNav->getPagesLinks(); 
           if ($page_navi_links){
               $page_navi_pages   = $pageNav->getPagesCounter();
               $page_navi_counter = $pageNav->getResultsCounter(); 
               $page_limit_box    = $pageNav->getLimitBox();  
           } 
           $footer = str_replace('{page_navigation}', $page_navi_links, $footer);
           $footer = str_replace('{page_navigation_results_counter}', $page_navi_counter, $footer);
           $footer = str_replace('{page_navigation_pages_counter}', $page_navi_pages, $footer);                

       } else {
           $footer = str_replace('{page_navigation}', '', $footer);
           $footer = str_replace('{page_navigation_results_counter}', '', $footer);
           $footer = str_replace('{page_navigation_pages_counter}', '', $footer);                
       }
    } else {
           $footer = str_replace('{page_navigation}', '', $footer);
           $footer = str_replace('{page_navigation_results_counter}', '', $footer);
           $footer = str_replace('{page_navigation_pages_counter}', '', $footer);                
    }
      
    // footer text
    if ($jlistConfig['downloads.footer.text'] != '') {
        $footer_text = stripslashes($jlistConfig['downloads.footer.text']);
        if ($jlistConfig['google.adsense.active'] && $jlistConfig['google.adsense.code'] != ''){
            $footer_text = str_replace( '{google_adsense}', stripslashes($jlistConfig['google.adsense.code']), $footer_text);
        } else {    
            $footer_text = str_replace( '{google_adsense}', '', $footer_text);
        }    
        $footer .= $footer_text;
    }
    
    // back button
	if ($make_back_button && $jlistConfig['view.back.button']){
        $footer = str_replace('{back_link}', '<a href="javascript:history.go(-1)">'.JText::_('COM_JDOWNLOADS_FRONTEND_BACK_BUTTON').'</a>', $footer); 
    } else {
        $footer = str_replace('{back_link}', '', $footer);
    }    
    
    if (strrev($jlistConfig['com']) != $secret){
        $power = 'Powered&nbsp;by&nbsp;jDownloads';
        $footer .= '<div style="text-align:center" class="jd_footer"><a href="http://www.jDownloads.com" target="_blank" title="www.jDownloads.com">'.$power.'</a></div>';
	}     
	return $footer;
}

function reportDownload($option,$cid){
    global $Itemid, $jlistConfig;
    
    $database = &JFactory::getDBO();
    $user = &JFactory::getUser();
    
    if ($jlistConfig['report.link.only.regged'] && !$user->guest || !$jlistConfig['report.link.only.regged']) { 
        $database->setQuery('SELECT file_title FROM #__jdownloads_files WHERE file_id = '.$cid.' AND published = 1');
        $title = $database->loadResult();
        if ($title){
            // send report
            $mailto_report = str_replace(' ', '', $jlistConfig['send.mailto.report']);
            $empfaenger = explode(';', $mailto_report);
            $betreff = JText::_('COM_JDOWNLOADS_REPORT_FILE_MESSAGE_TITLE');                                   
            $html_format = true;
            $text = sprintf(JText::_('COM_JDOWNLOADS_REPORT_FILE_MESSAGE_TEXT'), $title, $cid);
            $first_adress = array_shift($empfaenger);
            $success = JUtility::sendMail('jDownloads', 'jDownloads', $first_adress, $betreff, $text, $html_format, '',$empfaenger);
            if ($success){
                $message = '<div style="text-align:center" class="jd_cat_title"><br /><img src="'.JURI::base().'components/com_jdownloads/assets/images/summary.png" width="48" height="48" border="0" alt="" />'.JText::_('COM_JDOWNLOADS_REPORT_FILE_MESSAGE_OK').'<br /><br /></div>';
            } else {
                $message = '<div style="text-align:center" class="jd_cat_title"><br /><img src="'.JURI::base().'components/com_jdownloads/assets/images/warning.png" width="48" height="48" border="0" alt="" />'.JText::_('COM_JDOWNLOADS_REPORT_FILE_MESSAGE_ERROR').'<br /><br /></div>';
            }    
        } else {
                $message = '<div style="text-align:center" class="jd_cat_title"><br /><img src="'.JURI::base().'components/com_jdownloads/assets/images/warning.png" width="48" height="48" border="0" alt="" />'.JText::_('COM_JDOWNLOADS_REPORT_FILE_MESSAGE_ERROR').'<br /><br /></div>';
        }    
        $message .= '<div style="text-align:left" class="back_button"><a href="javascript:history.go(-1)">'.JText::_('COM_JDOWNLOADS_FRONTEND_BACK_BUTTON').'</a></div>'; 
        echo $message;
    }     
} 

function checkAccess_JD(){
    
    // special user group:
    // 3 = author
    // 4 = editor
    // 5 = publisher
    // 6 = manager
    // 7 = admin
    // 8 = super admin - super user
    
    $user = &JFactory::getUser();
    $coreUserGroups = $user->getAuthorisedGroups();
    // $coreViewLevels = $user->getAuthorisedViewLevels();
    $aid = max ($user->getAuthorisedViewLevels());
    
    $access = '';
    if ($aid == 1) $access = '02'; // public
    if ($aid == 2 || $aid > 3) $access = '11'; // regged or member from custom joomla group
    if ($aid == 3 || in_array(3,$coreUserGroups) || in_array(4,$coreUserGroups) || in_array(5,$coreUserGroups) || in_array(6,$coreUserGroups)) $access = '22'; // special user
    if (in_array(8,$coreUserGroups) || in_array(7,$coreUserGroups)){
        // is admin or super user
        $access = '99';
    }
    return $access;
}

function DatumsDifferenz_JD($Start,$Ende) {
    $Tag1=(int) substr($Start, 8, 2);
    $Monat1=(int) substr($Start, 5, 2);
    $Jahr1=(int) substr($Start, 0, 4);
    
    $Tag2=(int) substr($Ende, 8, 2);
    $Monat2=(int) substr($Ende, 5, 2);
    $Jahr2=(int) substr($Ende, 0, 4);

    if (checkdate($Monat1, $Tag1, $Jahr1)and checkdate($Monat2, $Tag2, $Jahr2)){
        $Datum1=mktime(0,0,0,$Monat1, $Tag1, $Jahr1);
        $Datum2=mktime(0,0,0,$Monat2, $Tag2, $Jahr2);

        $Diff=(Integer) (($Datum1-$Datum2)/3600/24);
        return $Diff;
    } else {
        return -1;
    }
} 

function infos($parent, &$subcats, &$files, $access, $user_groups) {
 $database = &JFactory::getDBO();
    // subcats holen
    $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE parent_id = '$parent' AND published = 1 AND (cat_access <= '$access' $user_groups)");
    $rows = $database->loadObjectList();
    if ($database->getErrorNum()) {
        echo $database->stderr();
        return false;
    }
    if ($rows){
        foreach ($rows as $v) {
            $database->setQuery("SELECT COUNT(*) FROM #__jdownloads_files WHERE cat_id = '$v->cat_id' AND published = 1");
            $sum = $database->loadResult();
            $files = $files + $sum;
            $subcats++;
            // nach nächster ebene suchen
            infos($v->cat_id, $subcats, $files, $access, $user_groups);
        }
    }
}

// Dateigröße einer externen Datei ermitteln
function urlfilesize($url) {
    if (substr($url,0,4)=='http' || substr($url,0,3)=='ftp') {
        // for php 4 users
        if (!function_exists('get_headers')) {
            function get_headers($url, $format=0) {
                $headers = array();
                $url = parse_url($url);
                $host = isset($url['host']) ? $url['host'] : '';
                $port = isset($url['port']) ? $url['port'] : 80;
                $path = (isset($url['path']) ? $url['path'] : '/') . (isset($url['query']) ? '?' . $url['query'] : '');
                $fp = fsockopen($host, $port, $errno, $errstr, 3);
                if ($fp) {
                    $hdr = "GET $path HTTP/1.1\r\n";
                    $hdr .= "Host: $host \r\n";
                    $hdr .= "Connection: Close\r\n\r\n";
                    fwrite($fp, $hdr);
                    while (!feof($fp) && $line = trim(fgets($fp, 1024))) {
                        if ($line == "\r\n") break;
                        list($key, $val) = explode(': ', $line, 2);
                        if ($format)
                            if ($val) $headers[$key] = $val;
                            else $headers[] = $key;
                        else $headers[] = $line;
                    }
                    fclose($fp);
                    return $headers;
                }
                return false;
            }
        }
        $size = array_change_key_case(get_headers($url, 1),CASE_LOWER);
        $size = $size['content-length'];
        if (is_array($size)) { $size = $size[1]; }
    } else {
        $size = @filesize($url); 
    }
    return $size;    
} 

function create_new_thumb($picturepath) {
    global $jlistConfig;
    jimport('joomla.filesystem.folder');     
    $thumbpath = JPATH_SITE.'/images/jdownloads/screenshots/thumbnails/';
    if (!is_dir($thumbpath)){
        JFolder::create("$thumbpath", 0755);
    }    
    $newsize = $jlistConfig['thumbnail.size.width'];
    $thumbfilename = $thumbpath.basename($picturepath);
    if (file_exists($thumbfilename)){
       return true;
    }   
    
    /* Prüfen ob Datei existiert */
    if(!file_exists($picturepath)) {
        return false;
    }
    
    /* MIME-Typ auslesen */
    $size=getimagesize($picturepath);
    switch($size[2]) {
        case "1":
        $oldpic = imagecreatefromgif($picturepath);
        break;
        case "2":
        $oldpic = imagecreatefromjpeg($picturepath);
        break;
        case "3":
        $oldpic = imagecreatefrompng($picturepath);
        break;
        default:
        return false;
    }
    /* Alte Maße auslesen */
    $width = $size[0];
    $height = $size[1]; 

    $maxwidth = $jlistConfig['thumbnail.size.width'];
    $maxheight = $jlistConfig['thumbnail.size.height'];
    if ($width/$maxwidth > $height/$maxheight) {
        $newwidth = $maxwidth;
        $newheight = $maxwidth*$height/$width;
    } else {
        $newheight = $maxheight;
        $newwidth = $maxheight*$width/$height;
    }
     
    /* Neues Bild erstellen mit den neuen Maßen */
    $newpic = imagecreatetruecolor($newwidth,$newheight);
    /* Jetzt wird das Bild nur noch verkleinert */
    imagecopyresampled($newpic,$oldpic,0,0,0,0,$newwidth,$newheight,$width,$height); 
    // Bild speichern
    switch($size[2]) {
        case "1":    return imagegif($newpic, $thumbfilename);
        break;
        case "2":    return imagejpeg($newpic, $thumbfilename);
        break;
        case "3":    return imagepng($newpic, $thumbfilename);
        break;
    }
    //Bilderspeicher freigeben
    imagedestroy($oldpic);
    imagedestroy($newpic);
}

function create_new_image($picturepath) {
    global $jlistConfig;
    jimport('joomla.filesystem.folder'); 
    $thumbpath = JPATH_SITE.'/images/jdownloads/screenshots/';
    if (!is_dir($thumbpath)){
        JFolder::create("$thumbpath", 0755);
    }    
    $newsize = $jlistConfig['create.auto.thumbs.from.pics.image.width'];
    $thumbfilename = $thumbpath.basename($picturepath);
    if (file_exists($thumbfilename)){
       return true;
    }   
    
    /* Pruefen ob Datei existiert */
    if(!file_exists($picturepath)) {
        return false;
    }
    
    /* MIME-Typ auslesen */
    $size=getimagesize($picturepath);
    switch($size[2]) {
        case "1":
        $oldpic = imagecreatefromgif($picturepath);
        break;
        case "2":
        $oldpic = imagecreatefromjpeg($picturepath);
        break;
        case "3":
        $oldpic = imagecreatefrompng($picturepath);
        break;
        default:
        return false;
    }
    /* Alte Groesse auslesen */
    $width = $size[0];
    $height = $size[1]; 
    /* Neue Groesse errechnen */

    $maxwidth = $jlistConfig['create.auto.thumbs.from.pics.image.width'];
    $maxheight = $jlistConfig['create.auto.thumbs.from.pics.image.height'];
    if ($width/$maxwidth > $height/$maxheight) {
        $newwidth = $maxwidth;
        $newheight = $maxwidth*$height/$width;
    } else {
        $newheight = $maxheight;
        $newwidth = $maxheight*$width/$height;
    }

    $newpic = imagecreatetruecolor($newwidth,$newheight);
    imagealphablending($newpic,false);
    imagesavealpha($newpic,true);
    
    /* Jetzt wird das Bild nur noch verkleinert */
    imagecopyresampled($newpic,$oldpic,0,0,0,0,$newwidth,$newheight,$width,$height); 
    // Bild speichern
    switch($size[2]) {
        case "1":    return imagegif($newpic, $thumbfilename);
        break;
        case "2":    return imagejpeg($newpic, $thumbfilename);
        break;
        case "3":    return imagepng($newpic, $thumbfilename);
        break;
    }
    //Bilderspeicher freigeben
    imagedestroy($oldpic);
    imagedestroy($newpic);
}

// create thumnail from pdf file
function create_new_pdf_thumb($target_path, $only_name, $thumb_path, $screenshot_path){
    global $jlistConfig;    
    
    $pdf_thumb_file_name = '';
    
    if (extension_loaded('imagick')){ 
        // create small thumb
        $image = new Imagick($target_path.'[0]');
        $image -> setImageIndex(0);
        $image -> setImageFormat($jlistConfig['pdf.thumb.image.type']);
        $image -> scaleImage($jlistConfig['pdf.thumb.height'],$jlistConfig['pdf.thumb.width'],1);
        $pdf_thumb_file_name = $only_name.'.'.strtolower($jlistConfig['pdf.thumb.image.type']);
        $image->writeImage($thumb_path.$only_name.'.'.strtolower($jlistConfig['pdf.thumb.image.type']));
        $image->clear();
        $image->destroy();
        // create big thumb
        $image = new Imagick($target_path.'[0]');
        $image -> setImageIndex(0);
        $image -> setImageFormat($jlistConfig['pdf.thumb.image.type']);
        $image -> scaleImage($jlistConfig['pdf.thumb.pic.height'],$jlistConfig['pdf.thumb.pic.width'],1);
        $image->writeImage($screenshot_path.$only_name.'.'.strtolower($jlistConfig['pdf.thumb.image.type']));
        $image->clear();
        $image->destroy();    
    }
    return $pdf_thumb_file_name; 
}

function checkFileName($name){
    global $jlistConfig;
    if ($name) {
        // change to uppercase
        if ($jlistConfig['fix.upload.filename.uppercase']){
            $name = strtolower($name); 
        }            
        // change blanks
        if ($jlistConfig['fix.upload.filename.blanks']){
            $name = str_replace(' ', '_', $name);
        }
        if ($jlistConfig['fix.upload.filename.specials']){
            // change special chars
            $search  = array( 'ä', 'ü', 'ö', 'Ä', 'Ü', 'Ö', 'ß');
            $replace = array( 'ae', 'ue', 'oe', 'Ae', 'Ue', 'Oe', 'ss');
            for ($i=0; $i < count($search); $i++) { 
                $name = str_replace($search[$i], $replace[$i], $name);
            }    
            
            // remove invalid chars
            $file_extension = strrchr($name,".");
            $name_cleared = preg_replace('#[^A-Za-z0-9 _.-]#', '', $name);
            if ($name_cleared != $file_extension){
                $name = $name_cleared;
            }    
        }
        // anti hack .php.rar
        $name = str_replace('.php.', '.', $name);
        $name = str_replace('.php4.', '.', $name); 
        $name = str_replace('.php5.', '.', $name);
    }               
    return $name;    
}

Function createPathway($catid, $breadcrumbs, $option){
    global $mainframe, $Itemid;
    
    $database = &JFactory::getDBO();
    // cat laden
    $database->setQuery('SELECT * FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '.$catid);
    $cat = $database->loadObjectList();

    $path = array();
    $values = array();
    while ($cat[0]->parent_id){
        $database->setQuery('SELECT cat_id, cat_title, cat_access, parent_id FROM #__jdownloads_cats WHERE published = 1 AND cat_id = '.$cat[0]->parent_id);
        $parent = $database->loadObject();
        if ($parent){
            array_unshift($path, $parent->cat_title.'|'.JRoute::_('index.php?option='.$option.'&amp;Itemid='.$Itemid.'&amp;view=viewcategory&amp;catid='.$parent->cat_id)); 
        } else {
          $cat[0]->parent_id = 0;  
        } 
        $cat[0]->parent_id = $parent->parent_id;    
    }
    foreach($path as $pat){
       $values = explode ( '|', $pat );
       $breadcrumbs->addItem($values[0], $values[1]);    
    }
    return $breadcrumbs;
}
    
function getID3v2Tags($file,$blnAllFrames=0){
    if (is_file($file)){
        $arrTag[_file]=$file;
        $fp=fopen($file,"rb");
        if($fp){
            $id3v2=fread($fp,3);
            if($id3v2=="ID3"){// a ID3v2 tag always starts with 'ID3'
                $arrTag[_ID3v2]=1;
                $arrTag[_version]=ord(fread($fp,1)).".".ord(fread($fp,1));// = version.revision
                fseek($fp,6);// skip 1 'flag' byte, because i don't need it :)
                unset($tagSize);
                for($i=0;$i<4;$i++){
                    $tagSize=$tagSize.base_convert(ord(fread($fp,1)),10,16);
                }
                $tagSize=hexdec($tagSize);
                if($tagSize>filesize($file)){
                    $arrTag[_error]=4;// = tag is bigger than file
                }
                fseek($fp,10);
                while(ereg("^[A-Z][A-Z0-9]{3}$",$frameName=fread($fp,4))){
                    unset($frameSize);
                    for($i=0;$i<4;$i++){
                        $frameSize=$frameSize.base_convert(ord(fread($fp,1)),10,16);
                    }
                    $frameSize=hexdec($frameSize);
                    if($frameSize>$tagSize){
                        $arrTag[_error]=5;// = frame is bigger than tag
                        break;
                    }
                    fseek($fp,ftell($fp)+2);// skip 2 'flag' bytes, because i don't need them :)
                    if($frameSize<1){
                        $arrTag[_error]=6;// = frame size is smaller then 1
                        break;
                    }
                    if($blnAllFrames==0){
                        if(!ereg("^T",$frameName)){// = not a text frame, they always starts with 'T'
                            unset($arrTag[$frameName]);
                            fseek($fp,ftell($fp)+$frameSize);// go to next frame
                            continue;// read next frame
                        }
                    }
                    $frameContent=fread($fp,$frameSize);
                    if(!$arrTag[$frameName]){
                        $arrTag[$frameName]=trim(utf8_encode($frameContent));// the frame content (always?) starts with 0, so it's better to remove it
                    }
                    else{// if there is more than one frame with the same name
                        $arrTag[$frameName]=$arrTag[$frameName]."~".trim($frameContent);
                    }
                }// while(ereg("^[A-Z0-9]{4}$",fread($fp,4)))
            }// if($id3v2=="ID3")
            else{
                $arrTag[_ID3v2]=0;// = no ID3v2 tag found
                $arrTag[_error]=3;// = no ID3v2 tag found
            }
        }// if($fp)
        else{
            $arrTag[_error]=2;// can't open file
        }
        fclose($fp);
    }// if(is_file($file) and eregi(".mp3$",$file)){
    else{
        $arrTag[_error]=1;// = file doesn't exists or isn't a mp3
    }
    // convert lenght
    if ($arrTag[TLEN] > 0){
        $arrTag[TLEN] = round(($arrTag[TLEN] / 1000)/60,2);
    }    
   
    return $arrTag;
}     

function getRatings($id){    
    global $mainframe, $jlistConfig;
    $app = &JFactory::getApplication();
    $user = &JFactory::getUser();
    $aid = max ($user->getAuthorisedViewLevels());
    $database = &JFactory::getDBO();
    $document=& JFactory::getDocument(); 
    $vote = array();
    $database->setQuery('SELECT * FROM #__jdownloads_rating WHERE file_id='. (int) $id);
    $vote = $database->loadObject();
    if ($vote->rating_count!=0){
            $result = number_format(intval($vote->rating_sum) / intval( $vote->rating_count ),2)*20;
    }    
    $rating_sum = intval($vote->rating_sum);
    $rating_count = intval($vote->rating_count);
    // rating only for registered?
    if (($jlistConfig['rating.only.for.regged'] && $aid > 1) || !$jlistConfig['rating.only.for.regged']) {
        $script='
        <!-- JW AJAX Vote Plugin v1.1 starts here -->
        <script type="text/javascript">
        var live_site = \''.JURI::base().'\';
        var jwajaxvote_lang = new Array();
        jwajaxvote_lang[\'UPDATING\'] = \''.JText::_('JDVOTE_UPDATING').'\';
        jwajaxvote_lang[\'THANKS\'] = \''.JText::_('JDVOTE_THANKS').'\';
        jwajaxvote_lang[\'ALREADY_VOTE\'] = \''.JText::_('JDVOTE_ALREADY_VOTE').'\';
        jwajaxvote_lang[\'VOTES\'] = \''.JText::_('JDVOTE_VOTES').'\';
        jwajaxvote_lang[\'VOTE\'] = \''.JText::_('JDVOTE_VOTE').'\';
        </script>
        <script type="text/javascript" src="'.JURI::base().'components/com_jdownloads/assets/rating/js/ajaxvote.php"></script>
        <!-- JW AJAX Vote Plugin v1.1 ends here -->
        ';    
        if(!$addScriptJWAjaxVote){ 
            $addScriptJWAjaxVote = 1;
            if($app->getCfg(caching)) {
                $html = $script;
            } else {
                $document->addCustomTag($script);
            }
        }        

        $html .='
        <!-- JW AJAX Vote Plugin v1.1 starts here -->
        <div class="jwajaxvote-inline-rating">
        <ul class="jwajaxvote-star-rating">
        <li id="rating'.$id.'" class="current-rating" style="width:'.$result.'%;"></li>
        <li><a href="javascript:void(null)" onclick="javascript:jwAjaxVote('.$id.',1,'.$rating_sum.','.$rating_count.');" title="1 '.JText::_('JDVOTE_STAR').' 5" class="one-star"></a></li>
        <li><a href="javascript:void(null)" onclick="javascript:jwAjaxVote('.$id.',2,'.$rating_sum.','.$rating_count.');" title="2 '.JText::_('JDVOTE_STARS').' 5" class="two-stars"></a></li>
        <li><a href="javascript:void(null)" onclick="javascript:jwAjaxVote('.$id.',3,'.$rating_sum.','.$rating_count.');" title="3 '.JText::_('JDVOTE_STARS').' 5" class="three-stars"></a></li>
        <li><a href="javascript:void(null)" onclick="javascript:jwAjaxVote('.$id.',4,'.$rating_sum.','.$rating_count.');" title="4 '.JText::_('JDVOTE_STARS').' 5" class="four-stars"></a></li>
        <li><a href="javascript:void(null)" onclick="javascript:jwAjaxVote('.$id.',5,'.$rating_sum.','.$rating_count.');" title="5 '.JText::_('JDVOTE_STARS').' 5" class="five-stars"></a></li>
        </ul>
        <div id="jwajaxvote'.$id.'" class="jwajaxvote-box">
        ';
    } else {
        // view only the results
        $html .='
        <!-- JW AJAX Vote Plugin v1.1 starts here -->
        <div class="jwajaxvote-inline-rating">
        <ul class="jwajaxvote-star-rating">
        <li id="rating'.$id.'" class="current-rating" style="width:'.$result.'%;"></li>
        <li><a href="javascript:void(null)" onclick="" title="1 '.JText::_('JDVOTE_STAR').' 5" class="one-star"></a></li>
        <li><a href="javascript:void(null)" onclick="" title="2 '.JText::_('JDVOTE_STARS').' 5" class="two-stars"></a></li>
        <li><a href="javascript:void(null)" onclick="" title="3 '.JText::_('JDVOTE_STARS').' 5" class="three-stars"></a></li>
        <li><a href="javascript:void(null)" onclick="" title="4 '.JText::_('JDVOTE_STARS').' 5" class="four-stars"></a></li>
        <li><a href="javascript:void(null)" onclick="" title="5 '.JText::_('JDVOTE_STARS').' 5" class="five-stars"></a></li>
        </ul>
        <div id="jwajaxvote'.$id.'" class="jwajaxvote-box">
        ';
    }
    if($rating_count!=1) {
       $html .= "(".$rating_count." ".JText::_('JDVOTE_VOTES').")";
    } else { 
       $html .= "(".$rating_count." ".JText::_('JDVOTE_VOTE').")";
    }
    $html .= '
        </div>
        </div>
        <div class="jwajaxvote-clr"></div>
        <!-- JW AJAX Vote Plugin v1.1 ends here -->    
        '; 
    return $html;       
}

function setAUPPointsUploads($submitted_by, $file_title){
    // added (or reduce) points to the alphauserpoints when is activated in the jD config
    // $submitted_by = user ID after upload a file
    global $jlistConfig;
    if ($jlistConfig['use.alphauserpoints'] && $submitted_by){
        $api_AUP = JPATH_SITE.DS.'components'.DS.'com_alphauserpoints'.DS.'helper.php';
        if (file_exists($api_AUP)){
            require_once ($api_AUP);
            $aupid = AlphaUserPointsHelper::getAnyUserReferreID( $submitted_by );
            if ($aupid){
                $text = JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_UPLOAD_TEXT');
                $text = sprintf($text, $file_title);
                AlphaUserPointsHelper::newpoints( 'plgaup_jdownloads_user_upload_published', $aupid, $file_title, $text);
            }     
        }    
    }
}    

function setAUPPointsDownload($user_id, $file_title, $file_id, $price){
    // added (or reduce) points to the alphauserpoints when is activated in the jD config
    // $user_id = user ID from the file download
    global $jlistConfig;
    if ($jlistConfig['use.alphauserpoints'] && $user_id){
        $session = JFactory::getSession();
        $session_data = $session->get('jd_aup_session');
        if (isset($session_data) && $session_data[id] == $user_id && $session_data[file_id] == $file_id){ 
            return true;
        }
        $api_AUP = JPATH_SITE.DS.'components'.DS.'com_alphauserpoints'.DS.'helper.php';
        if (file_exists($api_AUP)){
            require_once ($api_AUP);
            $aupid = AlphaUserPointsHelper::getAnyUserReferreID( $user_id );
            if ($aupid){
                $text = JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_DOWNLOAD_TEXT');
                $text = sprintf($text, $file_title);
                // get AUP user data
                $profil = AlphaUserPointsHelper:: getUserInfo ( '', $user_id );
                if ($jlistConfig['user.can.download.file.when.zero.points'] || $profil->points > 0 || $price == 0){
                    if ($price){
                        // price as points activated
                        if ($profil->points >= $price){
                            if ($jlistConfig['use.alphauserpoints.with.price.field']){
                            AlphaUserPointsHelper::newpoints( 'plgaup_jdownloads_user_download_use_price', $aupid, '', $text, '-'.$price, $text);
                            $session_data = array('id' => $user_id, 'file_id' => $file_id);
                            $session->set('jd_aup_session', $session_data);
                            return true;
                            } else {
                                AlphaUserPointsHelper::newpoints( 'plgaup_jdownloads_user_download', $aupid, '', $text);
                                $session_data = array('id' => $user_id, 'file_id' => $file_id);
                                $session->set('jd_aup_session', $session_data);
                                return true;
                            }    
                        } else {
                            // not enough points . no download
                            return false;
                        }    
                    } else {
                        // use points set in AUP plugin
                        //AlphaUserPointsHelper::newpoints( 'plgaup_jdownloads_user_download', $aupid, '', $text);
                        return true;
                    }    
                } else {
                    // not enough points . no download
                    return false;
                }   
            }     
        } else {
           return true;
        }    
    } else {
      if ($price){
          // not registered user
          return false;
      } else {     
          // guest but no price
          return true;  
      }    
    } 
}

function setAUPPointsDownloads($user_id, $file_title, $file_id, $price){
    // added (or reduce) points to the alphauserpoints when is activated in the jD config
    // $user_id = user ID from the file download
    global $jlistConfig;
    if ($jlistConfig['use.alphauserpoints'] && $user_id){
        $session = JFactory::getSession();
        $session_data = $session->get('jd_aup_session');
        if (isset($session_data) && $session_data[id] == $user_id && $session_data[file_id] == $file_id){ 
            return true;
        }
        $api_AUP = JPATH_SITE.DS.'components'.DS.'com_alphauserpoints'.DS.'helper.php';
        if (file_exists($api_AUP)){
            require_once ($api_AUP);
            $aupid = AlphaUserPointsHelper::getAnyUserReferreID( $user_id );
            if ($aupid){
                $text = JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_DOWNLOAD_TEXT');
                $text = sprintf($text, $file_title);
                // get AUP user data
                $profil = AlphaUserPointsHelper:: getUserInfo ( '', $user_id );
                if ($jlistConfig['user.can.download.file.when.zero.points'] || $profil->points > 0 || $price == 0){
                    if ($price){
                        // price as points activated
                            AlphaUserPointsHelper::newpoints( 'plgaup_jdownloads_user_download_use_price', $aupid, '', $text, '-'.$price, $text);
                            $session_data = array('id' => $user_id, 'file_id' => $file_id);
                            $session->set('jd_aup_session', $session_data);
                            return true;
                    } else {
                        AlphaUserPointsHelper::newpoints( 'plgaup_jdownloads_user_download', $aupid, '', $text);
                        $session_data = array('id' => $user_id, 'file_id' => $file_id);
                        $session->set('jd_aup_session', $session_data);
                        return true;
                    }    
                } else {
                    return false;
                }   
            }     
        } else {
           return true;
        }   
    } else {
      return true;
    }
}

function setAUPPointsDownloaderToUploader($fileid, $files){
    // Assign points to the file uploader when a user download this file from jDownloads
    $database = &JFactory::getDBO(); 
    $files_arr = explode(',', $files);
    $files_arr[] = $fileid;  
    foreach ($files_arr as $file){  
      if ($file){
        $database->setQuery("SELECT submitted_by FROM #__jdownloads_files WHERE file_id = '$file'");
        $uploader_id = (int)$database->loadResult();
        if ($uploader_id){
            $database->setQuery("SELECT file_title FROM #__jdownloads_files WHERE file_id = '$file'");
            $file_title = $database->loadResult();
            $api_AUP = JPATH_SITE.DS.'components'.DS.'com_alphauserpoints'.DS.'helper.php';
            if (file_exists($api_AUP)){
                require_once ($api_AUP);
                $aupid = AlphaUserPointsHelper::getAnyUserReferreID( $uploader_id );
                if ($aupid){
                    $text = JText::_('COM_JDOWNLOADS_BACKEND_SET_AUP_DOWNLOADER_TO_UPLOADER_TEXT');
                    $text = sprintf($text, $file_title);
                    AlphaUserPointsHelper::newpoints( 'plgaup_jdownloads_downloader_to_uploader', $aupid);
                }     
            }
        }
      }      
    }        
}    

function checkLog($fileid, $user){
    global $jlistConfig;
    $database = &JFactory::getDBO();
    $app = JFactory::getApplication();
    $offset = $app->getCfg('offset');
    $datenow =& JFactory::getDate(); 
    $datenow->setOffset($offset);
    
    $date = $datenow->toFormat("%Y-%m-%d %H:%M:%S");
    $max_files_day = $jlistConfig['limited.download.number.per.day'];

    $ip = getRealIp();
    
    // download logs
    if ($jlistConfig['activate.download.log'] == '1' && $max_files_day == 0){
        $database->setQuery("INSERT INTO #__jdownloads_log (log_file_id, log_ip, log_datetime, log_user, log_browser) VALUES ('".$fileid."', '".$ip."', '".$date."', '".$user->get('id')."', '')");
        $database->query();
        return true;
    }
        
    if ($max_files_day != 0){
        // check limit
        $logged_user_files = array();
        $search_date = $datenow->toFormat("%Y-%m-%d");
        $database->setQuery("SELECT * FROM #__jdownloads_log WHERE DATE(log_datetime) = '$search_date' AND log_user = '". (int) $user->get('id')."'");
        $logged_user_files = $database->loadObjectList();
        if (!$logged_user_files || count($logged_user_files) < $max_files_day){
            // add file in log 
            $database->setQuery("INSERT INTO #__jdownloads_log (log_file_id, log_ip, log_datetime, log_user, log_browser) VALUES ('".$fileid."', '".$ip."', '".$date."', '".$user->get('id')."', '')");
            $database->query();
            return true;
        } else {
            // download not allowed
            return false;
        }   
    } else {
        return true;
    }       
} 

// added for search function
function _ctrSort($a, $b) {
     if (!is_array($a) || !is_array($b) || !array_key_exists("ctr", $a) || !array_key_exists("ctr", $b) || $a['ctr'] == $b['ctr'])
         return 0;
    return ($a['ctr'] < $b['ctr']) ? 1 : -1;

}   

function placeThumbs($html_file, $thumb1, $thumb2, $thumb3){
     global $jlistConfig;
 
            
        if ($thumb1 != ''){
            $thumbnail =  JURI::base().'images/jdownloads/screenshots/thumbnails/'.$thumb1; 
            $screenshot = JURI::base().'images/jdownloads/screenshots/'.$thumb1; 
            $html_file = str_replace('{thumbnail}', $thumbnail, $html_file);
            $html_file = str_replace('{screenshot}', $screenshot, $html_file);
            $html_file = str_replace('{screenshot_end}', '', $html_file);
            $html_file = str_replace('{screenshot_begin}', '', $html_file); 
            
         } else { 
            if ($jlistConfig["thumbnail.view.placeholder.in.lists"]) {
                $thumbnail = JURI::base().'images/jdownloads/screenshots/thumbnails/no_pic.gif';
                $screenshot = JURI::base().'images/jdownloads/screenshots/no_pic.gif';
                $html_file = str_replace('{thumbnail}', $thumbnail, $html_file);
                $html_file = str_replace('{screenshot}', $screenshot, $html_file);    
                $html_file = str_replace('{screenshot_end}', '', $html_file);
                $html_file = str_replace('{screenshot_begin}', '', $html_file);
            } else {    
                $pos_end = strpos($html_file, '{screenshot_end}');
                $pos_beg = strpos($html_file, '{screenshot_begin}');
                if ($pos_beg && $pos_end){     
                     $html_file = substr_replace($html_file, '', $pos_beg, ($pos_end - $pos_beg) + 16);
                } 
            }    
         }  

     
        if ($thumb2 != ''){
            $thumbnail =  JURI::base().'images/jdownloads/screenshots/thumbnails/'.$thumb2; 
            $screenshot = JURI::base().'images/jdownloads/screenshots/'.$thumb2; 
            $html_file = str_replace('{thumbnail2}', $thumbnail, $html_file);
            $html_file = str_replace('{screenshot2}', $screenshot, $html_file);
            $html_file = str_replace('{screenshot_end2}', '', $html_file);
            $html_file = str_replace('{screenshot_begin2}', '', $html_file); 
         } else { 
            if ($jlistConfig["thumbnail.view.placeholder.in.lists"]) {
                $thumbnail = JURI::base().'images/jdownloads/screenshots/thumbnails/no_pic.gif';
                $screenshot = JURI::base().'images/jdownloads/screenshots/no_pic.gif';
                $html_file = str_replace('{thumbnail2}', $thumbnail, $html_file);
                $html_file = str_replace('{screenshot2}', $screenshot, $html_file);    
                $html_file = str_replace('{screenshot_end2}', '', $html_file);
                $html_file = str_replace('{screenshot_begin2}', '', $html_file);
            } else {    
                if ($pos_end = strpos($html_file, '{screenshot_end2}')){
                     $pos_beg = strpos($html_file, '{screenshot_begin2}');
                     $html_file = substr_replace($html_file, '', $pos_beg, ($pos_end - $pos_beg) + 17);
                } 
            }    
         }  
     
        if ($thumb3 != ''){
            $thumbnail =  JURI::base().'images/jdownloads/screenshots/thumbnails/'.$thumb3; 
            $screenshot = JURI::base().'images/jdownloads/screenshots/'.$thumb3; 
            $html_file = str_replace('{thumbnail3}', $thumbnail, $html_file);
            $html_file = str_replace('{screenshot3}', $screenshot, $html_file);
            $html_file = str_replace('{screenshot_end3}', '', $html_file);
            $html_file = str_replace('{screenshot_begin3}', '', $html_file); 
         } else { 
            if ($jlistConfig["thumbnail.view.placeholder.in.lists"]) {
                $thumbnail = JURI::base().'images/jdownloads/screenshots/thumbnails/no_pic.gif';
                $screenshot = JURI::base().'images/jdownloads/screenshots/no_pic.gif';
                $html_file = str_replace('{thumbnail3}', $thumbnail, $html_file);
                $html_file = str_replace('{screenshot3}', $screenshot, $html_file);    
                $html_file = str_replace('{screenshot_end3}', '', $html_file);
                $html_file = str_replace('{screenshot_begin3}', '', $html_file);
            } else {    
                if ($pos_end = strpos($html_file, '{screenshot_end3}')){
                     $pos_beg = strpos($html_file, '{screenshot_begin3}');
                     $html_file = substr_replace($html_file, '', $pos_beg, ($pos_end - $pos_beg) + 17);
                } 
            }    
         }  
    return $html_file;
}

function getUserGroupsX(){
    $database = &JFactory::getDBO();
    $user = &JFactory::getUser();
    $group_list = array();
    $user_in_groups = array();
    $database->setQuery("SELECT id, groups_members FROM #__jdownloads_groups");
    $all_groups = $database->loadObjectList();
    if (count($all_groups > 0)){
        foreach ($all_groups as $group){
                 $group_list = explode(',', $group->groups_members);
                 if (in_array($user->id, $group_list)){
                     $user_in_groups[] = $group->id;
                 }    
        }    
    }    
    if (count($user_in_groups) > 1){
       $user_in_groups = implode(',', $user_in_groups);
    } else {
       $user_in_groups = $user_in_groups[0];
    }     
    return $user_in_groups;
}

function getUserEditGroup(){
    global $jlistConfig;
    
    $database = &JFactory::getDBO();
    $user = &JFactory::getUser();
    $members_arr = array();
    $edit_group = (int)$jlistConfig['group.can.edit.fe'];
    if ($edit_group > 0){
        $database->setQuery("SELECT groups_members FROM #__jdownloads_groups WHERE id = '$edit_group'");
        $members = $database->loadResult();
        if ($members){
            $members_arr = explode(',', $members);
            if (in_array($user->id, $members_arr)){
                return true;
            }    
        }    
    }
    return false;
}

function existsCustomFieldsTitlesX(){
    global $jlistConfig;
    // check that any field is activated (has title)
    $custom_arr = array();
    $custom_array = array();
    $custom_titles = array();
    $custom_values = array();
    for ($i=1; $i<15; $i++){
        if ($jlistConfig["custom.field.$i.title"] != ''){
           $custom_array[] = $i;
           $custom_titles[] = $jlistConfig["custom.field.$i.title"];
           $custom_values[] = explode(',', $jlistConfig["custom.field.$i.values"]);
           array_unshift($custom_values[$i-1],"select");
        } else {
           $custom_array[] = 0;
           $custom_titles[] = '';
           $custom_values[] = '';
        }   
    }    
    $custom_arr[]=$custom_array;
    $custom_arr[]=$custom_titles;
    $custom_arr[]=$custom_values;
    return $custom_arr;
}

function buildFieldTitles($html_file, $file){
    global $jlistConfig;
    
    if ($jlistConfig['remove.field.title.when.empty']){
        $html_file = ($file->license) ? str_replace('{license_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_LICENSE_TITLE'), $html_file) : str_replace('{license_title}', '', $html_file);
        $html_file = ($file->price) ? str_replace('{price_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_PRICE_TITLE'), $html_file) : str_replace('{price_title}', '', $html_file);                                          
        $html_file = ($file->language) ? str_replace('{language_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_LANGUAGE_TITLE'), $html_file) : str_replace('{language_title}', '', $html_file);
        $html_file = ($file->size) ? str_replace('{filesize_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_FILESIZE_TITLE'), $html_file) : str_replace('{filesize_title}', '', $html_file);
        $html_file = ($file->system) ? str_replace('{system_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_SYSTEM_TITLE'), $html_file) : str_replace('{system_title}', '', $html_file);
        $html_file = ($file->author) ? str_replace('{author_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_AUTHOR_TITLE'), $html_file) : str_replace('{author_title}', '', $html_file);
        $html_file = ($file->url_home) ? str_replace('{author_url_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_AUTHOR_URL_TITLE'), $html_file) : str_replace('{author_url_title}', '', $html_file);
        $html_file = ($file->date_added != '0000-00-00 00:00:00') ? str_replace('{created_date_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_CREATED_DATE_TITLE'), $html_file) : str_replace('{created_date_title}', '', $html_file);
        $html_file = ($file->downloads != '') ? str_replace('{hits_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_HITS_TITLE'), $html_file) : str_replace('{hits_title}', '', $html_file);
        $html_file = ($file->created_by) ? str_replace('{created_by_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_CREATED_BY_TITLE'), $html_file) : str_replace('{created_by_title}', '', $html_file);
        $html_file = ($file->modified_by) ? str_replace('{modified_by_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_MODIFIED_BY_TITLE'), $html_file) : str_replace('{modified_by_title}', '', $html_file);
        $html_file = ($file->modified_date != '0000-00-00 00:00:00') ? str_replace('{modified_date_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_MODIFIED_DATE_TITLE'), $html_file) : str_replace('{modified_date_title}', '', $html_file);
        $html_file = ($file->file_date != '0000-00-00 00:00:00') ? str_replace('{file_date_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_FILE_DATE_TITLE'), $html_file) : str_replace('{file_date_title}', '', $html_file);
        $html_file = ($file->url_download) ? str_replace('{file_name_title}', JText::_('COM_JDOWNLOADS_FE_DEATAILS_FILE_NAME_TITLE'), $html_file) : str_replace('{file_name_title}', '', $html_file);          
    } else {    
        $html_file = str_replace('{license_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_LICENSE_TITLE'), $html_file);
        $html_file = str_replace('{price_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_PRICE_TITLE'), $html_file);
        $html_file = str_replace('{language_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_LANGUAGE_TITLE'), $html_file);
        $html_file = str_replace('{filesize_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_FILESIZE_TITLE'), $html_file);
        $html_file = str_replace('{system_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_SYSTEM_TITLE'), $html_file);
        $html_file = str_replace('{author_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_AUTHOR_TITLE'), $html_file);
        $html_file = str_replace('{author_url_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_AUTHOR_URL_TITLE'), $html_file);
        $html_file = str_replace('{created_date_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_CREATED_DATE_TITLE'), $html_file);
        $html_file = str_replace('{hits_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_HITS_TITLE'), $html_file);
        $html_file = str_replace('{created_by_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_CREATED_BY_TITLE'), $html_file);
        $html_file = str_replace('{modified_by_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_MODIFIED_BY_TITLE'), $html_file);
        $html_file = str_replace('{modified_date_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_MODIFIED_DATE_TITLE'), $html_file);
        $html_file = str_replace('{file_date_title}', JText::_('COM_JDOWNLOADS_FE_DETAILS_FILE_DATE_TITLE'), $html_file);
        $html_file = str_replace('{file_name_title}', JText::_('COM_JDOWNLOADS_FE_DEATAILS_FILE_NAME_TITLE'), $html_file);   
    }
    return $html_file;
} 

// support for editor button plugin
// insert for the content plugin a file id or a category id 
function editorInsertFile($option){
    global $mainframe, $jlistConfig;
    
    $database = &JFactory::getDBO();
    $document = & JFactory::getDocument();
    $lang = & JFactory::getLanguage();
    $lang->load('plg_editors-xtd_jdownloads', JPATH_ADMINISTRATOR);
    
    // build cat tree listbox
    $query = "SELECT cat_id AS id, parent_id AS parent, cat_title AS title FROM #__jdownloads_cats WHERE published = '1' ORDER BY ordering";
    $database->setQuery( $query );
    $cats2 = $database->loadObjectList();
    $preload = array();
    $catlist= treeSelectList( $cats2, 0, $preload, 'cat_id', 'class="inputbox" size="9"', 'value', 'text', '');

    // build files listbox
    $files_list = array();
    
    $query = "SELECT a.cat_id, a.published, a.file_id AS id,"
    . " CONCAT(b.cat_dir, '/', a.file_title, ' ', a.release) AS name"
    . ' FROM #__jdownloads_files AS a'
    . ' LEFT JOIN #__jdownloads_cats AS b ON b.cat_id = a.cat_id'
    . " WHERE a.published = '1'"
    . ' ORDER BY a.cat_id, a.file_title';
    
    $database->setQuery( $query );
    $files = $database->loadObjectList();
    foreach ($files as $file) {
        $files_list[] = JHTML::_('select.option', $file->id, $file->name);
    }
    $files_listbox =  JHTML::_('select.genericlist', $files_list, 'file_id', 'class="inputbox" size="9"', 'value', 'text', '' );
    
    $eName    = JRequest::getVar('e_name');
    $eName    = preg_replace( '#[^A-Z0-9\-\_\[\]]#i', '', $eName );
   
    $js = "
              function insertDownload()
      {
        var file_id = document.getElementById(\"file_id\").value;
        var cat_id = document.getElementById(\"cat_id\").value;
        var count = document.getElementById(\"count\").value;
        var tag;
         
        if (file_id >0){
            tag = \"\{jd_file file==\"+file_id+\"\}\";
        } else {
           if (cat_id > 0){
               tag = \"\{jd_file category==\"+cat_id+\" count==\"+count+\"\}\";
           }    
        }    
        if (file_id || cat_id){                                                                                 
           window.parent.jInsertEditorText(tag, '".$eName."');
           window.parent.SqueezeBox.close();
           return true;     
        }    
        window.parent.SqueezeBox.close();  
        return false;
       }";

        $doc = JFactory::getDocument();
        $doc->addScriptDeclaration($js);
   
    ?>
   
    <body class="jd_editor_body"> 
    <fieldset class="adminform">
    <form name="adminFormLink" id="adminFormLink">
    <table class="jd_editor_body" width="100%" cellpadding="0" cellspacing="2" border="0" style="padding: 0px;">
       <tr> 
         <td colspan="2">
            <img src="<?php echo JURI::root(); ?>administrator/components/com_jdownloads/images/jd_logo_48.png" width="32px" height="32px" align="middle" border="0"/>
            <b><?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_TITLE').'</b><br />'; ?>
            <?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_DESC'); ?>
         </td>
       </tr>
       <tr>
          <td class="key" align="right" width="25%" valign="top">
              <label for="file_id">
                  <?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_FILE_ID_TITLE'); ?>
              </label>
          </td>
          <td width="75%">
              <?php echo $files_listbox; ?>
          </td>
       </tr>
              <tr><td></td><td><small><?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_FILE_ID_NOTE'); ?></small></td></tr>
       <tr><td colspan="2"><hr></td></tr>
            <tr>
                <td class="key" align="right" valign="top">
                    <label for="cat_id">
                        <?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_CAT_ID_TITLE'); ?>
                    </label>
                </td>
                <td>
                   <?php echo $catlist; ?>
                </td>
            </tr>
            <tr>
                <td class="key" align="right" valign="top">
                    <label for="count">
                        <?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_COUNT_TITLE'); ?>
                    </label>
                </td>
                <td>
                   <input type="text" id="count" name="count" value="0" />
                </td>
            </tr>
            <tr><td></td><td><small><?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_COUNT_DESC'); ?></small></td></tr>
            <tr>
                <td class="key" align="right"></td>
                <td>
                    <button onclick="insertDownload();return false;"><?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_CAT_BUTTON_TEXT'); ?></button>
                    <button type="button" onclick="window.parent.SqueezeBox.close();"><?php echo JText::_('JCANCEL') ?></button>                     
                </td>
            </tr>
            <tr><td colspan="2"><small><?php echo JText::_('PLG_EDITORS-XTD_JDOWNLOADS_INFO'); ?></small></td></tr> 
        </table>

        <input type="hidden" name="task" value="" />
        <input type="hidden" name="boxchecked" value="0" />
        <input type="hidden" name="e_name" value="<?php echo $eName; ?>" />
        <?php echo  JHTML::_( 'form.token' ); ?>
        </form>
        </fieldset> 
        </body>  
        <?php
}

function removeEmptyTags($html){
    $pattern = "/<[^\/>]*>([\s]?)*<\/[^>]*>/";
    return preg_replace($pattern, '', $html);
} 

function getRealIp() {
      if(!empty($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP']; // share internet
      } elseif(!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR']; // pass from proxy
      } else {
        $ip = $_SERVER['REMOTE_ADDR'];
      }
      return $ip;
}
  
// need it only, to make it compatible with joomla 1.6 !
function jdgenericlist( $arr, $name, $attribs = null, $key = 'value', $text = 'text', $selected = NULL, $idtag = false, $translate = false )
    {
        if ( is_array( $arr ) ) {
            reset( $arr );
        }

        if (is_array($attribs)) {
            $attribs = JArrayHelper::toString($attribs);
         }

        $id = $name;

        /*if ( $idtag ) {
            $id = $idtag;
        }

        $id        = str_replace('[','',$id);
        $id        = str_replace(']','',$id);
        */
        $html    = '<select name="'. $name .'" id="'. $id .'" '. $attribs .'>';
        $html    .= jdoptions( $arr, $key, $text, $selected, $translate );
        $html    .= '</select>';

        return $html;
    }
    
// need it only, to make it compatible with joomla 1.6 !   
function jdoptions( $arr, $key = 'value', $text = 'text', $selected = null, $translate = false )
    {
        $html = '';

        foreach ($arr as $i => $option)
        {
            $element =& $arr[$i]; // since current doesn't return a reference, need to do this

            $isArray = is_array( $element );
            $extra     = '';
            if ($isArray)
            {
                $k         = $element[$key];
                $t         = $element[$text];
                $id     = ( isset( $element['id'] ) ? $element['id'] : null );
                if(isset($element['disable']) && $element['disable']) {
                    $extra .= ' disabled="disabled"';
                }
            }
            else
            {
                $k         = $element->$key;
                $t         = $element->$text;
                $id     = ( isset( $element->id ) ? $element->id : null );
                if(isset( $element->disable ) && $element->disable) {
                    $extra .= ' disabled="disabled"';
                }
            }

            // This is real dirty, open to suggestions,
            // barring doing a propper object to handle it
            if ($k === '<OPTGROUP>') {
                $html .= '<optgroup label="' . $t . '">';
            } else if ($k === '</OPTGROUP>') {
                $html .= '</optgroup>';
            }
            else
            {
                //if no string after hypen - take hypen out
                $splitText = explode( ' - ', $t, 2 );
                $t = $splitText[0];
                if(isset($splitText[1])){ $t .= ' - '. $splitText[1]; }

                //$extra = '';
                //$extra .= $id ? ' id="' . $arr[$i]->id . '"' : '';
                if (is_array( $selected ))
                {
                    foreach ($selected as $val)
                    {
                        $k2 = is_object( $val ) ? $val->$key : $val;
                        if ($k == $k2)
                        {
                            $extra .= ' selected="selected"';
                            break;
                        }
                    }
                } else {
                    $extra .= ( (string)$k == (string)$selected  ? ' selected="selected"' : '' );
                }

                //if flag translate text
                if ($translate) {
                    $t = JText::_( $t );
                }

                // ensure ampersands are encoded
                $k = JFilterOutput::ampReplace($k);
                $t = JFilterOutput::ampReplace($t);

                $html .= '<option value="'. $k .'" '. $extra .'>' . $t . '</option>';
            }
        }

        return $html;
    }  
    

    
    
    
    
function booleanlist( $name, $attribs = null, $selected = null, $yes='yes', $no='no', $id=false )
    {
        $arr = array(
            JHTML::_('select.option',  '0', JText::_( $no ) ),
            JHTML::_('select.option',  '1', JText::_( $yes ) )
        );
        return jdradiolist($arr, $name, $attribs, 'value', 'text', (int) $selected, $id );
    }  
    
function jdradiolist( $arr, $name, $attribs = null, $key = 'value', $text = 'text', $selected = null, $idtag = false, $translate = false )
    {
        reset( $arr );
        $html = '';
        $html = '<fieldset class="radio">';

        if (is_array($attribs)) {
            $attribs = JArrayHelper::toString($attribs);
         }

        $id_text = $name;
        if ( $idtag ) {
            $id_text = $idtag;
        }

        for ($i=0, $n=count( $arr ); $i < $n; $i++ )
        {
            $k    = $arr[$i]->$key;
            $t    = $translate ? JText::_( $arr[$i]->$text ) : $arr[$i]->$text;
            $id    = ( isset($arr[$i]->id) ? @$arr[$i]->id : null);

            $extra    = '';
            $extra    .= $id ? " id=\"" . $arr[$i]->id . "\"" : '';
            if (is_array( $selected ))
            {
                foreach ($selected as $val)
                {
                    $k2 = is_object( $val ) ? $val->$key : $val;
                    if ($k == $k2)
                    {
                        $extra .= " selected=\"selected\"";
                        break;
                    }
                }
            } else {
                $extra .= ((string)$k == (string)$selected ? " checked=\"checked\"" : '');
            }
            $html .= "\n\t<input type=\"radio\" name=\"$name\" id=\"$id_text$k\" value=\"".$k."\"$extra $attribs />";
            $html .= "\n\t<label for=\"$id_text$k\">$t</label>";
        }
        $html .= '</fieldset>';
        $html .= "\n";
        return $html;
    }   

function getParentsCatsTitles($parent_id){
    $database = &JFactory::getDBO(); 
    $title = '';
    while ($parent_id){
        $database->setQuery("SELECT cat_title, parent_id FROM #__jdownloads_cats WHERE cat_id = '$parent_id'");
        $result = $database->loadObject();
        if ($title){
            $title = $result->cat_title.' / '.$title;
        } else {
            $title = $result->cat_title;
        }    
        $parent_id = $result->parent_id;
    }
    return $title;  
}
   
?>