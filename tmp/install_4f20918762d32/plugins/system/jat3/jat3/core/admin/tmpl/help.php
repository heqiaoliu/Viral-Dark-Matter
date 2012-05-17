<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// No direct access
defined('_JEXEC') or die;
?>

<?php
if (!$obj->checkexistExtensinsManagement()) {?>
<script type='text/javascript'>
    window.addEvent ('load', function () {
        addobj.delay(1500);
    });
    addobj = function(){var obj = new Element ('iframe', {width:500,height:311,src:'http://www.youtube.com/embed/mNAuJRmifG8',frameborder:0}).inject ($('ja-youtubemain-obj-content'));}
</script>
<?php }?>
<table width="100%" class="ja-help-support">
    <tr  class="level2">
        <td>
            <h4 id="ja-head-version" class="block-head block-head-logosetting open" rel="2">
                <span class="block-setting"><?php echo JText::_('UPDATE_AND_VERSION_INFORMATION')?></span>
                <span class="icon-help editlinktip hasTip" title="<?php echo JText::_('UPDATE_AND_VERSION_INFORMATION_DESC')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                <a onclick="showHideRegion('ja-head-version', 'level2'); return false;"  title="<?php echo JText::_('CLICK_HERE_TO_EXPAND_OR_COLLAPSE')?>" class="toggle-btn">open</a>
             </h4>
        </td>
    </tr>
    <tr  class="level3">
        <td>
            <br/>
            <span class="version-title"><?php echo JText::_('Version')?>:</span> <span class="version-current"><?php echo $version?></span>
            <div class="help-support-content">
                <?php if ($obj->checkexistExtensinsManagement()) {?>
                    <?php echo JText::_('EXTENSION_MANAGEMENT_HAS_INSTALLED'); ?>
                <?php }else{?>
                    <?php echo JText::_('EXTENSION_MANAGEMENT_DOES_NOT_EXIST'); ?>
                <?php }?>
            </div>
            <br/>
            <br/>
        </td>
    </tr>

    <tr  class="level2">
        <td>
            <h4 id="ja-head-help-support" class="block-head block-head-logosetting open" rel="2">
                <span class="block-setting"><?php echo JText::_('HELP_AND_SUPPORT')?></span>
                <span class="icon-help editlinktip hasTip" title="<?php echo JText::_('HELP_AND_SUPPORT_DESC')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                <a onclick="showHideRegion('ja-head-help-support', 'level2'); return false;" title="<?php echo JText::_('CLICK_HERE_TO_EXPAND_OR_COLLAPSE')?>"  class="toggle-btn">open</a>
            </h4>
        </td>
    </tr>
    <tr  class="level3">
        <td>
            <?php echo JText::_('HELP_AND_SUPPORT_DETAILS')?>
        </td>
    </tr>
</table>