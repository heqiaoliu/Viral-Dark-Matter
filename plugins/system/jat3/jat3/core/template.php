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
 * T3Template class
 *
 * @package JAT3.Core
 */
class T3Template extends ObjectExtendable
{
  var $_params = null;
  var $_tpl = null;
  var $_layout_setting = null;
  var $_colwidth = null;
  var $_theme_info = null;
  var $_css = array();
  var $_js = array();
  var $_blocks = array();
  var $_body_class = array();
  var $_html = '';

  var $template = '';
  var $cache = null;

  var $nonecache = false;

  /**
   * Constructor
   *
   * @param string $template  Template name
   *
   * @return void
   */
  function __construct($template = null)
  {
      $this->template = T3_ACTIVE_TEMPLATE;
      $this->_params = & T3Parameter::getInstance();
      $this->_theme_info = T3Common::get_active_themes_info();
      if ($template) {
          $this->_tpl = $template;
          $this->_extend(array($template));
      }
  }

  /**
   * Return T3Template object
   *
   * @param string $template  Template name
   *
   * @return T3Template
   */
  function &getInstance($template = null)
  {
      static $instance = null;

      if (!isset($instance)) {
          $instance = new T3Template($template);
      }

      return $instance;
  }

  /**
   * Set template object
   *
   * @param string $template  Template name
   *
   * @return void
   */
  function setTemplate($template)
  {
      $this->_tpl = $template;
      $this->_extend(array($template));
  }

  /**
   * Get template parameter
   *
   * @param string $name     Parameter name
   * @param string $default  Default value
   *
   * @return string  Parameter value
   */
  function getParam($name, $default = '')
  {
      return $this->_params->getParam($name, $default);
  }

  /**
   * Get element information
   *
   * @param array  $xml   Element data
   * @param string $name  Element name
   *
   * @return string  Element information
   */
  function getInfo($xml, $name)
  {
      $element = T3Common::arr_find_child($xml, $name);
      if ($element) return $element['data'];
      return null;
  }

  /**
   * Get layout settings
   *
   * @param string $name     Setting name
   * @param string $default  Default value
   *
   * @return string  Setting value
   */
  function getLayoutSetting($name, $default = null)
  {
      if (!isset($this->_layout_setting)) return $default;
      $setting = $this->_layout_setting;
      $keys = preg_split('/\./', $name);
      foreach ($keys as $key) {
          if (!isset($setting[$key])) return $default;
          $setting = $setting[$key];
      }
      return $setting;
  }

  /**
   * Get main (middle) block. The blocks are defined in info.xml and for each device type
   *
   * @param string $name    Block name
   * @param string $parent  Parent block name
   *
   * @return array
   */
  function &getBlockXML($name, $parent = 'middle')
  {
      $null = null;
      $layout = & $this->getLayoutXML();
      if (!$layout) return $null;
      $blocks = & $this->getBlocksXML($parent);
      if (!$blocks) return $null;
      $block = & T3Common::arr_find_child($blocks, 'block', 'name', $name);
      return $block;
  }

  /**
   * Get blocks by name
   *
   * @param string $name  Block name
   *
   * @return array  List block
   */
  function &getBlocksXML($name)
  {
      $null = null;
      $layout = & $this->getLayoutXML();
      if (!$layout) return $null;
      $blocks = & T3Common::arr_find_child($layout, 'blocks', 'name', $name);
      return $blocks;
  }

  /**
   * Get layout xml
   *
   * @return array  Layout xml
   */
  function &getLayoutXML()
  {
      $layout = & $this->_theme_info['layout'];
      return $layout;
  }

  /**
   * Get block style
   *
   * @param string $block        Block name
   * @param string $blocks_name  Parent block name
   *
   * @return string  Block style
   */
  function getBlockStyle($block, $blocks_name = 'middle')
  {
      if ($style = T3Common::node_attributes($block, 'style')) return $style;

      $layout = $this->getLayoutXML();
      $blocks = T3Common::xml_find_element($layout, 'blocks', 'name', $blocks_name);

      if ($style = T3Common::node_attributes($blocks, 'style')) return $style;
      if ($style = T3Common::node_attributes($layout, 'style')) return $style;
      return 'JAxhtml';
  }

  /**
   * Find template of block
   *
   * @param string $block  Block name
   *
   * @return string  Path of block
   */
  function findBlockTemplate($block)
  {
      if (!$block) return false;
      $block_type = T3Common::node_attributes($block, 'type', 'modules');
      $tmpl_path = T3Path::getPath("blocks/$block_type.php");
      if (!$tmpl_path) return false;
      return $tmpl_path;
  }

  /**
   * Show block
   *
   * @param array $block  Block name
   *
   * @return void
   */
  function showBlock($block)
  {
      $data = $this->loadBlock($block);
      if (!$data) return;
      if (is_array($block)) {
          //show block begin & end
          $parent = T3Common::node_attributes($block, 'parent', 'middle');
          if ($parent == 'head') {
              echo $data;
          } else if ($parent == 'middle') {
              $this->genMiddleBlockBegin($block);
              echo $data;
              $this->genMiddleBlockEnd($block);
          } else {
              $this->genBlockBegin($block);
              echo $data;
              $this->genBlockEnd($block);
          }
      } else {
          echo $data;
      }
      return;
  }

