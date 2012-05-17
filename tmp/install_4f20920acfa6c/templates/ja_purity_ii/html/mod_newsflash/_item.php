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
?>

<?php if ($params->get('item_title')) : ?>
<h4>
	<?php if ($params->get('link_titles') && (isset($item->linkOn))) : ?>
	<a href="<?php echo JRoute::_($item->linkOn); ?>" class="contentpagetitle<?php echo $params->get('moduleclass_sfx'); ?>">
		<?php echo $item->title; ?></a>
	<?php else :
		echo $item->title;
	endif; ?>
</h4>
<?php endif; ?>

<?php if (!$params->get('intro_only')) :
	echo $item->afterDisplayTitle;
endif; ?>

<?php echo $item->beforeDisplayContent;
echo JFilterOutput::ampReplace($item->text);

$itemparams=new JParameter($item->attribs);
$readmoretxt=$itemparams->get('readmore',JText::_('Read more'));
if (isset($item->linkOn) && $item->readmore && $params->get('readmore')) : ?>
<a href="<?php echo $item->linkOn; ?>" class="readon">
	<?php echo $readmoretxt; ?></a>
<?php endif; ?>
<span class="article_separator">&nbsp;</span>
