<?php
$imgext = 'png';
?>
<ul class="ja-usertools-screen">
	<li><img style="cursor: pointer;" src="<?php echo $this->templateurl(); ?>/images/auto<?php echo ($this->getParam(JA_TOOL_SCREEN)=='auto') ? "-hilite.$imgext" : ".$imgext" ;?>" title="Full Screen" alt="Full Screen" id="ja-tool-auto" onclick="switchTool('<?php echo $this->template."_".JA_TOOL_SCREEN;?>','auto');return false;" /></li>

	<li><img style="cursor: pointer;" src="<?php echo $this->templateurl(); ?>/images/wide<?php echo ($this->getParam(JA_TOOL_SCREEN)=='980') ? "-hilite.$imgext" : ".$imgext" ;?>" title="Wide Screen" alt="Wide Screen" id="ja-tool-wide" onclick="switchTool('<?php echo $this->template."_".JA_TOOL_SCREEN;?>','980');return false;" /></li>

	<li><img style="cursor: pointer;" src="<?php echo $this->templateurl(); ?>/images/narrow<?php echo ($this->getParam(JA_TOOL_SCREEN)=='770') ? "-hilite.$imgext" : ".$imgext" ;?>" title="Narrow Screen" alt="Narrow Screen" id="ja-tool-narrow" onclick="switchTool('<?php echo $this->template."_".JA_TOOL_SCREEN;?>','770');return false;" /></li>
</ul>
