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

/**
 * JAT3_AdminUtil package
 *
 * @package JAT3.Core.Admin
 */
class JAT3_AdminUtil
{
    /**
     *
     * @var Template name
     */
    var $template = '';

    /**
     * Constructor
     *
     * @return void
     */
    function JAT3_AdminUtil()
    {
        $this->template = JAT3_AdminUtil::get_active_template();
    }

    /**
     * Get active template
     *
     * @return string  Name of active template
     */
    function get_active_template()
    {
        $app = JFactory::getApplication('administrator');
        if ($app->isAdmin()) {
            $styleid  = JRequest::getInt('id');
            $db       = JFactory::getDBO();
            $query    = 'SELECT template'
                . ' FROM #__template_styles'
                . ' WHERE id='.(int)$styleid;
            $db->setQuery($query);
            $template = $db->loadResult();
            return strtolower($template);
        } else {
            return $app->getTemplate(false);
        }
    }

    /**
     * Get all active templates in J1.6
     *
     * @return array  An array of active templates
     */
    function get_active_templates()
    {
        $db    = JFactory::getDBO();
        $query = 'SELECT template'
            . ' FROM #__template_styles'
            . ' WHERE client_id = 0 AND home <> \'0\' ';
        $db->setQuery($query);
        $templates = $db->loadResultArray();
        return $templates;
    }

    /**
     * Get general configuration
     *
     * @return string  The raw of general configuration
     */
    function getGeneralConfig()
    {
        $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'params.ini';
        if (file_exists($path)) {
            return JFile::read($path);
        }
        return '';
    }

    /**
     * Generate page assignment selected box
     *
     * @param string $name  Name of page assignment box
     *
     * @return string  Page assignment selected box markup
     */
    function getPageIds($name)
    {
        $menutypes  = $this->getMenuTypes();
        $components = $this->getComponents();

        $selections  = '<div class="page-assignment-panel">';
        $selections .= '<ul id="page-assignment-list">'; // BEGIN page-assingment-list

        foreach ($menutypes as $menutype) {
            $selections .= $this->buildMenu($menutype);
        }
        $selections .= '<li><input type="checkbox" class="menutype" disabled /><label  style="font-weight:bold;">components</label>';
        $selections .= '<ul class="level1">';
        foreach ($components as $text) {
            $selections .= '<li><input class="pageitem" type="checkbox" id="'.$text.'" />';
            $selections .= '<label for="'.$text.'">'.$text.'</label></li>';
        }
        $selections .= '</ul></li>';

        $selections .= '</ul>'; // END page-assingment-list
        $selections .= '</div>';

        return $selections;
    }

    // @todo: remove comment
    /**
     * Generate language selected box
     *
     * @param $name
     */
    /*
    function getLanguages($name)
    {
        $langlist = self::getLanguageList();

        $options   = array();
        $options[] = JHtml::_('select.option', 'default', 'default');
        foreach ($langlist as $lang) {
            $options[] = JHtml::_('select.option', $lang, $lang);
        }

        $html = JHtml::_(
            'select.genericlist', $options, $name.'_lang', 'id="'.$name.'_lang" size="5"',
            'value', 'text', array(), $name.'_lang'
        );

        return $html;
    }
    */

    /**
     * Get all componenets
     *
     * @return array  An array of components
     */
    function getComponents()
    {
        jimport('joomla.filesystem.folder');

        // Initialise variables.
        $lang = JFactory::getLanguage();
        $list = array();

        // Get the list of components.
        $db = JFactory::getDBO();
        $db->setQuery(
            'SELECT `element` AS "option"' .
            ' FROM `#__extensions`' .
            ' WHERE `type` = "component"' .
            ' AND `enabled` = 1' .
            ' ORDER BY `name`'
        );
        $components = $db->loadResultArray();
        $list = array();
        foreach ($components as $k=>$component) {
            $mainFolder = JPATH_SITE.'/components/'.$component;
            if (JFolder::exists($mainFolder)) {
                $list[] = $component;
            }
        }
        return $list;
    }