  /**
   * Load all blocks
   *
   * @return void
   */
  function loadBlocks()
  {
      $layout = $this->getLayoutXML();
      if (!$layout) return;
      $blockses = T3Common::node_children($layout, 'blocks');
      foreach ($blockses as $blocks) {
          $_blocks = T3Common::node_children($blocks, 'block');
          foreach ($_blocks as $block) {
              $this->loadBlock($block);
          }
      }
  }

  /**
   * Load block content
   *
   * @param mixed $block  Block type or block data
   *
   * @return string  Block content
   */
  function loadBlock($block)
  {
      $parent = null;
      if (is_array($block)) {
          $parent = T3Common::node_attributes($block, 'parent', 'middle');
          $block_type = T3Common::node_attributes($block, 'type', ($parent == 'middle' ? 'middle' : 'modules'));
          $name = T3Common::node_attributes($block, 'name');
          $key = "$parent.$name";
      } else {
          $block_type = $block;
          $key = $block_type;
      }
      if (isset($this->_blocks[$key])) return $this->_blocks[$key];

      $tmpl_path = T3Path::getPath("blocks/$block_type.php");
      if (!$tmpl_path) return false;

      ob_start();
      include $tmpl_path;
      $data = trim(ob_get_contents());
      ob_end_clean();
      //Add a div wrapper for showing block information
      //delete limit && in_array($parent, array('top','middle','bottom'))
      if ($this->getParam('infomode', 1) == 1 && JRequest::getCmd('t3info') && ($key != 'message') && ($key != 'fixheight')) {
          $data = "<div id=\"jainfo-block-$key\" class=\"jainfo-block\">$data</div>";
      }
      $this->_blocks[$key] = $data;
      return $data;
  }

  /**
   * Generate markup before block content
   *
   * @param array  $block  Block data
   * @param string $name   Name of block
   *
   * @return void
   */
  function genBlockBegin ($block, $name='')
  {
      if (!is_array($block)) return;

      static $genned = array();
      if (!$name) $name = T3Common::node_attributes($block, 'name');
      if (isset ($genned[$name])) return; //for each block, generate once
      $genned[$name] = 1;

      $class = T3Common::node_attributes($block, 'class');
      //call hook block_begin
      $html = T3Hook::_('block_begin', array($block, $name));
      if ($html) {
          echo $html;
          return;
      }

      $clearfix = '';
      $nowrap = $name == 'middle' ? 1 : intval(T3Common::node_attributes($block, 'no-wrap')); //no wrap in case generate
      $nomain = intval(T3Common::node_attributes($block, 'no-main'));
      if (T3Common::node_attributes($block, 'parent') == 'middle') $nomain = 1;
      $wrapinner = intval(T3Common::node_attributes($block, 'wrap-inner'));
      $maininner = intval(T3Common::node_attributes($block, 'main-inner'));
      ?>
      <?php if (!$nowrap):
      if (!$wrapinner && $nomain && !$maininner) $clearfix = ' clearfix';
      ?>
      <div id="ja-<?php echo $name ?>" class="wrap <?php echo $class ?><?php echo $clearfix ?>">
      <?php endif ?>

      <?php if ($wrapinner):
      for ($i=1;$i<=$wrapinner;$i++):
      if ($nomain && !$maininner && $i==$wrapinner) $clearfix = ' clearfix';
      ?>
          <div class="wrap-inner<?php echo $i.$clearfix ?>">
      <?php endfor;
      endif ?>

      <?php if (!$nomain):
      if (!$maininner) $clearfix = ' clearfix';
      ?>
          <div class="main<?php echo $clearfix ?>">
      <?php endif ?>

      <?php
      //gen special begin markup (markup=1/2/3)
      //1: basic - nothing; 2: advanced - left & right ; 3: complex - top - middle -bottom
      $markup = intval(T3Common::node_attributes($block, 'markup'));
      switch ($markup) {
          case 2:
              ?>
              <div class="l"></div>
              <div class="main-inner clearfix">
              <?php
              break;
          case 3:
              ?>
              <div class="top">
              <div class="tl"></div>
              <div class="tr"></div>
              </div>
              <div class="mid clearfix">
              <div class="ml"></div>
              <div class="main-inner clearfix">
              <?php
              break;
          case 1:
          default:
              break;
      }
      ?>

      <?php if ($maininner):
      for ($i=1;$i<=$maininner;$i++):
      if ($i==$maininner) $clearfix = ' clearfix';
      ?>
          <div class="main-inner<?php echo $i.$clearfix ?>">
      <?php endfor;
      endif;
  }

