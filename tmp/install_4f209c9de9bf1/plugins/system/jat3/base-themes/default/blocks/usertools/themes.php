<?php
/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');

?>
<?php
$themes = T3Common::get_themes ();
$currthemes = preg_split('/,/', $this->getParam('themes'));
?>

<h3><?php echo JText::_('Change Themes')?></h3>

<div class="ja-box-usertools">
  <ul class="ja-usertools-theme clearfix">
  <?php foreach ($themes as $theme=>$themeinfo) : ?>
  	<li class="theme theme-<?php echo str_replace('.','-',$theme).(in_array($theme, $currthemes)?'-active':'') ?>">
  	<input type="checkbox" id="user_themes_<?php echo $theme ?>" name="user_themes" value="<?php echo $theme ?>" <?php echo in_array($theme, $currthemes)?'checked="checked"':'' ?> />
  	<label for="user_themes_<?php echo $theme ?>" title="<?php echo $this->getInfo ($themeinfo, 'description')?$this->getInfo ($themeinfo, 'description'):$theme ?>"><span><?php echo $this->getInfo ($themeinfo, 'name')?$this->getInfo ($themeinfo, 'name'):$theme ?></span>
  	</label></li>
  <?php endforeach; ?>
  </ul>
</div>