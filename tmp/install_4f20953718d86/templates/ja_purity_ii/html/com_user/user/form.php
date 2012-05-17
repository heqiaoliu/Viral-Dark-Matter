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
<?php if($this->params->get('show_page_title',1)) : ?>
<h1 class="componentheading<?php echo $this->escape($this->params->get('pageclass_sfx')) ?>">
	<?php echo $this->escape($this->params->get('page_title')) ?>
</h1>
<?php endif; ?>
<script type="text/javascript">
<!--
	Window.onDomReady(function(){
		document.formvalidator.setHandler('passverify', function (value) { return ($('password').value == value); }	);
	});
// -->
</script>

<form action="<?php echo JRoute::_( 'index.php' ); ?>" method="post" name="userform" autocomplete="off" class="user-details user">

	<p class="user_name">
		<label for="username"><?php echo JText::_( 'User Name' ); ?>: </label>
		<span><?php echo $this->escape($this->user->get('username')); ?></span>
	</p>

	<p class="name">
		<label for="name"><?php echo JText::_( 'Your Name' ); ?>: </label>
		<input class="inputbox" type="text" id="name" name="name" value="<?php echo $this->escape($this->user->get('name')); ?>" size="40" />
	</p>

	<p class="email">
		<label for="email"><?php echo JText::_( 'email' ); ?>: </label>
		<input class="inputbox required validate-email" type="text" id="email" name="email" value="<?php echo $this->escape($this->user->get('email'));?>" size="40" />
	</p>

	<?php if($this->user->get('password')) : ?>
	<p class="pass">
		<label for="password"><?php echo JText::_( 'Password' ); ?>: </label>
		<input class="inputbox validate-password" type="password" id="password" name="password" value="" size="40" />
	</p>

	<p class="verify_pass">
		<label for="verifyPass"><?php echo JText::_( 'Verify Password' ); ?>: </label>
		<input class="inputbox validate-passverify" type="password" id="password2" name="password2" size="40" />
	</p>
	<?php endif; ?>

	<?php if(isset($this->params)) :
		echo $this->params->render( 'params' );
	endif; ?>

	<button class="button validate" type="submit" onclick="submitbutton( this.form );return false;"><?php echo JText::_( 'Save' ); ?></button>

	<input type="hidden" name="username" value="<?php echo $this->escape($this->user->get('username'));?>" />
	<input type="hidden" name="id" value="<?php echo (int)$this->user->get('id');?>" />
	<input type="hidden" name="gid" value="<?php echo (int)$this->user->get('gid');?>" />
	<input type="hidden" name="option" value="com_user" />
	<input type="hidden" name="task" value="save" />
	<?php echo JHTML::_( 'form.token' ); ?>

</form>
