<?php


defined('_JEXEC') or die('Restricted access');
$cparams = JComponentHelper::getParams ('com_media');
?>

<div class="blog<?php echo $this->escape($this->params->get('pageclass_sfx')); ?> clearfix">

	<?php if ($this->params->get('show_page_title')) : ?>
	<h1 class="componentheading">
		<?php echo $this->escape($this->params->get('page_title')); ?>
	</h1>
	<?php endif; ?>

	<?php if ($this->params->def('show_description', 1) || $this->params->def('show_description_image', 1)) : ?>
	<div class="category-desc clearfix">

		<?php if ($this->params->get('show_description_image') && $this->category->image) : ?>
		<img src="<?php echo $this->baseurl . $cparams->get('image_path') . '/' . $this->category->image; ?>" class="image_<?php echo $this->category->image_position; ?>" />
		<?php endif; ?>

		<?php if ($this->params->get('show_description') && $this->category->description) :
			echo $this->category->description;
		endif; ?>

		<?php if ($this->params->get('show_description_image') && $this->category->image) : ?>
		<div class="wrap_image">&nbsp;</div>
		<?php endif; ?>

	</div>
	<?php endif; ?>

	<?php $i = $this->pagination->limitstart;
	$rowcount = $this->params->def('num_leading_articles', 1);
	if ($rowcount && $i < $this->total) : ?>
	<div class="items-leading">	
		<?php 
		for ($y = 0; $y < $rowcount && $i < $this->total; $y++, $i++) : ?>
			<div class="leading leading-<?php echo $y ?> clearfix">
				<?php $this->item =& $this->getItem($i, $this->params);
				echo $this->loadTemplate('item'); ?>
			</div>
		<?php endfor; ?>
	</div>
	<?php endif; ?>
	
	<?php $introcount = $this->params->def('num_intro_articles', 4);
	if ($introcount) :
		$colcount = (int)$this->params->def('num_columns', 2);
		if ($colcount == 0) :
			$colcount = 1;
		endif;
		$rowcount = (int) $introcount / $colcount;
		$ii = 0;
		for ($y = 0; $y < $rowcount && $i < $this->total; $y++) : ?>
			<div class="items-row cols-<?php echo $colcount; ?> <?php echo 'row-'.$y ; ?> clearfix">
				<?php for ($z = 0; $z < $colcount && $ii < $introcount && $i < $this->total; $z++, $i++, $ii++) : ?>
					<div class="item column<?php echo $z; ?>" >
						<?php $this->item =& $this->getItem($i, $this->params);
						echo $this->loadTemplate('item'); ?>
					</div>
				<?php endfor; ?>
			</div>
		<?php endfor;
	endif; ?>

	<?php $numlinks = $this->params->def('num_links', 4);
	if ($numlinks && $i < $this->total) : ?>
	<div class="items-more clearfix">
		<?php $this->links = array_slice($this->items, $i - $this->pagination->limitstart, $i - $this->pagination->limitstart + $numlinks);
		echo $this->loadTemplate('links'); ?>
	</div>
	<?php endif; ?>

	<?php if ($this->params->def('show_pagination', 2) == 1  || ($this->params->get('show_pagination') == 2 && $this->pagination->get('pages.total') > 1)) : ?>
	<div class="pagination clearfix">
		<?php if( $this->pagination->get('pages.total') > 1 ) : ?>
		<p class="counter">
			<span><?php echo $this->pagination->getPagesCounter(); ?></span>
		</p>
		<?php endif; ?>
		<?php if ($this->params->def('show_pagination_results', 1)) : ?>
			<?php echo $this->pagination->getPagesLinks(); ?>
		<?php endif; ?>
	</div>
	<?php endif; ?>

</div>
