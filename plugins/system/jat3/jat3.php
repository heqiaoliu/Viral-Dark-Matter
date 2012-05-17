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

jimport('joomla.plugin.plugin');
jimport('joomla.application.module.helper');

require_once dirname(__FILE__) . DS . 'jat3' . DS . 'core' . DS . 'common.php';

/**
 * plgSystemJAT3 class
 *
 * @package JAT3
 */
class plgSystemJAT3 extends JPlugin
{
    var $plugin = null;
    var $plgParams = null;
    var $time = 0;

    /**
     * Constructor
     *
     * @param object &$subject   The object to observe
     * @param array  $config     An optional associative array of configuration settings.
     */
    function __construct (&$subject, $config)
    {
        parent::__construct($subject, $config);
        $this->plugin = &JPluginHelper::getPlugin('system', 'jat3');
        jimport('joomla.html.parameter');
        $this->plgParams = new JParameter($this->plugin->params);
    }

    /**
     * Implement after render event
     *
     * @return null
     */
    function onAfterRender ()
    {
        $app = JFactory::getApplication();
        t3import('core.admin.util');

        $util = new JAT3_AdminUtil();

        if ($app->isAdmin()) {
            ob_start();
            $util->show_button_clearCache();
            $content = ob_get_clean();
            $buffer = JResponse::getBody();
            $buffer = preg_replace('/<\/body>/', $content . "\n</body>", $buffer);
            JResponse::setBody($buffer);
        }

        if ($util->checkPermission()) {
            if (JAT3_AdminUtil::checkCondition_for_Menu()) {
                // HTML= Parser lib
                include_once T3Path::path(T3_CORE) . DS . 'libs' . DS . "html_parser.php";
                include_once T3Path::path(T3_CORE) . DS . 'admin' . DS . "util.php";

                $_body = JResponse::getBody();

                // Replace content
                $jat3core = new JAT3_AdminUtil();
                $_body = $jat3core->replaceContent($_body);

                if ($_body) {
                    JResponse::setBody($_body);
                }
            }
        }

        if (! T3Common::detect())
            return;

        if ($util->checkPermission()) {
            if ($util->checkCondition()) {
                $params = T3Path::path(T3_CORE) . DS . 'admin' . DS . 'index.php';
                if (file_exists($params)) {
                    ob_start();
                    include $params;
                    $content = ob_get_clean();
                    $buffer = JResponse::getBody();

                    $buffer = preg_replace('/<\/body>/', $content . "\n</body>", $buffer);
                    JResponse::setBody($buffer);
                }
            }
            return;
        }

        if (!$app->isAdmin()) {
            //Expires date set to very long
            //JResponse::setHeader( 'Expires', gmdate( 'D, d M Y H:i:s', time() + 3600000 ) . ' GMT', true );
            //JResponse::setHeader( 'Last-Modified', gmdate( 'D, d M Y H:i:s', time()) . ' GMT', true );
            JResponse::setHeader('Expires', '', true);
            JResponse::setHeader('Cache-Control', 'private', true);

            //Update cache in case of the whole page is cached
            $t3template = T3Template::getInstance();
            $key = T3Cache::getPageKey();
            //if (($data = T3Cache::get ( $key )) && !preg_match('#<jdoc:include\ type="([^"]+)" (.*)\/>#iU', $data)) {
            if ($key != null && $t3template->nonecache == false) {
                $time = time();
                JResponse::setHeader('Last-Modified', gmdate('D, d M Y H:i:s', $time) . ' GMT', true);
                JResponse::setHeader('ETag', md5($key), true);

                $time = sprintf('%20d', $time);
                $buffer = $time . JResponse::getBody();
                $t3cache = T3Cache::getT3Cache();
                $t3cache->store($buffer, $key);
            }
        }
    }

