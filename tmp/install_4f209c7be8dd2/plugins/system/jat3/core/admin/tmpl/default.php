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

$db = JFactory::getDBO();
$helpurl = 'http://www.joomlart.com/?ajax=module&name=youtubeplaylist';
JHTML::_('behavior.modal', 'a.modal');
?>
<script type="text/javascript">
	var imgloading = '<?php echo $uri.'/assets/images/loading-small.gif';?>';
	var imgdelete = 'images/publish_x.png';
	var profiles = <?php echo json_encode($jsonData)?>;
	var jatabs = null;	
	var template = '<?php echo $template?>';
	var layouts =  <?php echo json_encode($layouts)?>;
	var jat3admin = null;
	var numberTab = '<?php echo $numbertab?>';
	var requesting = false;
	window.addEvent('load', function (e){
		var colsbox = $(document.adminForm).getElements('div.col');
		jatabs = new JATabs("ja-tabswrap", {numbtab:numberTab, animType:'animNone',style:'default',position:'top',width:'100%',height:'auto',mouseType:'click',duration:1000,colors:10,useAjax:false,skipAnim:true});
		
		var table_params = colsbox[1].getElement('table.admintable');
		table_params.set({'id':'jat3-profile-params'});
		var params_extra = table_params.getElement('table.paramlist').rows;
		
		/*var tabs = $('ja-tabswrapmain');
		if($type(table_params)){
			tabs.remove().injectBefore(table_params);
		}*/				
		table_params.remove();

		var params_main = $('jat3-profile-params').getElement('table.paramlist').getElement('tbody');		
		var length = params_extra.length;
		for(var j=0; j<length; j++){
			$(params_extra[0]).injectInside(params_main);
		}
		
		var tabswrapmain = $('ja-tabswrapmain').remove();
		colsbox[1].setText('');
		tabswrapmain.injectInside(colsbox[1]);

		document.adminForm.show();
		$('ja-tabswrapmain').show();

		/* Add More info box */
		if($('additional_information')!=null){
			$('additional_information').injectInside(colsbox[0]);
			$('additional_information').show();
		}
		$('ja-info').setStyle('display', 'none');

		colsbox[1].show();
		colsbox[0].show();
		
		var els = $$('a.ja-help-close');
		els.each(function(el){
			if(!Cookie.get(el.getParent().id)){
				el.getParent().setStyle('display', 'block');
			}
			else{
				el.getParent().setStyle('display', 'none');
			}
		});
		
		jat3admin = new JAT3_ADMIN();				
		jatabs.resize();

		/* Button help */
		$('toolbar-help').getElement('a.toolbar').remove();		
		<?php if($helpurl!=''){?>
		$('ja-introduce').inject($('toolbar-help'));			
		<?php }?>
	});
