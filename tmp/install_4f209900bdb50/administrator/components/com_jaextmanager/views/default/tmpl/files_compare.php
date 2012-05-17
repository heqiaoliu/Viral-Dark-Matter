<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
# Author: JoomlArt.com
# Websites: http://www.joomlart.com - http://www.joomlancers.com.
# ------------------------------------------------------------------------
*/

//no direct access
defined( '_JEXEC' ) or die( 'Retricted Access' );

global $mainframe, $option, $jauc;

$diffInfo = $this->obj->diffInfo;
?>
<div id="ja-diff-toolbar">
<a href="#" class="close" onclick="window.close();"><?php echo JText::_("CLOSE"); ?></a>
</div>
<div id="ja-diff-viewer">
  <div id="diffviewer-side-left">
    <div class="title">
    	<h4><?php echo $diffInfo->left->title; ?></h4>
        <?php if($diffInfo->right->editabled): ?>
        <a href="#" onclick="jaDiffCopyAllToRight(); return false;"><?php echo JText::_("COPY_ALL_TO_RIGHT"); ?></a> | 
        <?php else: ?>
        <a href="#" class="disabled"><?php echo JText::_("COPY_ALL_TO_RIGHT"); ?></a> | 
        <?php endif; ?>
        
        <a href="#" onclick="jaDiffViewSource('left', 'view'); return false;"><?php echo JText::_("VIEW_PLAIN"); ?></a> | 
        
        <?php if($diffInfo->left->editabled): ?>
        <a href="#" onclick="jaDiffViewSource('left', 'edit'); return false;"><?php echo JText::_("EDIT_SOURCE"); ?></a> | 
        <a href="#" onClick="jaDiffSaveSource('left'); return false;"><?php echo JText::_("SAVE"); ?></a>
        <?php else: ?>
        <a href="#" class="disabled"><?php echo JText::_("EDIT_SOURCE"); ?></a> | 
        <a href="#" class="disabled"><?php echo JText::_("SAVE"); ?></a>
        <?php endif; ?>
        <br  />
        <em><?php echo $diffInfo->left->file; ?> </em>
    </div>
    <?php echo $diffInfo->left->result; ?> 
  </div>
  <div id="diffviewer-side-right">
    <div class="title">
    	<h4><?php echo $diffInfo->right->title; ?></h4>
        <?php if($diffInfo->left->editabled): ?>
        <a href="#" onclick="jaDiffCopyAllToLeft(); return false;"><?php echo JText::_("COPY_ALL_TO_LEFT"); ?></a> |
        <?php else: ?>
        <a href="#" class="disabled"><?php echo JText::_("COPY_ALL_TO_LEFT"); ?></a> | 
        <?php endif; ?>
        
        <a href="#" onclick="jaDiffViewSource('right', 'view'); return false;"><?php echo JText::_("VIEW_PLAIN"); ?></a> | 
        
        <?php if($diffInfo->right->editabled): ?>
        <a href="#" onclick="jaDiffViewSource('right', 'edit'); return false;"><?php echo JText::_("EDIT_SOURCE"); ?></a> | 
        <a href="#" onClick="jaDiffSaveSource('right'); return false;"><?php echo JText::_("SAVE"); ?></a>
        <?php else: ?>
        <a href="#" class="disabled"><?php echo JText::_("EDIT_SOURCE"); ?></a>  | 
        <a href="#" class="disabled"><?php echo JText::_("SAVE"); ?></a>
        <?php endif; ?>
        <br  />
        <em><?php echo $diffInfo->right->file; ?> </em>
    </div>
    <?php echo $diffInfo->right->result; ?> 
  </div>
</div>
<form id="frmDiffViewer" name="frmDiffViewer" method="post" action="" enctype="multipart/form-data">
    <textarea name="diffViewSrc" id="diffViewSrc" style="display:none;"></textarea>
    <textarea name="srcLeft" id="srcLeft" style="display:none;"></textarea>
    <textarea name="srcRight" id="srcRight" style="display:none;"></textarea>
    <input type="hidden" name="backUrl" id="backUrl" value="<?php echo JURI::current() ."?". $_SERVER['QUERY_STRING']; ?>" />
    <input type="hidden" name="titleLeft" id="titleLeft" value="<?php echo addslashes($diffInfo->left->title); ?>" />
    <input type="hidden" name="fileLeft" id="fileLeft" value="<?php echo addslashes($diffInfo->left->file); ?>" />
    <input type="hidden" name="editabledLeft" id="editabledLeft" value="<?php echo addslashes($diffInfo->left->editabled); ?>" />
    
    <input type="hidden" name="titleRight" id="titleRight" value="<?php echo addslashes($diffInfo->right->title); ?>" />
    <input type="hidden" name="fileRight" id="fileRight" value="<?php echo addslashes($diffInfo->right->file); ?>" />
    <input type="hidden" name="editabledRight" id="editabledRight" value="<?php echo addslashes($diffInfo->right->editabled); ?>" />
</form>
<script type="text/javascript">
/*<![CDATA[*/
jQuery(document).ready(function () {
	jaDiffScroll();
});
/*]]>*/
</script>
