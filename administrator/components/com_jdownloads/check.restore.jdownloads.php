<?php
/**
* @version 1.6
* @package JDownloads
* @copyright (C) 2009 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* functions to check db after restore backup file!
*
*/

defined( '_JEXEC' ) or die( 'Restricted access' );
  

function checkAfterRestore() {
    global $jlistConfig;
    $database = &JFactory::getDBO();

    // insert the new default header, subheader and footer layouts in every layout.
    require_once(JPATH_SITE."/administrator/components/com_jdownloads/helpers/jd_layouts.php");

    
  //*********************************************
  // JD VERSION:
     $jd_version = '1.9.0';
     $jd_version_state = 'Stable';
     $jd_version_svn = '909'; 
  //*********************************************
    
    $output = '';
    
//********************************************************************************************
// insert default config data - if not exist
// *******************************************************************************************
      $root_dir = '';
      $sum_configs = 0;
      
        $database->setQuery("SELECT * FROM #__jdownloads_config WHERE setting_name = 'files.uploaddir'");
        $temp = $database->loadResult();
        if (!$temp) {
            $database->SetQuery("INSERT INTO #__jdownloads_config (setting_name, setting_value) VALUES ('files.uploaddir', 'jdownloads')");
            $database->query();
            $sum_configs++;
        }  else {
            $database->setQuery("SELECT setting_value FROM #__jdownloads_config WHERE setting_name = 'files.uploaddir'");
            $dir = $database->loadResult();
            $root_dir = JPATH_SITE.'/'.$dir.'/';   
        }    

        
        $database->setQuery("SELECT * FROM #__jdownloads_config WHERE setting_name = 'global.datetime'");
        $temp = $database->loadResult();
        if (!$temp) {
            $database->SetQuery("INSERT INTO #__jdownloads_config (setting_name, setting_value) VALUES ('global.datetime', '".JText::_('COM_JDOWNLOADS_INSTALL_DEFAULT_DATE_FORMAT')."')");
            $database->query();
            $sum_configs++;
        } else {
            $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '".JText::_('COM_JDOWNLOADS_INSTALL_DEFAULT_DATE_FORMAT')."' WHERE setting_name = 'global.datetime'");
            $database->query();
            $jlistConfig['global.datetime'] = JText::_('COM_JDOWNLOADS_INSTALL_DEFAULT_DATE_FORMAT');
        }
        
        $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '0' WHERE setting_name = 'jcomments.active'");
        $database->query();
        $jlistConfig['jcomments.active'] = '0';
        
        
        $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '0' WHERE setting_name = 'view.jom.comment'");
        $database->query();
        $jlistConfig['view.jom.comment'] = '0';
        
                
        /*
        // new param für versionsnummer von jd
        $database->setQuery("SELECT * FROM #__jdownloads_config WHERE setting_name = 'jd.version'");
        $temp = $database->loadResult();
        if (!$temp) {
            $database->SetQuery("INSERT INTO #__jdownloads_config (setting_name, setting_value) VALUES ('jd.version','$jd_version')");
            $database->query();
            $sum_configs++;
        } else {
            // set new value
            $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '$jd_version' WHERE setting_name = 'jd.version'");  
            $database->query();
        } 
        
        // new param für versions status von jd
        $database->setQuery("SELECT * FROM #__jdownloads_config WHERE setting_name = 'jd.version.state'");
        $temp = $database->loadResult();
        if (!$temp) {
            $database->SetQuery("INSERT INTO #__jdownloads_config (setting_name, setting_value) VALUES ('jd.version.state','$jd_version_state')");
            $database->query();
            $sum_configs++;
        } else {
            // set new value
            $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '$jd_version_state' WHERE setting_name = 'jd.version.state'");  
            $database->query();
        }    

        // new param für svn version von jd
        $database->setQuery("SELECT * FROM #__jdownloads_config WHERE setting_name = 'jd.version.svn'");
        $temp = $database->loadResult();
        if (!$temp) {
            $database->SetQuery("INSERT INTO #__jdownloads_config (setting_name, setting_value) VALUES ('jd.version.svn','$jd_version_svn')");
            $database->query();
            $sum_configs++;
        } else {
            // set new value
            $database->setQuery("UPDATE #__jdownloads_config SET setting_value = '$jd_version_svn' WHERE setting_name = 'jd.version.svn'");  
            $database->query();
        }
        */
         // new in 1.5
        
                          
        if ($sum_configs == 0) {
            $output .= '<font color="green"><strong> '.JText::_('COM_JDOWNLOADS_INSTALL_1').'</strong></font><br />';
        } else {
            $output .= '<font color="green"> '.$sum_configs.' '.JText::_('COM_JDOWNLOADS_INSTALL_2').'</font><br />';
        }

        //***************************** config data end **********************************************

        // add new fields for joomla 1.6 version
        $sum_added_fields = 0;
        $prefix = $database->getPrefix();
        $tables = array( $prefix.'jdownloads_cats' );
        $result = $database->getTableFields( $tables );
        
        if (!$result[$prefix.'jdownloads_cats']['jaccess']){
            $database->SetQuery("ALTER TABLE #__jdownloads_cats ADD jaccess TINYINT(3) NOT NULL DEFAULT 0 AFTER metadesc");
            if ($database->query()) {
                $sum_added_fields++;
            }
            $database->SetQuery("ALTER TABLE #__jdownloads_cats ADD jlanguage VARCHAR(7) NOT NULL DEFAULT '' AFTER jaccess");
            if ($database->query()) {
                $sum_added_fields++;
            }      
        }

        $tables = array( $prefix.'jdownloads_files' );
        $result = $database->getTableFields( $tables );
        
        if (!$result[$prefix.'jdownloads_files']['jaccess']){
            $database->SetQuery("ALTER TABLE #__jdownloads_files ADD jaccess TINYINT(3) NOT NULL DEFAULT 0 AFTER custom_field_14");
            if ($database->query()) {
                $sum_added_fields++;
            } 
            $database->SetQuery("ALTER TABLE #__jdownloads_files ADD jlanguage VARCHAR(7) NOT NULL DEFAULT '' AFTER jaccess"); 
            if ($database->query()) {
                $sum_added_fields++;   
            }
        }

        if (!$result[$prefix.'jdownloads_files']['created_id']){
            $database->SetQuery("ALTER TABLE #__jdownloads_files ADD created_id INT(11) NOT NULL DEFAULT 0 AFTER created_by");
            if ($database->query()) {
                $sum_added_fields++;
            } 
            $database->SetQuery("ALTER TABLE #__jdownloads_files ADD modified_id INT(11) NOT NULL DEFAULT 0 AFTER modified_by");
            if ($database->query()) {
                $sum_added_fields++;   
            }
        }
        
        $tables = array( $prefix.'jdownloads_license' );
        $result = $database->getTableFields( $tables );
        
        if (!$result[$prefix.'jdownloads_license']['jlanguage']){
            $database->SetQuery("ALTER TABLE #__jdownloads_license ADD jlanguage VARCHAR(7) NOT NULL DEFAULT '' AFTER license_url"); 
            if ($database->query()) {
                $sum_added_fields++;   
            }
        }        
        
        $tables = array( $prefix.'jdownloads_templates' );
        $result = $database->getTableFields( $tables );
        
        if (!$result[$prefix.'jdownloads_templates']['jlanguage']){
            $database->SetQuery("ALTER TABLE #__jdownloads_templates ADD jlanguage VARCHAR(7) NOT NULL DEFAULT '' AFTER symbol_off"); 
            if ($database->query()) {
                $sum_added_fields++;   
            }
        }
        
        $tables = array( $prefix.'jdownloads_groups' );
        $result = $database->getTableFields( $tables );
        
        if (!$result[$prefix.'jdownloads_groups']['jlanguage']){
            $database->SetQuery("ALTER TABLE #__jdownloads_groups ADD jlanguage VARCHAR(7) NOT NULL DEFAULT '' AFTER groups_members"); 
            if ($database->query()) {
                $sum_added_fields++;   
            }
        }        
        
        $tables = array( $prefix.'jdownloads_log' );
        $result = $database->getTableFields( $tables );
        
        if (!$result[$prefix.'jdownloads_log']['jlanguage']){
            $database->SetQuery("ALTER TABLE #__jdownloads_log ADD jlanguage VARCHAR(7) NOT NULL DEFAULT '' AFTER log_browser"); 
            if ($database->query()) {
                $sum_added_fields++;   
            }
        }         
        
        $tables = array( $prefix.'jdownloads_rating' );
        $result = $database->getTableFields( $tables );
        
        if (!$result[$prefix.'jdownloads_rating']['jlanguage']){
            $database->SetQuery("ALTER TABLE #__jdownloads_rating ADD jlanguage VARCHAR(7) NOT NULL DEFAULT '' AFTER lastip"); 
            if ($database->query()) {
                $sum_added_fields++;   
            }
        }        
        
        if ($sum_added_fields == 0) {
            $output .= "<font color='green'><strong> ".JText::_('COM_JDOWNLOADS_INSTALL_1_2')."</strong></font><br />";
        } else {
            $output .= "<font color='green'> ".$sum_added_fields." ".JText::_('COM_JDOWNLOADS_INSTALL_2_2')."</font><br />";        
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

   
   return $output;
}      
?>