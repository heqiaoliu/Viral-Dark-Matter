<?php


defined( '_JEXEC' ) or die( 'Restricted access' );
?>
<form action="<?php echo JRoute::_( 'index.php', true, $this->params->get('usesecure')); ?>" method="post" name="login" id="login" class="login_form<?php echo $this->params->get( 'pageclass_sfx' ); ?>">
	<?php if ( $this->params->get( 'show_login_title' ) ) : ?>
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

	<input type="submit" name="submit" class="button" value="<?php echo JText::_( 'Login' ); ?>" />
	<noscript><?php echo JText::_( 'WARNJAVASCRIPT' ); ?></noscript>
	<input type="hidden" name="option" value="com_user" />
	<input type="hidden" name="task" value="login" />
	<input type="hidden" name="return" value="<?php echo $this->return; ?>" />
	<?php echo JHTML::_( 'form.token' ); ?>
	
<p>
		<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=reset' ); ?>">
		<?php echo JText::_('FORGOT_YOUR_PASSWORD'); ?></a>&nbsp;&nbsp;|&nbsp;&nbsp;

		<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=remind' ); ?>">
		<?php echo JText::_('FORGOT_YOUR_USERNAME'); ?></a>&nbsp;&nbsp;|&nbsp;&nbsp;

	<?php
	$usersConfig = &JComponentHelper::getParams( 'com_users' );
	if ($usersConfig->get('allowUserRegistration')) : ?>
		<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=register' ); ?>">
			<?php echo JText::_('REGISTER'); ?></a>
	<?php endif; ?>
</p>
	
</form>