</script>
<div id="jat3-loading"></div>
<div style="width: 100%;" class="ja-tabswrap default"	id="ja-tabswrapmain">
<div class="container" id="ja-tabswrap">
	<div style="height: 30px;" class="ja-tabs-title-top">
		<ul class="ja-tabs-title">
			<li class="first general">
				<h3><span class="general"><?php echo JText::_('General')?></span></h3>
			</li>								
			<li class="profiles">
				<h3><span class="profiles"><?php echo JText::_('Profiles')?></span></h3>
			</li>
			<li class="layouts">
				<h3><span class="layouts"><?php echo JText::_('Layouts')?></span></h3>
			</li>					
			<li class="themes">
				<h3><span class="themes"><?php echo JText::_('Themes')?></span></h3>
			</li>
			<li class="last help-support">
				<h3><span class="help-support"><?php echo JText::_('Update & Help')?></span></h3>
			</li>
		</ul>
		<a class="ja-icon-video" href="javascript:void(0)" onclick="$('ja-introduce').fireEvent('click', new Event(window.event || event));"><span><?php echo JText::_('Video')?></span></a>	
	</div>
	
	<div class="ja-tab-panels-top" style="height:0;">				
		<!-- Begin: General Content -->
		<div class="ja-tab-content"	style="position: absolute; left: 0px; display: block;">
			<div class="ja-tab-subcontent">
				<ul style="padding: 10px 1px 20px 30px !important">					
					<li class="ja-icon-help" onclick="jat3admin.showHelp($('ja-general-help'))"><span><?php echo JText::_('Help')?></span></li>
				</ul>
				
				<!-- BEGIN: Help -->
				<div id="ja-general-help">
					<a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
					<?php echo JText::_('JAT3 GENERAL HELP')?>
				</div>
				 <!-- END: Help -->
				
				
				<table width="100%" class="ja-general-settings">
					<tr  class="level2">
						<td>
							<h4 id="ja-head-page-settings" class="block-head block-head-logosetting open" rel="2">
								<span class="block-setting"><?php echo JText::_('Page assignments')?></span> 
								<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Page assignments desc')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
								<a onclick="showHideRegion('ja-head-page-settings', 'level2'); return false;" title="<?php echo JText::_('Click here to expand or collapse')?>" class="toggle-btn">open</a>
							 </h4>
						</td>
					</tr>
					<tr  class="level3">
						<td>
							<?php include_once dirname(__FILE__).DS.'pageidsettings.php';?>
						</td>
					</tr>
				</table>
				
				<?php echo $configForm->render('general')?>
								
			</div>
		</div>
		<!-- End: General Content -->

		<!-- Begin: Profiles Content -->
		<div class="ja-tab-content"	style="position: absolute; left: 0px; display: block;">
			<div class="ja-tab-subcontent" id="ja-profiles-content">					
				
				<?php include_once dirname(__FILE__).DS.'profiles.php';?>																				
			</div>
		</div>
		<!-- End: Profiles Content -->
		
		<!-- Begin: Layouts Content -->
		<div class="ja-tab-content"	style="position: absolute; left: 0px; display: block;">
			<div class="ja-tab-subcontent" id="ja-layouts-content">
				<ul style="padding: 10px 1px 20px 30px !important">
					<li class="ja-icon-help" onclick="jat3admin.showHelp($('ja-layout-help'))"><span><?php echo JText::_('Help')?></span></li>
				</ul>
				
				<!-- BEGIN: Help -->
				<div id="ja-layout-help">
					<a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
					<?php echo JText::_('JAT3 LAYOUT HELP')?>							
				</div>
				<!-- END: Help -->
				
				<table width="100%" class="ja-layout-settings">
					<tr  class="level2">
						<td>
							<h4 id="ja-head-layout-settings" class="block-head block-head-logosetting open" rel="2">
								<span class="block-setting"><?php echo JText::_('Layout settings')?></span> 
								<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Layout settings desc')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
								<a onclick="showHideRegion('ja-head-layout-settings', 'level2'); return false;" title="<?php echo JText::_('Click here to expand or collapse')?>"  class="toggle-btn">open</a>
							 </h4>
						</td>
					</tr>
					<tr  class="level3">
						<td>
							<?php include_once dirname(__FILE__).DS.'layouts.php';?>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<!-- End: Layouts Content -->
						
		<!-- Begin: Themes Content -->
		<div class="ja-tab-content"	style="position: absolute; left: 0px; display: block;">
			<div class="ja-tab-subcontent">
				<ul style="padding: 10px 1px 20px 30px !important">
					<li class="ja-icon-help" onclick="jat3admin.showHelp($('ja-theme-help'))"><span><?php echo JText::_('Help')?></span></li>
				</ul>
				
				<!-- BEGIN: Help -->
				<div id="ja-theme-help">
					<a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
					<?php echo JText::_('JAT3 THEME HELP')?>
				</div>
				 <!-- END: Help -->
				<?php include_once dirname(__FILE__).DS.'themes.php';?>
			</div>
		</div>
		<!-- End: Themes Content -->
		
		
		<!-- Begin: Update & Help Content -->
		<div class="ja-tab-content"	style="position: absolute; left: 0px; display: block;">
			<div class="ja-tab-subcontent">
				<ul style="padding: 10px 1px 20px 30px !important">
					<li class="ja-icon-help" onclick="jat3admin.showHelp($('ja-help-support-help'))"><span><?php echo JText::_('Help')?></span></li>
				</ul>
				
				<!-- BEGIN: Help -->
				<div id="ja-help-support-help">
					<a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
					<?php echo JText::_('JAT3 HELP SUPPORT HELP')?>
				</div>
				 <!-- END: Help -->
				
				
				<?php include_once dirname(__FILE__).DS.'help.php';?>			
				
			</div>
		</div>
		<!-- End: Update & Help Content -->
	</div>
</div>
</div>

