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
//get reference of this block and update its no-wrap attribute
$block = & $this->getBlockXML (T3Common::node_attributes($block, 'name'), T3Common::node_attributes($block, 'parent', 'middle'));
T3Common::set_node_attributes($block, 'no-wrap', 1);
T3Common::set_node_attributes($block, 'no-main', 1);
?>
<?php if (!$this->getParam ('option_layouts') && !$this->getParam ('option_screen') && !$this->getParam ('option_font') && !$this->getParam ('option_themes') && !$this->getParam ('option_direction') && !$this->getParam ('option_menu')) return ; ?>
<div id="ja-cpanel-wrapper">
<div id="ja-cpanel">
    <div id="ja-cpanel-main">
        <div class="ja-cpanel-head clearfix">
            <a href="http://wiki.joomlart.com/wiki/JA_T3_Framework_2/Overview" class="first" title="About T3"><span>About</span></a>
            <a href="http://wiki.joomlart.com/wiki/JA_T3_Framework_2/Guides" title="Guides"><span>Guides</span></a>
            <a href="http://wiki.joomlart.com/wiki/JA_T3_Framework_2/FAQs" title="FAQs"><span>FAQs</span></a>
        </div>
        <div class="ja-cpanel-tools clearfix">
        <?php if ($this->getParam ('option_font')) : ?>
            <?php $this->showBlock('usertools/font'); ?>
        <?php endif;?>
        <?php if ($this->getParam ('option_screen')) : ?>
            <?php $this->showBlock('usertools/screen'); ?>
        <?php endif;?>
        <?php if ($this->getParam ('option_profile')) : ?>
            <?php $this->showBlock('usertools/profiles'); ?>
        <?php endif;?>
        <?php if ($this->getParam ('option_layouts')) : ?>
            <?php $this->showBlock('usertools/layouts'); ?>
        <?php endif;?>
        <?php if ($this->getParam ('option_menu')) : ?>
            <?php $this->showBlock('usertools/menu'); ?>
        <?php endif;?>
        </div>
        <div class="ja-cpanel-action clearfix">
            <a href="#" onclick="cpanel_apply();return false;" class="button" title="Apply setting"><span>Apply</span></a>
            <a href="#" onclick="cpanel_reset();return false;" title="Reset to default setting"><span>Reset</span></a>
            <a target="_blank" href="http://www.joomlart.com/joomla/jat3-framework/" class="ja-cpanel-video"><span>&nbsp;</span></a>
        </div>
    </div>
    <a href="#" id="ja-cpanel-toggle"><span>Cpanel</span></a>
</div>
</div>

<script type="text/javascript">
    var tmpl_name = '<?php echo $this->template ?>';
    window.addEvent('load', function () {
        $('ja-cpanel-toggle').status == 'close';
        $('ja-cpanel-toggle').slider = new Fx.Slide('ja-cpanel-main', {duration: 400});
        $('ja-cpanel-toggle').slider.hide();
        $('ja-cpanel').setStyle ('top', 0);
        $('ja-cpanel-toggle').addEvent ('click', function (e) {
            this.slider.toggle();
            if (this.hasClass ('open')) {
                this.removeClass ('open').addClass ('close');
            } else {
                this.removeClass ('close').addClass ('open');
            }
            new Event(e).stop();
        });
    });
</script>