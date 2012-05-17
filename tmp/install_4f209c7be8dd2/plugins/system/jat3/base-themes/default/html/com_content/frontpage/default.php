<?php


defined('_JEXEC') or die('Restricted access');
?>

<div class="blog-featured<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>">

	<?php if ($this->params->get('show_page_title',1)) : ?>
	<h1 class="componentheading"><?php echo JText::_('Home page title'); ?></h1>
	<?php endif; ?>

	<?php $i = $this->pagination->limitstart;
	$leading = $this->params->def('num_leading_articles', 1);
	if ($leading) : ?>
	<div class="items-leading">
	<?php
	for ($y = 0; $y < $leading && $i < $this->total; $y++, $i++) : ?>
		<div class="leading leading-<?php echo $y?> clearfix">
			<?php $this->item =& $this->getItem($i, $this->params);
			echo $this->loadTemplate('item'); ?>
		</div>
	<?php endfor; ?>
	</div>
	<?php endif; ?>
	
	<?php $introcount = min($this->total - $i, $this->params->def('num_intro_articles', 4));
	
	if ($introcount) :
		$colcount = $this->params->def('num_columns', 2);
		if ($colcount == 0) :
			$colcount = 1;
		endif;
		$rowcount = ceil ($introcount / $colcount);
		$ii = 0;
		for ($y = 0; $y < $rowcount && $i < $this->total; $y++) : 
			/*
			//Fix last row
			if ($y >= ($rowcount - 1)):
				$colcount = $introcount - $y * $colcount;
			endif;
			*/
		?>
			<div class="items-row cols-<?php echo $colcount; ?> row-<?php echo $y ?> clearfix">
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
	<div class="items-more">
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
