<?php
/**
* jDownloads 
* @version 1.6.1
* @package 
* @copyright (C) 2010 by Arno Betz - www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
*  
*/
Error_Reporting(E_ERROR & ~E_DEPRECATED);

/* Initialize Joomla framework */
define( '_JEXEC', 1 );
define('JPATH', dirname(__FILE__) );
define( 'DS', DIRECTORY_SEPARATOR );
$parts = explode( DS, JPATH );  
$j_root =  implode( DS, $parts ) ;
$x = array_search ( 'administrator', $parts  );
if (!$x) exit;
for($i=0; $i < $x; $i++){
    $path = $path.$parts[$i].DS; 
}
define('JPATH_BASE', $path );
define('JPATH_SITE', $path );
/* Required Files */
require_once ( JPATH_BASE.DS.'includes'.DS.'defines.php' );
require_once ( JPATH_BASE.DS.'includes'.DS.'framework.php' );
/* To use Joomla's Database Class */
require_once ( JPATH_BASE.DS.'libraries'.DS.'joomla'.DS.'factory.php' );
require_once ( JPATH_BASE.DS.'libraries'.DS.'joomla'.DS.'database'.DS.'table.php' );
// jDownloads database tables class
require_once ( JPATH_BASE.DS.'components'.DS.'com_jdownloads'.DS.'jdownloads.class.php' );
/* Create the Application */
$mainframe =& JFactory::getApplication('site');
$root_path = JPATH_BASE; 
require_once 'ProgressBar.class.php';
$database = &JFactory::getDBO();
$document=& JFactory::getDocument();

// get jd config
$jlistConfig = buildjlistConfig();
$task = 'scan.files';
$lang =& JFactory::getLanguage();
$lang->load('com_jdownloads');

