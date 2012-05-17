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

<?php if ($this->params->get('show_page_title',1)) : ?>
<h1 class="componentheading<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>">
	<?php echo $this->escape($this->params->get('page_title')); ?>
</h1>
<?php endif; ?>

<div class="blog<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>">

	<?php $i = $this->pagination->limitstart;
	$leading = $this->params->def('num_leading_articles', 1);
	for ($y = 0; $y < $leading && $i < $this->total; $y++, $i++) : ?>
		<div class="leading<?php echo $this->params->get('pageclass_sfx'); ?> clearfix">
			<?php $this->item =& $this->getItem($i, $this->params);
			echo $this->loadTemplate('item'); ?>
		</div>
	<?php endfor; ?>

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
			<div class="article_row<?php echo $this->escape($this->params->get('pageclass_sfx')); ?> cols<?php echo $colcount; ?> clearfix">
				<?php for ($z = 0; $z < $colcount && $ii < $introcount && $i < $this->total; $z++, $i++, $ii++) : ?>
					<div class="article_column column<?php echo $z + 1; ?>" >
						<?php $this->item =& $this->getItem($i, $this->params);
						echo $this->loadTemplate('item'); ?>
					</div>
				<?php endfor; ?>
			</div>
		<?php endfor;
	endif; ?>

	<?php $numlinks = $this->params->def('num_links', 4);
	if ($numlinks && $i < $this->total) : ?>
	<div class="blog_more<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>">
		<?php $this->links = array_slice($this->items, $i - $this->pagination->limitstart, $i - $this->pagination->limitstart + $numlinks);
		echo $this->loadTemplate('links'); ?>
	</div>
	<?php endif; ?>

	<?php if ($this->params->def('show_pagination', 2) == 1  || ($this->params->get('show_pagination') == 2 && $this->pagination->get('pages.total') > 1)) : ?>
		<?php if( $this->pagination->get('pages.total') > 1 ) : ?>
		<p class="counter">
			<span><?php echo $this->pagination->getPagesCounter(); ?></span>
		</p>
		<?php endif; ?>
		<?php if ($this->params->def('show_pagination_results', 1)) : ?>
			<?php echo $this->pagination->getPagesLinks(); ?>
		<?php endif; ?>
	<?php endif; ?>
</div>
