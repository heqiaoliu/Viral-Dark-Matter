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
<table width="100%" class="ja-layout-settings">
	
	<tr  class="level2">
		<td>
			<h4 id="ja-head-theme-core-settings" class="block-head block-head-logosetting open" rel="2">
				<span class="block-setting"><?php echo JText::_('Core Themes')?></span> 
				<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Core Themes desc')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
				<a onclick="showHideRegion('ja-head-theme-core-settings', 'level2'); return false;" title="<?php echo JText::_('Click here to expand or collapse')?>" class="toggle-btn">open</a>
			 </h4>
		</td>
	</tr>
	<tr  class="level3">
		<td>
			<?php if(isset($themes['core']) && $themes['core']){?>
				<table class="ja-core-themes admintable">
					<?php $i = 0;?>
					
					<?php $path = JPATH_SITE.DS.'templates'.DS.$template.DS.'core'.DS.'themes'.DS.'default'.DS.'info.xml';?>
					<?php if(file_exists($path)){?> 
						<?php $data = $obj->getThemeinfo($path);?>
						<tr class="row<?php echo $i?>">
							<td width="15">
								1
							</td>
							<td width="35%">
								default
							</td>
							<td width="15">
								<?php echo @$data['version']?>&nbsp;
							</td>
							<td width="15%">
								<?php echo @$data['creationdate']?>&nbsp;
							</td>
							<td width="15%">
								<?php echo @$data['author']?>&nbsp;
							</td>		
							<td width="15">&nbsp;
								
							</td>
						</tr>
						<?php $i = 1 - $i;?>
					<?php }?>
					<?php $number = 2;?>
					<?php foreach ($themes['core'] as $k=>$theme){?>
						<?php $path = JPATH_SITE.DS.'templates'.DS.$template.DS.'core'.DS.'themes'.DS.$theme.DS.'info.xml';?>
						<?php if(!file_exists($path) || $theme=='default'){ 
							unset($themes['core'][$k]);
							continue;
						}?>
						<?php $data = $obj->getThemeinfo($path);?>
						<tr class="row<?php echo $i?>">
							<td width="15">
								<?php echo $number?>
							</td>
							<td width="35%">
								<?php echo $theme?>
							</td>
							<td width="15">
								<?php echo @$data['version']?>&nbsp;
							</td>
							<td width="15%">
								<?php echo @$data['creationdate']?>&nbsp;
							</td>
							<td width="15%">
								<?php echo @$data['author']?>&nbsp;
							</td>		
							<td width="15">&nbsp;
								
							</td>
						</tr>
						<?php $i = 1 - $i;?>
						<?php $number++;?>
					<?php }?>
				</table>					
			<?php }?>
		</td>
	</tr>
	
	<tr  class="level2">
		<td>
			<h4 id="ja-head-theme-local-settings" class="block-head block-head-logosetting open" rel="2">
				<span class="block-setting"><?php echo JText::_('Local Themes')?></span> 
				<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Local Themes desc')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
				<a onclick="showHideRegion('ja-head-theme-local-settings', 'level2'); return false;" title="<?php echo JText::_('Click here to expand or collapse')?>" class="toggle-btn">open</a>
			 </h4>
		</td>
	</tr>
	<tr  class="level3">
		<td>
		
			<table class="ja-user-themes admintable" id="ja-user-themes">
			<tbody>
			<?php if(isset($themes['local']) && $themes['local']){?>
					<?php $i = 0;?>
					<?php foreach ($themes['local'] as $k=>$theme){?>
						<?php $path = JPATH_SITE.DS.'templates'.DS.$template.DS.'local'.DS.'themes'.DS.$theme.DS.'info.xml';?>
						<?php if(!file_exists($path)){ 
							unset($themes['local'][$k]);
							continue;
						}?>
						<?php $data = $obj->getThemeinfo($path);?>
						<tr class="row<?php echo $i?>">
							<td width="15">
								<?php echo $k+1?>
							</td>
							<td width="35%">
								<?php echo $theme?>
							</td>
							<td width="15%">
								<?php echo @$data['version']?>&nbsp;
							</td>
							<td width="15%">
								<?php echo @$data['creationdate']?>&nbsp;
							</td>
							<td width="15%">
								<?php echo @$data['author']?>&nbsp;
							</td>		
							<td width="15">
								<span class="ja_close" onclick="jat3admin.removeTheme(this, '<?php echo $theme?>', '<?php echo $template?>')">
									<img border="0" alt="<?php echo JText::_('Remove')?>" src="images/publish_x.png" title="<?php echo JText::_('Click here to delete this theme')?>"/>
								</span>
							</td>
						</tr>
						<?php $i = 1 - $i;?>
					<?php }?>
			
			<?php }?>
			</tbody>
			</table>	
		</td>
	</tr>
	
	
	<tr  class="level2">
		<td>
			<h4 id="ja-head-package-settings" class="block-head block-head-logosetting open" rel="2">
				<span class="block-setting"><?php echo JText::_('Upload Package File')?></span> 
				<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Upload Package File desc')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
				<a onclick="showHideRegion('ja-head-package-settings', 'level2'); return false;" title="<?php echo JText::_('Click here to expand or collapse')?>" class="toggle-btn">open</a>
			 </h4>
		</td>
	</tr>
	<tr  class="level3">
		<td>

			<table class="adminform">
				<tbody>					
					<tr>
						<td width="120" valign="top">
							<label for="install_package"><?php echo JText::_('Package File')?>:</label>
						</td>
						<td>
							<input type="file" name="install_package" id="install_package" class="input_box">
							<input type="button" onclick="startUpload('<?php echo $template?>');" value="<?php echo JText::_('Upload File &amp; Install')?>" class="button">
							<span id="ja_upload_process" class="ja-upload-loading" style="display: none;">
								<img src="<?php echo $uri.'/assets/images/loading-small.gif';?>" alt="<?php echo JText::_("Loading"); ?>" style="float: left"/>
							</span>
							<p class="ja-error" id="err_myfile"></p>
						</td>
					</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>

<script type="text/javascript">
	var total_local_theme = <?php echo isset($themes['local'])?count($themes['local']):0?>
</script>
<iframe id="upload_target" name="upload_target"  src="" style="width:0; height:0; border:0px solid #fff;"></iframe>