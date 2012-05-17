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
$fonts = Array ('inc'=>JText::_('INCREASE_FONT_SIZE'),'dec'=>JText::_('DECREASE_FONT_SIZE'),'reset'=>JText::_('DEFAULT_FONT_SIZE'));
?>

<h3><?php echo JText::_('FONT_SIZE')?></h3>

<div class="ja-box-usertools">
  <ul class="ja-usertools-font clearfix">
  <?php foreach ($fonts as $font=>$title) : ?>
  	<li class="font-<?php echo $font ?>"><a title="<?php echo $title ?>" onclick="switchFontSize('<?php echo $this->template."_font";?>', '<?php echo $font ?>');return false;"><span><?php echo $title ?></span></a></li>
  <?php endforeach; ?>
  </ul>
</div>
<script type="text/javascript">
	var DefaultFontSize=parseInt('<?php echo $this->getParam('setting_font',3);?>');
	var CurrentFontSize=parseInt('<?php echo $this->getParam('font',3);?>');
</script>