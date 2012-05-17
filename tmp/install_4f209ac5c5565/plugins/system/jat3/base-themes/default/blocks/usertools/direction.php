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
$directions = Array ('ltr'=>JText::_('LTR'),'rtl'=>JText::_('RTL'));
?>

<h3><?php echo JText::_('Direction')?></h3>

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