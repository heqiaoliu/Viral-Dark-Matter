<?php
$imgext = 'gif';
?>
<ul class="ja-usertools-color">
<?php
foreach ($this->_ja_color_themes as $ja_color_theme) {
	echo "
	<li><img style=\"cursor: pointer;\" src=\"".$this->templateurl()."/images/".strtolower($ja_color_theme).( ($this->getParam(JA_TOOL_COLOR)==$ja_color_theme) ? "-hilite" : "" ).".".$imgext."\" title=\"".$ja_color_theme." color\" alt=\"".$ja_color_theme." color\" id=\"ja-tool-".$ja_color_theme."color\" onclick=\"switchTool('".$this->template."_".JA_TOOL_COLOR."','$ja_color_theme');return false;\" /></li>
	";
} ?>
</ul>