  /**
   * Generate markup after a block content
   *
   * @param arrary $block  Block data
   *
   * @return void
   */
  function genBlockEnd($block)
  {
      if (!is_array($block)) return;

      static $genned = array();
      $name = T3Common::node_attributes($block, 'name');
      if (isset ($genned[$name])) return; //for each block, generate once
      $genned[$name] = 1;

      // Call hook block_begin
      $html = T3Hook::_('block_end', array($block));
      if ($html) {
          echo $html;
          return;
      }

      $clearfix = '';
      $name = T3Common::node_attributes($block, 'name');
      $nowrap = $name == 'middle' ? 1 : intval(T3Common::node_attributes($block, 'no-wrap')); //no wrap in case generate
      $nomain = intval(T3Common::node_attributes($block, 'no-main'));
      if (T3Common::node_attributes($block, 'parent') == 'middle') $nomain = 1;
      $wrapinner = intval(T3Common::node_attributes($block, 'wrap-inner'));
      $maininner = intval(T3Common::node_attributes($block, 'main-inner'));
      ?>
      <?php if ($maininner):
      for ($i=1;$i<=$maininner;$i++):
      ?>
          </div>
      <?php endfor;
      endif; ?>

      <?php
      //gen special end markup (markup=1/2/3)
      //1: basic - nothing; 2: advanced - left & right ; 3: complex - top - middle -bottom
      $markup = intval(T3Common::node_attributes($block, 'markup'));
      switch ($markup) {
          case 2:
              ?>
              </div> <?php //for inner ?>
              <div class="r"></div>
              <?php
              break;
          case 3:
              ?>
              </div> <?php //for inner ?>
              <div class="mr"></div>
              </div> <?php //for mid ?>
              <div class="bot">
              <div class="bl"></div>
              <div class="br"></div>
              </div>
              <?php
              break;
          case 1:
          default:
              break;
      }
      ?>

      <?php if (!$nomain): ?>
          </div>
      <?php endif ?>

      <?php if ($wrapinner):
      for ($i=1;$i<=$wrapinner;$i++):
      ?>
          </div>
      <?php endfor;
      endif ?>

      <?php if (!$nowrap): ?>
      </div>
      <?php endif; ?>
      <?php
  }

  /**
   * Generate markup before a middle block content
   *
   * @param string $block  Block data
   * @param string $name   Block name
   *
   * @return string
   */
  function genMiddleBlockBegin($block, $name='')
  {
      if (!is_array($block)) return;

      static $genned = array();
      if (!$name) $name = T3Common::node_attributes($block, 'name');
      if (isset($genned[$name])) return; //for each block, generate once
      $genned[$name] = 1;

      //call hook block_begin
      $html = T3Hook::_('block_middle_begin', array($block, $name));
      if ($html) {
          echo $html;
          return;
      }

      $clearfix = '';
      $blockinner = intval(T3Common::node_attributes($block, 'block-inner'));
      //gen special begin markup (markup=1/2/3)
      //1: basic - nothing; 2: advanced - left & right ; 3: complex - top - middle -bottom
      $markup = intval(T3Common::node_attributes($block, 'markup'));
      switch ($markup) {
          case 2:
              ?>
              <div class="l"></div>
              <div class="block-inner clearfix">
              <?php
              break;
          case 3:
              ?>
              <div class="top">
              <div class="tl"></div>
              <div class="tr"></div>
              </div>
              <div class="mid clearfix">
              <div class="ml"></div>
              <div class="block-inner clearfix">
              <?php
              break;
          case 1:
          default:
              break;
      }
      ?>

      <?php if ($blockinner):
      for ($i=1;$i<=$blockinner;$i++):
      if ($i==$blockinner) $clearfix = ' clearfix';
      ?>
          <div class="block-inner<?php echo $i.$clearfix ?>">
      <?php endfor;
      endif;
  }

  /**
   * Generate markup for a middle block content
   *
   * @param string $block  Block data
   *
   * @return string
   */
  function genMiddleBlockEnd ($block)
  {
      if (!is_array($block)) return;

      static $genned = array();
      $name = T3Common::node_attributes($block, 'name');
      if (isset($genned[$name])) return; //for each block, generate once
      $genned[$name] = 1;

      //call hook block_begin
      $html = T3Hook::_('block_middle_end', array($block));
      if ($html) {
          echo $html;
          return;
      }

      $clearfix = '';
      $name = T3Common::node_attributes($block, 'name');
      $blockinner = intval(T3Common::node_attributes($block, 'block-inner'));

      ?>
      <?php if ($blockinner):
      for ($i=1;$i<=$blockinner;$i++):
      ?>
          </div>
      <?php endfor;
      endif; ?>

      <?php
      //gen special end markup (markup=1/2/3)
      //1: basic - nothing; 2: advanced - left & right ; 3: complex - top - middle -bottom
      $markup = intval(T3Common::node_attributes($block, 'markup'));
      switch ($markup) {
          case 2:
              ?>
              </div> <?php //for inner ?>
              <div class="r"></div>
              <?php
              break;
          case 3:
              ?>
              </div> <?php //for inner ?>
              <div class="mr"></div>
              </div>
              <?php //for mid ?>
              <div class="bot">
              <div class="bl"></div>
              <div class="br"></div>
              </div>
              <?php
              break;
          case 1:
          default:
              break;
      }
  }

