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
<script type="text/javascript">
	var jaclass_<?php echo $name?> = new JAT3_PAGEIDSETTINGS({param_name: '<?php echo $name?>'});
	
	window.addEvent('load', function (){	
		$(document.body).addEvent( 'click', function() {
			jaclass_<?php echo $name?>.clearData();
		});		
		
		$('<?php echo $name?>-selections').addEvent ('dblclick', function (){
														jaclass_<?php echo $name?>.select_multi_pageids()}
													);
		
		$('<?php echo $name?>-ja-popup-pageids').addEvent ('click', function (e) {
			new Event (e).stop();
		});
		
		<?php if(!$arr_values){?>			
			$E('.pageid_text', $('<?php echo $name?>-row-0')).setText('<?php echo JText::_('All Page')?>');
		<?php }?>		
	});
</script>


<table width="100%" class="ja-list-pageids" id="<?php echo $name?>-ja-list-pageids">
	<tr>
		<th width="47%">
			<?php echo JText::_('Pages')?>
		</th>
		<th width="47%">
			<?php echo JText::_('Profiles')?>
		</th>
		<th width="6%">
			
		</th>		
	</tr>
	<?php 
	if($arr_values){
		foreach ($arr_values as $k=>$row){?>
		
		<tr id="<?php echo $name?>-row-<?php echo $k?>" class="ja-item">
			<td>
				<span class="pageid_text" <?php if($k>0){?>onclick="jaclass_<?php echo $name?>.choosePageids(this, <?php echo $k?>)"<?php }?>>
					<?php if($k==0){?>
						All Page
					<?php }else{?>
						<?php echo @$row[0]?>
					<?php }?>
					
				</span>
			</td>
			<td width="47%">
				<span class="profile_text" onclick="jaclass_<?php echo $name?>.chooseProfile(this, <?php echo $k?>)">
					<?php echo @$row[1]?>
				</span>
			</td>
			<td width="6%">
				<?php if($k>0){?>
				<span class="ja_close" onclick="jaclass_<?php echo $name?>.removerow(this);"> 
					<img border="0" alt="<?php echo JText::_('Remove')?>" src="images/publish_x.png" title="<?php echo JText::_('Click here to remove this row')?>"/>
				</span>
				<?php }else {?>
					&nbsp;
				<?php }?>
			</td>		
		</tr>
		<?php }
	}else{?>
		<tr id="<?php echo $name?>-row-0" class="ja-item">
			<td>
				<span class="pageid_text">
					
				</span>
			</td>
			<td width="47%">
				<span class="profile_text" onclick="jaclass_<?php echo $name?>.chooseProfile(this, 0)">
					default
				</span>
			</td>
			<td width="6%">
				&nbsp;
			</td>		
		</tr>
	<?php }?>
	<tr class="ja-item newpagesetting">
		<td onclick="jaclass_<?php echo $name?>.addrow(this)" width="47%">
			<span class="pageid_text more">
				<?php echo JText::_('Click to add') ?>
			</span>
		</td>
		<td width="47%">
			<span class="profile_text more">
				&nbsp;
			</span>
		</td>
		<td width="6%">
			<span class="ja_close"> 
				<img border="0" alt="<?php echo JText::_('Remove')?>" title="<?php echo JText::_('Remove')?>" src="images/publish_x.png"/>
			</span>
		</td>		
	</tr>
	
</table>
<input name='general[<?php echo $name?>]' id="<?php echo $name?>-profile" value="<?php echo $value?>" type="hidden"/>