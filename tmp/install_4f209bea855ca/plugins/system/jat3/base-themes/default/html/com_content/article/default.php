<?php


// no direct access
defined('_JEXEC') or die('Restricted access'); ?>

<div class="item-page<?php echo $this->escape($this->params->get( 'pageclass_sfx' )); ?>">
<?php if ($this->params->get('show_page_title', 1) && $this->params->get('page_title') != $this->article->title) : ?>
<div class="componentheading<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>"><?php echo $this->escape($this->params->get('page_title')); ?></div>
<?php endif; ?>

<?php if (($this->user->authorize('com_content', 'edit', 'content', 'all') || $this->user->authorize('com_content', 'edit', 'content', 'own')) && !$this->print) : ?>
<div class="contentpaneopen_edit<?php echo $this->escape($this->params->get( 'pageclass_sfx' )); ?>" >
	<?php echo JHTML::_('icon.edit', $this->article, $this->params, $this->access, array('rel'=>'nofollow')); ?>
</div>
<?php endif; ?>

<?php if ($this->params->get('show_title',1)) : ?>
<h1 class="contentheading clearfix">
	<?php if ($this->params->get('link_titles') && $this->article->readmore_link != '') : ?>
	<a href="<?php echo $this->article->readmore_link; ?>" class="contentpagetitle<?php echo $this->escape($this->params->get( 'pageclass_sfx' )); ?>">
		<?php echo $this->escape(isset($this->article->page_title)?$this->article->page_title:$this->article->title); ?>
	</a>
	<?php else : ?>
		<?php echo $this->escape(isset($this->article->page_title)?$this->article->page_title:$this->article->title); ?>
	<?php endif; ?>
</h1>
<?php endif; ?>

<?php  if (!$this->params->get('show_intro')) :
	echo $this->article->event->afterDisplayTitle;
endif; ?>

<?php
if (
($this->params->get('show_create_date'))
|| (($this->params->get('show_author')) && ($this->article->author != ""))
|| (($this->params->get('show_section') && $this->article->sectionid) || ($this->params->get('show_category') && $this->article->catid))
|| ($this->params->get('show_pdf_icon') || $this->params->get('show_print_icon') || $this->params->get('show_email_icon'))
|| ($this->params->get('show_url') && $this->article->urls)
) :
?>
<div class="article-tools clearfix">
	<dl class="article-info clearfix">
	<?php if ($this->params->get('show_create_date')) : ?>
		<dd class="create">
			<?php $created = T3Hook::_('t3_date_format', array($this->article->created, 'article.created'));
			if (!$created) $created = JHTML::_('date', $this->article->created, JText::_('DATE_FORMAT_LC2')) ?>
			<?php echo $created ?>
		</dd>
	<?php endif; ?>

	<?php if (($this->params->get('show_author')) && ($this->article->author != "")) : ?>
		<dd class="createdby">
			<?php $this->escape(JText::printf(($this->escape($this->article->created_by_alias) ? $this->escape($this->article->created_by_alias) : $this->escape($this->article->author)) )); ?>
		</dd>
	<?php endif; ?>
	
	<?php if ($this->params->get('show_hits')) : ?>
	<dd class="hits">        
		<?php echo JText::_('Hits'); ?>: <?php echo $this->article->hits; ?>
	</dd>
	<?php endif; ?>

	<?php if (($this->params->get('show_section') && $this->article->sectionid) || ($this->params->get('show_category') && $this->article->catid)) : ?>
		<?php if ($this->params->get('show_section') && $this->article->sectionid && isset($this->article->section)) : ?>
		<dd class="parent-category-name">
		<strong><?php echo JText::_('SECTION'); ?>: </strong>
			<?php if ($this->params->get('link_section')) : ?>
				<?php echo '<a href="'.JRoute::_(ContentHelperRoute::getSectionRoute($this->article->sectionid)).'">'; ?>
			<?php endif; ?>
			<?php echo $this->escape($this->article->section); ?>
			<?php if ($this->params->get('link_section')) : ?>
				<?php echo '</a>'; ?>
			<?php endif; ?>
				<?php if ($this->params->get('show_category')) : ?>
				<?php echo ' - '; ?>
			<?php endif; ?>
		</dd>
		<?php endif; ?>
		<?php if ($this->params->get('show_category') && $this->article->catid) : ?>
		<dd class="category-name">
			<?php if ($this->params->get('link_category')) : ?>
				<?php echo '<a href="'.JRoute::_(ContentHelperRoute::getCategoryRoute($this->article->catslug, $this->article->sectionid)).'">'; ?>
			<?php endif; ?>
			<?php echo $this->escape($this->article->category); ?>
			<?php if ($this->params->get('link_category')) : ?>
				<?php echo '</a>'; ?>
			<?php endif; ?>
		</dd>
		<?php endif; ?>
	<?php endif; ?>
	
	</dl>
	
	<?php if ($this->params->get('show_pdf_icon') || $this->params->get('show_print_icon') || $this->params->get('show_email_icon')) : ?>
	<ul class="actions">
		<?php if (!$this->print) : ?>
			<?php if ($this->params->get('show_email_icon')) : ?>
			<li class="email-icon">
			<?php echo JHTML::_('icon.email',  $this->article, $this->params, $this->access, array('rel'=>'nofollow')); ?>
			</li>
			<?php endif; ?>

			<?php if ( $this->params->get( 'show_print_icon' )) : ?>
			<li class="print-icon">
			<?php echo JHTML::_('icon.print_popup',  $this->article, $this->params, $this->access, array('rel'=>'nofollow')); ?>
			</li>
			<?php endif; ?>

			<?php if ($this->params->get('show_pdf_icon')) : ?>
			<li>
			<?php echo JHTML::_('icon.pdf',  $this->article, $this->params, $this->access, array('rel'=>'nofollow')); ?>
			</li>
			<?php endif; ?>
		<?php else : ?>
			<li>
			<?php echo JHTML::_('icon.print_screen',  $this->article, $this->params, $this->access, array('rel'=>'nofollow')); ?>
			</li>
		<?php endif; ?>
	</ul>
	<?php endif; ?>
	
</div>
<?php endif; ?>

<?php echo $this->article->event->beforeDisplayContent; ?>

<div class="article-content">
<?php if (isset ($this->article->toc)) : ?>
	<?php echo $this->article->toc; ?>
<?php endif; ?>
<?php echo $this->article->text; ?>
</div>

<?php if ( intval($this->article->modified) !=0 && $this->params->get('show_modify_date')) : ?>
	<p class="modifydate">
		<?php $modified = T3Hook::_('t3_date_format', array($this->article->modified, 'article.modified'));
		if (!$modified) $modified = JHTML::_('date', $this->article->modified, JText::_('DATE_FORMAT_LC2')); ?>	
		<?php echo JText::sprintf('LAST_UPDATED2', $modified); ?>
	</p>
<?php endif; ?>

<?php if ($this->params->get('show_url') && $this->article->urls) : ?>
	<p class="article-url">
		<a href="http://<?php echo $this->escape($this->article->urls) ; ?>" target="_blank">
			<?php echo $this->escape($this->article->urls); ?></a>
	</p>
<?php endif; ?>

<?php echo $this->article->event->afterDisplayContent; ?>
</div>
