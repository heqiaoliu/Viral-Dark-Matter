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


defined( '_JEXEC' ) or die( 'Restricted access' );
?>
<form action="<?php echo JRoute::_( 'index.php', true, $this->params->get('usesecure')); ?>" method="post" name="login" id="login" class="login_form<?php echo $this->params->get( 'pageclass_sfx' ); ?>">
	<?php if ( $this->params->get( 'page_title' ) ) : ?>
	<h1 class="componentheading<?php echo $this->params->get( 'pageclass_sfx' ); ?>">
		<?php echo $this->params->get( 'header_login' ); ?>
	</h1>
	<?php endif; ?>

	<?php if ( $this->params->get( 'description_login' ) || isset( $this->image ) ) : ?>
		<div class="contentdescription<?php echo $this->params->get( 'pageclass_sfx' );?> clearfix">
			<?php if (isset ($this->image)) :
				echo $this->image;
			endif;
			if ($this->params->get('description_login')) : ?>
			<p>
				<?php echo $this->params->get('description_login_text'); ?>
			</p>
			<?php endif;
			if (isset ($this->image)) : ?>
			<div class="wrap_image">&nbsp;</div>
			<?php endif; ?>
		</div>
	<?php endif; ?>
	<fieldset>
		<p class="name">
			<label for="user" ><?php echo JText::_( 'Username' ); ?></label>
			<input name="username" type="text" class="inputbox" size="20"  id="user" />
		</p>
		<p class="pass">
			<label for="pass" ><?php echo JText::_( 'Password' ); ?></label>
			<input name="passwd" type="password" class="inputbox" size="20" id="pass" />
		</p>
		<p class="remember">
			<label for="rem"><?php echo JText::_( 'Remember me' ); ?></label>
			<input type="checkbox" name="remember" class="inputbox" value="yes" id="rem" />
		</p>
	</fieldset>

	<input type="submit" name="submit" class="button" value="<?php echo JText::_( 'Login' ); ?>" />
	<noscript><?php echo JText::_( 'WARNJAVASCRIPT' ); ?></noscript>
	<input type="hidden" name="option" value="com_user" />
	<input type="hidden" name="task" value="login" />
	<input type="hidden" name="return" value="<?php echo $this->return; ?>" />
	<?php echo JHTML::_( 'form.token' ); ?>
	
	<p>
		<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=reset#content' ); ?>">
			<?php echo JText::_('Lost Password?'); ?></a>
		<?php if ( $this->params->get( 'registration' ) ) : ?>
		<?php echo JText::_('No account yet?'); ?>
		<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=register#content' ); ?>">
			<?php echo JText::_( 'Register' ); ?></a>
		<?php endif; ?>
	</p>
	
</form>
