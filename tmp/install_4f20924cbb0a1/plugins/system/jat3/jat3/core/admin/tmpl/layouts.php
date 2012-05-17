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
<table class="ja-layout-titles admintable">
	<tr>
		<th width="15" style="border-left: none !important">
			<?php echo JText::_('#')?>
		</th>
		<th>
			<?php echo JText::_('LAYOUT_NAME')?>
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
				<span class="edit" onclick="jat3admin.editLayout('default')" title="<?php echo JText::_('CLICK_HERE_TO_EDIT_THIS_LAYOUT')?>"><?php echo JText::_('Edit')?></span>				
				<span class="clone" onclick="jat3admin.saveasLayout(this, 'default')" title="<?php echo JText::_('CLICK_HERE_TO_CLONE_THIS_LAYOUT')?>"><?php echo JText::_('Clone')?></span>
				<?php if($layouts['default']->core && $layouts['default']->local){?>					
					<span class="reset" onclick="jat3admin.resetLayout(this, 'default')" title="<?php echo JText::_('CLICK_HERE_TO_RESET_TO_DEFAULT_THIS_LAYOUT')?>"><?php echo JText::_('RESET_TO_DEFAULT')?></span>
					
				<?php }else if($layouts['default']->local){?>
					<span class="rename" onclick="jat3admin.renameLayout(this, 'default')" title="<?php echo JText::_('CLICK_HERE_TO_RENAME_THIS_LAYOUT')?>"><?php echo JText::_('Rename')?></span>
					<span class="delete" onclick="jat3admin.deleteLayout(this, 'default')" title="<?php echo JText::_('CLICK_HERE_TO_DELETE_THIS_LAYOUT')?>"><?php echo JText::_('Delete')?></span>
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
					<span class="edit" onclick="jat3admin.editLayout('<?php echo $layoutname?>')" title="<?php echo JText::_('CLICK_HERE_TO_EDIT_THIS_LAYOUT')?>"><?php echo JText::_('Edit')?></span>
					<span class="clone" onclick="jat3admin.saveasLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('CLICK_HERE_TO_CLONE_THIS_LAYOUT')?>"><?php echo JText::_('Clone')?></span>
					<?php if($layout->core && $layout->local){?>					
						<span class="reset" onclick="jat3admin.resetLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('CLICK_HERE_TO_RESET_TO_DEFAULT_THIS_LAYOUT')?>"><?php echo JText::_('Reset to default')?></span>
						
					<?php }else if($layout->local){?>
						<span class="rename" onclick="jat3admin.renameLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('CLICK_HERE_TO_RENAME_THIS_LAYOUT')?>"><?php echo JText::_('Rename')?></span>
						<span class="delete" onclick="jat3admin.deleteLayout(this, '<?php echo $layoutname?>')" title="<?php echo JText::_('CLICK_HERE_TO_DELETE_THIS_LAYOUT')?>"><?php echo JText::_('Delete')?></span>
					<?php }?>
					
				</td>
			</tr>
			<?php $k++?>
			<?php $i = 1 - $i?>
			<?php }?>
		<?php }?>
					
	<?php }?>
</table>
<div class="ja-layout-new" onclick="jat3admin.newLayout(this)"  title="<?php echo JText::_('CLICK_HERE_TO_ADD_NEW_LAYOUT')?>" ><span><?php echo JText::_('New')?></span></div>
