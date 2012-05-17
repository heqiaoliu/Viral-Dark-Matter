<?php


defined('_JEXEC') or die('Restricted access');
?>

<script language="javascript" type="text/javascript">
<!--
function tableOrdering( order, dir, task )
{
var form = document.adminForm;

form.filter_order.value = order;
form.filter_order_Dir.value = dir;
document.adminForm.submit( task );
}
// -->
</script>

<form action="<?php echo $this->action; ?>" method="post" name="adminForm">

<?php if ($this->params->get('filter') || $this->params->get('show_pagination_limit')) : ?>
<fieldset class="filters clearfix">
	
	<?php if ($this->params->get('filter')) : ?>
	<div class="filter-search">
		<?php echo JText::_($this->escape($this->params->get('filter_type')) . ' ' . 'Filter').'&nbsp;'; ?>
		<input type="text" name="filter" value="<?php echo $this->escape($this->lists['filter']); ?>" class="inputbox" onchange="document.adminForm.submit();" />
	</div>
	<?php endif; ?>

	<?php if ($this->params->get('show_pagination_limit')) : ?>
	<div class="display-limit">
		<?php echo JText::_('Display Num'); ?>&nbsp;
		<?php echo $this->pagination->getLimitBox(); ?>
	</div>
	<?php endif; ?>

</fieldset>
<?php endif; ?>

<table class="category">

	<?php if ($this->params->get('show_headings')) : ?>
	<thead>
	<tr>
		<th class="" id="count">
			<?php echo JText::_('Num'); ?>
		</th>

		<?php if ($this->params->get('show_title')) : ?>
		<th class="" id="tableOrdering">
			<?php echo JHTML::_('grid.sort', 'Item Title', 'a.title', $this->lists['order_Dir'], $this->lists['order']); ?>
		</th>
		<?php endif; ?>

		<?php if ($this->params->get('show_date')) : ?>
		<th class="" id="tableOrdering2">
			<?php echo JHTML::_('grid.sort', 'Date', 'a.created', $this->lists['order_Dir'], $this->lists['order']); ?>
		</th>
		<?php endif; ?>

		<?php if ($this->params->get('show_author')) : ?>
		<th class="" id="author">
			<?php echo JHTML::_('grid.sort', 'Author', 'author', $this->lists['order_Dir'], $this->lists['order']); ?>
		</th>
		<?php endif; ?>

		<?php if ($this->params->get('show_hits')) : ?>
		<th align="center" class="" width="5%" nowrap="nowrap" id="hits">
			<?php echo JHTML::_('grid.sort', 'Hits', 'a.hits', $this->lists['order_Dir'], $this->lists['order']); ?>
		</th>
		<?php endif; ?>
	</tr>
	</thead>
	<?php endif; ?>
	
	<tbody>

	<?php foreach ($this->items as $item) : ?>
	<tr class="cat-list-row<?php echo ($item->odd + 1) ?>">
		<td headers="count">
			<?php echo $this->pagination->getRowOffset((int)$item->count); ?>
		</td>

		<?php if ($this->params->get('show_title')) : ?>
		<td headers="tableOrdering">
			<?php if ($item->access <= $this->user->get('aid', 0)) : ?>
				<a href="<?php echo $item->link; ?>">
					<?php echo $this->escape($item->title); ?></a>
				<?php echo JHTML::_('icon.edit', $item, $this->params, $this->access, array('rel'=>'nofollow'));
			else :
				echo $item->title; ?> :
				<a href="<?php echo JRoute::_('index.php?option=com_user&task=register'); ?>">
					<?php echo JText::_('Register to read more...'); ?></a>
			<?php endif; ?>
		</td>
		<?php endif; ?>

		<?php if ($this->params->get('show_date')) : ?>
		<td  headers="tableOrdering2">
			<?php $created = T3Hook::_('t3_date_format', array($item->created, 'cat.default.created'));
			if (!$created) $created = $item->created; ?>
			<?php echo $created ?>
		</td>
		<?php endif; ?>

		<?php if ($this->params->get('show_author')) : ?>
		<td headers="author">
			<?php echo $item->created_by_alias ? $this->escape($item->created_by_alias) : $this->escape($item->author); ?>
		</td>
		<?php endif; ?>

		<?php if ($this->params->get('show_hits')) : ?>
		<td headers="hits">
			<?php echo $item->hits ? (int)$item->hits : '-'; ?>
		</td>
		<?php endif; ?>

	</tr>
	<?php endforeach; ?>
	
	</tbody>

</table>

<?php if ($this->params->get('show_pagination') && $this->pagination->getPagesCounter()) : ?>
<div class="pagination clearfix">
	<p class="counter">
		<span><?php echo $this->pagination->getPagesCounter(); ?></span>
	</p>
	<?php echo $this->pagination->getPagesLinks(); ?>
</div>
<?php endif; ?>

<input type="hidden" name="id" value="<?php echo (int)$this->category->id; ?>" />
<input type="hidden" name="sectionid" value="<?php echo (int)$this->category->sectionid; ?>" />
<input type="hidden" name="task" value="<?php echo $this->lists['task']; ?>" />
<input type="hidden" name="filter_order" value="" />
<input type="hidden" name="filter_order_Dir" value="" />
<input type="hidden" name="limitstart" value="0" />
</form>