    /**
     * Get all themes
     *
     * @return arrary  An array of themes information
     */
    function getThemes()
    {
        jimport('joomla.filesystem.folder');
        jimport('joomla.filesystem.file');

        $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'themes';
        // Check template use newest folder structure or not
        // If themes folder exists, considered as template use newest folder structure
        if (@is_dir($path)) {
            if (! @is_file($path.DS.'index.html')) {
                $content = '<!DOCTYPE html><title></title>';
                JFile::write($path.DS.'index.html', $content);
            }
            $folders = array('core'=>array(), 'local'=>array());
            $list = JFolder::folders($path, '.');
            foreach ($list as $theme) {
                $filepath = $path.DS.$theme.DS.'info.xml';
                if (is_file($filepath)) {
                    array_push($folders['core'], array($theme, $filepath, true));
        }
            }
        } else {
            // Compatible: if template still use older folder structure, try to use it.
            $folders = array('core'=>array(), 'local'=>array());
            // Load core theme
            $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'core'.DS.'themes';
            if (JFolder::exists($path)) {
                $list = @JFolder::folders($path);
                foreach ($list as $theme) {
                    $filepath = $path.DS.$theme.DS.'info.xml';
                    if (is_file($filepath)) {
                        array_push($folders['core'], array($theme, $filepath, false));
        }
                }
            }
            // Load local theme
            $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'local'.DS.'themes';
            if (JFolder::exists($path)) {
                $list = @JFolder::folders($path);
                foreach ($list as $theme) {
                    $filepath = $path.DS.$theme.DS.'info.xml';
                    if (is_file($filepath)) {
                        array_push($folders['local'], array($theme, $filepath, false));
                    }
                }
            }
        }

        return $folders;
    }

    /**
     * Get all layouts
     *
     * @return arrary  An array of layouts
     */
    function getLayouts()
    {
        jimport('joomla.filesystem.folder');
        jimport('joomla.filesystem.file');

        $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'etc'.DS.'layouts';
        // Check to sure that core & local folders were remove from template.
        // If etc/layouts exists, considered as core & local folders were removed
        if (@is_dir($path)) {
            if (!@is_file($path.DS.'index.html')) {
                $content = '<!DOCTYPE html><title></title>';
                JFile::write($path.DS.'index.html', $content);
            }
            $basepath = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts';
            if (! @is_dir($basepath)) {
                die($basepath);
            }

        $layouts = array();
            // Get filename list from layouts folder
            $local_file_list = JFolder::files($path, '\.xml');
            $base_file_list  = JFolder::files($basepath, '\.xml');
            // Read file data from template
            foreach ($local_file_list as $file) {
                $filename = substr($file, 0, -4);
                $layout = new stdclass();
                $layout->core  = null;
                $layout->local = JFile::read($path.DS.$file);
                $layouts[$filename] = $layout;
            }
            // Read file from basetheme
            foreach ($base_file_list as $file) {
                $filename = substr($file, 0, -4);
                if (!isset($layouts[$filename])) {
                    $layout = new stdclass();
                    $layout->local = null;
                    $layout->core = JFile::read($basepath.DS.$file);
                    $layouts[$filename] = $layout;
                } else {
                    $layouts[$filename]->core = JFile::read($basepath.DS.$file);
                }
            }
        } else {
            // Compatible: maybe template still use older structure folders, try to read it
            $layouts = array();
        $file_layouts = array();
        $arr_folder = array('core', 'local');
        foreach ($arr_folder as $folder) {
            $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.$folder.DS.'etc'.DS.'layouts';
            if (!JFolder::exists($path)) {
                    if (JFolder::create($path)) {
                $content = '';
                JFile::write($path.DS.'index.html', $content);
            }
                }

            $files = @JFolder::files($path, '\.xml');
            if ($files) {
                foreach ($files as $f) {
                    $file_layouts[$f] = $path.DS.$f;
                }
            }
        }
        //get layouts from core
        $path = T3Path::path(T3_BASETHEME).DS.'etc'.DS.'layouts';
            if (!is_dir($path)) {
                die ($path);
            }
        $files = @JFolder::files($path, '\.xml');
        if ($files) {
            foreach ($files as $f) {
                    if (!isset ($file_layouts[$f])) {
                        $file_layouts[$f] = $path.DS.$f;
            }
        }
            }

        if ($file_layouts) {
            foreach ($file_layouts as $name=>$p) {
                $layout = new stdclass();
                $path = 'etc'.DS.'layouts'.DS.$name;

                $file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'local'.DS.$path;
                $layout->local = null;
                if (JFile::exists($file)) {
                    $layout->local = JFile::read($file). ' ';
                }
                //Get core
                $file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'core'.DS.$path;
                    if (!JFile::exists($file)) {
                        $file = T3Path::path(T3_BASETHEME).DS.$path;
                    }
                $layout->core = null;
                if (JFile::exists($file)) {
                    $layout->core = JFile::read($file).' ';
                }
                $layouts[strtolower(substr($name, 0, -4))] = $layout;
            }
        }
        }
        return $layouts;
    }

