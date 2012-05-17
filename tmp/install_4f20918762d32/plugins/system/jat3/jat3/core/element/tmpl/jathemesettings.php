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
    if(typeof(jaclass)=='undefined'){
        var jaclass = new Array();
    }
    var all_themes = [];
    <?php
    $j = 0;
    foreach ($themes as $type=>$row) {
        if ($row) {
            foreach ($row as $t) {
            ?>
                all_themes[<?php echo $j?>] = '<?php echo $type.'.'.$t[0]?>';
            <?php
                $j++;
            }
        }
    }
    ?>
    window.addEvent('load', function (){
        jaclass['<?php echo $name?>'] = new JAT3_THEMESETTINGS({param_name: '<?php echo $name?>'});

        $$('#<?php echo $name?>-ja-popup-themes .ja-themes-apply').addEvent ('click', function (event){
                                                jaclass['<?php echo $name?>'].apply(event);
                                            });
        $$('#<?php echo $name?>-ja-popup-themes .ja-themes-cancel').addEvent ('click', jaclass['<?php echo $name?>'].cancel.bind (jaclass['<?php echo $name?>']));
        $(document.body).addEvent ('click', jaclass['<?php echo $name?>'].cancel.bind (jaclass['<?php echo $name?>']));

        $('<?php echo $name?>-ja-popup-themes').inject($(document.body));

        $$('.ja-popup-themes .cb-span').addEvent ('click', function(e) {
            new Event(e).stop();
            if (this.getParent().hasClass ('default')) return;
            if (!this.checked) {
                this.checked = true;
                this.addClass ('cb-span-checked');
                this.getParent().addClass ('selected');
            } else {
                this.checked = false;
                this.removeClass ('cb-span-checked');
                this.getParent().removeClass ('selected');
            }
        });

        $$('.ja-popup-themes').addEvent ('click', function(e){new Event(e).stop()});
        $('<?php echo $name?>-ja-change-theme-help').setStyle('visibility', 'hidden');

        $('<?php echo $name?>-ja-change-theme-help').inject($(document.body));

        $(document.body).addEvent('click', function(e){
            var popup = $('<?php echo $name?>-ja-change-theme-help');
            if ( popup != null && popup.getStyle('display') != 'none' &&
                 (!e.target || !$(e.target).getParents().contains(popup))
            ){
                jaclass['<?php echo $name?>'].close_popup(popup);
            }
        });
    });

</script>

<div class="ja-list-themes" id="<?php echo $name?>-ja-list-themes">
    <span class="ja-theme-edit">
        &nbsp;
    </span>
    <div class="ja-themes"></div>
    <span class="ja-theme core"><?php echo JText::_('Default')?></span>


</div>
<input name='<?php echo $this->name?>' id="<?php echo $name?>" value="" type="hidden" rel="jathemesettings"/>

<div id="<?php echo $name?>-ja-change-theme-help" class="ja-tool-tip right tool" style="height: 0; display: none">
    <div class="center-bottom">
        <div class="top1"><div class="top2"><div class="top3"><div class="top4"></div></div></div></div>
        <div class="mid1"><div class="mid2"><div class="mid3"><div class="tool-text"><span>
                <?php echo JText::_('JA_CHANGE_THEME_HELP')?>
                <input type="checkbox" value="1" id="jachangethemecheckbox" class="notshowagain"/> <label for="jachangethemecheckbox"><?php echo JText::_('Not show again')?></label>
        </span></div></div></div></div>
        <a title="<?php echo JText::_('Hide')?>" class="close" href="javascript:void(0)" onclick="jaclass['<?php echo $name?>'].hideTip(this, $('jachangethemecheckbox'))"></a>
        <div class="bot1"><div class="bot2"><div class="bot3"><div class="bot4"></div></div></div></div>
    </div>

</div>
<div id="<?php echo $name?>-ja-popup-themes" class="ja-popup-themes">
    <ul class="ja-popup-themes">
        <?php if(isset($themes['core']) && $themes['core']){?>
            <li class="parent">
                <?php echo JText::_('Theme')?>
            </li>
            <li class="default">
                <span class="theme core"><?php echo JText::_('Default')?></span>
                <span class="cb-span cb-span-checked"></span>
            </li>
               <?php     foreach ($themes['core'] as $k=>$theme){
                if ($theme == 'default') continue;
                   ?>
                <li>
                    <span class="theme core"><?php echo $theme[0]?></span>
                    <span class="cb-span"></span>
                </li>
            <?php }?>
           <?php }?>
           <?php if(isset($themes['local']) && $themes['local']){?>
                <li class="parent">
                    <?php echo JText::_('Local Theme')?>
                </li>
               <?php     foreach ($themes['local'] as $k=>$theme){     ?>
                <li>
                    <span class="theme local"><?php echo $theme[0]?></span>
                    <span class="cb-span"></span>
                </li>
            <?php }?>
           <?php }?>
    </ul>

    <div class="ja-themes-action">
        <span class="ja-themes-apply"><?php echo JText::_('Apply') ?></span>
        <span class="ja-themes-cancel"><?php echo JText::_('Cancel') ?></span>
    </div>
</div>