<?php
/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

//no direct access
defined( '_JEXEC' ) or die( 'Retricted Access' );

global $mainframe, $option, $jauc;

$extID = $this->obj->extId;

$compareVersion = JRequest::getVar('version');
?>
<script language="javascript">
// Proccess for check update button
/*<![CDATA[*/
Joomla.submitbutton = function(pressbutton) {
	var form = document.adminForm;
	// Check update
	if ( pressbutton == 'upgrade'){
		doUpgrade(jQuery("[name=id]").val(), jQuery("[name=version]").val(), 'UpgradeStatus');
		return;
	}
	
	submitform( pressbutton );
}

jQuery(document).ready(function(){
	new JATooltips ([$('diffview-status-new')], {
		content: '<?php echo JText::_("THESE_FILES_ARE_NEWLY_ADDED_TO_NEW_VERSIONBR__THESE_WILL_BE_ADDED_TO_USER_SITE_ON_UPGRADE", true); ?>'
	});
	new JATooltips ([$('diffview-status-bmodified')], {
		content: '<?php echo JText::sprintf("CONFICT_FILES_DESCRIPTION", $compareVersion, $compareVersion); ?>'
	});
	new JATooltips ([$('diffview-status-updated')], {
		content: '<?php echo JText::sprintf("THESE_FILES_ARE_CHANGED_IN_S_AND_ARE_NOT_MODIFIED_BY_YOU_IN_YOUR_LIVE_SITEBR__THESE_WILL_BE_UPDATED_TO_USER_SITE_ON_UPGRADE", $compareVersion, $compareVersion); ?>'
	});
	new JATooltips ([$('diffview-status-removed')], {
		content: '<?php echo JText::sprintf("THESE_FILES_ARE_DELETED_IN_S_VERSIONBR__THESE_WILL_BE_REMOVED_FROM_USER_SITE_ON_UPGRADE", $compareVersion, $compareVersion); ?>'
	});
	new JATooltips ([$('diffview-status-umodified')], {
		content: '<?php echo JText::sprintf("MODIFIED_BY_YOU_ONLY_THERE_IS_NO_CODE_CHANGE_FROM_VERSION_S_TO_SBR__THIS_FILE_WILL_NOT_BE_OVERWRITTEN_YOUR_CUSTOMIZATION_WILL_BE_RETAINED_AFTER_THE_UPGRADE_HOWEVER_IF_YOUR_CUSTOMIZATION_CAUSE_THE_ERRORBR__YOU_WILL_NEED_TO_OVERWRITE_WITH_THE_CLEAN_FILE_OF_VERSION_S_AND_THEN_REAPPLY_YOUR_CUSTOMIZATION", $this->obj->version, $compareVersion, $compareVersion); ?>'
	});
	new JATooltips ([$('diffview-status-ucreated')], {
		content: '<?php echo JText::_("THESE_FILES_ARE_CUSTOM_CREATED_BY_USER__OR_WERE_MOVED_TO_NEW_DIRECTORY_DURING_THE_INSTALLATION_PROCESSBR__NONEXTENSION_FILES_WILL_NOT_BE_AFFECTED_EXTENSION_FILES_WHICH_NEEDS_TO_MOVE_TO_OTHER_FOLDERS_DURING_INSTALLATION_WILL_BE_OVERWRITTEN", true); ?>'
	});
	new JATooltips ([$('diffview-status-nochange')], {
		content: '<?php echo JText::_("THESE_FILES_ARE_NOT_CHANGED_BETWEEN_THE_OLD_AND_NEW_VERSIONBR__THEY_WILL_NOT_BE_AFFECTED_BY_UPGRADE", true); ?>'
	});
});
/*]]>*/
</script>
<form name="adminForm" id="adminForm" action="index.php" method="post">
  <?php echo JHTML::_( 'form.token'); ?>
  <input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
  <input type="hidden" name="view" value="<?php echo JRequest::getVar("view", "default")?>" />
  <input type="hidden" name="task" value="" />
  <input type="hidden" name="version" value="<?php echo JRequest::getVar("version")?>" />
  <input type="hidden" name="cId[]" id="cId0" value="<?php echo $extID; ?>" />
  <input type="hidden" name="id" value="<?php echo $extID; ?>" />
  <?php if (isset($this->showMessage) && $this->showMessage) : ?>
    <?php echo $this->loadTemplate('message'); ?>
  <?php endif; ?>
  <!-- Include DTree 3rd party to show file tree view -->
	<script language="javascript" src="components/<?php echo JACOMPONENT; ?>/assets/dtree/dtree.js"></script>
	<link rel="stylesheet" href="components/<?php echo JACOMPONENT; ?>/assets/dtree/dtree.css" type="text/css" />
  <link rel="stylesheet" type="text/css" src="components/<?php echo JACOMPONENT; ?>/assets/css/default.css"  />
  