  /**
   * Check is there a block in a layout and is there a module will be rendered in this block
   *
   * @param string $name  Block name
   *
   * @return bool  TRUE if there is block and module in block, otherwise FALSE
   */
  function hasBlock($name)
  {
      $block = $this->getBlockXML($name);
      if (!$block || !T3Common::node_data($block)) return false;
      $positions = preg_split('/,/', T3Common::node_data($block));
      $parent = T3Common::node_attributes($block, 'parent', 'middle');
      $hidewhenedit = $parent == 'middle' ? true : false;
      foreach ($positions as $position) {
          if ($this->countModules($position, $hidewhenedit)) return true;
      }
      return false;
  }

  /**
   * Parse data of layout and blocks
   *
   * @return void
   */
  function loadLayout()
  {
      // Load js framework
      if (JVERSION < '1.7') {
          JHTML::_('behavior.mootools');
      } else {
          JHtml::_('behavior.framework', true);
      }

      $this->parseLayout();
      $this->parsehead();
      $this->loadBlocks();


  }

  /**
   * Render template
   *
   * @return void
   */
  function render()
  {
      $replace = array();
      $matches = array();				
      // Load page layout if not loaded
      if (!$this->_html) {
        $layout_path = $this->getLayout();
        ob_start();
        include $layout_path;
        $this->_html = ob_get_contents();
        ob_end_clean();
      }
      $data = $this->_html;
      
      if (preg_match_all('#<jdoc:include\ type="([^"]+)" (.*)\/>#iU', $data, $matches)) {

          $cache_exclude = $this->getParam('cache_exclude');
          $cache_exclude = new JParameter($cache_exclude);
          $nc_com = explode(',', $cache_exclude->get('component'));
          $nc_pos = explode(',', $cache_exclude->get('position'));
          $nc_mod = explode(',', $cache_exclude->get('module'));

          $replace = array();
          $matches[0] = array_reverse($matches[0]);
          $matches[1] = array_reverse($matches[1]);
          $matches[2] = array_reverse($matches[2]);

          $count  = count($matches[1]);
          $option = JRequest::getCmd('option');

          $headindex = -1;

          // Search for item load in template (css, images, js)
          $regex = '/(href|src)=("|\')([^"\']*\/templates\/' . T3_ACTIVE_TEMPLATE . '\/([^"\']*))\2/';

          for ($i = 0; $i < $count; $i++) {
              $attribs = JUtility::parseAttributes($matches[2][$i]);
              $type  = $matches[1][$i];

              $name  = isset($attribs['name']) ? $attribs['name'] : null;
              //no cache => no cache for all jdoc include except head
              //cache: exclude modules positions & components listed in cache exclude param
              //check if head
              if ($type == 'head') {
                  $headindex = $i;
                  continue;
              } else {
                  $content = $this->getBuffer($type, $name, $attribs);
                  // Add a div wrapper for showing block information
                  if ($this->getParam('infomode', 1) == 1 && JRequest::getCmd('t3info')) {
                      if ($type == 'modules') {
                          $key = "pos.$name";
                      } elseif ($type == 'module') {
                          $key = "mod.$name";
                      } elseif ($type == 'component') {
                          $key = "content";
                      } else {
                          $key = "$type.$name";
                      }
                      $content = "<div id=\"jainfo-pos-$key\" class=\"jainfo-pos-$type\">$content</div>";
                  }
                  // Process url
                  $content = preg_replace_callback($regex, array($this , 'processReplateURL'), $content);
              }

              if (!$this->getParam('cache')
                  || ($type == 'modules'   && in_array($name, $nc_pos))
                  || ($type == 'module'    && in_array($name, $nc_mod))
                  || ($type == 'component' && in_array($option, $nc_com))
              ) {
                  $this->nonecache = true;
              }
              $replace[$i] = $content;
          }

          // Update head
          if ($headindex > -1) {
              T3Head::proccess();
              $head = $this->getBuffer('head');
              $replace[$headindex] = $head;
          }

          // Replace all cache content
          $data = str_replace($matches[0], $replace, $data);
          // Update cache
          // $key = T3Cache::getPageKey();
          //if ($key != null && $this->nonecache == false) {
          //    T3Cache::store($data, $key);
          //}

          // Replace none cache content
          //$data = str_replace($nonecachesearch, $nonecachereplace, $data);
      } else {
          $token       = JUtility::getToken();
          $search      = '#<input type="hidden" name="[0-9a-f]{32}" value="1" />#';
          $replacement = '<input type="hidden" name="' . $token . '" value="1" />';
          $data        = preg_replace($search, $replacement, $data);
      }

      echo $data;
  }

  /**
   * Get menu type
   *
   * @param string $menutype  Menu type name
   *
   * @return string  Menu type
   */
  function getMenuType($menutype = null)
  {
      global $option;
      if ($menutype && is_file(T3Path::path(T3_CORE) . DS . 'menu' . DS . "$menutype.class.php")) return $menutype;

      /* Not detect handheld if desktop mainnav is used
      //auto detect
      if (($mobile=T3Common::mobile_device_detect ())) {
          if (is_file(T3Path::path(T3_CORE).DS.'menu'.DS."$mobile.class.php")) $menutype = $mobile;
          else $menutype = 'handheld';
          return $menutype;
      }
      */

      $page_menus = $this->getParam('page_menus');
      $page_menus = str_replace("<br />", "\n", $page_menus);
      $pmenus = new JParameter($page_menus);

      //specify menu type for page
      $menutype = $pmenus->get(T3Common::getItemid());
      if (is_file(T3Path::path(T3_CORE) . DS . 'menu' . DS . "$menutype.class.php")) return $menutype;

      //specify menu type for component
      $menutype = $pmenus->get($option);
      if (is_file(T3Path::path(T3_CORE) . DS . 'menu' . DS . "$menutype.class.php")) return $menutype;

      //default menu type for site
      $menutype = $this->getParam(T3_TOOL_MENU, 'css');
      if (is_file(T3Path::path(T3_CORE) . DS . 'menu' . DS . "$menutype.class.php")) return $menutype;
      return 'css';
  }

