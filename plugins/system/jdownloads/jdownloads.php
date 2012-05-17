<?php
/**
* @version 1.2
* @package JDownloads
* @copyright (C) 2011 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* Plugin to handle the auto publishing timeframe options.
* In v1.2 added the hide function.
*/

defined( '_JEXEC' ) or die( 'Restricted access' );
//Error_Reporting(E_ERROR);   

jimport('joomla.plugin.plugin'); 
  class plgSystemjdownloads extends JPlugin { 
     
     function plgSystemjdownloads (&$subject, $config) { 
        parent::__construct( $subject, $config ); 
     } 

     function onAfterInitialise() { 
     
         $app = &JFactory::getApplication();
         $database = &JFactory::getDBO();

         // exist the tables?
         $prefix = $database->getPrefix(); 
         $tablelist = $database->getTableList();
         if ( !in_array ( $prefix.'jdownloads_files', $tablelist ) ){
             return;
         } 
         
         $plugin =& JPluginHelper::getPlugin('system', 'jdownloads');
         jimport( 'joomla.utilities.utility' );
         // get params
         $params = new JRegistry();
         $params->loadJSON($plugin->params);
         
         //$use_hider = $params->get( 'reduce_log_data_sets_to' );
         //if (!$use_hider) $return = true;   
         
         // No need in admin
         //if( $app->isAdmin() ) return;

         $j = date('Y');
         $m = date('m');
         $d = date('d');
         $h = date('H');
         $min = date('i');
         $sec = date('s');
         
         $unpublish_time = date('Y-m-d H:i:s',mktime($h,$min,$sec,$m,$d-1,$j));
         $now = date('Y-m-d H:i:s');
         
         // get all published files with use the timeframe options
         $database->setQuery("SELECT file_id from #__jdownloads_files WHERE published = 1 AND use_timeframe = 1 AND publish_to != '0000-00-00 00:00:00' AND publish_to <= '$now'");
         $files = $database->loadResultArray();
         if ($files){
                $fileslist = implode(',', $files);  
                $database->setQuery("UPDATE #__jdownloads_files SET published = '0', use_timeframe = '0' WHERE file_id IN ('$fileslist')"); 
                $database->query(); 
         }
         // get all unpublished files with use the timeframe options
         $database->setQuery("SELECT file_id from #__jdownloads_files WHERE published = 0 AND use_timeframe = 1 AND publish_from != '0000-00-00 00:00:00' AND publish_from <= '$now'");
         $files = $database->loadResultArray();
         if ($files){
                $fileslist = implode(',', $files);  
                $database->setQuery("UPDATE #__jdownloads_files SET published = '1' WHERE file_id IN ('$fileslist')"); 
                $database->query(); 
         }
         return;  
     }
     
    // Functions for hide elements from output for special user groups
    // Inspired by the hider content plugin from Dioscouri Design
    // Part of this functions are copyright by Dioscouri Design - www.dioscouri.com 
    
    function _reg( &$matches ) {
        $user = JFactory::getUser();
        $return = '';
        if ($user->id) { $return = $matches[1]; }
        return $return;
    }

    function _pub( &$matches ) {
        $user = JFactory::getUser();
        $return = $matches[1];
        if ($user->id) { $return = ''; }
        return $return;
    }

    function _author( &$matches ) {
        $user = JFactory::getUser();
        $coreUserGroups = $user->getAuthorisedGroups();
        $return = $matches[1];
        if (!in_array(3,$coreUserGroups) && !in_array(8,$coreUserGroups)){
            $return = '';
        }
        return $return;
    }

    function _editor( &$matches ) {
        $user = JFactory::getUser();
        $coreUserGroups = $user->getAuthorisedGroups();
        $return = $matches[1];
        if (!in_array(4,$coreUserGroups) && !in_array(8,$coreUserGroups)){
            $return = '';
        }
        return $return;
    }

    function _publisher( &$matches ) {
        $user = JFactory::getUser();
        $coreUserGroups = $user->getAuthorisedGroups();
        $return = $matches[1];
        if (!in_array(5,$coreUserGroups) && !in_array(8,$coreUserGroups)){
            $return = '';
        }
        return $return;
    }

    function _manager( &$matches ) {
        $user = JFactory::getUser();
        $coreUserGroups = $user->getAuthorisedGroups();
        $return = $matches[1];
        if (!in_array(6,$coreUserGroups) && !in_array(8,$coreUserGroups)){
            $return = '';
        }
        return $return;
    }

    function _admin( &$matches ) {
        $user = JFactory::getUser();
        $coreUserGroups = $user->getAuthorisedGroups();
        $return = $matches[1];
        if (!in_array(7,$coreUserGroups) && !in_array(8,$coreUserGroups)){
            $return = '';
        }
        return $return;
    }

    function _super( &$matches ) {
        $user = JFactory::getUser();
        $coreUserGroups = $user->getAuthorisedGroups();
        $return = $matches[1];
        if (!in_array(8,$coreUserGroups)){
            $return = '';
        }
        return $return;
    }
    
    function _special( &$matches ) {
        $user = JFactory::getUser();
        $aid = max ($user->getAuthorisedViewLevels());
        $return = $matches[1];
        if ($aid != 3){
            $return = '';
        }
        return $return;
    }    

    function onAfterRender() { 
         $app = &JFactory::getApplication();
         $database = &JFactory::getDBO();
         $return = false;
         
         // exist the tables?
         $prefix = $database->getPrefix(); 
         $tablelist = $database->getTableList();
         if ( !in_array ( $prefix.'jdownloads_files', $tablelist ) ){
             $return = true;
         }     
         $plugin =& JPluginHelper::getPlugin('system', 'jdownloads');
         jimport( 'joomla.utilities.utility' );
         // get params
         $params = new JRegistry();
         $params->loadJSON($plugin->params);
         $use_hider = $params->get( 'use_hider' );
         if (!$use_hider) $return = true;
    
         // No need in admin
         if (!$app->isAdmin()) {
             $body = JResponse::getBody();
             if (!$return){
             
                function _getParameter( $name, $default='' ) {
                    $return = "";
                    $return = $this->params->get( $name, $default );
                }
                
                // define the regular expression
                $regex1 = "#{jdreg}(.*?){/jdreg}#s";
                $regex2 = "#{jdpub}(.*?){/jdpub}#s";
    
                $regex3 = "#{jdauthor}(.*?){/jdauthor}#s";
                $regex4 = "#{jdeditor}(.*?){/jdeditor}#s";
                $regex5 = "#{jdpublisher}(.*?){/jdpublisher}#s";
                $regex6 = "#{jdmanager}(.*?){/jdmanager}#s";
                $regex7 = "#{jdadmin}(.*?){/jdadmin}#s";
                $regex8 = "#{jdsuper}(.*?){/jdsuper}#s";
                $regex9 = "#{jdspecial}(.*?){/jdspecial}#s";
                
                // replacement for _reg
                $body = preg_replace_callback( $regex1, array('plgSystemjdownloads', '_reg'), $body );
                // replacement for _pub
                $body = preg_replace_callback( $regex2, array('plgSystemjdownloads', '_pub'), $body );
                // replacements for groups by name
                $body = preg_replace_callback( $regex9, array('plgSystemjdownloads', '_special'), $body );
                $body = preg_replace_callback( $regex3, array('plgSystemjdownloads', '_author'), $body );
                $body = preg_replace_callback( $regex4, array('plgSystemjdownloads', '_editor'), $body );
                $body = preg_replace_callback( $regex5, array('plgSystemjdownloads', '_publisher'), $body );
                $body = preg_replace_callback( $regex6, array('plgSystemjdownloads', '_manager'), $body );
                $body = preg_replace_callback( $regex7, array('plgSystemjdownloads', '_admin'), $body );
                $body = preg_replace_callback( $regex8, array('plgSystemjdownloads', '_super'), $body );
                

                JResponse::setBody($body);
             
             } else {
                // Hide option is deactivated - so we must remove maybe the prior inserted placeholder
                $body = str_replace('{jdreg}', '', $body);
                $body = str_replace('{/jdreg}', '', $body);
                $body = str_replace('{jdpub}', '', $body);
                $body = str_replace('{/jdpub}', '', $body);
                $body = str_replace('{jdauthor}', '', $body);
                $body = str_replace('{/jdauthor}', '', $body);
                $body = str_replace('{jdeditor}', '', $body);
                $body = str_replace('{/jdeditor}', '', $body);
                $body = str_replace('{jdpublisher}', '', $body);
                $body = str_replace('{/jdpublisher}', '', $body);
                $body = str_replace('{jdmanager}', '', $body);
                $body = str_replace('{/jdmanager}', '', $body);
                $body = str_replace('{jdadmin}', '', $body);
                $body = str_replace('{/jdadmin}', '', $body);
                $body = str_replace('{jdsuper}', '', $body);
                $body = str_replace('{/jdsuper}', '', $body);
                $body = str_replace('{jdspecial}', '', $body);
                $body = str_replace('{/jdspecial}', '', $body);
                
                JResponse::setBody($body);
             }     
         }
    } 
    
    function onAfterRoute(){

         // reduce download log data sets when a maximum value exists
         $database = &JFactory::getDBO();
         // exist the table?
         $prefix = $database->getPrefix(); 
         $tablelist = $database->getTableList();
         if ( !in_array ( $prefix.'jdownloads_log', $tablelist ) ){
             return;
         } 
         
         $plugin =& JPluginHelper::getPlugin('system', 'jdownloads');
         jimport( 'joomla.utilities.utility' );
         // get params
         $params = new JRegistry();
         $params->loadJSON($plugin->params);
         $reduce_data_to = (int)$params->get('reduce_log_data_sets_to');
         if ($reduce_data_to == 0) return;
         
         // reduce data
         $database->setQuery("SELECT COUNT(*) FROM #__jdownloads_log");
         $sum = $database->loadResult();
         $sum_delete = $sum - $reduce_data_to;
         if ($sum_delete > 0){
            $database->setQuery("DELETE FROM #__jdownloads_log ORDER BY id LIMIT $sum_delete");
            $database->query();   
         }
         return;
    }    
        
  }
?>