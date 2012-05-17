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

<script type="text/javascript">
	function tableOrdering(order, dir, task) {
		var form = document.adminForm;

		form.filter_order.value = order;
		form.filter_order_Dir.value = dir;
		document.adminForm.submit(task);
	}
</script>

<div class="sortby clearfix">
	<div class="display">
		<form action="<?php echo $this->escape($this->action); ?>" method="post" name="adminForm">
			<?php echo JText :: _('Display Num'); ?>&nbsp;
			<?php echo $this->pagination->getLimitBox(); ?>
			<input type="hidden" name="filter_order" value="<?php echo $this->lists['order'] ?>" />
			<input type="hidden" name="filter_order_Dir" value="" />
		</form>
	</div>
</div>


<table class="weblinks">

	<?php if ($this->params->def('show_headings', 1)) : ?>
	<tr>

		<th class="sectiontableheader<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>" width="5" id="num">
			<?php echo JText::_('Num'); ?>
		</th>

		<th width="90%" class="sectiontableheader<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>" id="title">
			<?php echo JHTML::_('grid.sort', 'Web Link', 'title', $this->lists['order_Dir'], $this->lists['order']); ?>
		</th>

		<?php if ($this->params->get('show_link_hits')) : ?>
		<th width="10%" class="sectiontableheader<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>" nowrap="nowrap" id="hits">
			<?php echo JHTML::_('grid.sort', 'Hits', 'hits', $this->lists['order_Dir'], $this->lists['order']); ?>
		</th>
		<?php endif; ?>

	</tr>
	<?php endif; ?>

	<?php foreach ($this->items as $item) : ?>
	<tr class="sectiontableentry<?php echo $item->odd + 1; ?>">

		<td align="center" headers="num">
			<?php echo $this->pagination->getRowOffset($item->count); ?>
		</td>

		<td headers="title">
			<?php if ($item->image) :
				echo $item->image;
			endif;
			echo $item->link;
			if ($this->params->get('show_link_description')) : ?>
			<br />
			<?php echo nl2br($item->description);
			endif; ?>
		</td>

		<?php if ($this->params->get('show_link_hits')) : ?>
		<td headers="hits">
			<?php echo (int)$item->hits; ?>
		</td>
		<?php endif; ?>

	</tr>
	<?php endforeach; ?>

</table>


<p class="counter">
	<?php echo $this->pagination->getPagesCounter(); ?>
</p>
<?php echo $this->pagination->getPagesLinks();