  /**
   * Load menu
   *
   * @param string $menutype  Menu type name
   *
   * @return object  Menu object
   */
  function loadMenu($menutype = null)
  {
      static $jamenu = null;
      if (!isset($jamenu)) {
          //Init menu
          //Main navigation
          $ja_menutype = $this->getMenuType($menutype);
          if ($ja_menutype && $ja_menutype != 'none') {
              $japarams = new JParameter('');
              $japarams->set('menutype', $this->getParam('menutype', 'mainmenu'));
              $japarams->set('menu_images_align', 'left');
              $japarams->set('menu_images', 1); //0: not show image, 1: show image which set in menu item
              $japarams->set('menu_background', 1); //0: image, 1: background
              $japarams->set('mega-colwidth', 200); //Megamenu only: Default column width
              $japarams->set('mega-style', 1); //Megamenu only: Menu style.
              $japarams->set('startlevel', $this->getParam('startlevel', 0)); //Startlevel
              $japarams->set('endlevel', $this->getParam('endlevel', 0)); //endlevel
              //$jamenu = $this->loadMenu($japarams, $ja_menutype);
          }
          //End for main navigation

          $file = T3Path::path(T3_CORE) . DS . 'menu' . DS . "$ja_menutype.class.php";
          if (!is_file($file)) return null;
          include_once $file;
          $menuclass = "JAMenu{$ja_menutype}";
          $jamenu = new $menuclass($japarams);
          //assign template object
          $jamenu->_tmpl = $this;
          //load menu
          $jamenu->loadMenu();
          //check css/js file
          $this->addStylesheet(T3_TEMPLATE . "/css/menu/$ja_menutype.css");
          $this->addScript(T3_TEMPLATE . "/js/menu/$ja_menutype.js", true);
      }

      return $jamenu;
  }

  /**
   * Check having submenu
   *
   * @return bool  TRUE if having, otherwise FALSE
   */
  function hasSubmenu()
  {
      $jamenu = $this->loadMenu();
      if ($jamenu && $jamenu->hasSubMenu(1) && $jamenu->showSeparatedSub) return true;
      return false;
  }

  /**
   * Get layout path
   *
   * @return string  Layout path
   */
  function getLayout()
  {
      if (JRequest::getCmd('tmpl') == 'component') {
          $layout_path = T3Path::getPath("page/component.php");
          if ($layout_path) return $layout_path;
      }

      if (JRequest::getCmd('ajax')) {
          $layout_path = T3Path::getPath("page/ajax." . JRequest::getCmd('ajax') . ".php");
          if ($layout_path) return $layout_path;
      }

      $mobile = T3Common::mobile_device_detect();
      if ($mobile) {
          //try to find layout render
          $layout_path = T3Path::getPath("page/$mobile.php");
          if (!$layout_path) {
              $layout_path = T3Path::getPath("page/handheld.php");
          }
          if (!$layout_path) {
              $layout_path = T3Path::getPath("page/default.php");
          }
      } else {
          $layout_path = T3Path::getPath("page/default.php");
      }
      return $layout_path;
  }

