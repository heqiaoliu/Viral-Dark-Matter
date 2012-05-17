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

jimport('joomla.filesystem.file');

/**
 * JAT3_Ajax class
 *
 * @package JAT3.Core
 */
class JAT3_Ajax
{
    /**
     * Upload & install theme
     *
     * @return void
     */
    function installTheme()
    {
        jimport('joomla.filesystem.folder');
        jimport('joomla.filesystem.file');
        jimport('joomla.filesystem.archive');
        jimport('joomla.filesystem.path');

        $template = JRequest::getCmd('template');
        $path = JPATH_SITE.DS.'templates'.DS.$template;
        if (!$template || !JFolder::exists($path)) {
            ?>
            <script type="text/javascript">
                window.document.errorUpload('<span class="err" style="color:red"><?php echo JText::_('TEMPLATE_NOT_DEFINE')?></span>');
             </script>
            <?php
        }

        global $mainframe;

        if (isset($_FILES['install_package']['name'])
            && $_FILES['install_package']['size']>0
            && $_FILES['install_package']['tmp_name']!=''
        ) {
            include_once dirname(__FILE__).DS.'admin'.DS.'util.php';

            $result = $this->_UploadTheme($template, $path);

            if (!is_array($result)) {
                ?>
                    <script type="text/javascript">
                        window.parent.errorUpload('<span class="err" style="color:red"><?php echo $result?></span>');
                     </script>
                <?php
            } else {
                $util = new JAT3_AdminUtil();
                $themes = $util->getThemes($template);
                ?>
                    <script type="text/javascript">
                        window.parent.stopUpload(<?php echo count($themes['core'])?>, '<?php echo $result['name']?>', '<?php echo @$result['version']?>', '<?php echo @$result['creationdate']?>', '<?php echo @$result['author']?>', '<?php echo $template?>');
                    </script>
                <?php
            }
            exit;
        } else {
            ?>
                <script type="text/javascript">
                    window.parent.errorUpload('<span class="err" style="color:red"><?php echo JText::_('UPLOADED_FILE_DOES_NOT_EXIST')?></span>');
                </script>
            <?php
            exit;
        }
    }

    /**
     * Remove installed theme
     *
     * @return void
     */
    function removeTheme ()
    {
        $theme = JRequest::getCmd('theme', '');
        $template = JRequest::getCmd('template', '');
        if (!$theme || !$template) {
            echo JText::_('INVALID_INFO');
            exit;
        }
        $path = JPATH_SITE.DS.'templates'.DS.$template.DS.'themes';
        // Check template use new structure folder
        // If themes folder exists, using new structure folder
        if (@is_dir($path)) {
            // Check theme is used or not
            $profile_path = JPATH_SITE.DS.'templates'.DS.$template.DS.'etc'.DS.'profiles';
            $files = JFolder::files($profile_path, '\.ini$');
            if ($files) {
                $profiles = array();
                foreach ($files as $file) {
                    $param = file_get_contents($profile_path . DS . $file);
                    $param = new JParameter($param);
                    $theme_list = $param->get('themes', '');
                    $theme_list = explode(',', $theme_list);
                    // If theme is being use, raise error
                    if (in_array('core.'.$theme, $theme_list)) {
                    	//$profile = substr($file, 0, -4);
                    	array_push($profiles, substr($file, 0, -4));
                    }
                }
                if (!empty($profiles)) {
                    echo sprintf(JText::_('THEME_IS_BEING_USED'), $theme, count($profiles), implode(', ',$profiles));
                    exit;
                }
            }
            $path .= DS.$theme;
        } else {
            // Compatible: if template still use older folder structure, try to read it.
        $path = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'themes'.DS.$theme;
        }
        if (!file_exists($path)) {
            echo sprintf(JText::_('THEME_S_NOT_FOUND'), $path);
            exit;
        }

        jimport('joomla.filesystem.folder');
        if (! @JFolder::delete($path)) {
            echo sprintf(JText::_('FAILED_TO_DELETE_THEME_S', $theme));
            exit;
        }
        exit;
    }

