<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */
?>
<?php
$themes = T3Common::get_themes ();
$currthemes = preg_split('/,/', $this->getParam('themes'));
?>

<h3><?php echo JText::_('CHANGE_THEMES')?></h3>

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
