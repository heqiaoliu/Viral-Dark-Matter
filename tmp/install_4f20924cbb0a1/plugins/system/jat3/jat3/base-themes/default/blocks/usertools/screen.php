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
$screens = Array ('wide'=>JText::_('WIDE_SCREEN'),'auto'=>JText::_('FULL_SCREEN'),'narrow'=>JText::_('NARROW_SCREEN'));
?>

<h3><?php echo JText::_('SCREEN')?></h3>

<div class="ja-box-usertools">
  <ul class="ja-usertools-screen clearfix">
  <?php foreach ($screens as $screen=>$title) : ?>
  
  	<li class="screen-<?php echo $screen.($this->getParam('screen')==$screen?'-active':'') ?>">
  	<input type="radio" id="user_screen_<?php echo $screen ?>" name="user_screen" value="<?php echo $screen ?>" <?php echo $this->getParam('screen')==$screen?'checked="checked"':'' ?> />
  	<label for="user_screen_<?php echo $screen ?>" title="<?php echo $title ?>"><span><?php echo $title ?></span>
  	</label></li>
  <?php endforeach; ?>
  </ul>
</div>