$document->addCustomTag('<meta http-equiv="Expires" content="Fri, Jan 01 1900 00:00:00 GMT">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="en">
<title>jDownloads - Check Download Area Complete</title>');
?>
<style type="text/css">
BODY
{
 FONT-FAMILY: Verdana;
 FONT-SIZE: 8pt;
 COLOR: #222222;
 background-color: #FFFFCC;
 padding: 15;
}
</style>
<?php

$document->setTitle(JText::_('COM_JDOWNLOADS_RUN_MONITORING_TITLE'));

echo '<div  style="font-family:Verdana; font-size:10"><b>'.JText::_('COM_JDOWNLOADS_RUN_MONITORING_INFO2').'</b><br />'.JText::_('COM_JDOWNLOADS_RUN_MONITORING_INFO').'<br /><br /></div>';
ob_flush();
flush();

$time_start = microtime_float();
checkFiles($task);
$time_end = microtime_float();
$time = $time_end - $time_start;

echo '<br /><small>The scan duration: '.number_format ( $time, 2).' seconds.</small>'; 
echo '</body></html>';


/* checkFiles
/
/ check uploaddir and subdirs for variations
/ 
/
*/
function checkFiles($task) {
    global $jlistConfig, $lang;
    ini_set('max_execution_time', '600');
    ignore_user_abort(true);
    ob_flush();
    flush();

    jimport('joomla.filesystem.folder');
    jimport('joomla.filesystem.file');
    
    $database = &JFactory::getDBO();
    //check if all files and dirs in the uploaddir directory are listed
    if($jlistConfig['files.autodetect'] || $task == 'restore.run' || $task == 'scan.files'){
        if(file_exists(JPATH_SITE.$jlistConfig['files.uploaddir']) && $jlistConfig['files.uploaddir'] != ''){
          $startdir       = JPATH_SITE.$jlistConfig['files.uploaddir'].'/';
          $dir_len      = strlen($startdir);
          $dir          = $startdir;
          $only         = FALSE;
          $type         = array();
          if ($jlistConfig['all.files.autodetect']){
              $allFiles     = true;
          } else {   
              $allFiles     = FALSE;
              $type =  explode(',', $jlistConfig['file.types.autodetect']);
          }    
          $recursive    = TRUE;
          $onlyDir      = TRUE;
          $files        = array();
          $file         = array();
          
          $dirlist      = array();
          
          $new_files       = 0;
          $new_dirs_found  = 0;
          $new_dirs_create = 0;
          $new_dirs_errors = 0;
          $new_dirs_exists = 0;
          $new_cats_create = 0;
          $log_message     = '';
          $success         = FALSE;   
          
          $log_array = array();          
          
          // ********************************************   
          // first search new categories
          // ********************************************   
          
          clearstatcache();
          $searchdir    = JPATH_SITE.$jlistConfig['files.uploaddir'].'/';
          $searchdirs   = array();
          $dirlist = searchdir($searchdir);
          
          $no_writable = 0;
          for ($i=0; $i < count($dirlist); $i++) {
              // no tempzifiles directory
              if(strpos($dirlist[$i], 'tempzipfiles') === FALSE) {
                  if (!is_writable($dirlist[$i])){
                      $no_writable++;
                  }
                  $dirlist[$i] = str_replace($searchdir, '', $dirlist[$i]);
                  // delete last slash /
                  if ($pos = strrpos($dirlist[$i], '/')){
                    $searchdirs[] = substr($dirlist[$i], 0, $pos);
                  }
                  // $dirlist[$i] = substr($dirlist[$i], 0, $pos);
                  // $searchdirs[] = $dirlist[$i];
              }
          }  
          unset($dirlist);
          $count_cats = count($searchdirs);
          // first progressbar for cats
          $title1 = JText::_('COM_JDOWNLOADS_RUN_MONITORING_INFO3');
          $bar = new ProgressBar();
          $bar->setMessage($title1);
          $bar->setAutohide(false);
          $bar->setSleepOnFinish(0);
          $bar->setPrecision(100);
          $bar->setForegroundColor('#990000');
          $bar->setBackgroundColor('#CCCCCC');
          $bar->setBarLength(300);
          $bar->initialize($count_cats-1); // print the empty bar

          for ($i=0; $i < count($searchdirs); $i++) {
             $dirs = explode('/', $searchdirs[$i]);
             $sum = count($dirs);
             // this characters are not allowed in foldernames
             if (!eregi("[?!:;\*@#%~=\+\$\^'\"\(\)\<\>]", $searchdirs[$i])) {              
               // check that folder exist
               $database->setQuery("SELECT COUNT(*) FROM #__jdownloads_cats WHERE cat_dir = '$searchdirs[$i]'");
               $cat_da = $database->loadResult(); 
               // when not exist - add it
               if (!$cat_da) {
                   $new_dirs_found++;
                   // create new cat
                   $row = new jlist_cats($database);
                   // bind it to the table
                   if (!$row -> bind($_POST)) {
                       echo "<script> alert('".$row -> getError()."'); window.history.go(-1); </script>\n";
                       exit();
                   }
                   $row->cat_description = '';    
                   $row->cat_title = $dirs[$sum - 1];
                   $row->cat_pic = $jlistConfig['cat.pic.default.filename'];                                 
                   if ($sum > 1) {
                       // get cat_id value for parent_id
                       $parent = substr($searchdirs[$i], 0, strrpos($searchdirs[$i] , '/') );
                       $database->setQuery("SELECT cat_id, cat_access, cat_group_access FROM #__jdownloads_cats WHERE cat_dir = '$parent'");
                       $row_parent = $database->loadObject(); 
                       $row->parent_id = $row_parent->cat_id;
                       $row->cat_access = $row_parent->cat_access;
                       $row->cat_group_access = $row_parent->cat_group_access;
                   }        
                   $row->cat_alias = $row->cat_title;
                   $row->cat_alias = JFilterOutput::stringURLSafe($row->cat_alias);
                   if(trim(str_replace('-','',$row->cat_alias)) == '') {
                        $datenow =& JFactory::getDate();
                        $row->cat_alias = $datenow->toFormat("%Y-%m-%d-%H-%M-%S");
                   }
                   $row->cat_dir = $searchdirs[$i];
                   
                   // set publishing?
                   if ($jlistConfig['autopublish.founded.files']){
                       $row->published = 1;
                   } else {
                       $row->published = 0;
                   }    
                   
                   // get a correct ordering value
                   if (!$row->ordering) {
                       $row->ordering = $row->getNextOrder();
                   }    
                   if (!$row -> store()) {
                       echo "<script> alert('".$row -> getError()."'); window.history.go(-1); </script>\n";
                       exit();
                   } else {
                       if(!$row->cat_id) $row->cat_id = mysql_insert_id();
                   }
                   $new_cats_create++;
                   // copy index.html to the new folder
                   $index_copied = JFile::copy(JPATH_SITE.DS.$jlistConfig['files.uploaddir'].DS.'index.html', JPATH_SITE.DS.$jlistConfig['files.uploaddir'].DS.$searchdirs[$i].DS.'index.html');
                   $log_array[] = date($jlistConfig['global.datetime']).' - '.JText::_('COM_JDOWNLOADS_AUTO_CAT_CHECK_ADDED').' <b>'.$searchdirs[$i].'</b><br />';
               }
             }  else {
                // folder with illegal characters in name founded - create msg
                $log_array[] = date($jlistConfig['global.datetime']).' -  <b>'.$searchdirs[$i].'</b><font color="red"> '.JText::_('COM_JDOWNLOADS_AUTO_CAT_CHECK_ILLEGAL_NAME_FOUND_MSG').'</font><br />';
             }
             $bar->increase(); // calls the bar with every processed element    
          }
          echo '<small><br />'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_SUM_FOLDERS').' '.count($searchdirs).'<br /><br /></small>';   
          ob_flush();
          flush();      
          
          unset($dirs);
          unset($searchdirs);
          
          // ********************************************
          // exists all published categorie folders?
          // ********************************************
          
          $mis_cats = 0;
          $database->setQuery("SELECT * FROM #__jdownloads_cats WHERE published=1");
          $cats = $database->loadObjectList();
          
          $count_cats = count($cats);
          // first progressbar for cats
          $bar = new ProgressBar();
          $title2 = JText::_('COM_JDOWNLOADS_RUN_MONITORING_INFO4');  
          $bar->setMessage($title2);
          $bar->setAutohide(false);
          $bar->setSleepOnFinish(0);
          $bar->setPrecision(100);
          $bar->setForegroundColor('#990000');
          $bar->setBarLength(300);
          $bar->initialize($count_cats); // print the empty bar          
          
          foreach($cats as $cat){
                $cat_dir = $searchdir.$cat->cat_dir;
                // wenn nicht da - unpublishen
                if(!is_dir($cat_dir)){
                    $database->setQuery("UPDATE #__jdownloads_cats SET published = 0 WHERE cat_id = '$cat->cat_id'");
                    $database->query();
                    $mis_cats++;
                    $log_array[] = date($jlistConfig['global.datetime']).' - <font color="red">'.JText::_('COM_JDOWNLOADS_AUTO_CAT_CHECK_DISABLED').' <b>'.$cat->cat_dir.'</b></font><br />';
               } 
               $bar->increase(); // calls the bar with every processed element  
          }
          echo '<br /><br />';   
           // when add categories - the access rigts must checked from all
          if ($new_cats_create){
            //  $sum = set_rights_of_cat (0, '00', $sum);    // all cats will checked   
          }   
          
          unset($cats);
          
          // ****************************************************             
          // search all files and compare it with the files table
          // ****************************************************   
                    
          $all_dirs = scan_dir($dir, $type, $only, $allFiles, $recursive, $onlyDir, $files);
          if ($all_dirs != FALSE) {
              $count_files = count($files);
              // first progressbar for cats
              $bar = new ProgressBar();
              $title3 = JText::_('COM_JDOWNLOADS_RUN_MONITORING_INFO5');  
              $bar->setMessage($title3);
              $bar->setAutohide(false);
              $bar->setSleepOnFinish(0);
              $bar->setPrecision(100);
              $bar->setForegroundColor('#990000');
              $bar->setBarLength(300);
              $bar->initialize($count_files); // print the empty bar          
              
              reset ($files);
              $new_files = 0;
              foreach($files as $key3 => $array2) {
                  $file_thumbnail = '';
                  $file_thumbnail2 = '';
                  $file_thumbnail3 = '';                  
                  $filename = $files[$key3]['file'];
                   if ($filename <> '' && substr($filename, 0, 1) !== '.') {
                      // no files in tempzipfiles and jD root directory
                     if(strpos($files[$key3]['path'], 'tempzipfiles') === FALSE && $files[$key3]['path'] != $startdir) {
                         $dir_path_total = $files[$key3]['path'];
                         $restpath = substr($files[$key3]['path'], $dir_len);
                         $only_dirs = substr($restpath, 0, strlen($restpath) - 1);
                         $upload_dir = '/'.$jlistConfig['files.uploaddir'].'/'.$only_dirs.'/';
                         // existiert filename in files?
                         $exist_file = false;
                         $database->setQuery("SELECT cat_id FROM #__jdownloads_files WHERE url_download = '".$filename."'");
                         $row_file_exists = $database->loadObjectList();
                         // wenn da - in cats suchen
                         if ($row_file_exists) {
                            foreach ($row_file_exists as $row_file_exist) {
                              if (!$exist_file) { 
                                $database->setQuery("SELECT COUNT(*) FROM #__jdownloads_cats WHERE cat_dir = '$only_dirs' AND cat_id = '$row_file_exist->cat_id'" );
                                $row_cat_find = $database->loadResult();               
                               
                                if ($row_cat_find) {
                                    $exist_file = true;
                                } else {
                                   $exist_file = false;                                    
                                }    
                              }
                            }     
                         }  else {
                              $exist_file = false;
                         }    
                         
                         if(!$exist_file) {
                           // not check the filename when restore backup file
                           if ($task != 'restore.run'){  
                              $filename_new = checkFileName($filename);
                              if ($filename_new != $filename) {
                                if ($filename_new != $filename){
                                  $success = @rename($startdir.$only_dirs.'/'.$filename, $startdir.$only_dirs.'/'.$filename_new); 
                                  if ($success) {
                                      $filename = $filename_new; 
                                  } else {
                                      // could not rename filename
                                  }
                                } else {
                                  $filename = $filename_new;
                                }     
                              }
                           }
                            $target_path = JPATH_SITE.$upload_dir.$filename;     
                            $database->setQuery("SELECT cat_id FROM #__jdownloads_cats WHERE cat_dir = '$only_dirs'");
                            $cat_id = $database->loadResult();
                            if ($cat_id) {
                                $date =& JFactory::getDate();
                                $date->setOffset(JFactory::getApplication()->getCfg('offset'));

                                $file_extension = strtolower(substr(strrchr($filename,"."),1)); 
                                // fill the data
                                $file_file_id = 0;
                                $file_url_download   = $filename;
                                $file_file_title     = str_replace('.'.$file_extension, '', $filename); 
                                $file_size           = $files[$key3]['size'];
                                $file_description    = '';                                                                                       
                                $file_date_added     = $date->toFormat('%Y-%m-%d %H:%M:%S'); 
                                $file_file_date      = '0000-00-00 00:00:00';
                                $file_cat_id         = $cat_id;
                                $file_file_alias = $file_file_title;
                                $file_file_alias = JFilterOutput::stringURLSafe($file_file_alias);
                                if(trim(str_replace('-','',$file_file_alias)) == '') {
                                    $datenow =& JFactory::getDate();
                                    $file_file_alias = $datenow->toFormat("%Y-%m-%d %H:%M:%S");
                                }
                                $filepfad = JPATH_SITE.'images/jdownloads/fileimages/'.$file_extension.'.png';
                                if(file_exists(JPATH_SITE.'images/jdownloads/fileimages/'.$file_extension.'.png')){
                                    $file_file_pic       = $file_extension.'.png';
                                } else {
                                    $file_file_pic       = $jlistConfig['file.pic.default.filename'];
                                }
                                $file_created_by     = JText::_('COM_JDOWNLOADS_AUTO_FILE_CHECK_IMPORT_BY');
                                
                                // create thumbs form pdf
                                if ($jlistConfig['create.pdf.thumbs'] && $jlistConfig['create.pdf.thumbs.by.scan'] && $file_extension == 'pdf'){
                                   $only_name = substr($filename_new, 0, strrpos($filename_new, '.'));
                                   $thumb_path = JPATH_SITE.'/images/jdownloads/screenshots/thumbnails/';
                                   $screenshot_path = JPATH_SITE.'/images/jdownloads/screenshots/';
                                   $pdf_tumb_name = create_new_pdf_thumb($target_path, $only_name, $thumb_path, $screenshot_path);
                                   if ($pdf_tumb_name){
                                       // add thumb file name to thumbnail data field
                                       if ($file_thumbnail == ''){
                                            $file_thumbnail = $pdf_tumb_name;
                                       } elseif ($file_thumbnail2 == '') {
                                            $file_thumbnail2 = $pdf_tumb_name;  
                                       } else {
                                             $file_thumbnail3 = $pdf_tumb_name;  
                                       }   
                                   }    
                                }
                                // create auto thumb when extension is a pic
                                if ($jlistConfig['create.auto.thumbs.from.pics'] && $jlistConfig['create.auto.thumbs.from.pics.by.scan'] && ($file_extension == 'gif' || $file_extension == 'png' || $file_extension == 'jpg')){
                                  $thumb_created = create_new_thumb($target_path);       
                                  if ($thumb_created){
                                      // add thumb file name to thumbnail data field
                                      $file_thumbnail = $filename_new;  
                                  }
                                  // create new big image for full view
                                  $image_created = create_new_image($target_path);
                                }
                                
                                // publish only when option is activated
                                if ($jlistConfig['autopublish.founded.files']){
                                    $file_published = 1;
                                } else {
                                    $file_published = 0;
                                }    
                                
                                $database->setQuery("INSERT INTO #__jdownloads_files (`file_id`, `file_title`, `file_alias`, `description`, `description_long`, `file_pic`, `thumbnail`, `thumbnail2`, `thumbnail3`, `price`, `release`, `language`, `system`, `license`, `url_license`, `update_active`, `cat_id`, `metakey`, `metadesc`, `size`, `date_added`, `file_date`, `publish_from`, `publish_to`, `url_download`, `extern_file`, `url_home`, `author`, `url_author`, `created_by`, `created_mail`, `modified_by`, `modified_date`, `submitted_by`, `downloads`, `ordering`, `published`, `checked_out`, `checked_out_time`)
                                VALUES ('', '$file_file_title', '$file_file_alias', '$file_description', '$file_description_long', '$file_file_pic', '$file_thumbnail', '$file_thumbnail2', '$file_thumbnail3', '', '', '', '', '', '', '', '$file_cat_id', '', '', '$file_size', '$file_date_added', '$file_file_date', '', '', '$file_url_download', '', '', '', '', '$file_created_by', '', '', '', '', '', '$file_ordering', '$file_published', '0', '0000-00-00 00:00:00')");
                                if (!$database->query()) {
                                    echo $database->stderr();
                                    exit;
                                } else {
                                    if (!$file_file_id) $file_file_id = mysql_insert_id();
                                    if ($file_file_id){
                                        $database->setQuery("SELECT max(ordering) FROM #__jdownloads_files WHERE cat_id = '$file_cat_id'");
                                        $ord = (int)$database->loadResult() + 1;
                                        $database->setQuery("UPDATE #__jdownloads_files SET ordering = '$ord' WHERE file_id = '$file_file_id'");     
                                        $database->query();
                                    }    
                                }    
                                $new_files++;
                                $log_array[] = date($jlistConfig['global.datetime']).' - '.JText::_('COM_JDOWNLOADS_AUTO_FILE_CHECK_ADDED').' <b>'.$only_dirs.'/'.$filename.'</b><br />';
                            } else {
                                // cat dir not exist or invalid name
                                
                            }        
                         }                   
                      }
                  }
                  $bar->increase(); // calls the bar with every processed element
                  // unset($database->_log);
              }  
          }                    
          echo '<small><br />'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_SUM_FILES').' '.count($files).'<br /><br /></small>';   
          // unset($database->_log);
          unset($files);
          flush();
          
          //prüfen ob download dateien alle physisch vorhanden - sonst unpublishen
          $mis_files = 0;
          $database->setQuery("SELECT * FROM #__jdownloads_files WHERE published=1");
          $files = $database->loadObjectList();
          
          $count_files = count($files);
          // first progressbar for cats
          $bar = new ProgressBar();
          $title4 = JText::_('COM_JDOWNLOADS_RUN_MONITORING_INFO6');
          $bar->setMessage($title4);
          $bar->setAutohide(false);
          $bar->setSleepOnFinish(0);
          $bar->setPrecision(100);
          $bar->setForegroundColor('#990000');
          $bar->setBarLength(300);
          $bar->initialize($count_files); // print the empty bar

          foreach($files as $file){
              // nur interne files testen
              if ($file->url_download <> ''){   
                $database->setQuery("SELECT cat_dir FROM #__jdownloads_cats WHERE cat_id = '$file->cat_id'");
                $cat_dir = $database->loadResult();  
                $cat_dir_long = $startdir.$cat_dir.'/'.$file->url_download;
                // wenn nicht da - unpublishen
                if(!is_file($cat_dir_long)){
                    $database->setQuery("UPDATE #__jdownloads_files SET published = 0 WHERE file_id = '$file->file_id'");
                    $database->query();
                    $mis_files++;
                    $log_array[] = date($jlistConfig['global.datetime']).' - <font color="red">'.JText::_('COM_JDOWNLOADS_AUTO_FILE_CHECK_DISABLED').' <b>'.$cat_dir.'/'.$file->url_download.'</b></font><br />';
               }  
             }
             $bar->increase(); // calls the bar with every processed element 
          }
          echo '<br /><br />';
          echo '<div style="font-family:Verdana; font-size:10"><b>'.JText::_('COM_JDOWNLOADS_RUN_MONITORING_INFO7').'</b><br /><br /></div>';
          flush(); 
       
       // save log
       foreach ($log_array as $log) {
            $log_message .= $log;
       }
       if ($task != 'restore.run'){
           $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '$log_message' WHERE setting_name = 'last.log.message'");
           $database->query();
           $jlistConfig['last.log.message'] = $log_message;
       }     
              
        if ($task == 'scan.files') {
            echo '<table width="100%"><tr><td><font size="1" face="Verdana">'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_TITLE').'</font><br />';
            if ($new_cats_create > 0){
                echo '<font color="#FF6600" size="1" face="Verdana"><b>'.$new_cats_create.' '.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_NEW_CATS').'</b></font><br />';
            } else {
                echo '<font color="green" size="1" face="Verdana"><b>'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_NO_NEW_CATS').'</b></font><br />';
            }
            
            if ($new_files > 0){
                echo '<font color="#FF6600" size="1" face="Verdana"><b>'.$new_files.' '.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_NEW_FILES').'</b></font><br />';
            } else {
                echo '<font color="green" size="1" face="Verdana"><b>'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_NO_NEW_FILES').'</b></font><br />';
            }            
            
            if ($mis_cats > 0){
                echo '<font color="#990000" size="1" face="Verdana"><b>'.$mis_cats.' '.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_MISSING_CATS').'</b></font><br />';
            } else {
                echo '<font color="green" size="1" face="Verdana"><b>'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_NO_MISSING_CATS').'</b></font><br />';
            }    
            
            if ($mis_files > 0){
                echo '<font color="#990000"  size="1" face="Verdana"><b>'.$mis_files.' '.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_MISSING_FILES').'</b><br /></td></tr></table>';
            } else {
                echo '<font color="green" size="1" face="Verdana"><b>'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_NO_MISSING_FILES').'</b><br /></td></tr></table>';
            }
        
            if ($log_message)  echo '<table width="100%"><tr><td><font size="1" face="Verdana">'.JText::_('COM_JDOWNLOADS_BACKEND_AUTOCHECK_LOG_TITLE').'<br />'.$log_message.'</font></td></tr></table>';

        } 
        } else {
            // error upload dir not exists
            echo '<font color="red"><b>'.JText::_('COM_JDOWNLOADS_AUTOCHECK_DIR_NOT_EXIST').'<br /><br />'.JText::_('COM_JDOWNLOADS_AUTOCHECK_DIR_NOT_EXIST_2').'</b></font>';
            
        }
    }            
}


// get all dirs und subdirs for upload
// $path : path to browse
// $maxdepth : how deep to browse (-1=unlimited)
// $mode : "FULL"|"DIRS"|"FILES"
// $d : must not be defined

function searchdir ( $path , $maxdepth = -1 , $mode = "DIRS" , $d = 0 ) {
   if ( substr ( $path , strlen ( $path ) - 1 ) != '/' ) { $path .= '/' ; }
   $dirlist = array () ;
   if ( $mode != "FILES" ) {
       $dirlist[] = $path ;
   }
   if ( $handle = opendir ( $path ) ) {
       while ( false !== ( $file = readdir ( $handle ) ) ) {
           if ( $file != '.' && $file != '..' && substr($file, 0, 1) !== '.') {
               $file = $path . $file ;
               if ( ! is_dir ( $file ) ) {
                  if ( $mode != "DIRS" ) {
                   $dirlist[] = $file ;
                  }
               }
               elseif ( $d >=0 && ($d < $maxdepth || $maxdepth < 0) ) {
                   $result = searchdir ( $file . '/' , $maxdepth , $mode , $d + 1 ) ;
                   $dirlist = array_merge ( $dirlist , $result ) ;
               }
               }
       }
       closedir ( $handle ) ;
   }
   if ( $d == 0 ) { 
       natcasesort ( $dirlist ) ;
   }
   return ( $dirlist ) ;
}

function scan_dir($dir, $type=array(),$only=FALSE, $allFiles=FALSE, $recursive=TRUE, $onlyDir="", &$files){
    $handle = @opendir($dir);
    if(!$handle)
        return false;
    while ($file = @readdir ($handle))
    {
        if (eregi("^\.{1,2}$",$file) || $file == 'index.html')
        {
            continue;
        }
        if(!$recursive && $dir != $dir.$file."/")
        {
            if(is_dir($dir.$file))
                continue;
        }
        if(is_dir($dir.$file))
        {
            scan_dir($dir.$file."/", $type, $only, $allFiles, $recursive, $file, $files);
        }
        else
        {
   if($only)
                $onlyDir = $dir;

            $files = buildArray($dir,$file,$onlyDir,$type,$allFiles,$files);
        }
    }
    @closedir($handle);
    return $files;
}

/**
 * Füllt das Array mit den Dateiinformationen
 * (Pfad, Verzeichnisname, Dateiname, Dateigröße, letzte Aktualisierung
 *
 * @param        string    $dir             Pfad zum Verzeichnis
 * @param        string    $file            enthält den Dateinamen
 * @param        string    $onlyDir        Enthält nur den Verzeichnisnamen
 * @param        array        $type        Suchmuster dateitypen
 * @param        bool        $allFiles    Listet alle Dateien in den Verzeichnissen auf ohne Rücksicht auf $type
 * @param        array        $files        Enthält den Inhalt der Verzeichnisstruktur
 * @return    array                        Das Array mit allen Dateinamen
 */
function buildArray($dir,$file,$onlyDir,$type,$allFiles,$files) {

    $typeFormat = FALSE;
    foreach ($type as $item)
  {
      if (strtolower($item) == substr(strtolower($file), -strlen($item)))
            $typeFormat = TRUE;
    }

    if($allFiles || $typeFormat == TRUE)
    {
        if(empty($onlyDir))
            $onlyDir = substr($dir, -strlen($dir), -1);
        $files[$dir.$file]['path'] = $dir;
        $files[$dir.$file]['file'] = $file;
        $files[$dir.$file]['size'] = fsize($dir.$file);
        $files[$dir.$file]['date'] = filemtime($dir.$file);
    }
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
  
function buildjlistConfig(){
    $database = &JFactory::getDBO();
    $jlistConfig = array();
    $database->setQuery("SELECT setting_name, setting_value FROM #__jdownloads_config");
    $jlistConfigObj = $database->loadObjectList();
    if(!empty($jlistConfigObj)){
        foreach ($jlistConfigObj as $jlistConfigRow){
            $jlistConfig[$jlistConfigRow->setting_name] = $jlistConfigRow->setting_value;
        }
    }
    return $jlistConfig;
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
    }               
    return $name; 
}

/*
 * Simple function to replicate PHP 5 behaviour
 */
function microtime_float(){
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
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

    $maxwidth = $jlistConfig['thumbnail.size.width'];
    $maxheight = $jlistConfig['thumbnail.size.height'];
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
?>