<fieldset>
<legend><?php echo JText::sprintf('FILE_COMPARISON_BETWEEN_S_VERSION_S_AND_S', $this->obj->name, $this->obj->version, $compareVersion); ?></legend>
  <div class="ja-compare-result">
	<div id="UpgradeStatus" style="color:#0066CC; font-weight:bold"></div><br/>
    <fieldset class="Legends">
              <div class="Item">
                <div class="Desc"><?php echo JText::_('SHOW')?>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<?php echo JText::_('FILE_TYPE')?></div>
              </div>
              <div class="Item">
                <div class="Desc">
                    <input name="file_type" type="checkbox" value="new" checked="checked" />&nbsp;
                    <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_new.gif" />&nbsp;
                    <a href="#" id="diffview-status-new" title="" class="ja-tips-title"><?php echo JText::_('NEW_FILE_IN_NEW_VERSION')?></a>
                    </div>
              </div>
              <div class="Item">
                <div class="Desc">
                <input name="file_type" type="checkbox" value="bmodified" checked="checked" />&nbsp;
                <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_bmodified.gif" />&nbsp; 
                <a href="#" id="diffview-status-bmodified" title="" class="ja-tips-title"><?php echo JText::_('CONFLICTED_FILES')?></a>
                </div>
              </div>
              <div class="Item">
                <div class="Desc">
                <input name="file_type" type="checkbox" value="updated" checked="checked" />&nbsp;
                <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_updated.gif" />&nbsp; 
                <a href="#" id="diffview-status-updated" title="" class="ja-tips-title"><?php echo JText::_('UPDATED_FILE_IN_NEW_VERSION')?></a>
                </div>
              </div>
             <div class="Item">
                <div class="Desc">
                <input name="file_type" type="checkbox" value="removed" checked="checked" />&nbsp;
                <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_removed.gif" />&nbsp;
                <a href="#" id="diffview-status-removed" title="" class="ja-tips-title"><?php echo JText::_('REMOVED_FILE_IN_NEW_VERSION')?></a>
                </div>
              </div>
               <div class="Item">
                <div class="Desc">
                <input name="file_type" type="checkbox" value="umodified" checked="checked" />&nbsp;
                <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_umodified.gif" />&nbsp; 
                <a href="#" id="diffview-status-umodified" title="" class="ja-tips-title"><?php echo JText::_('MODIFIED_BY_USER')?></a>
                </div>
              </div>
              <div class="Item">
                <div class="Desc">
                <input name="file_type" type="checkbox" value="ucreated" checked="checked" />&nbsp;
                <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_ucreated.gif" />&nbsp; 
                <a href="#" id="diffview-status-ucreated" title="" class="ja-tips-title"><?php echo JText::_('CREATED_BY_USER')?></a>
                </div>
              </div>
              <div class="Item">
                <div class="Desc">
                <input name="file_type" type="checkbox" value="nochange" />&nbsp;
                <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_nochange.gif" />&nbsp;
                <a href="#" id="diffview-status-nochange" title="" class="ja-tips-title"><?php echo JText::_('NO_CHANGE')?></a>
                </div>
              </div>

    </fieldset>
    <table class="adminlist" cellpadding="1" cellspacing="1">
      <thead>
        <tr>
          <th><?php echo JText::_("FILE_CHANGES") ?></th>
        </tr>
      </thead>
      <tbody>
	  	<tr>
            <td>
            	<div class="dtree">
                <!-- Write to tree -->
                <script type="text/javascript">
                    <?php
						echo printChildNode($this->obj->diffInfo);
                    ?>
                </script>
              </div>
              </td>
         </tr>
      </tbody>
    </table>
  </div>
</fieldset>
</form>

<script type="text/javascript">
/*<![CDATA[*/
jQuery(document).ready(function () {
	jaTreeAddActions('<?php echo $extID; ?>', '<?php echo $this->obj->version; ?>', '<?php echo $compareVersion; ?>');
	jaShowTreeFiles(numTreeNode, '');
	jQuery("[name=file_type]").each(function(){
		jQuery(this).click(function(){
			jaShowTreeFiles(numTreeNode, jQuery(this).val());
		});
	});
});
/*]]>*/
</script>