  /**
   * Parse layout
   *
   * @return void
   */
  function parseLayout()
  {
      //parse layout
      $this->_colwidth = array();
      //Left
      $l = $l1 = $l2 = 0;
      if ($this->hasBlock('left-mass-top') || $this->hasBlock('left-mass-bottom') || ($this->hasBlock('left1') && $this->hasBlock('left2'))) {
          $l = 2;
          $l1 = $this->getColumnBasedWidth('left1');
          $l2 = $this->getColumnBasedWidth('left2');
      } else if ($this->hasBlock("left1")) {
          $l = 1;
          $l1 = $this->getColumnBasedWidth('left1');
      } else if ($this->hasBlock("left2")) {
          $l = 1;
          $l2 = $this->getColumnBasedWidth('left2');
      }
      $cls_l = $l ? "l$l" : "";
      $l = $l1 + $l2;

      //right
      $r = $r1 = $r2 = 0;
      if ($this->hasBlock("right-mass-top") || $this->hasBlock("right-mass-bottom") || ($this->hasBlock("right1") && $this->hasBlock("right2"))) {
          $r = 2;
          $r1 = $this->getColumnBasedWidth('right1');
          $r2 = $this->getColumnBasedWidth('right2');
      } else if ($this->hasBlock("right1")) {
          $r = 1;
          $r1 = $this->getColumnBasedWidth('right1');
      } else if ($this->hasBlock("right2")) {
          $r = 1;
          $r2 = $this->getColumnBasedWidth('right2');
      }
      $cls_r = $r ? "r$r" : "";
      $r = $r1 + $r2;

      //inset
      $inset1 = $this->getPositionName('inset1');
      $inset2 = $this->getPositionName('inset2');
      $i1 = $i2 = 0;
      if ($this->hasBlock("inset1")) $i1 = $this->getColumnBasedWidth('inset1');
      if ($this->hasBlock("inset2")) $i2 = $this->getColumnBasedWidth('inset2');

      //width
      $totalw = 100;
      if ($this->isIE()) $totalw = 99.99;
      $this->_colwidth['r'] = $r;
      if ($r) {
          $this->_colwidth['r1'] = round($r1 * 100 / $r, 2);
          $this->_colwidth['r2'] = $totalw - $this->_colwidth['r1'];
      }
      $this->_colwidth['mw'] = $totalw - $r;
      $m = $totalw - $l - $r;
      $this->_colwidth['l'] = ($l + $m) ? round($l * 100 / ($l + $m), 2) : 0;
      if ($l) {
          $this->_colwidth['l1'] = round($l1 * 100 / $l, 2);
          $this->_colwidth['l2'] = $totalw - $this->_colwidth['l1'];
      }
      $this->_colwidth['m'] = $totalw - $this->_colwidth['l'];

      $c = $m - $i1 - $i2;
      $this->_colwidth['i2'] = round($i2 * 100 / $m, 2);
      $this->_colwidth['cw'] = $totalw - $this->_colwidth['i2'];
      $this->_colwidth['i1'] = ($c + $i1) ? round($i1 * 100 / ($c + $i1), 2) : 0;
      $this->_colwidth['c'] = $totalw - $this->_colwidth['i1'];

      $cls_li = $this->hasBlock("inset1") ? 'li' : '';
      $cls_ri = $this->hasBlock("inset2") ? 'ri' : '';

      $this->_colwidth['cls_w'] = ($cls_l || $cls_r) ? "ja-$cls_l$cls_li$cls_ri$cls_r" : "";
      $this->_colwidth['cls_m'] = ($cls_li || $cls_ri) ? "ja-$cls_li$cls_ri" : "";
      $this->_colwidth['cls_l'] = $this->hasBlock("left1") && $this->hasBlock("left2") ? "ja-l2" : ($this->hasBlock("left1") || $this->hasBlock("left2") ? "ja-l1" : "");
      $this->_colwidth['cls_r'] = $this->hasBlock("right1") && $this->hasBlock("right2") ? "ja-r2" : ($this->hasBlock("right1") || $this->hasBlock("right2") ? "ja-r1" : "");
  }

  /**
   * Calculate spotlight width of each position
   *
   * @param string $spotlight     Splotlight name
   * @param int    $totalwidth    Total width
   * @param int    $specialwidth  Special width
   * @param string $special       Special position
   *
   * @return array  Calcalated position
   */
  function calSpotlight($spotlight, $totalwidth = 100, $specialwidth = 0, $special = 'left')
  {
    $modules = array();
    $modules_s = array();
    foreach ($spotlight as $position) {
        if ($this->countModules($position)) {
            $modules_s[] = $position;
        }
        $modules[$position] = array('class' => '-full', 'width' => $totalwidth . '%');
    }

    if (!count($modules_s)) return null;
    if ($specialwidth) {
        if (count($modules_s) > 1) {
            $width = floor(($totalwidth - $specialwidth) / (count($modules_s) - 1) * 10) / 10 . "%";
            $specialwidth = $specialwidth . "%";
        } else {
            $specialwidth = $totalwidth . "%";
        }
    } else {
        $width = (floor($totalwidth / (count($modules_s)) * 10) / 10) . "%";
        $specialwidth = $width;
    }

    if (count($modules_s) > 1) {
      $modules[$modules_s[0]]['class'] = "-left";
      $modules[$modules_s[0]]['width'] = ($special == 'left' || $special == 'first') ? $specialwidth : $width;
      $modules[$modules_s[count($modules_s) - 1]]['class'] = "-right";
      $modules[$modules_s[count($modules_s) - 1]]['width'] = ($special != 'left' && $special != 'first') ? $specialwidth : $width;
      for ($i = 1; $i < count($modules_s) - 1; $i++) {
          $modules[$modules_s[$i]]['class'] = "-center";
          $modules[$modules_s[$i]]['width'] = $width;
      }
    }

    return $modules;
  }

  /**
   * Checking is there any module in positions
   *
   * @param string $positions     The condition to use
   * @param string $hidewhenedit  Hide when editing
   *
   * @return bool  TRUE if modules exists, otherwise FALSE
   */
  function countModules($positions, $hidewhenedit = false)
  {
    if ($this->isContentEdit() && $hidewhenedit) return false;
    if (!$positions) return false;
    $positions = preg_split('/,/', $positions);
    $_tpl = $this->_tpl;
    foreach ($positions as $position) {
        if (method_exists($_tpl, 'countModules') && $_tpl->countModules($position)) return true;
    }
    return false;
  }

