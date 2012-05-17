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
$fonts = Array ('inc'=>JText::_('Increase font size'),'dec'=>JText::_('Decrease font size'),'reset'=>JText::_('Default font size'));
?>

<h3><?php echo JText::_('Font Size')?></h3>

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