    /**
     * Generate layout selected box
     *
     * @param string $value  Default value
     * @param string $name   Selected box name
     *
     * @return string  Layout selected box markup
     */
    function buildHTML_Layout($value, $name)
    {
        $layouts = $this->getLayouts();
        $element = array();
        $element[] = JHTML::_('select.option',  '-1', JText::_('disabled'));
        if (!in_array($value, $layouts)) $value = 'default';
        if ($layouts) {
            foreach ($layouts as $layout=>$content) {
                $element[] = JHTML::_('select.option', $layout, $layout);
            }
        }
        $layoutHTML = JHTML::_('select.genericlist', $element, "$name", 'class="inputbox jat3-el-layouts"', 'value', 'text', $value);
        return $layoutHTML;
    }

    /**
     * Get all profiles
     *
     * @return array  An array of profiles
     */
    function getProfiles()
    {
        jimport('joomla.filesystem.folder');
        jimport('joomla.filesystem.file');

        $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'etc'.DS.'profiles';
        // Check to sure that core & local folders were remove from template.
        // If etc/$type exists, considered as core & local folders were removed
        if (@is_dir($path)) {
            if (!is_file($path.DS.'index.html')) {
                $content = '<!DOCTYPE html><title></title>';
                JFile::write($path.DS.'index.html', $content);
            }

            // Read custom parameters
            $dparams = array();
            $xmlpath = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'templateDetails.xml';
            $xml     = &JFactory::getXMLParser('Simple');
            if ($xml->loadFile($xmlpath)) {
                $params =& $xml->document->params;
                if ($params) {
                    foreach ($params as $param) {
                        foreach ($param->children() as $p) {
                            if ($p->attributes('name') && isset($p->_attributes['default'])) {
                                $dparams [$p->attributes('name')] = $p->attributes('default');
                            }
                        }
                    }
                }
            }

            $filelist = array();
        $profiles = array();

            // Get filename list from profiles folder
            $file_list = JFolder::files($path, '\.ini');
            // Load profile data
            foreach ($file_list as $file) {
                // Get filename & filepath
                $filename = strtolower(substr($file, 0, -4));
                $filepath = $path . DS . $file;
                if (@file_exists($filepath)) {
                    $profile = new stdclass();
                    $profile->local = null;
                    $params = new JParameter(JFile::read($filepath));
                    // Check if it is default profile or not
                    if ($filename == 'default') {
                        $profile->core  = $params->toArray();
                        // Merge custom parameters
                        $profile->local = array_merge($dparams, $params->toArray());
                    } else {
                        $profile->local = $params->toArray();
                    }
                    $profiles[$filename] = $profile;
                }
            }
            // If there isn't any profile in etc/profiles folders, create empty default profile
            if (empty($profiles) || !isset($profiles['default'])) {
                $profile = new stdclass();
                $profile->core  =  '  ';
                $profile->local =  null;
                $profiles['default'] = $profile;
            }
        } else {
            // Maybe template still has older structure folders, so try to read core/local folder.
            $profiles = array();
        $file_profiles = array();
        $arr_folder = array('core', 'local');
        foreach ($arr_folder as $folder) {
            $path = JPATH_SITE.DS.'templates'.DS.$this->template.DS.$folder.DS.'etc'.DS.'profiles';
            if (!JFolder::exists($path)) {
                    if (JFolder::create($path)) {
                $content = '';
                JFile::write($path.DS.'index.html', $content);
            }
                }

            $files = @JFolder::files($path, '\.ini');
            if ($files) {
                foreach ($files as $f) {
                    $file_profiles[$f] = $path.DS.$f;
                }
            }
        }

        if ($file_profiles) {
            foreach ($file_profiles as $name=>$p) {
                $dparams = array();
                if ($name == 'default.ini') {
                        // Read custom parameters
                    $xmlpath = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'templateDetails.xml';
                    $xml = & JFactory::getXMLParser('Simple');

                    if ($xml->loadFile($xmlpath)) {
                        if ($params =& $xml->document->params) {
                            foreach ($params as $param) {
                                foreach ($param->children() as $p) {
                                    if ($p->attributes('name') && isset($p->_attributes['default'])) {
                                        $dparams [$p->attributes('name')] = $p->attributes('default');
                                    }
                                }
                            }
                        }
                    }
                }
                $profile = new stdclass();
                $path = 'etc'.DS.'profiles'.DS.$name;

                $file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'local'.DS.$path;
                $profile->local = null;
                if (JFile::exists($file)) {
                    $params = new JParameter(JFile::read($file));
                    $profile->local = array_merge($dparams, $params->toArray());
                }
                $file = JPATH_SITE.DS.'templates'.DS.$this->template.DS.'core'.DS.$path;
                $profile->core = null;
                if (JFile::exists($file)) {
                    $params = new JParameter(JFile::read($file));
                    $profile->core = array_merge($dparams, $params->toArray());
                }
                $profiles[strtolower(substr($name, 0, -4))] = $profile;
            }
        }
        if (!$profiles) {
            $profile = new stdclass();
            $profile->core =  '  ';
            $profile->local =  null;
            $profiles['default'] = $profile;
        }
        }

        return $profiles;
    }

