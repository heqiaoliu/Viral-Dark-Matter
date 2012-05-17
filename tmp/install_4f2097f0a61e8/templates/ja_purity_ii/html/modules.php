<?php
/*
#------------------------------------------------------------------------
  JA Purity II for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/


defined('_JEXEC') or die('Restricted access');

/**
 * This is a file to add template specific chrome to module rendering.  To use it you would
 * set the style attribute for the given module(s) include in your template to use the style
 * for each given modChrome function.
 *
 * eg.  To render a module mod_test in the sliders style, you would use the following include:
 * <jdoc:include type="module" name="test" style="slider" />
 *
 * This gives template designers ultimate control over how modules are rendered.
 *
 * NOTICE: All chrome wrapping methods should be named: modChrome_{STYLE} and take the same
 * three arguments.
 */


/*
 * Default Module Chrome that has sematic markup and has best SEO support
 */
function modChrome_JAxhtml($module, &$params, &$attribs)
{ 
	$badge = preg_match ('/badge/', $params->get('moduleclass_sfx'))?"<span class=\"badge\">&nbsp;</span>\n":"";
?>
	<div class="ja-moduletable moduletable<?php echo $params->get('moduleclass_sfx'); ?>  clearfix" id="Mod<?php echo $module->id; ?>">
		<?php echo $badge; ?>
		<?php if ($module->showtitle != 0) : ?>
		<h3><span><?php echo $module->title; ?></span></h3>
		<?php endif; ?>
		<div class="ja-box-ct clearfix">
		<?php echo $module->content; ?>
		</div>
    </div>
	<?php
}

/*
 * Module chrome that allows for rounded corners by wrapping in nested div tags
 */
function modChrome_JArounded($module, &$params, &$attribs)
{
	$badge = preg_match ('/badge/', $params->get('moduleclass_sfx'))?"<span class=\"badge\">&nbsp;</span>\n":"";
?>
	<div class="ja-module ja-box-br module<?php echo $params->get('moduleclass_sfx'); ?>" id="Mod<?php echo $module->id; ?>">
	<div class="ja-box-bl"><div class="ja-box-tr"><div class="ja-box-tl clearfix">
		<?php echo $badge; ?>
		<?php if ($module->showtitle != 0) : ?>
		<h3><span><?php echo $module->title; ?></span></h3>
		<?php endif; ?>
		<div class="jamod-content ja-box-ct clearfix">
		<?php echo $module->content; ?>
		</div>
	</div></div></div>
	</div>
	<?php
}