<div id="<?php echo $name?>-ja-popup-pageids" class="ja-popup-pageids">
	<div style="width: 100%; float: right; text-align: right; padding: 5px;">
		<input type="button" name="<?php echo JText::_('Select'); ?>" value="select" onclick="jaclass_<?php echo $name?>.select_multi_pageids('<?php echo $name?>'); return false;" class="save"/>
		<input type="button" name="<?php echo JText::_('Cancel'); ?>" value="cancel" onclick="jaclass_<?php echo $name?>.close_popup('<?php echo $name?>-ja-popup-pageids')" class="cancel"/>
	</div>
	
	<?php echo $pageids?>
</div>

<div id="<?php echo $name?>-ja-popup-profiles" class="ja-popup-profiles">
	<ul class="ja-popup-profiles">
		<?php if($profiles){?>
       	<?php 	foreach ($profiles as $k=>$profile){ 	?>
			<li>
				<a href="javascript:void(0)" onclick="jaclass_<?php echo $name?>.select_profile(this);">
					<?php echo $k?> 
				</a>
			</li>
		<?php }?>
       	<?php }?>
	</ul>	
</div>
<div id="ja-layout-container" style="display: none; width:450px;height:340px;">
	<ul>		
		<li class="save" onclick="jat3admin.saveLayout(this)"><?php echo JText::_('Save')?></li>
		<li class="cancel" onclick="jat3admin.cancelLayout(this)"><?php echo JText::_('Cancel')?></li>
	</ul>
	
	<div class="layout-name">
		<label for="name_layout"><?php echo JText::_('Layout Name')?>:</label> 
		<input type="text" value="" name="name_layout" id="name_layout" maxlength="20"/>
	</div>
	
	<textarea rows="20" cols="80" id="content_layout" name="content_layout"><?php //echo @$layouts['default']?></textarea>
</div>

<script type="text/javascript">
function submitbutton(pressbutton){
	if (pressbutton == 'apply') {		
		jat3admin.saveData($('toolbar-apply'));
		return false;
	}	
	else{
		submitform( pressbutton );
	}
	return false;
} 
</script>
<script type="text/javascript">
	var lg_profile_name_exist = '<?php echo JText::_('Profile name "%s" already exist. Please choose another.')?>';
	var lg_enter_profile_name = '<?php echo JText::_('Enter profile name:')?>';
	var lg_select_profile = '<?php echo JText::_('Please select profile')?>';
	var lg_please_enter_profile_name = '<?php echo JText::_('Profile name can not be empty')?>';
	var lg_confirm_delete_profile = '<?php echo JText::_('Are you sure to delete this profile?')?>';
	var lg_confirm_reset_profile = '<?php echo JText::_('Are you sure to reset to default this profile?')?>';
	var lg_confirm_rename_profile = '<?php echo JText::_('CONFIRM WHEN RENAME OR DELETE PROFILE')?>';
	
	var lg_layout_name_exist = '<?php echo JText::_('Layout name "%s" already exist. Please choose another.')?>';
	var lg_enter_layout_name = '<?php echo JText::_('Enter layout name:')?>';
	var lg_please_enter_layout_name = '<?php echo JText::_('Layout name can not be empty')?>';
	var lg_select_layout = '<?php echo JText::_('Please select layout')?>';
	var lg_confirm_to_cancel = '<?php echo JText::_('Are you sure to cancel?')?>';
	var lg_confirm_delete_layout = '<?php echo JText::_('Are you sure to delete this layout?')?>';
	var lg_confirm_reset_layout = '<?php echo JText::_('Are you sure to reset to default this layout?')?>';
	var lg_confirm_rename_layout = '<?php echo JText::_('CONFIRM WHEN RENAME OR DELETE LAYOUT')?>';
	var lg_confirm_save_layout = '<?php echo JText::_('Do you want to save changes to layout %s?')?>';
	
	var lg_invalid_info = '<?php echo JText::_('Invalid info.')?>';
	var lg_confirm_delete_theme = '<?php echo JText::_('Are you sure to delete this theme?')?>';
	
</script>

<?php 
/* Check info.php file */
$file = JPATH_SITE.DS.'templates'.DS.$template.DS.'info'.DS.'info.php';
if(file_exists($file)){?>
	<fieldset class="adminform" id="additional_information" style="display: none">
		<?php include_once $file;?>
	</fieldset>
<?php }?>

<?php if($helpurl!=''){?>

<a rel="{handler: 'iframe', size: {x: 960, y: 590} }" href="<?php echo $helpurl?>" class="modal toolbar" id="ja-introduce">
	<span title="<?php echo JText::_('Help')?>" class="icon-32-help"></span>
	<?php echo JText::_('Help')?>
</a>
<?php }?>