    /**
     * Upload theme
     *
     * @param string $template  Template name
     * @param string $path      Template path
     *
     * @return string  Result message
     */
    function _UploadTheme ($template, $path)
    {
        $path_temp = dirname(JPATH_BASE).DS."tmp".DS.'jat3'.time().DS;
        if (!is_dir($path_temp)) {
            @ JFolder::create($path_temp);
        }
        if (!is_dir($path_temp)) {
            return JText::_('Can not create temp folder.');
        }

        $directory = $_FILES['install_package']['name'];

        $tmp_dest = $path_temp .$directory;

        $userfile = $_FILES['install_package'];

        // Build the appropriate paths
        $tmp_src    = $userfile['tmp_name'];

        //
        $uploaded = JFile::upload($tmp_src, $tmp_dest);

        if (!$uploaded) {
            return JText::_('UPLOAD_FALSE');
        }

        // Unpack the downloaded package file
        $package = JAT3_AdminUtil::unpackzip($tmp_dest);
        if (! $package) {
            return JText::_('PACKAGE_ERROR');
        }

        //delete zip file
        JFile::delete($tmp_dest);

        $folder_uploaded = @ JFolder::folders($path_temp);
        $files_uploaded  = @ JFolder::files($path_temp);

        $theme_info_path = '';
        if ($files_uploaded) {
            foreach ($files_uploaded as $file) {
                if ($file == 'info.xml') {
                    $theme_info_path = $path_temp.$file;
                    break;
                }
            }
        } elseif (isset($folder_uploaded[0])) {
            $files = @ JFolder::files($path_temp.DS.$folder_uploaded[0]);
            foreach ($files as $file) {
                if ($file == 'info.xml') {
                    $theme_info_path = $path_temp.$folder_uploaded[0].DS.$file;
                    break;
                }
            }
        }

        if (! JFile::exists($theme_info_path)) {
            return  JText::_('FILE_INFO_XML_NOT_FOUND');
        }

        $data = JAT3_AdminUtil::getThemeinfo($theme_info_path, true);

        if (! isset($data['name']) || !$data['name']) {
            return JText::_('THEME_NAME_IS_NOT_DEFINED');
        }

        //$data['name'] = str_replace(' ', '_', $data['name']);
        $data['name'] = preg_replace('/[^a-zA-Z0-9\_]/', '_', $data['name']);
        // Check length
        if (strlen($data['name']) > 50) {
            return JText::_('Theme name length must be smaller than 50');
        }

        $path .= DS.'themes'.DS.$data['name'];
        $path = JPath::clean($path);

        //$arr_spec = array('~','`', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+', '\'',);
        //foreach ($arr_spec as $what) {
        //    if (($pos = strpos($data['name'], $what))!==false) {
        //        return JText::_('Theme name invalid!');
        //    }
        //}

        if (JFolder::exists($path)) {
            return sprintf(JText::_('THEME_S_ALREADY_EXISTS'), $data['name']);
        }

        if ($files_uploaded) {
            $filedest = $path_temp;
        } elseif (isset($folder_uploaded[0])) {
            $filedest = $path_temp.DS.$folder_uploaded[0];
        }
        $result = @ JFolder::move($filedest, $path);

        if ((is_bool($result) && !$result) || (is_string($result) && $result!='') ) {
            return sprintf(JText::_('FAILED_TO_MOVE_FOLDER_S'), $data['name']);
        }

        return $data;
    }

    /**
     * Reset layout content
     *
     * @return void
     */
    /*
    function resetLayout ()
    {
        t3_import('core/admin/util');

        // Initialize some variables
        $client   =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $template = JRequest::getCmd('template');
        $layout   = JRequest::getCmd('layout');
        $errors   = array();
        $result   = array();
        if (!$template || !$layout) {
            $result['error'] = JText::_('OPERATION_FAILED').': '.JText::_('NO_TEMPLATE_OR_LAYOUT_SPECIFIED');
            echo json_encode($result);
            exit;
        }

        //$file = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'layouts'.DS.strtolower($layout).'.xml';
        $file = self::getFilePath($template, $layout, 'layouts', '.xml');
        $return = false;
        if (file_exists($file)) {
            $return = JFile::delete($file);
        }
        if (!$return) {
            $errors[] = JText::_('OPERATION_FAILED').': '.JText::sprintf('Failed to delete file.', $file);
        }
        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = sprintf(JText::_('RESET_S_LAYOUT_SUCCESSFULLY'), $layout);
            $result['layout'] = $layout;
            $result['reset'] = true;
        }

        echo json_encode($result);
        exit;
    }*/

    /**
     * Rename layout name
     *
     * @return void
     */
    function renameLayout ()
    {
        t3_import('core/admin/util');

        // Initialize some variables
        $client         =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $template       = JRequest::getCmd('template');
        $current_layout = JRequest::getCmd('current_layout');
        $new_layout     = JRequest::getCmd('new_layout');

        $errors = array();
        $result = array();

        if (!$template || !$current_layout || !$new_layout) {
            $result['error'] = JText::_('NO_TEMPLATE_SPECIFIED_OR_LAYOUT_NAME_CONTAINS_SPACE_OR_SPECIAL_CHRACTERS');
            echo json_encode($result);
            exit;
        }

        $profiles = '';
        if (self::checkLayoutWasUsed($template, $current_layout, $profiles)) {
            $errors[] = sprintf(JText::_('LAYOUT_IS_BEING_USED'), $current_layout, count($profiles), implode(', ', $profiles));
        } else {
            $src  = self::getFilePath($template, $current_layout, 'layouts', '.xml');
            $dest = self::getFilePath($template, $new_layout, 'layouts', '.xml');
            if (! @JFile::move($src, $dest)) {
            $errors[] =  JText::_('RENAME_FAILED');
        }
        }

        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = sprintf(JText::_('RENAME_S_LAYOUT_SUCCESSFULLY'), $current_layout);
            $result['layout'] = $new_layout;
            $result['layoutolder'] = $current_layout;
            $result['type'] = 'rename';
        }

