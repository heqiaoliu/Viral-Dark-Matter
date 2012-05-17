<?php


// no direct access
defined('_JEXEC') or die('Restricted access'); ?>

<?php if ($this->user->authorize('com_content', 'edit', 'content', 'all') || $this->user->authorize('com_content', 'edit', 'content', 'own')) : ?>
	<div class="contentpaneopen_edit<?php echo $this->escape($this->item->params->get( 'pageclass_sfx' )); ?>" style="float: left;">
		<?php echo JHTML::_('icon.edit', $this->item, $this->item->params, $this->access, array('rel'=>'nofollow')); ?>
	</div>
<?php endif; ?>
<div class="contentpaneopen<?php echo $this->escape($this->item->params->get( 'pageclass_sfx' )); ?>">

<?php if ($this->item->params->get('show_title')) : ?>
<h2 class="contentheading"><?php if ($this->item->params->get('link_titles') && $this->item->readmore_link != '') : ?><a href="<?php echo $this->item->readmore_link; ?>"><?php echo $this->escape($this->item->title); ?></a><?php else : ?><?php echo $this->escape($this->item->title); ?><?php endif; ?></h2>
<?php endif; ?>

<?php  if (!$this->item->params->get('show_intro')) :
	echo $this->item->event->afterDisplayTitle;
endif; ?>

<?php
if (
($this->item->params->get('show_create_date'))
|| (($this->item->params->get('show_author')) && ($this->item->author != ""))
|| (($this->item->params->get('show_section') && $this->item->sectionid) || ($this->item->params->get('show_category') && $this->item->catid))
|| ($this->item->params->get('show_pdf_icon') || $this->item->params->get('show_print_icon') || $this->item->params->get('show_email_icon'))
|| ($this->item->params->get('show_url') && $this->item->urls)
) :
?>
<div class="article-tools clearfix">
<dl class="article-info" <?php if (!($this->item->params->get('show_pdf_icon') || $this->item->params->get('show_print_icon') || $this->item->params->get('show_email_icon'))):?>style="width: 100%"<?php endif;?>>

	<?php if ($this->item->params->get('show_create_date')) : ?>
		<dd class="create">
			<?php $created = T3Hook::_('t3_date_format', array($this->item->created, 'cat.blog.created'));
			if (!$created) $created = JHTML::_('date', $this->item->created, JText::_('DATE_FORMAT_LC2')) ?>
			<?php echo $created ?>
		</dd>
	<?php endif; ?>

	<?php if (($this->item->params->get('show_author')) && ($this->item->author != "")) : ?>
		<dd class="createdby">
			<?php JText::printf(($this->item->created_by_alias 
				? $this->escape($this->item->created_by_alias) 
				: $this->escape($this->item->author)) ); ?>
		</dd>
	<?php endif; ?>

	<?php if ($this->params->get('show_hits')) : ?>
	<dd class="hits">        
		<?php echo JText::_('Hits'); ?>: <?php echo $this->item->hits; ?>
	</dd>
	<?php endif; ?>

	<?php if (($this->item->params->get('show_section') && $this->item->sectionid) || ($this->item->params->get('show_category') && $this->item->catid)) : ?>
		<?php if ($this->item->params->get('show_section') && $this->item->sectionid && isset($this->item->section)) : ?>
		<dd class="parent-category-name">
			<strong><?php echo JText::_('SECTION'); ?>: </strong>
			<?php if ($this->item->params->get('link_section')) : ?>
				<?php echo '<a href="'.JRoute::_(ContentHelperRoute::getSectionRoute($this->item->sectionid)).'">'; ?>
			<?php endif; ?>
			<?php echo $this->escape($this->item->section); ?>
			<?php if ($this->item->params->get('link_section')) : ?>
				<?php echo '</a>'; ?>
			<?php endif; ?>
			<?php if ($this->item->params->get('show_category')) : ?>
				<?php echo ' - '; ?>
			<?php endif; ?>
		</dd>
		<?php endif; ?>
		<?php if ($this->item->params->get('show_category') && $this->item->catid) : ?>
		<dd class="category-name">
			<?php if ($this->item->params->get('link_category')) : ?>
				<?php echo '<a href="'.JRoute::_(ContentHelperRoute::getCategoryRoute($this->item->catslug, $this->item->sectionid)).'">'; ?>
			<?php endif; ?>
			<?php echo $this->escape($this->item->category); ?>
			<?php if ($this->item->params->get('link_category')) : ?>
				<?php echo '</a>'; ?>
			<?php endif; ?>
		</dd>
		<?php endif; ?>
	<?php endif; ?>

</dl>

<?php if ($this->item->params->get('show_pdf_icon') || $this->item->params->get('show_print_icon') || $this->item->params->get('show_email_icon')) : ?>
<ul class="actions">
	<?php if ($this->item->params->get('show_email_icon')) : ?>
	<li class="email-icon">
	<?php echo JHTML::_('icon.email', $this->item, $this->item->params, $this->access, array('rel'=>'nofollow')); ?>
	</li>
	<?php endif; ?>

	<?php if ( $this->item->params->get( 'show_print_icon' )) : ?>
	<li class="print-icon">
	<?php echo JHTML::_('icon.print_popup', $this->item, $this->item->params, $this->access, array('rel'=>'nofollow')); ?>
	</li>
	<?php endif; ?>

	<?php if ($this->item->params->get('show_pdf_icon')) : ?>
	<li class="pdf-icon">
	<?php echo JHTML::_('icon.pdf', $this->item, $this->item->params, $this->access, array('rel'=>'nofollow')); ?>
	</li>
	<?php endif; ?>
</ul>
<?php endif; ?>

<?php if ($this->item->params->get('show_url') && $this->item->urls) : ?>
	<p class="article-url">
		<a href="http://<?php echo $this->escape($this->item->urls) ; ?>" target="_blank">
			<?php echo $this->escape($this->item->urls); ?>
		</a>
	</p>
<?php endif; ?>
</div>
<?php endif; ?>

<?php echo $this->item->event->beforeDisplayContent; ?>

<div class="article-content">
<?php if (isset ($this->item->toc)) : ?>
	<?php echo $this->item->toc; ?>
<?php endif; ?>
<?php echo $this->item->text; ?>
</div>

<?php if ( intval($this->item->modified) != 0 && $this->item->params->get('show_modify_date')) : ?>
	<p class="modifydate">
		<?php $modified = T3Hook::_('t3_date_format', array($this->item->modified, 'cat.blog.modified'));
		if (!$modified) $modified = JHTML::_('date', $this->item->modified, JText::_('DATE_FORMAT_LC2')); ?>
		<?php echo JText::sprintf('LAST_UPDATED2', $modified); ?>
	</p>
<?php endif; ?>

<?php if ($this->item->params->get('show_readmore') && $this->item->readmore) : ?>
	<p class="readmore">
		<a href="<?php echo $this->item->readmore_link; ?>" class="<?php echo $this->escape($this->item->params->get('pageclass_sfx')); ?>">
			<?php if ($this->item->readmore_register) :
				echo JText::_('Register to read more...');
			elseif ($readmore = $this->item->params->get('readmore')) :
				echo $readmore;
			else :
				echo JText::sprintf('Read more...');
			endif; ?></a>
	</p>
<?php endif; ?>

</div>

<?php echo $this->item->event->afterDisplayContent; ?>
