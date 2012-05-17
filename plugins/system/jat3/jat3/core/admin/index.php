<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// No direct access
defined('_JEXEC') or die;

t3_import('core/admin/util');

$obj = new JAT3_AdminUtil();

// Check template use old or new folder structure
$isNewFolderStruct = $obj->checkUseNewFolderStructure();

$uri = str_replace(DS, "/", str_replace(JPATH_SITE, JURI::base(), dirname(__FILE__)));
$uri = str_replace("/administrator", "", $uri);

$template  = $obj->template;

$name = 'pages_profile';
$profiles = $obj->getProfiles();
$pageids  = $obj->getPageIds($name);
$langlist = $obj->getLanguageList();

jimport('joomla.filesystem.file');

$jsonData = $profiles;

$configfile = dirname(__FILE__).DS.'config.xml';
if (file_exists($configfile)) {
    /* For General Tab */
    $generalconfig = $obj->getGeneralConfig();
    $configform    = JForm::getInstance('general', $configfile, array('control' => 'jform'));

    $params = new JParameter($generalconfig);
    $jsonData['generalconfigdata'] = $params->toArray();
    $jsonData['generalconfigdata'][$name] = str_replace("\n", "\\\\n", $params->get($name, ''));

    $arr_values = array();
    $value = $params->get($name, '');
    $assignedMenus = $obj->getAssignedMenu();
    if ($value) {
        $arr_values_tmp = explode("\n", $value);
        foreach ($arr_values_tmp as $k=>$v) {
            if ($v) {
                // Separate data of row
                $row = explode('=', $v);
                // Get pages & language
                $tmp = explode(',', $row[0]);
                $pages    = array();
                $language = 'All';
                foreach ($tmp as $t) {
                    // Seperate language & pages
                    $u = explode('#', $t);
                    // Join page id
                    if (count($u) > 1) {
                    	// Check pages aren't assigned
                    	if (in_array($u[1], $assignedMenus)) {
	                        $pages[] = $u[1];
	                        $language = $u[0];
                    	}
                    } else {
                    	$u[0] = trim($u[0]);
                        // If u[0] is numeric, it is pageid. Otherwise, it is language
                        if (is_numeric($u[0])) {
                        	// Check pages aren't assigned
                        	if (in_array($u[0], $assignedMenus)) {
                                $pages[] = $u[0];
                        	}
                        } elseif (strpos($u[0], 'com_') === 0) {
                        	$pages[] = $u[0];
                        } else {
                            $language = $u[0];
                        }
                    }
                }
                // Get profile
                if (count($row) > 1) {
                    $profile = $row[1];
                } else {
                    $profile = '';
                }

                // Check if there aren't assgined page or isn't language
                if ($language != 'All' || !empty($pages)) {
                    $arr_values[] = array($language, implode(', ', $pages), $profile);
                }
            }
        }
    }
}

$paramsFile = dirname(__FILE__).DS.'params.xml';
if (file_exists($paramsFile)) {
    /* For General Tab */
    $paramsForm = JForm::getInstance('params', $paramsFile, array('control' => 'jform'));
}

/* For Themes Tab */
$themes = $obj->getThemes();

/* For Layouts Tab*/
$layouts = $obj->getLayouts();

/* Set tab default */
switch (JRequest::getCmd('tab')){
    case 'profile':
        $numbertab = 2;
        break;

    case 'layout':
        $numbertab = 3;
        break;

    case 'theme':
        $numbertab = 4;
        break;

    case 'update':
        $numbertab = 5;
        break;

    case 'global':
    default:
        $numbertab = 1;
        break;
}

/* Version */
$version = $obj->getTemplateVersion($template);
$layout = dirname(__FILE__).DS.'tmpl'.DS.'default.php';
if (file_exists($layout)) {
    include_once $layout;
}
