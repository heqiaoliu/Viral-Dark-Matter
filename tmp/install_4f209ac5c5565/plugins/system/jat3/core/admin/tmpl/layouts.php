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
<table class="ja-layout-titles admintable">
	<tr>
		<th width="15" style="border-left: none !important">
			<?php echo JText::_('#')?>
		</th>
		<th>
			<?php echo JText::_('Layout name')?>
		</th>
		<th>
			<?php echo JText::_('Action')?>
		</th>		
	</tr>
	<?php $i=0?>
	<?php if($layouts){?>
		<?php if(isset($layouts['default'])){?>
		<tr id="layout_default" class="row<?php echo $i?>">
			<td width="15" style="border-left: none !important">
				<?php echo 1?>
			</td>
			<td>
				Default
			</td>
			<td>
				<span class="edit" onclick="jat3admin.editLayout('default')" title="<?php echo JText::_('Click here to edit this layout')?>"><?php echo JText::_('Edit')?></span>				
				<span class="clone" onclick="jat3admin.saveasLayout(this, 'default')" title="<?php echo JText::_('Click here to rename this layout')?>"><?php echo JText::_('Clone')?></span>
				<?php if($layouts['default']->core && $layouts['default']->local){?>					
					<span class="reset" onclick="jat3admin.resetLayout(this, 'default')" title="<?php echo JText::_('Click here to reset to default this layout')?>"><?php echo JText::_('Reset to default')?></span>
					
				<?php }else if($layouts['default']->local){?>
					<span class="rename" onclick="jat3admin.renameLayout(this, 'default')" title="<?php echo JText::_('Click here to rename this layout')?>"><?php echo JText::_('Rename')?></span>
					<span class="delete" onclick="jat3admin.deleteLayout(this, 'default')" title="<?php echo JText::_('Click here to delete this layout')?>"><?php echo JText::_('Delete')?></span>
				<?php }?>
			</td>
		</tr>
		<?php $i = 1 - $i?>
		<?php }?>
		
		<?php $k=1?>
		
		<?php foreach ($layouts  as $layoutname=>$layout){?>
			<?php if($layoutname!='default'){?>
			<tr id="layout_<?php echo $layoutname?>" class="row<?php echo $i?>">
				<td width="15">
					<?php echo $k+1?>
				</td>
				<td>
					<?php echo $layoutname?>
				</td>
				<td>
					<span class="edit" onclick="jat3admin.editLayout('<?php echo $layoutname?>')" title="<?php echo JText::_('Click here to edit this layout')?>"><?php echo JText::_('Edit')?></span>
					<span class="clone" onclick="jat3admin.saveasLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('Click here to clone this layout')?>"><?php echo JText::_('Clone')?></span>
					<?php if($layout->core && $layout->local){?>					
						<span class="reset" onclick="jat3admin.resetLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('Click here to reset to default this layout')?>"><?php echo JText::_('Reset to default')?></span>
						
					<?php }else if($layout->local){?>
						<span class="rename" onclick="jat3admin.renameLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('Click here to rename this layout')?>"><?php echo JText::_('Rename')?></span>
						<span class="delete" onclick="jat3admin.deleteLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('Click here to delete this layout')?>"><?php echo JText::_('Delete')?></span>
					<?php }?>
					
				</td>
			</tr>
			<?php $k++?>
			<?php $i = 1 - $i?>
			<?php }?>
		<?php }?>
					
	<?php }?>
</table>
<div class="ja-layout-new" onclick="jat3admin.newLayout(this)"  title="<?php echo JText::_('Click here to add new layout')?>" ><span><?php echo JText::_('New')?></span></div>