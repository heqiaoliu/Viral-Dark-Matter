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

<h4 class="poll-title"><?php echo $poll->title; ?></h4>
<form name="form2" method="post" action="index.php" class="poll">
	<fieldset>
		<?php for ($i = 0, $n = count($options); $i < $n; $i++) : ?>
		<input type="radio" name="voteid" id="voteid<?php echo $options[$i]->id; ?>" value="<?php echo $options[$i]->id; ?>" alt="<?php echo $options[$i]->id; ?>" />
		<label for="voteid<?php echo $options[$i]->id; ?>">
			<?php echo $options[$i]->text; ?>
		</label>
		<br />
		<?php endfor; ?>
	</fieldset>

	<input type="submit" name="task_button" class="button" value="<?php echo JText::_('Vote'); ?>" />
	<a href="<?php echo JRoute::_('index.php?option=com_poll&id='.$poll->slug.$itemid.'#content'); ?>" class="poll-result"><?php echo JText::_('Results'); ?></a>

	<input type="hidden" name="option" value="com_poll" />
	<input type="hidden" name="id" value="<?php echo $poll->id; ?>" />
	<input type="hidden" name="task" value="vote" />
	<?php echo JHTML::_( 'form.token' ); ?>
</form>
