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
$screens = Array ('wide'=>JText::_('Wide Screen'),'auto'=>JText::_('Full Screen'),'narrow'=>JText::_('Narrow Screen'));
?>

<h3><?php echo JText::_('Screen')?></h3>

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