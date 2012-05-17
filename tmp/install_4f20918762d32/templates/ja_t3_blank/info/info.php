/*
 * ------------------------------------------------------------------------
 * JA T3 Blank template for joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
*/
<table id="ja-info" cellpadding="0" cellspacing="0"  width="100%">	
	<tr class="level1">
		<td class="ja-block-head">
			<h4  id="ja-head-additionalinformation" class="block-head block-head-additionalinformation open" rel="1" >
				<span class="block-setting" ><?php echo JText::_('Additional Information')?></span> 
				<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Additional Information')?>::<?php echo sprintf(JText::_('Additional Information desc'), strtoupper($template))?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
				<a class="toggle-btn open" title="<?php echo JText::_('Expand all')?>" onclick="showRegion('ja-head-additionalinformation', 'level1'); return false;"><?php echo JText::_('Expand all')?></a>
				<a class="toggle-btn close" title="<?php echo JText::_('Collapse all')?>" onclick="hideRegion('ja-head-additionalinformation', 'level1'); return false;"><?php echo JText::_('Collapse all')?></a>
			</h4>
			
			<div style="text-align: right; padding-right: 4px;">
				<a href="javascript:void(0);" onclick="updateAdditionalInfo()"  id="link-update"><?php echo JText::_('Show Additional Information')?></a>
				<span id="link-update-loading" style="display: none"><img src="../plugins/system/jat3/jat3/core/admin/assets/images/loading-small.gif" alt="<?php echo JText::_('Loading')?>"/></span>
			</div>
		</td>
    </tr>
</table>
<div id="ja-info-more">
	
</div>	


<script type="text/javascript">
	function updateAdditionalInfo(){
		$('link-update').setStyle('display', 'none');
		$('link-update-loading').setStyle('display', 'block');
		new Ajax('?jat3type=plugin&jat3action=updateAdditionalInfo&template=<?php echo $template?>', {method: 'post', onComplete: inserAdditionalInfo}).request();		
	}	

	function inserAdditionalInfo(text){
		$('link-update').setStyle('display', 'block');
		$('link-update-loading').setStyle('display', 'none');
		$('ja-info-more').innerHTML = text;
	}
</script>

