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
defined('_JEXEC') or die();

?>

<script type="text/javascript">
window.addEvent('load', function(e) {
    $('ja-popup-gfont').inject($(document.body));

    $(document.body).addEvent('click', function(e) {
        gfont_close_popup();
    });

    var apply_button  = document.getElement('#ja-popup-gfont .ja-gfont-apply');
    var cancel_button = document.getElement('#ja-popup-gfont .ja-gfont-cancel');

    gfonts_init(
            $('gfont-family'), $('gfont-variant'), $('gfont-subset'),
            $('gfont-custom'), $('gfont-style'),
            apply_button, cancel_button
    );

});
</script>

<div id="ja-popup-gfont" style="width: 300px; display:none;">
    <div class="gfont-control gfont-title">
        <label style="width:100%">GFont properties</label>
        <a rel="{handler: 'iframe', size: {x: 930, y: 510} }" href="<?php echo $uri; ?>/assets/gfont_guide.htm" class="modal gfont-help">
            <span title="Help" class="gfont-help-icon">?</span>
        </a>
    </div>
    <div class="gfont-control">
        <label for="gfont-family"><?php echo JText::_('FONT_FAMILY'); ?></label>
        <input type="text" id="gfont-family" />
    </div>
    <div class="gfont-control">
        <label for="gfont-variant"><?php echo JText::_("FONT_VARIANT"); ?></label>
        <select id="gfont-variant"></select>
    </div>
    <div class="gfont-control">
        <label for="gfont-subset"><?php echo JText::_("FONT_SUBSET"); ?></label>
        <select id="gfont-subset"></select>
    </div>

    <div class="gfont-control">
        <input type="checkbox" id="gfont-custom" style="width:15px;" />
        <label for="gfont-custom" class="editlinktip hasTip txtgfont" title="<?php JText::_('CUSTOM_CSS_DESC'); ?>">
            <?php echo JText::_('CUSTOM_CSS'); ?>
        </label>
    </div>
    <textarea id="gfont-style" cols="40" rows="5" name="gfont-style" class="clearfix" style="display:none; margin-top: 5px; clear: both;">
    </textarea>

     <div class="ja-gfont-action">
        <span class="ja-gfont-apply"><?php echo JText::_('Apply') ?></span>
        <span class="ja-gfont-cancel"><?php echo JText::_('Cancel') ?></span>
    </div>
</div>