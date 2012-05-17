<?php
if (!($mobile = $this->mobile_device_detect())) return; 
$handheld_view = $this->getParam('ui');
$switch_to = $handheld_view=='desktop'?'default':'desktop';
$text = $handheld_view=='desktop'?'Mobile Version':'Desktop Version';
?>

<a class="ja-tool-switchlayout" href="<?php echo JURI::base()?>?ui=<?php echo $switch_to?>" title="<?php echo JText::_($text)?>"><span><?php echo JText::_($text)?></span></a>