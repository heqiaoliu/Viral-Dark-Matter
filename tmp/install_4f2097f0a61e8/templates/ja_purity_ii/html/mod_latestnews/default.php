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

<?php if (count($list)) : ?>
<ul class="latestnews<?php echo $params->get('pageclass_sfx'); ?>">
	<?php foreach ($list as $item) : ?>
	<li class="latestnews<?php echo $params->get('pageclass_sfx'); ?>">
		<a href="<?php echo $item->link; ?>" class="latestnews<?php echo $params->get('pageclass_sfx'); ?>">
			<?php echo $item->text; ?></a>
	</li>
	<?php endforeach; ?>
</ul>
<?php endif;