    /**
     * Implement after route event
     *
     * @return null
     */
    function onAfterRoute ()
    {
        // Load t3 language file for front-end & template admin.
        $this->loadLanguage(null, JPATH_ADMINISTRATOR);

        t3import('core.framework');

        $app = JFactory::getApplication('administrator');

        if ($app->isAdmin()) {
            t3import('core.admin.util');
            // Clean cache if there's something changed backend
            if (JRequest::getCmd('jat3action') || in_array(JRequest::getCmd('task'), array ('save', 'delete', 'remove', 'apply', 'publish', 'unpublish'))) {
                if (JRequest::getCmd('jat3action')) {
                    //if template parameter updated => clear cache
                    t3_import('core/cache');
                    T3Cache::clean(2);
                } else {
                    $params = T3Common::get_template_based_params();
                    $cache = $params->get('cache');
                    if ($cache) {
                        //if other update: clear cache if cache is enabled
                        t3_import('core/cache');
                        T3Cache::clean(1);
                    }
                }
            }

            if (JAT3_AdminUtil::checkPermission()) {

                if (JAT3_AdminUtil::checkCondition_for_Menu()) {
                    JHTML::stylesheet('', JURI::root() . T3_CORE . '/element/assets/css/japaramhelper.css');
                    JHTML::script('', JURI::root() . T3_CORE . '/element/assets/js/japaramhelper.js', true);
                }

                if (JRequest::getCmd('jat3type') == 'plugin') {
                    $action = JRequest::getCmd('jat3action');

                    t3import('core.ajax');
                    $obj = new JAT3_Ajax();

                    if ($action && method_exists($obj, $action)) {
                        $obj->$action();
                    }
                    return;
                }

                if (! T3Common::detect()) {
                    return;
                }

                JAT3_AdminUtil::loadStyle();
                JAT3_AdminUtil::loadScipt();

                return;
            } elseif (JRequest::getCmd('jat3type') == 'plugin') {
                $result ['error'] = 'Session has expired. Please login before continuing.';
                echo json_encode($result);
                exit();
            }

            return;
        }

        if (! $app->isAdmin() && T3Common::detect()) {
            $action = JRequest::getCmd('jat3action');
            // Process request ajax like action - public
            if ($action) {
                t3import('core.ajaxsite');
                if (method_exists('T3AjaxSite', $action)) {
                    T3AjaxSite::$action ();
                    $app->close(); //exit after finish action
                }
            }

            // Load core library
            T3Framework::t3_init($this->plgParams);
            // Init T3Engine
            // Get list templates
            $themes = T3Common::get_active_themes();
            $path = T3Path::getInstance();
            // Path in t3 engine
            // Active themes path
            if ($themes && count($themes)) {
                foreach ( $themes as $theme ) {
                    if ($theme [0] == 'engine') {
                        $path->addPath(
                            $theme [0] . '.' . $theme [1],
                            T3Path::path(T3_BASE . '/base-themes/' . $theme [1]),
                            T3Path::url(T3_BASE . '/base-themes/' . $theme [1])
                        );
                    } elseif ($theme [0] == 'template') {
                        $path->addPath($theme [0] . '.' . $theme [1], T3Path::path(T3_TEMPLATE), T3Path::url(T3_TEMPLATE));
                    } else {
                        $themepath = T3Path::path(T3_TEMPLATE).DS.'themes';
                        // Check if template use newest folder structure or not
                        // If themes folder is exists in template folder, consider as template use newst folder structure
                        if (@is_dir($themepath)) {
                            $path->addPath(
                                $theme[0].'.'.$theme[1],
                                T3Path::path(T3_TEMPLATE).DS.'themes'.DS.$theme[1],
                                T3Path::url(T3_TEMPLATE) . "/themes/{$theme[1]}"
                            );
                        } else {
                            // Compatible: if template use older folder structure, try to use it
                            $path->addPath(
                                $theme [0] . '.' . $theme [1],
                                T3Path::path(T3_TEMPLATE) . DS . $theme [0] . DS . 'themes' . DS . $theme [1],
                                T3Path::url(T3_TEMPLATE) . "/{$theme[0]}/themes/{$theme[1]}"
                            );
                    }
                    }
                }
            }
            // Disable editor if website is access by iphone & handheld
            $device = T3Common::mobile_device_detect();
            if ($device == 'iphone' || $device == 'handheld') {
                $config = JFactory::getConfig();
                $config->set('editor', 'none');
            }
            T3Framework::init_layout();
        }
    }

    /**
     * Add JA Extended menu parameter - used for Joomla 1.6
     *
     * @param   JForm   $form   The form to be altered.
     * @param   array   $data   The associated data for the form
     *
     * @return  null
     */
    function onContentPrepareForm($form, $data)
    {
        if ($form->getName() == 'com_menus.item') {
            JForm::addFormPath(JPATH_SITE . DS . T3_CORE . DS . 'params');
            $form->loadFile('params', false);
        }
    }

    /**
     * Implement event onRenderModule to include the module chrome provide by T3
     * This event is fired by overriding ModuleHelper class
     * Return false for continueing render module
     *
     * @param   object  &$module   A module object.
     * @param   array   $attribs   An array of attributes for the module (probably from the XML).
     *
     * @return  bool
     */
    function onRenderModule (&$module, $attribs)
    {
        static $chromed = false;
        // Detect layout path in T3 themes
        if (T3Common::detect()) {
            // Remove outline style which added when tp=1
            // T3 template provide an advanced tp mode which could show more information than the default
            if (JRequest::getCmd('t3info')) {
                $attribs ['style'] = preg_replace('/\s\boutline\b/i', '', $attribs ['style']);
            }

            // Chrome for module
            if (!$chromed) {
                $chromed = true;
                // We don't need chrome multi times
                $chromePath = T3Path::getPath('html'.DS.'modules.php', false);
                if (file_exists($chromePath)) {
                    include_once $chromePath;
                }
            }
        }
        return false;
    }

    /**
     * Implement event onGetLayoutPath to return the layout which override by T3 & T3 templates
     * This event is fired by overriding ModuleHelper class
     * Return path to layout if found, false if not
     *
     * @param   string  $module  The name of the module
     * @param   string  $layout  The name of the module layout. If alternative
     *                           layout, in the form template:filename.
     *
     * @return  null
     */
    function onGetLayoutPath($module, $layout)
    {
        // Detect layout path in T3 themes
        if (T3Common::detect()) {
            $tPath = T3Path::getPath('html' . DS . $module . DS . $layout . '.php', false);
            if ($tPath)
                return $tPath;
        }
        return false;
    }
}