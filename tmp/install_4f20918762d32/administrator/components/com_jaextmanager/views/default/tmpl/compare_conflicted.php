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

?>
<form name="adminForm" id="adminForm" action="index.php" method="post">
  <?php echo JHTML::_( 'form.token'); ?>
  <input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
  <input type="hidden" name="view" value="<?php echo JRequest::getVar("view", "default")?>" />
  <input type="hidden" name="task" value="" />
  <input type="hidden" name="folder" value="<?php echo JRequest::getVar("folder")?>" />
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
  <legend><?php echo JText::_("CONFLICTED_COMPARE_AND_SOLVE"); ?></legend>
  <div class="ja-compare-result">
      <fieldset class="Legends">
              <div class="Item">
                <div class="Desc"><?php echo JText::_('SHOW')?>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<?php echo JText::_('FILE_TYPE')?></div>
              </div>
              <div class="Item">
                <div class="Desc">
                    <input name="file_type" type="checkbox" value="solved" checked="checked" />&nbsp;
                    <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_solved.gif" />&nbsp; 
                    <a href="#" id="diffview-status-solved" title="" class="ja-tips-title"><?php echo JText::_('SOLVED_FILES')?></a>
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
                    <input name="file_type" type="checkbox" value="empty" />&nbsp;
                    <img src="components/<?php echo JACOMPONENT; ?>/assets/dtree/img/icon_empty.gif" />&nbsp; 
                    <a href="#" id="diffview-status-empty" title="" class="ja-tips-title"><?php echo JText::_('EMPTY_FOLDER')?></a>
                </div>
              </div>
    
        </fieldset>
    <table class="adminlist" cellpadding="1" cellspacing="1">
      <thead>
        <tr>
          <th><?php echo JText::_("CONFLICTED_BACKUP_FILES") ?></th>
        </tr>
      </thead>
      <tbody>
	  	<tr>
            <td>
            	<div class="dtree">
                <!-- Write to tree -->
                <script type="text/javascript">
                    <?php
						echo printTreeConflicted($this->obj, $this->obj->conflictedDir);
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
	jaTreeConflictedAddActions('<?php echo $extID; ?>', '<?php echo JRequest::getVar("folder")?>');
	jaShowTreeFiles(numTreeNode, '');
	jQuery("[name=file_type]").each(function(){
		jQuery(this).click(function(){
			jaShowTreeFiles(numTreeNode, jQuery(this).val());
		});
	});
});
/*]]>*/
</script>
