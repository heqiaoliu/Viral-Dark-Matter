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
$cparams = JComponentHelper::getParams ('com_media');
?>

<?php if ($this->params->get('show_page_title',1) && $this->params->get('page_title') != $this->contact->name) : ?>
<h1 class="componentheading<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>">
	<?php echo $this->escape($this->params->get('page_title')); ?>
</h1>
<?php endif; ?>

<div id="component-contact" class="contact<?php echo $this->escape($this->params->get('pageclass_sfx')); ?>">
	<?php if ($this->params->get('show_contact_list') && count($this->contacts) > 1) : ?>
	<form method="post" name="selectForm" id="selectForm">
		<?php echo JText::_('Select Contact'); ?>
		<?php echo JHTML::_('select.genericlist', $this->contacts, 'contact_id', 'class="inputbox" onchange="this.form.submit()"', 'id', 'name', $this->contact->id); ?>
		<input type="hidden" name="option" value="com_contact" />
	</form>
	<br />
	<?php endif; ?>
	
	<?php if ($this->contact->image && $this->contact->params->get('show_image')) : ?>
		<?php echo JHTML::_('image', 'images/stories' . '/'.$this->escape($this->contact->image), JText::_( 'Contact' ), array('align' => 'right')); ?>
	<?php endif; ?>

	<?php if ($this->contact->name && $this->contact->params->get('show_name')) : ?>
	<h2 class="contact-name contentheading">
		<?php echo $this->escape($this->contact->name); ?>
	</h2>
	<?php endif; ?>

	<?php if ($this->contact->con_position && $this->contact->params->get('show_position')) : ?>
	<span class="contact-position">
		<?php echo $this->escape($this->contact->con_position); ?>
	</span>
	<?php endif; ?>

	<?php echo $this->loadTemplate('address'); ?>

	<?php if ( $this->contact->params->get('allow_vcard')) : ?>
	<p>
		<?php echo JText::_('Download information as a'); ?>
		<a href="index.php?option=com_contact&amp;task=vcard&amp;contact_id=<?php echo (int)$this->contact->id; ?>&amp;format=raw">
			<?php echo JText::_('VCard'); ?></a>
	</p>
	<?php endif; ?>

	<?php if ($this->contact->params->get('show_email_form')) :
		echo $this->loadTemplate('form');
	endif; ?>
</div>