    /**
     * Get template version
     *
     * @param string $template  Template name
     *
     * @return string  Template version
     */
    function getTemplateVersion($template)
    {
        $version = '';
        $name = '';
        $path = JPATH_SITE.DS.'templates'.DS.$template.DS.'templateDetails.xml';
        if (!file_exists($path)) {
            return JText::_('Not information about the version of this template');
        }
        $xml =& JFactory::getXMLParser('Simple');

        if ($xml->loadFile($path)) {
            $temp_info =& $xml->document;
            if (isset($temp_info->_children) && count($temp_info->_children)) {
                foreach ($temp_info->_children as $node) {
                    if ($version && $name) break;
                    if ($node->_name=='version') {
                        $version = $node->_data;
                    } elseif ($node->_name == 'name') {
                        $name = $node->_data;
                    }
                }
            }
        }
        if (!$version) $version = '1.0.0';
        return $version;
    }

    /**
     * Unzip file
     *
     * @param string $p_filename  Zip file path
     *
     * @return bool  TRUE if success, otherwise FALSE
     */
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
        $result = JArchive::extract($archivename, $extractdir);

        if ( $result === false ) {
            return false;
        }
        return true;
    }

    /**
     * Get theme information
     *
     * @param string $theme_info_path  Them information path
     *
     * @return array  Theme information
     */
    function getThemeinfo($theme_info_path)
    {
        $data = array();

        $xml = & JFactory::getXMLParser('Simple');
        if ($xml->loadFile($theme_info_path)) {
            $theme_info = & $xml->document;
            if (isset($theme_info->_children) && count($theme_info->_children)) {
                foreach ($theme_info->_children as $node) {
                    $data[$node->_name] = $node->_data;
                }
            }
        }
        return $data;
    }

    /**
     * Build position selected box
     *
     * @param string $name  Name of attribute
     *
     * @return string  Selected box markup
     */
    function buildHTML_Positions($name)
    {
        $positions = $this->getPositions();
        $positionsHTML = '';
        $element = array();
        if ($positions) {
            foreach ($positions as $p) {
                $element[] = JHTML::_('select.option', $p, $p);
            }
        }
        $positionsHTML = JHTML::_(
            'select.genericlist', $element, $name.'-positions[]',
            'class="inputbox" size="15" ondblclick="jaclass_'.$name.'.select_position(this)"',
            'value', 'text', array(), $name.'-positions'
        );
        return $positionsHTML;
    }

    /**
     * Get all position
     *
     * @return array  An array module position
     */
    function getPositions()
    {
        jimport('joomla.filesystem.folder');

        $client =& JApplicationHelper::getClientInfo(0);
        if ($client === false) {
            return false;
        }

        //Get the database object
        $db    =& JFactory::getDBO();

        // template assignment filter
        $query = 'SELECT DISTINCT(template) AS text, template AS value'.
                ' FROM #__templates_menu' .
                ' WHERE client_id = '.(int) $client->id;
        $db->setQuery($query);
        $templates = $db->loadObjectList();

        // Get a list of all module positions as set in the database
        $query = 'SELECT DISTINCT(position)'.
                ' FROM #__modules' .
                ' WHERE client_id = '.(int) $client->id;
        $db->setQuery($query);
        $positions = $db->loadResultArray();
        $positions = (is_array($positions)) ? $positions : array();

        // Get a list of all template xml files for a given application
        // Get the xml parser first
        for ($i = 0, $n = count($templates); $i < $n; $i++) {
            $path = $client->path.DS.'templates'.DS.$templates[$i]->value;

            $xml =& JFactory::getXMLParser('Simple');
            if ($xml->loadFile($path.DS.'templateDetails.xml')) {
                $p =& $xml->document->getElementByPath('positions');
                if (is_a($p, 'JSimpleXMLElement') && count($p->children())) {
                    foreach ($p->children() as $child) {
                        if (!in_array($child->data(), $positions)) {
                            $positions[] = $child->data();
                        }
                    }
                }
            }
        }

        if (defined('_JLEGACY') && _JLEGACY == '1.0') {
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

    /**
     * Check can set col width
     *
     * @param string $block  Block name
     *
     * @return bool  TRUE if can, otherwise FALSE
     */
    function isSetColwidth($block='')
    {
        if (in_array($block, array('left1', 'left2', 'right1', 'right2', 'inset1', 'inset2'))) {
            return true;
        }
        return false;
    }

    /**
     * Check Extension manager exists
     *
     * @return int  1 if exits, otherwise 0
     */
    function checkexistExtensinsManagement()
    {
        $db = JFactory::getDBO();
        $query =" SELECT Count(*) FROM #__extensions as c WHERE c.name='com_jaextmanager' and c.type='component' and c.`client_id`=0 and c.enabled=1";
        $db->setQuery($query);
        return $db->loadResult();
    }

    /**
     * Get database menu value
     *
     * @return object
     */
    function getDatabaseValue()
    {
        $db =& JFactory::getDBO();
        $id = JRequest::getVar('cid', 0, '', 'array');
        $id = ( int ) $id [0];
        if ($id == "") $id = 0;
        $query = "SELECT * FROM #__menu WHERE id = '".$id."'";
        $db->setQuery($query);
        return $db->loadObject();
    }

    /**
     * Get system parameters
     *
     * @param string $xmlstring  XML String
     *
     * @return string
     */
    function getSystemParams($xmlstring)
    {
        // Initialize variables
        $params = null;
        $item   = $this->getDatabaseValue();
        if (isset($item->params)) {
            $params = new JParameter($item->params);
            //update value to make it compatible with old parameter
            if (!$params->get('mega_subcontent_mod_modules', '') && $params->get('mega_subcontent-mod-modules')) {
                $params->set('mega_subcontent_mod_modules', $params->get('mega_subcontent-mod-modules'));
            }
            if (!$params->get('mega_subcontent_pos_positions', '') && $params->get('mega_subcontent-pos-positions')) {
                $params->set('mega_subcontent_pos_positions', $params->get('mega_subcontent-pos-positions'));
            }
        } else {
            $params = new JParameter("");
        }
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
     * @param string $bodyContent  The body string content.
     *
     * @return string  The replaced body string content
     */
    function replaceContent($bodyContent)
    {
        // Build HTML params area
        $xmlFile = T3Path::path(T3_CORE) . DS . 'params' . DS ."jatoolbar.xml";
        if (! file_exists($xmlFile)) {
            return $bodyContent;
        }
        $str = "";

        $configform = JForm::getInstance('params', $xmlFile, array('control' => 'jform'));

        $fieldSets = $configform->getFieldsets('params');
        $html = '';
        foreach ($fieldSets as $name => $fieldSet) {
            $html .= '<div class="panel">
                <h3 id="jatoolbar-page" class="jpane-toggler title">
                    <a href="#"><span>'.JText::_($fieldSet->label).'</span></a>
                </h3>';

            $html .= '
                <div class="jpane-slider content">
                    <fieldset class="panelform">';
            if (isset($fieldSet->description) && trim($fieldSet->description)) {
                $html .= '<div class="block-des">'.JText::_($fieldSet->description).'</div>';
            }

            $html .= '    <ul class="adminformlist">';
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

    /**
     * Get data from url, request
     *
     * @param string $URL  URL string
     * @param string $req  Request string
     *
     * @return string  Received data
     */
    function curl_getdata($URL, $req)
    {
        $proxy = JRequest::getVar('enable_proxy', 0);
        if ($proxy) {
            $proxy_address  = JRequest::getVar('proxy_address', '');
            $proxy_port     = JRequest::getVar('proxy_port', '');
            $proxystr       = "$proxy_address:$proxy_port";
            $proxy_user     = JRequest::getVar('proxy_user', '');
            $proxy_pass     = JRequest::getVar('proxy_pass', '');
            $proxyUserPass  = "$proxy_user:$proxy_pass";
            $proxyType      = JRequest::getVar('proxy_type', 'CURLPROXY_HTTP');
        }

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_URL, $URL);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $req);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

        if ($proxy) {
            curl_setopt($ch, CURLOPT_PROXY, $proxystr);
            curl_setopt($ch, CURLOPT_PROXYTYPE, $proxyType);
            curl_setopt($ch, CURLOPT_PROXYUSERPWD, $proxyUserPass);
        }

        $result = curl_exec($ch);
        curl_close($ch);
        return $result;
    }

    /**
     * Get data from host
     *
     * @param string $host  Host address
     * @param string $path  Path address
     * @param string $req   Request string
     *
     * @return string  Received data
     */
    function socket_getdata($host, $path, $req)
    {
        $header = "POST $path HTTP/1.0\r\n";
        $header .= "Host: " . $host . "\r\n";
        $header .= "Content-Type: application/x-www-form-urlencoded\r\n";
        $header .= "User-Agent:      Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1) Gecko/20061010 Firefox/2.0\r\n";
        $header .= "Content-Length: " . strlen($req) . "\r\n\r\n";
        $header .= $req;
        set_time_limit(500);
        $fp = @fsockopen($host, 80, $errno, $errstr, 500);
        if (! $fp) return;
        @fwrite($fp, $header);
        $data = '';
        $i = 0;
        do {
            $header .= @fread($fp, 1);
        } while (! preg_match('/\\r\\n\\r\\n$/', $header));

        while (! @feof($fp)) {
            $data .= @fgets($fp, 128);
        }
        fclose($fp);
        return $data;
    }

    /**
     * Check condition
     *
     * @return void
     */
    function checkCondition()
    {
        return (JRequest::getCmd('option', '') == 'com_templates'
            && JRequest::getCmd('layout') == 'edit'
            && JRequest::getCmd('view') == 'style');
    }

    /**
     * Check condition for menu
     *
     * @return bool  FALSE
     */
    function checkCondition_for_Menu()
    {
        return false;
    }

    /**
     * Check user permission
     *
     * @return bool  TRUE if registered user and is backend page, otherwise FALSE
     */
    function checkPermission()
    {
        $app = JFactory::getApplication();
        $user = JFactory::getUser();
        return ($user->id > 0 && $app->isAdmin());
    }

    /**
     * Load style
     *
     * @return void
     */
    function loadStyle()
    {
        if (JRequest::getCmd('option', '') == 'com_templates'
            && JRequest::getCmd('layout') == 'edit'
            && JRequest::getCmd('view') == 'style'
        ) {
            $path = JURI::root() . 'plugins/system/jat3/jat3/core/';
            JHTML::stylesheet($path. 'admin/assets/css/ja.tabs.css');
            JHTML::stylesheet($path. 'admin/assets/css/jat3.css');
            JHTML::stylesheet($path. 'admin/assets/tooltips/style.css');
            JHTML::stylesheet($path. 'element/assets/css/japaramhelper.css');
        }
    }

    /**
     * Load script
     *
     * @return void
     */
    function loadScipt()
    {
        if (JRequest::getCmd('option', '') == 'com_templates'
            && JRequest::getCmd('layout') == 'edit'
            && JRequest::getCmd('view') == 'style'
        ) {
            $path = JURI::root() . 'plugins/system/jat3/jat3/core/';

            $javersion = new JVersion();
            if ($javersion->RELEASE == '1.7') {
                JHtml::_('behavior.framework', true);
            } else {
                JHTML::_('behavior.mootools');
            }
            JHTML::script($path . 'admin/assets/js/ja_tabs.js');
            JHTML::script($path . 'admin/assets/js/jat3.js?v=1.6');
            //JHTML::script( $path. 'admin/assets/js/swfobject.js');
            JHTML::script($path . 'admin/assets/js/ja.moo.extends.js');
            JHTML::script($path . 'admin/assets/js/japageidsettings.js');
            JHTML::script($path . 'admin/assets/js/ja.upload.js');
            JHTML::script($path . 'element/assets/js/japaramhelper.js');
            //JHTML::script ( $path. 'admin/assets/js/firebug-lite-debug.js' );
            JHTML::_('behavior.modal');
        }
    }

    /**
     * Show buttun clear cache
     *
     * @return void
     */
    function show_button_clearCache()
    {
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

    /**
     * Get array of menutypes
     *
     * @return array
     */
    private function getMenuTypes()
    {
        $db = JFactory::getDbo();
        $db->setQuery('SELECT a.menutype FROM #__menu_types AS a');
        return $db->loadResultArray();
    }

    /**
     * Build menu tree by menutype
     *
     * @param string $menuType  Menutype name
     *
     * @return string  Rendered data
     */
    private function buildMenu($menuType)
    {
        $links = self::loadMenu($menuType);
        $n     = count($links);
        $data  = array();

        if ($n > 0) {
            $data[] = '<li>';
            $data[] = '<input type="checkbox" class="menutype" disabled /><label style="font-weight:bold;">'. $menuType .'</label>';
            for ($i = 1; $i < $n; $i++) {
                $value = $links[$i]->value;
                $text  = $links[$i]->text;
                $inputbox = '<li><input type="checkbox" class="pageitem" id="'.$value.'" /><label for="'. $value .'">'. $text .'</label>';
                if ($links[$i]->level > $links[$i-1]->level) {
                    $data[] = '<ul class="level' . $links[$i]->level . '">';
                    $data[] = $inputbox;
                } elseif ($links[$i]->level == $links[$i-1]->level) {
                    $data[] =  '</li>';
                    $data[] .= $inputbox;
                } else {
                    $data[] = '</li>';
                    for ($j = $links[$i]->level, $m = $links[$i-1]->level; $j < $m; $j++) {
                        $data[] = '</ul></li>';
                    }
                    $data[] = $inputbox;
                }
            }
            $data []= '</li>';
            for ($j = 0, $m = $links[$i-1]->level; $j < $m; $j++) {
                $data []=  '</ul></li>' . "\n";
            }
        }

        // Implode data
        $data = implode("\n", $data);
        return $data;
    }

    /**
     * Load menu items by menu type
     *
     * @param string $menuType  Menu type name
     *
     * @return array  List of item list
     */
    private function loadMenu($menuType)
    {
        static $links = array();
        if (isset($links[$menuType])) return $links[$menuType];

        $db = JFactory::getDbo();
        $query = $db->getQuery(true);

        $query->select('a.id AS value, a.title AS text, a.level, a.menutype, a.type, a.template_style_id, a.checked_out, a.language');
        $query->from('#__menu AS a');
        $query->join('LEFT', '`#__menu` AS b ON a.lft > b.lft AND a.rgt < b.rgt');

        if ($menuType) {
            $query->where('(a.menutype = '.$db->quote($menuType).' OR a.parent_id = 0)');
        }

        $query->where('a.published != -2');
        $query->group('a.id');
        $query->order('a.lft ASC');

        $db->setQuery($query);

        $links[$menuType] = $db->loadObjectList();

        return $links[$menuType];
    }

    /**
     * Get list of menu id that assigned for the specific template
     *
     * @param int $template_style_id  Template style id
     *
     * @return arrray  List of menu id
     */
    public function getAssignedMenu($styleid = null)
    {
    	if ($styleid == null) {
    	   $styleid  = JRequest::getInt('id');
    	}
    	$db = JFactory::getDbo();
    	$query = $db->getQuery(true);

    	$query->select('a.id');
    	$query->from('#__menu as a');
    	$query->where('a.template_style_id = '.intval($styleid));

    	$db->setQuery($query);

    	return $db->loadColumn();
    }

    /**
     * Method to get installed languages data.
     *
     * @param int $client  Indicate front-end or back-end
     *
     * @return  string  An SQL query
     */
    public function getLanguageList($client = 0)
    {
        // Create a new db object.
        $db = JFactory::getDbo();
        $query = $db->getQuery(true);
        $type = "language";
        // Select field element from the extensions table.
        $query->select('a.element');
        $query->from('`#__extensions` AS a');

        $type = $db->Quote($type);
        $query->where('(a.type = '.$type.')');

        $query->where('state = 0');
        $query->where('enabled = 1');

        $query->where('client_id=' . intval($client));

        // for client_id = 1 do we need to check language table also ?
        $db->setQuery($query);

        $langlist = $db->loadResultArray();

        if (count($langlist) > 1) {
            $langlist = array_pad($langlist, -(count($langlist)+1), 'All');
        } else {
            $langlist = array('All');
        }

        return $langlist;
    }

    /**
     * Check use new folder structure or old
     *
     * @return bool   TRUE if use, otherwise FALSE
     */
    public function checkUseNewFolderStructure()
    {
        // Check etc folder exists in template folder
        $path = JPATH_SITE.'/templates/'.$this->template;
        if (!is_dir($path.'/etc')) {
            return false;
        }
        // Check themes folder exists in template folder
        if (!is_dir($path.'/themes')) {
            return false;
        }
        return true;
    }
}

if (!function_exists('json_decode')) {
    if (!class_exists('Services_JSON')) {
        t3_import('core/libs/JSON');
    }

    /**
     * Decode JSON to string
     *
     * @param string $str  JSON string
     *
     * @return string  Decoded string
     */
    function json_decode($str)
    {
        //make a new json parser
        $json = new Services_JSON;
        return $json->decode($str);
    }
}

if (!function_exists('json_encode')) {
    if (!class_exists('Services_JSON')) {
        t3_import('core/libs/JSON');
    }

    /**
     * Encode string to JSON
     *
     * @param string $var  String
     *
     * @return string  JSON string
     */
    function json_encode($var)
    {
        //make a new json parser
        $json = new Services_JSON;
        return $json->encode($var);
    }

}

?>