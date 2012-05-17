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
?>
<?php
$imgext = 'gif';
?>

<h3><?php echo JText::_('CHANGE_COLORS')?></h3>

<div class="ja-box-usertools">
  <ul class="ja-usertools-color clearfix">
  <?php
  foreach ($this->_ja_color_themes as $ja_color_theme) {
    echo "
    <li><img style=\"cursor: pointer;\" src=\"".$this->templateurl()."/images/".strtolower($ja_color_theme).( ($this->getParam(T3_TOOL_COLOR)==$ja_color_theme) ? "-hilite" : "" ).".".$imgext."\" title=\"".$ja_color_theme." color\" alt=\"".$ja_color_theme." color\" id=\"ja-tool-".$ja_color_theme."color\" onclick=\"switchTool('".$this->template."_".T3_TOOL_COLOR."','$ja_color_theme');return false;\" /></li>
    ";
  } ?>
  </ul>
</div>