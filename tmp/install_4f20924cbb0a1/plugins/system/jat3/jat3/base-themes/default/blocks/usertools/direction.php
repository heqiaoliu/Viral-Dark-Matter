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
$directions = Array ('ltr'=>JText::_('LTR'),'rtl'=>JText::_('RTL'));
?>

<h3><?php echo JText::_('DIRECTION')?></h3>

<div class="ja-box-usertools">
  <ul class="ja-usertools-direction clearfix">
  <?php foreach ($directions as $direction=>$title) : ?>
  
  	<li class="direction-<?php echo $direction.($this->getParam('direction')==$direction?'-active':'') ?>">
  	<input type="radio" id="user_direction_<?php echo $direction ?>" name="user_direction" value="<?php echo $direction ?>" <?php echo $this->getParam('direction')==$direction?'checked="checked"':'' ?> />
  	<label for="user_direction_<?php echo $direction ?>" title="<?php echo $title ?>"><span><?php echo $title ?></span>
  	</label></li>
  <?php endforeach; ?>
  </ul>
</div>