  /**
   * Customwidth
   *
   * @param string $name   Name
   * @param int    $width  Width
   *
   * @return void
   * @deprecated
   */
  function customwidth($name, $width)
  {
    if (!isset($this->_customwidth)) $this->_customwidth = array();
    $this->_customwidth[$name] = $width;
  }

  /**
   * Get column based width
   *
   * @param string $name  Block name
   *
   * @return int  Width of column
   */
  function getColumnBasedWidth($name)
  {
    if ($this->isContentEdit()) return 0;

    $block = $this->getBlockXML($name);
    if ($block && T3Common::node_attributes($block, 'width')) return T3Common::node_attributes($block, 'width');
    //return default colwidth
    $blocks = $this->getBlocksXML('middle');
    if (!$blocks) return 0;
    if (T3Common::node_attributes($blocks, 'colwidth')) return T3Common::node_attributes($blocks, 'colwidth');
    return 20;
  }

  /**
   * Get column width
   *
   * @param string $name  Name of element
   *
   * @return int  Width of column
   */
  function getColumnWidth($name)
  {
    if (isset($this->_colwidth[$name])) return $this->_colwidth[$name];
    return null;
  }

  /**
   * Check the current page is front page
   *
   * @return bool  TRUE if the current page is front page
   */
  function isFrontPage()
  {
    return (JRequest::getCmd('option') == 'com_content' && JRequest::getCmd('view') == 'frontpage');
  }

  /**
   * Check the current page is editing page
   *
   * @return bool  TRUE if the current page is editing page
   */
  function isContentEdit()
  {
    return (JRequest::getCmd('option') == 'com_content' && ((JRequest::getCmd('view') == 'article' && (JRequest::getCmd('task') == 'edit' || JRequest::getCmd('layout') == 'form')) || (JRequest::getCmd('view') == 'form' && JRequest::getCmd('layout') == 'edit')));
  }

  /**
   * Add CSS
   *
   * @param Mics $node css declaration
 *   if node is a string, add it as linked stylesheet
 *   if node type is file or url, Adds a linked stylesheet to the page
 *   if node type is content, Adds a stylesheet declaration to the page
   * @param string $media  Media type
   *
   * @return void
   */
  function addCSS($node, $media = 'all')
  {
    $url = $content = '';
    //detect url or content
    if (is_string ($node)) {
      $url = $node;
    } else if (is_array($node)) {
      if ($node['name'] == 'file' || $node['name'] == 'url') {
        $url = T3Common::node_data($node);
      }
      if ($node['name'] == 'content') {
        $content = T3Common::node_data($node);
      }
    }
    //it's a url, detect if it's full url (maybe outside), add the url, else add the relative url in template.
    if ($url) {
            //if (is_array($node)) {
            //    $url = T3Common::node_data($node);;
            //}
            if (!preg_match ('#^https?:\/\/#i', $url)) {
                $url = 'templates/' . $this->template . '/' . $url;
            }
      $this->addStylesheet ($url, 'text/css', $media);
    }
    //it's a content, just add to head
    if ($content) {
      $this->addStyleDeclaration ($content);
    }
  }

  /**
   * Add JS
   *
   * @param Mics $node js declaration 
 *   if node is a string, add it as linked script
 *   if node type is file or url, Adds a linked script to the page
 *   if node type is content, Adds a script to the page
   *
   * @return void
   */
  function addJS($node)
  {
    $url = $content = '';
    //detect url or content
    if (is_string ($node)) {
      $url = $node;
    } else if (is_array($node)) {
      if ($node['name'] == 'file' || $node['name'] == 'url') {
        $url = T3Common::node_data($node);
      }
      if ($node['name'] == 'content') {
        $content = T3Common::node_data($node);
      }
    }
    //it's a url, detect if it's full url (maybe outside), add the url, else add the relative url in template.
    if ($url) {
            //if (is_array($node)) {
            //    $url = T3Common::node_data($node);
            //}
      if (!preg_match ('#^https?:\/\/#i', $url)) {
        $url = 'templates/' . $this->template . '/' . $url;
      }
      $this->addScript($url);
    }
    //it's a content, just add to head
    if ($content) {
      //$content = T3Common::node_data($node);
      $this->addScriptDeclaration ($content);
    }
  }

  /**
   * Generate heading
   *
   * @return void
   */
  function parsehead()
  {
      //get theme css
      $css = array();
      $stylesheets = T3Common::node_children($this->_theme_info, 'stylesheets', 0);
      //isset($this->_theme_info->stylesheets)?$this->_theme_info->stylesheets[0]:null;
      if ($stylesheets) {
          $files = $stylesheets['children'];
          foreach ($files as $file) {
              if ($file['name'] != 'file') continue;
              $this->addCSS($file, T3Common::node_attributes($file, 'media'));
          }
      }
      //get layout extra css
      $layout = $this->getLayoutXML();
      $stylesheets = T3Common::node_children($layout, 'stylesheets', 0);
      if ($stylesheets) {
          $files = $stylesheets['children'];
          foreach ($files as $file) {
              if ($file['name'] != 'file') continue;
              $this->addCSS($file, T3Common::node_attributes($file, 'media'));
          }
      }

      //Special css
      if (JRequest::getCmd('tmpl') == 'component') {
          $this->addCSS('css/component.css');
      }
      if (JRequest::getCmd('print')) {
          $this->addCSS('css/print.css');
      }
      if (JRequest::getCmd('format') == 'pdf') {
          $this->addCSS('css/pdf.css');
      }

      //get theme js
      $js = array();
      $scripts = T3Common::node_children($this->_theme_info, 'scripts', 0);
      if ($scripts) {
          $files = $scripts['children'];
          foreach ($files as $file) {
              $this->addJS($file);
          }
      }
      //get layout extra js
      $layout = $this->getLayoutXML();
      $scripts = T3Common::node_children($layout, 'scripts', 0);
      if ($scripts) {
          $files = $scripts['children'];
          foreach ($files as $file) {
              $this->addJS($file);
          }
      }
  }

