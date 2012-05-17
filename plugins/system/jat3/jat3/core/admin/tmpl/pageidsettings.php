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
<script type="text/javascript">
    var jaclass_<?php echo $name?> = new JAT3_PAGEIDSETTINGS({param_name: '<?php echo $name?>'});

    window.addEvent('load', function () {
        jaclass_<?php echo $name; ?>.buildPageAssignmentList();

        $(document.body).addEvent( 'click', function() {
            jaclass_<?php echo $name?>.clearData();
        });

        $('<?php echo $name?>-ja-popup-pageids').addEvent('click', function(e) {
            e.cancelBubble = true;
            if (e.stopPropagation) e.stopPropagation();
        });

        <?php if (!$arr_values) {?>
            $('<?php echo $name?>-row-0').getElement('.pageid_text').set('text','<?php echo JText::_('ALL_PAGE')?>');
        <?php }?>
    });
</script>

<div id="<?php echo $name;?>-ja-message-pageids"></div>
<table width="100%" class="ja-list-pageids" id="<?php echo $name?>-ja-list-pageids">
    <tr>
        <th width="47%">
            <?php echo JText::_('Pages'); ?>
        </th>
        <th width="47%">
            <?php echo JText::_('Profiles'); ?>
        </th>
        <th width="6%">
        </th>
    </tr>
    <?php
    if ($arr_values) {
        foreach ($arr_values as $k=>$row) {
    ?>
        <tr id="<?php echo $name?>-row-<?php echo $k?>" class="ja-item">
            <td width="47%">
                <span class="pageid_text" <?php if ($k > 0) {?>onclick="jaclass_<?php echo $name?>.choosePageids(this, <?php echo $k?>)"<?php }?>>
                <?php
                    if ($k==0) {
                        echo JText::_('All Page');
                    } else {
                        echo $row[0];
                        if ('' != $row[1]) {
                            echo ' / ', $row[1];
                        }
                    }
                ?>
                </span>
            </td>
            <td width="47%">
                <span class="profile_text" onclick="jaclass_<?php echo $name?>.chooseProfile(this, <?php echo $k?>)">
                    <?php echo @$row[2]?>
                </span>
            </td>
            <td width="6%">
                <?php if ($k>0) {?>
                <span class="ja_close" onclick="jaclass_<?php echo $name?>.removerow(this);">
                    <img border="0" alt="<?php echo JText::_('Remove')?>"
                        src="<?php echo JURI::root()?>/plugins/system/jat3/jat3/core/admin/assets/images/icon-16-deny.png"
                        title="<?php echo JText::_('CLICK_HERE_TO_REMOVE_THIS_ROW')?>"/>
                </span>
                <?php }else {?>
                    &nbsp;
                <?php }?>
            </td>
        </tr>
        <?php }
    } else { ?>
        <tr id="<?php echo $name?>-row-0" class="ja-item">
            <td width="47%">
                <span class="pageid_text"></span>
            </td>
            <td width="47%">
                <span class="profile_text" onclick="jaclass_<?php echo $name?>.chooseProfile(this, 0)">
                    default
                </span>
            </td>
            <td width="6%">&nbsp;

            </td>
        </tr>
    <?php }?>
    <tr class="ja-item newpagesetting">
        <td width="47%" onclick="jaclass_<?php echo $name?>.addrow(this)">
            <span class="pageid_text more">
                <?php echo JText::_('CLICK_TO_ADD') ?>
            </span>
        </td>
        <td width="47%">
            <span class="profile_text more">
                &nbsp;
            </span>
        </td>
        <td width="6%">
            <span class="ja_close">
                <img border="0" alt="<?php echo JText::_('Remove')?>" title="<?php echo JText::_('Remove')?>"
                    src="<?php echo JURI::root()?>/plugins/system/jat3/jat3/core/admin/assets/images/icon-16-deny.png"/>
            </span>
        </td>
    </tr>

</table>
<input name='jform[general][<?php echo $name?>]' id="<?php echo $name?>-profile" value="<?php echo $value?>" type="hidden"/>