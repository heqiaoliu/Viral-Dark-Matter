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
<ul class="ja-profile-titles">
	<?php if($profiles){?>
		<li class="ja-profile default active"><span class="ja-profile-title">Default</span><span class="ja-profile-action">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></li>
		<?php foreach ($profiles  as $profilename=>$profile){?>
			<?php if($profilename!='default'){?>
			<li class="ja-profile"><span class="ja-profile-title"><?php echo $profilename?></span><span class="ja-profile-action">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></li>
			<?php }?>
		<?php }?>
	<?php }?>
	<li class="ja-icon-help" onclick="jat3admin.showHelp($('ja-profile-help'))"><span><?php echo JText::_('Help')?></span></li>
	<li class="ja-profile-new" onclick="jat3admin.newProfile(this)" title="<?php echo JText::_('Click here to add new profile')?>"><span><?php echo JText::_('New')?></span></li>
	
</ul>

<!-- BEGIN: Help -->
<div id="ja-profile-help">
	<a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
	<?php echo JText::_('JAT3 PROFILE HELP')?>																			
</div>
<!-- END: Help -->

<table class="admintable" id="jat3-profile-params">
	<tbody>
	<tr>
		<td>
			<?php echo $paramsForm->render('params')?>
		</td>
	</tr>
	</tbody>
</table>

<div id="ja-profile-action">
	<ul>
		<li class="saveas"><?php echo JText::_('Clone')?></li>
		<li class="rename"><?php echo JText::_('Rename')?></li>
		<li class="reset"><?php echo JText::_('Reset to default')?></li>
		<li class="delete"><?php echo JText::_('Delete')?></li>
	</ul>
</div>

<script type="text/javascript">
window.addEvent('load', function (){
	$('ja-profile-action').remove().inject ($(document.body));
});

$$('.ja-profile-action').addEvent ('click', function (event) {	

	var event = new Event(event);
	$('ja-profile-action').setStyles ({
		'top': event.page.y,
		'left': event.page.x,
		'display': 'block'
	});
	event.stop();
	
	jat3admin.showProfileAction(this);
	
});

</script>