        echo json_encode($result);
        exit;
    }

    /**
     * Delete layout
     *
     * @return void
     */
    function deleteLayout ()
    {
        t3_import('core/admin/util');

        // Initialize some variables
        $client   =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $template = JRequest::getCmd('template');
        $layout   = JRequest::getCmd('layout');

        $errors = array();
        $result = array();
        if (!$template || !$layout) {
            $result['error'] = JText::_('OPERATION_FAILED').': '.JText::_('NO_TEMPLATE_OR_LAYOUT_SPECIFIED');
            echo json_encode($result);
            exit;
        }

        $profiles = '';
        if (self::checkLayoutWasUsed($template, $layout, $profiles)) {
            $errors[] = sprintf(JText::_('LAYOUT_IS_BEING_USED'), $layout, count($profiles), implode(', ', $profiles));
        } else {
            $src = self::getFilePath($template, $layout, 'layouts', '.xml');
        if (file_exists($src)) {
            if (!JFile::delete($src)) {
                $errors[] = JText::_('OPERATION_FAILED').': '.JText::sprintf('Failed to delete file.', $src);
            }
        }
        }

        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = sprintf(JText::_('DELETE_S_LAYOUT_SUCCESSFULLY'), $layout);
            $result['layout'] = $layout;
            $result['type'] = 'delete';
        }
        echo json_encode($result);
        exit;
    }

    /**
     * Save modified layout
     *
     * @return void
     */
    function saveLayout()
    {
        global $mainframe;
        t3_import('core/admin/util');

        // Initialize some variables
        $client =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $json   = isset($_REQUEST['data'])?$_REQUEST['data']:'';
        $json   = str_replace(array("\\n","\\t"), array("\n", "\t"), $json);
        $data   = str_replace('\\', '', $json);

        $template = JRequest::getCmd('template');
        $layout   = JRequest::getCmd('layout');

        $errors = array();
        $result = array();
        if (!$template || !$layout || !T3_ACTIVE_TEMPLATE) {
            $result['error'] = JText::_('NO_TEMPLATE_SPECIFIED_OR_LAYOUT_NAME_CONTAINS_SPACE_OR_SPECIAL_CHRACTERS');
            echo json_encode($result);
            exit;
        }

        // Set FTP credentials, if given
        jimport('joomla.client.helper');

        JClientHelper::setCredentialsFromRequest('ftp');
        $ftp = JClientHelper::getCredentials('ftp');

        $file      = self::getFilePath($template, $layout, 'layouts', '.xml');
        $file_core = self::getFilePath($template, $layout, 'layouts', '.xml', false);
        // Get layouts from core
        $file_base = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts'.DS.strtolower($layout).'.xml';

        if (file_exists($file) || file_exists($file_core) || file_exists($file_base)) {
            $result['type'] = 'edit';
        } else {
            $result['type'] = 'new';
        }

        if (JFile::exists($file)) {
            chmod($file, 0777);
        }
        $return = @JFile::write($file, $data);

        // Try to make the params file unwriteable
        if (!$ftp['enabled'] && @JPath::isOwner($file) && !JPath::setPermissions($file, '0644')) {
            $errors[] = sprintf(JText::_('COULD_NOT_MAKE_THE_S_FILE_UNWRITABLE'), $file);
        }
        if (! $return) {
            $errors[] = JText::_('OPERATION_FAILED').': '.JText::sprintf('Failed to open file for writing.', $file);
        }

        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            if ($result['type'] == 'new') {
                $result['successful'] = sprintf(JText::_('LAYOUT_S_WAS_SUCCESSFULLY_CREATED'), $layout);
            } else {
                $result['successful'] = sprintf(JText::_('SAVE_S_LAYOUT_SUCCESSFULLY'), $layout);
            }
            $result['layout'] = $layout;
        }

        echo json_encode($result);
        exit;
    }

    /**
     * Update Gfont
     *
     * @return void
     */
    function updateGfont ()
    {
        // Check template exists
        $template = JRequest::getCmd('template');
        if (!$template) {
            $result['error'] = JText::_('No template specified');
            echo json_encode($result);
            exit;
        }
        // Set & check path gfonts.xml
        $path = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'gfonts.xml';
        $path = str_replace(DS, "/", $path);

        t3_import('core/libs/html_parser');
        // Get content from google font website
        $url = 'http://www.google.com/webfonts';
        $content = @file_get_contents($url);
        if ($content === false) {
            $result['error'] = JText::_("Can not get font from google font website");
            echo json_encode($result);
            exit;
        }
        // Get font list
        $html = new simple_html_dom;
        $html->load($content, true);
        $subsets = $html->find('.nav li a');
        // Write to file gfonts.xml
        $data = '';
        $tab = "\t";
        foreach ($subsets as $subset) {
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
                    foreach ($elements as $element) {
                        $name = preg_replace('#\(.*\)#', '', $element->text());
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

    /**
     * Rename profile name
     *
     * @return void
     */
    function renameProfile ()
    {
        t3_import('core/admin/util');

        // Initialize some variables
        $client   = &JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $template = JRequest::getCmd('template');

        $current_profile = JRequest::getCmd('current_profile');
        $new_profile     = JRequest::getCmd('new_profile');

        $errors = array();
        $result = array();
        if (!$template || !$current_profile || !$new_profile) {
            $result['error'] = JText::_('NO_TEMPLATE_SPECIFIED_OR_PROFILE_NAME_CONTAINS_SPACE_OR_SPECIAL_CHRACTERS');
            echo json_encode($result);
            exit;
        }

        $src  = self::getFilePath($template, $current_profile, 'profiles');
        $dest = self::getFilePath($template, $new_profile, 'profiles');
        if (file_exists($src)) {
            if (!JFile::move($src, $dest)) {
                $errors[] =  JText::_('RENAME_FAILED');
            }
        }

        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = sprintf(JText::_('RENAME_S_PROFILE_SUCCESSFULLY'), $current_profile);
            $result['profile'] = $new_profile;
            $result['profileolder'] = $current_profile;
            $result['type'] = 'rename';
        }

        echo json_encode($result);
        exit;
    }

    /**
     * Delete profile
     *
     * @return void
     */
    function deleteProfile ()
    {
        t3_import('core/admin/util');

        // Initialize some variables
        $client   =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $template = JRequest::getCmd('template');
        $profile  = JRequest::getCmd('profile');

        $errors = array();
        $result = array();
        if (!$template || !$profile) {
            $result['error'] = JText::_('OPERATION_FAILED').': '.JText::_('No template or profile specified.');
            echo json_encode($result);
            exit;
        }

        $src = self::getFilePath($template, $profile, 'profiles');
        if (file_exists($src)) {
            if (! JFile::delete($src)) {
                $errors[] = JText::_('OPERATION_FAILED').': '.JText::sprintf('Failed to delete file.', $src);
            }
        }

        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = sprintf(JText::_('DELETE_S_PROFILE_SUCCESSFULLY'), $profile);
            $result['profile'] = $profile;
            $result['type'] = 'delete';
        }

        echo json_encode($result);
        exit;
    }

    /**
     * Reset profile contain
     *
     * @return void
     */
    /*
    function resetProfile()
    {
        t3_import('core/admin/util');

        // Initialize some variables

        $client   =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $template = JRequest::getCmd('template');
        $profile  = JRequest::getCmd('profile');

        $errors = array();
        $result = array();
        if (!$template || !$profile) {
            $result['error'] = JText::_('OPERATION_FAILED').': '.JText::_('No template or profile specified.');
            echo json_encode($result);
            exit;
        }

        //$file   = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.'profiles'.DS.$profile.'.ini';
        $file   = self::getFilePath($template, $profile, 'profiles');
        $return = false;
        if (file_exists($file)) {
            $return = JFile::delete($file);
        }
        if (!$return) {
            $errors[] = JText::_('OPERATION_FAILED').': '.JText::sprintf('Failed to delete file.', $file);
        }
        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = sprintf(JText::_('RESET_S_PROFILE_SUCCESSFULLY'), $profile);
            $result['profile'] = $profile;
            $result['reset'] = true;
            $result['type'] = 'reset';
        }

        echo json_encode($result);
        exit;
    }
    */

    /**
     * Save proifle
     *
     * @param string $profile   Profile name
     * @param array  $post      Posted data
     *
     * @return void
     */
    function saveProfile ($profile = '', $post = null)
    {
        global $mainframe;
        t3_import('core/admin/util');

        // Initialize some variables
        $db     =& JFactory::getDBO();
        $client =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        if (!$post) {
            $post = JRequest::getVar('jsondata');
        }
        $template = JRequest::getCmd('template');
        if (!$profile) {
            $profile = JRequest::getCmd('profile');
        }

        $result = array();
        if (!$template || !$profile) {
            $result['error'] = JText::_('NO_TEMPLATE_SPECIFIED_OR_LAYOUT_NAME_CONTAINS_SPACE_OR_SPECIAL_CHRACTERS');
            echo json_encode($result);
            exit;
        }
        // Set FTP credentials, if given
        jimport('joomla.client.helper');
        JClientHelper::setCredentialsFromRequest('ftp');
        $ftp  = JClientHelper::getCredentials('ftp');

        $file = self::getFilePath($template, $profile, 'profiles');

        $errors = array();
        $params = new JParameter('');
        if (isset($post)) {
            foreach ($post as $k=>$v) {
                $params->set($k, $v);
            }
        }
        $data = $params->toString('.ini');
        if (JFile::exists($file)) {
            @chmod($file, 0777);
        }
        $return = @JFile::write($file, $data);

        // Try to make the params file unwriteable
        if (!$ftp['enabled'] && @JPath::isOwner($file) && !JPath::setPermissions($file, '0644')) {
            $errors[] = sprintf(JText::_('COULD_NOT_MAKE_THE_S_FILE_UNWRITABLE'), $file);
        }
        if (!$return) {
            $errors[] = JText::_('OPERATION_FAILED').': '.JText::sprintf('Failed to open file for writing.', $file);
        }

        if (JRequest::getCmd('jat3action') != 'saveProfile') {
            return $errors;
        }

        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = sprintf(JText::_('SAVE_S_PROFILE_SUCCESSFULLY'), $profile);
            $result['profile'] = $profile;
            $result['type'] = 'new';
        }

        echo json_encode($result);
        exit;
    }

    /**
     * Save general data
     *
     * @param array $post   Posted data
     *
     * @return void
     */
    function saveGeneral ($post = null)
    {
        global $mainframe;
        t3_import('core/admin/util');

        // Initialize some variables
        $db      =& JFactory::getDBO();
        $client  =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));

        if (!$post) {
            $json = JRequest::getVar('json');
            $json = str_replace(array("\\n", "\\t"), array("\n", "\t"), $json);
            $json = str_replace('\\', '', $json);
            $post = json_decode($json);
        }

        $template = JRequest::getCmd('template');

        $result = array();
        if (! $template) {
            $result['error'] = JText::_('OPERATION_FAILED').': '.JText::_('NO_TEMPLATE_SPECIFIED');
            echo json_encode($result);
            exit;
        }
        // Set FTP credentials, if given
        jimport('joomla.client.helper');
        JClientHelper::setCredentialsFromRequest('ftp');
        $ftp = JClientHelper::getCredentials('ftp');

        $errors = array();

        if ($post) {
            if (isset($post)) {
                $file = $client->path.DS.'templates'.DS.$template.DS.'params.ini';

                $params = new JParameter('');
                foreach ($post as $k=>$v) {
                    $v = str_replace(array("\\n", "\\t"), array("\n", "\t"), $v);
                    $v = str_replace('\\', '', $v);
                    $params->set($k, $v);
                }
                $data = $params->toString('.ini');

                if (JFile::exists($file)) {
                    @chmod($file, 0777);
                }
                $return = JFile::write($file, $data);

                // Try to make the params file unwriteable
                if (!$ftp['enabled'] && JPath::isOwner($file) && !JPath::setPermissions($file, '0644')) {
                    $errors[] = sprintf(JText::_('Could not make the %s file unwritable'), $file);
                }
                if (!$return) {
                    $errors[] = JText::_('OPERATION_FAILED').': '.JText::sprintf('Failed to open file for writing.', $file);
                }
            }
        }

        if (JRequest::getCmd('jat3action') != 'saveGeneral') return $errors;

        if ($errors) {
            $result['error'] = implode('<br/>', $errors);
        } else {
            $result['successful'] = JText::_('SAVE_DATA_SUCCESSFULLY');
        }

        echo json_encode($result);
        exit;
    }

    /**
     * Save data configuraton was posted from client
     *
     * @return void
     */
    function saveData ()
    {
        global $mainframe;
        t3_import('core/admin/util');

        // Initialize some variables
        $db       =& JFactory::getDBO();
        $client   =& JApplicationHelper::getClientInfo(JRequest::getVar('client', '0', '', 'int'));
        $template = JRequest::getCmd('template');
        $default  = JRequest::getBool('default');

        $result = array();
        if (! $template) {
            $result['error'] = JText::_('OPERATION_FAILED').': '.JText::_('NO_TEMPLATE_SPECIFIED');
            echo json_encode($result);
            exit;
        }

        //Check and save general, profiles information
        $json = $_REQUEST;

        $error_msg = '';
        $success_msg =  JText::_('SAVE_DATA_SUCCESSFULLY');
        if (isset($json['generalconfigdata']) && $json['generalconfigdata']) {
            $app = JFactory::getApplication('administrator');
            $styleid = JRequest::getInt('id');
            $user = JFactory::getUser();

            if (!empty($json['generalconfigdata']['pages_profile']) && $styleid > 0) {
                $list_pages = explode('\n', $json['generalconfigdata']['pages_profile']);
                $pages = array();
                foreach ($list_pages as $r) {
                    $row = explode('=', $r);
                    if ($row[0] != 'all') {
                        $tmp = explode(',', $row[0]);
                        // Check and get page list
                        foreach ($tmp as $t) {
                        	// Split language and pages
                        	$t = explode('#', $t);
                        	// Check page
                        	if (count($t) > 1) {
                        		$pages[] = $t[1];
                        	} elseif (is_numeric($t[0])) {
                        		$pages[] = $t[0];
                    }
                }
                    }
                }

                // Refresh page assignment
                if ($pages) {
                    JArrayHelper::toInteger($pages);

                    // Update the mapping for menu items that this style IS assigned to.
                    $query = $db->getQuery(true);
                    $query->update('#__menu');
                    $query->set('template_style_id = '.(int) $styleid);
                    $query->where('id IN ('.implode(',', $pages).')');
                    $query->where('template_style_id != '.(int) $styleid);
                    $query->where('checked_out in (0,'.(int) $user->id.')');
                    $db->setQuery($query);
                    $db->query();
                }

                // Delete all menu before they were assigned
                // Remove style mappings for menu items this style is NOT assigned to.
                // If unassigned then all existing maps will be removed.
                $query = $db->getQuery(true);
                $query->update('#__menu');
                $query->set('template_style_id=0');
                if ($pages) {
                    $query->where('id NOT IN ('.implode(',', $pages).')');
                }

                $query->where('template_style_id='.(int) $styleid);
                $query->where('checked_out in (0,'.(int) $user->id.')');
                $db->setQuery($query);
                $db->query();
            }

            $error = $this->saveGeneral($json['generalconfigdata']);
            if (count($error)) {
                $error_msg .= JText::_('SAVE_GENERAL_ERROR')."<br /><p class=\"msg\">".explode('<br />', $error)."</p>";
                $result['generalconfigdata'] = 0;
            } else {
                $success_msg .= "<p class=\"msg\">".JText::_('SAVE_GENERAL_SUCCESSFULLY')."</p>";
                $result['generalconfigdata'] = 1;
            }
        }

        if (isset($json['profiles']) && $json['profiles']) {
            $result['profiles'] = array();
            foreach ($json['profiles'] as $p=>$profile) {
                $error = $this->saveProfile($p, $profile);
                if (count($error)) {
                    $error_msg .= sprintf(JText::_('SAVE_PROFILE_S_ERROR'), $p)."<br /><p class=\"msg\">".explode('<br />', $error)."</p>";
                    $result['profiles'][$p] = 0;
                } else {
                    $success_msg .= "<p class=\"msg\">".sprintf(JText::_('SAVE_PROFILE_S_SUCCESSFULLY'), $p)."</p>";
                    $result['profiles'][$p] = 1;
                }
            }
        }

        // Fixed bug - cann't save style name & style home
        if (isset($json['jform']) && $json['jform']) {
            $style_name = $json['jform']['title'];

            // Update style name
            if (!empty($style_name)) {
                $query = $db->getQuery(true);
                $query->update('#__template_styles');
                $query->set('title = '.$db->quote($style_name));
                $query->where('id = '.(int)$styleid);
                $db->setQuery($query);
                if (!$db->query()) {
                    $error_msg .= JText::_('SAVE_TEMPLATE_DETAILS_ERROR') . "<br />" . $db->getErrorMsg();
                    $result['jform']['title'] = 0;
                } else {
                    $result['jform']['title'] = 1;
                }
            }

            // Update style home
            if (isset($json['jform']['home'])) {
                $style_home = $json['jform']['home'];
                if (strlen(trim($style_home)) == 0) $style_home = 0;

                $query = $db->getQuery(true);
                $query->update('#__template_styles')
                    ->set('home = \'0\'')
                    ->where('home = '.$db->quote($style_home))
                    ->where('client_id = 0');
                $db->setQuery($query);
                if (! $db->query()) {
                    $error_msg .= JText::_('SAVE_TEMPLATE_DETAILS_ERROR') . "<br />" . $db->getErrorMsg();
                } else {
                    $query = $db->getQuery(true);
                    $query->update('#__template_styles')
                        ->set('home = '.$db->quote($style_home))
                        ->where('id = '.(int)$styleid);
                    $db->setQuery($query);
                    if (!$db->query()) {
                        $error_msg .= JText::_('SAVE_TEMPLATE_DETAILS_ERROR') . "<br />" . $db->getErrorMsg();
                        $result['jform']['home'] = 0;
                    } else {
                        if ($style_home == 1)
                            $result['jform']['home'] = 2;
                        else
                            $result['jform']['home'] = 1;
                    }
                }
            }
        }

        // Clean cache
        t3_import('core/cache');
        T3Cache::clean();

        $result['successful'] = $success_msg;
        $result['error'] = $error_msg;
        $result['cache'] = T3Cache::clean();
        echo json_encode($result);
        exit;
    }

    /**
     * Get additonal info from joomlart.com
     *
     * @return void
     */
    function updateAdditionalInfo ()
    {
        $template = JRequest::getCmd('template');
        if (! $template) exit;

        $host = 'www.joomlart.com';
        $path = "/jatc/getinfo.php";
        $req  = 'template=' . $template;
        $URL  = "$host$path";

        include_once dirname(__FILE__).DS.'admin'.DS.'util.php';
        if (! function_exists('curl_version')) {
            if (! ini_get('allow_url_fopen')) {
                echo JText::_('Sorry, but your server does not currently support open method. Please contact the network administrator system for help.');
                exit;
            } else {
                $result = JAT3_AdminUtil::socket_getdata($host, $path, $req);
            }
        } else {
            $result = JAT3_AdminUtil::curl_getdata($URL, $req);
        }

        echo $result;
        exit;
    }

    /**
     * Clear cache
     *
     * @return void
     */
    function clearCache()
    {
        // Clean cache
        t3_import('core/cache');
        T3Cache::clean(10);

        echo JText::_('T3 Cache is cleaned!');
        exit;
    }

    /**
     * Convert template folder structure to new folder structure
     *
     * @return mixed  true if succussful, false if template folder can't writeable, string message if having error
     */
    public function convertFolder()
    {
        $message  = array();
        $template = JRequest::getCmd('template');
        // Get path
        $path = JPATH_SITE.'/templates/'.$template;
        // Check template folder is writeable
        $tmpfile = $path.'/tmp.'.uniqid(mt_rand());
        if (!JFolder::create($tmpfile)) {
            // Template folder isn't writable, stop convert
            $message[] = JText::_('Template folder wasn\'t set write permission.');
        } else {
            JFolder::delete($tmpfile);
        }

        // Check if there is etc folder in template
        if (!is_dir($path.'/etc') && empty($message)) {
            // Move core/etc folder to template folder
            $srcpath = $path.'/core/etc';
            if (is_dir($srcpath)) {
                $ret = JFolder::copy($srcpath, $path.'/etc');
                if ($ret !== true) {
                    $message[] = $ret;
                }
            }

            if (empty($message)) {
                // Move local/etc/profiles/* files to template folder and change extension
                $srcpath = $path.'/local/etc/profiles';
                $items = JFolder::files($srcpath, '\.ini');
                if ($items !== false) {
                    foreach ($items as $file) {
                        $ret = JFile::copy($srcpath.'/'.$file, $path.'/etc/profiles/'.$file);
                        if ($ret !== true) {
                            $message[] = $ret;
                        }
                    }
                }
                // Move local/etc/layouts/* files to template folder and change extension
                $srcpath = $path.'/local/etc/layouts';
                $items = JFolder::files($srcpath, '\.xml');
                if ($items !== false) {
                    foreach ($items as $file) {
                        $ret = JFile::copy($srcpath.'/'.$file, $path.'/etc/layouts/'.$file);
                        if ($ret !== true) {
                            $message[] = $ret;
                        }
                    }
                }
            }
        }
        // Check there is themes folder in template folder
        if (!is_dir($path.'/themes') && empty($message)) {
            // Move core/themes folders to template folder
            $srcpath = $path.'/core/themes';
            if (is_dir($srcpath)) {
                $ret = JFolder::copy($srcpath, $path.'/themes');
                if ($ret !== true) {
                    $message[] = $ret;
                }
            }
            if (empty($message)) {
                // Check exists folder themes, if not create themes folder
                if (!is_dir($path.'/themes')) {
                    JFolder::create($path.'/themes');
                }
                // Move local/themes files to template folder and change extension
                $srcpath = $path.'/local/themes';
                $items = JFolder::folders($srcpath);
                if ($items !== false) {
                    // Array regular expression to find configure layout in profile file
                    $findArray = array();
                    // Array replace themes when found it by regular exprssion
                    $replaceArray = array();
                    // Implement move local folder
                    foreach ($items as $folder) {
                        if (!is_dir($path.'/themes/lc_'.$folder)) {
                            $ret = JFolder::copy($srcpath.'/'.$folder, $path.'/themes/lc_'.$folder);
                            // Add find & replace regular expression string
                            $findArray[] = '/(^|\n)(themes=.*)(local.'. $folder .')(.*)($|\n)/';
                            $replaceArray[] = '$1$2core.lc_'. $folder .'$4$5';
                            // Add message if error
                            if ($ret !== true) {
                                $message[] = $ret;
                            }
                        }
                    }
                    // Update profiles
                    if (empty($message)) {
                        // Get list profiles
                        $profileList = JFolder::files($path.'/etc/profiles', '\.ini');
                        // Update each file
                        foreach ($profileList as $profile) {
                            // Create profile path
                            $filepath = $path.'/etc/profiles/'.$profile;
                            // Get content
                            $content = JFile::read($filepath);
                            // Replace content
                            for ($i = 0, $n = count($findArray); $i < $n; $i++) {
                                $tmp = preg_replace($findArray[$i], $replaceArray[$i], $content);
                                if ($tmp != null) {
                                    $content = $tmp;
                                }
                            }
                            JFile::write($filepath, $content);
                        }
                    }
                }
            }
        }
        if (empty($message)) {
            // If success, delete core/local folder
            JFolder::delete($path.'/core');
            JFolder::delete($path.'/local');
        } else {
            // Can't delete it
            $message[] = JText::_('Error when delete core or local folder');
        }
        $res = array();
        if (empty($message)) {
            $res['success'] = 'Convert successful!';
        } else {
            $res['error'] = implode('<br />', $message);
        }
        echo json_encode($res);
        exit;
    }

    /**
     * Get local file path
     *
     * @param string $template  Template name
     * @param string $filename  File name
     * @param string $type      T3 element name
     * @param string $ext       File extension
     * @param bool   $local     Indicate get local file or core file
     *
     * @return string
     */
    function getFilePath($template, $filename, $type, $ext = '.ini', $local = true, $compatible = false)
    {
        // Check to sure that core & local folders were remove from template.
        // If etc/$type exists, considered as core & local folders were removed
        $filepath  = JPATH_SITE.DS.'templates'.DS.$template.DS.'etc'.DS.$type.DS;
        if (@is_dir($filepath)) {
            //$ext = ($local) ? '.local'.$ext : $ext;
            $filepath .= strtolower($filename).$ext;
            return $filepath;
        }

        // If compatible mode, get file path of old structure folder
        if ($compatible) {
            $filepath  = ($local)
                ? JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.$type.DS.strtolower($filename).$ext
                : JPATH_SITE.DS.'templates'.DS.$template.DS.'core'.DS.'etc'.DS.$type.DS.strtolower($filename).$ext;
        }
        return $filepath;
    }
    /**
     * Check layout was used. If it was used, raise error.
     *
     * @param string $template   Template name
     * @param string $layout     Layout name
     * @param string &$profiles  List profiles are using layout
     *
     * @return bool  TRUE if it was used, otherwise FALSE
     */
    function checkLayoutWasUsed($template, $layout, &$profiles)
    {
        // Check theme is used or not
        $profile_path = JPATH_SITE.DS.'templates'.DS.$template.DS.'etc'.DS.'profiles';
        $profiles = array();
        $files = JFolder::files($profile_path, '\.ini$');
        if ($files) {
            foreach ($files as $file) {
                $param = file_get_contents($profile_path . DS . $file);
                $param = new JParameter($param);
                // If layout was use, raise error
                $used_layout = $param->get('desktop_layout', '');
                if ($used_layout == $layout) {
                	array_push($profiles, substr($file, 0, -4));
                	continue;
                }
                $used_layout = $param->get('handheld_layout', '');
                if ($used_layout == $layout) {
                	array_push($profiles, substr($file, 0, -4));
                	continue;
                }
                $used_layout = $param->get('iphone_layout', '');
                if ($used_layout == $layout) {
                	array_push($profiles, substr($file, 0, -4));
                	continue;
                }
                $used_layout = $param->get('android_layout', '');
                if ($used_layout == $layout) {
                	array_push($profiles, substr($file, 0, -4));
                	continue;
                }
            }
        }
        // If there aren't profile using this layout, return false
        if (empty($profiles)) return false;
        return true;
    }
    /**
     * Get font properties by name
     *
     * @return void
     */
    function getFontProperties()
    {
        $template = JRequest::getCmd('template');
        $fontname = JRequest::getVar('fontname');
        // Get gfont path
        $fontpath = self::getFontPath($template);
        // Get font data
        if ($fontpath !== false) {
            $data   = @file_get_contents($fontpath);
            // Check to update font
            $idx = strpos($data, '#');
            if ($idx !== false) {
                // Seperate time & json font list
                $time = (int) substr($data, 0, $idx);
                $data = substr($data, $idx+1);
                // Check if not update 3 days => update
                if (time() - $time > 3 * 86400) {
                    // Get local font path
                    $fontpath = self::getFontPath($template, 'gfonts.dat', true);
                    // Update font list
                    $status = self::updateFontList($fontpath);
                    // If success, re-get font list
                    if ($status) {
                        $data = @file_get_contents($fontpath);
                        $idx = strpos($data, '#');
                        if ($idx !== false) {
                            $data = substr($data, $idx+1);
                        }
                    }
                }
            }
            // Parse fonts information
            $font   = json_decode($data);
            $items  = $font->items;
            $result = null;
            // Find suitable font by fontname
            foreach ($items as $item) {
                if (strcasecmp($fontname, $item->family) == 0) {
                    $result = $item;
                    break;
                }
            }
        } else {
            $result = '';
        }
        echo json_encode($result);
        exit;
    }


    /**
     * Get font list
     *
     * @return void
     */
    function getFontList()
    {
        $template = JRequest::getCmd('template');
        $fontname = JRequest::getVar('value');
        // Get gfont path
        $fontpath = self::getFontPath($template);
        if ($fontpath !== false) {
            // Get font list
            $data = @file_get_contents($fontpath);
            // Remove time before json data
            $idx = strpos($data, '#');
            if ($idx !== false) {
                $data = substr($data, $idx+1);
            }
            // Parse data
            $font  = json_decode($data);
            $items = $font->items;
            $result = array();
            $pattern = '/^'.$fontname.'.*/i';
            // Find suitable font by fontname
            foreach ($items as $item) {
                if (preg_match($pattern, $item->family)) {
                    $result[] = $item->family;
                }
            }
        } else {
            $result = array();
        }
        echo json_encode($result);
        exit;
    }

    /**
     * Get gfont path
     *
     * @param string $template  Template name
     * @param string $filename  Filename include extension
     * @param bool   $local     Indicate get local path or not
     *
     * @return mixed  Gfont file path if found, otherwise FALSE
     */
    function getFontPath($template, $filename='gfonts.dat', $local = false)
    {
        // Check to sure that template is using new folder structure
        // If etc folder exists, considered as template is using new folder structure
        $filepath = JPATH_SITE.DS.'templates'.DS.$template.DS.'etc';
        if (@is_dir($filepath)) {
            $filepath .= DS.$filename;
        } else {
            // Template still use old folder structure
            $filepath = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'etc'.DS.$filename;
        }
        // Check file exists or not
        if (@is_file($filepath) || $local) {
            return $filepath;
        }
        // Check file in base-themes
        $filepath = T3Path::path(T3_BASETHEME).DS.'etc'.DS.$filename;
        if (@is_file($filepath)) {
            return $filepath;
        }

        // Can not find google font file
        return false;
    }

    /**
     * Update font list from google web font page
     *
     * @param string $path  File path store font list
     *
     * @return bool  TRUE if update success, otherwise FALSE
     */
    function updateFontList($path)
    {
        $key = 'AIzaSyA6_mK8ERGaR4_dhK6tJVEdvJPQEdwULWg';
        $url = 'https://www.googleapis.com/webfonts/v1/webfonts?key='.$key;
        $content = @file_get_contents($url);
        if (!empty($content)) {
            $content = time() . '#' . $content;
            $result = file_put_contents($path, $content);
            return ($result !== false);
        }
        return false;
    }
}
?>