  /**
   * Check RTL
   *
   * @return bool  TRUE if RTL, otherwise FALSE
   */
  function isRTL()
  {
      return ($this->direction == 'rtl' || $this->getParam('direction', 'ltr') == 'rtl');
  }

  /**
   * Check IE6 browser
   *
   * @return bool  TRUE if IE6, otherwise FALSE
   */
  function isIE6()
  {
      $bname = T3Common::getBrowserSortName();
      $bver = T3Common::getBrowserMajorVersion();
      return $bname == 'ie' && $bver == 6;
  }

  /**
   * Check IE browser
   *
   * @return bool  TRUE if IE, otherwise FALSE
   */
  function isIE()
  {
      $bname = T3Common::getBrowserSortName();
      return $bname == 'ie';
  }

  /**
   * Get configured main width
   *
   * @return string  Main width
   */
  function getMainWidth()
  {
      if (T3Common::mobile_device_detect()) return false;
      //get screen size setting
      $screen = $this->getParam('screen', 'reset');
      if ($screen == 'reset') $screen = $this->getParam('setting_screen', 'wide');
      //echo "[$screen]";
      switch ($screen) {
          case 'auto':
              $screen_width = '95%';
              break;
          case 'fixed':
              $screen_width = $this->getParam('screen_fixed_width', '980px');
              if (is_numeric($screen_width)) {
                  if (100 > (int) $screen_width) {
                      $screen_width = $screen_width . '%';
                  } else {
                      $screen_width = $screen_width . 'px';
                  }
              }
              break;
          case 'narrow':
              $screen_width = '770px';
              break;
          case 'wide':
          default:
              $screen_width = '950px';
              break;
      }

      return $screen_width;
  }

  /**
   * Get class of body tag
   *
   * @return string
   */
  function getBodyClass()
  {
      //font class
      $cls = '';
      //body class from layout
      $layout = $this->getLayoutXML();
      if ($bd_cls = T3Common::node_attributes($layout, 'body-class')) $cls .= $bd_cls;

      //get custom class
      $custom_cls = T3Hook::_('custom_body_class');
      if ($custom_cls) $cls .= " " . $custom_cls;
      //make the font class to the last position
      $cls .= " " . 'fs' . $this->getParam(T3_TOOL_FONT, 3);
      //add component name to body class - should be used to override style for some special components
      $option = JRequest::getCmd('option');
      if ($option) $cls .= ' ' . $option;
      //class added from _body_class
      $cls .= ' ' . implode(' ', $this->_body_class);
      //add class body-rtl incase it is rtl
      if ($this->isRTL()) $cls .= ' body-rtl';
      //add page class suffix class if exists
      $menu = &JSite::getMenu();
      $active = $menu->getActive();
      if ($active) {
          $params = new JParameter($active->params);
          if ($params->get('pageclass_sfx')) {
              $cls .= ' body' . $params->get('pageclass_sfx');
          }
      }

      return trim($cls);
  }

  /**
   * Add class to body tag
   *
   * @param string $class  Class string
   *
   * @return void
   */
  function addBodyClass($class)
  {
      $this->_body_class[] = $class;
  }

  /**
   * Process replace URL
   *
   * @param array $matches  Matches
   *
   * @return string  Replaced URL
   */
  function processReplateURL($matches)
  {
      $buffer = JResponse::getBody();
      if (!preg_match('#<head>.*' . str_replace('#', '\\#', preg_quote($matches[0])) . '.*<\/head>#smU', $buffer)) { //by pass if this url in head
          $url = T3Path::getURL($matches[4]);
          if ($url) {
              return "{$matches[1]}={$matches[2]}$url{$matches[2]}";
          }
      }
      return $matches[0];
  }

  /**
   * Get rendering buffer extension
   *
   * @param string $type     Type of extension
   * @param string $name     Name of extension
   * @param array  $attribs  Attributed element
   *
   * @return string  Rendered buffer
   */
  function getBuffer($type, $name = '', $attribs = array())
  {
    $_tpl = $this->_tpl;
    switch ($type) {
        case 'hook':
            return T3Hook::_($name);
            break;
        default:
            $buff = $_tpl->getBuffer($type, $name, $attribs);
            // # Fix bug when render custom module
            if ($type == 'module') {
                $_tpl->setBuffer(null, array('type' => $type, 'name' => $name));
            }
            return $buff;
            break;
    }
  }
}
