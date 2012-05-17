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
<ul class="ja-profile-titles">
    <?php if ($profiles) {?>
        <li class="ja-profile default active">
            <span class="ja-profile-title"><?php echo JText::_('Default')?></span>
            <span class="ja-profile-action">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
        </li>
        <?php foreach ($profiles as $profilename=>$profile) {?>
            <?php if ($profilename!='default') {?>
            <li class="ja-profile">
                <span class="ja-profile-title"><?php echo $profilename?></span>
                <span class="ja-profile-action">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                </li>
            <?php }?>
        <?php }?>
    <?php } ?>
    <?php if ($isNewFolderStruct): ?>
    <li class="ja-profile-new" onclick="jat3admin.newProfile(this)" title="<?php echo JText::_('CLICK_HERE_TO_ADD_NEW_PROFILE')?>"><span><?php echo JText::_('New')?></span></li>
    <?php endif; ?>
</ul>

<div class="pane-sliders clearfix" id="jat3-profile-params" style="clear: both">
<?php $fieldSets = $paramsForm->getFieldsets('params');?>
<?php foreach ($fieldSets as $name => $fieldSet) :
        $label = !empty($fieldSet->label) ? $fieldSet->label : 'COM_TEMPLATES_'.$name.'_FIELDSET_LABEL';?>

        <div class="panel">
            <h3 class="jpane-toggler title" id="<?php echo $name.'-options'?>">
                <a href="javascript:void(0)"><span><?php echo JText::_($label)?></span></a>
            </h3>

            <?php if (isset($fieldSet->description) && trim($fieldSet->description)) :?>
            <p class="tip"><?php echo $this->escape(JText::_($fieldSet->description))?></p>
            <?php endif;?>

            <div class="jpane-slider content">
                <fieldset class="panelform">
                    <table width="100%" cellspacing="1" class="paramlist admintable">
                        <tbody>
                            <?php foreach ($paramsForm->getFieldset($name) as $field) : ?>
                                <tr>
                                    <?php if($field->label!=''){?>
                                    <td width="40%" class="paramlist_key">
                                        <?php echo $field->label; ?>
                                    </td>
                                    <?php }?>
                                    <td <?php if($field->label!='') {?>class="paramlist_value"<?php } else { ?> colspan="2" <?php }?>>
                                        <?php echo $field->input; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </fieldset>
            </div>
        </div>
<?php endforeach;  ?>
</div>

<div id="ja-profile-action">
    <ul>
        <li class="saveas"><?php echo JText::_('Clone');?></li>
        <li class="rename"><?php echo JText::_('Rename');?></li>
        <li class="reset"><?php echo JText::_('RESET_TO_DEFAULT');?></li>
        <li class="delete"><?php echo JText::_('Delete');?></li>
    </ul>
</div>

<script type="text/javascript">
window.addEvent('load', function (){
    $('ja-profile-action').inject ($(document.body));
});

if (isNewFolderStruct) {
    $$('.ja-profile-action').addEvent ('click', function (event) {
        var event = new Event(event);
        $('ja-profile-action').setStyles ({
            'top': event.page.y,
            'left': event.page.x
        });
        event.stop();
        jat3admin.showProfileAction(this);
    });
} else {
    $$('.ja-profile-action').hide();
}
</script>