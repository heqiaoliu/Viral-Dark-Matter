<?php
// no direct access
defined('_JEXEC') or die('Restricted access'); ?>

<?php
	//load mod_login language
	$lang =& JFactory::getLanguage();
	$lang->load( 'mod_login');
	//get user and detect if logged in
	$user = & JFactory::getUser();
	$type = (!$user->get('guest')) ? 'logout' : 'login';
	$uri = JFactory::getURI();
	$url = $uri->toString(array('path', 'query', 'fragment'));
	$return = base64_encode($url);
?>

<?php if($type == 'logout') : ?>
<form action="index.php" method="post" name="form-login" id="form-login">
	<?php echo JText::sprintf( 'HINAME', $user->get('name') ); ?>
	<div align="center">
		<input type="submit" name="Submit" class="button" value="<?php echo JText::_( 'BUTTON_LOGOUT'); ?>" />
	</div>

	<input type="hidden" name="option" value="com_user" />
	<input type="hidden" name="task" value="logout" />
	<input type="hidden" name="return" value="<?php echo $return; ?>" />
</form>
<?php else : ?>
<?php if(JPluginHelper::isEnabled('authentication', 'openid')) : ?>
	<?php JHTML::_('script', 'openid'); ?>
<?php endif; ?>
<form action="index.php" method="post" name="form-login" id="form-login" >
	<p id="form-login-username">
		<label for="username">
			<strong><?php echo JText::_('Username') ?></strong>
			<input name="username" id="username" type="text" class="inputbox" alt="username" size="18" />
		</label>
	</p>
	<p id="form-login-password">
		<label for="passwd">
			<strong><?php echo JText::_('Password') ?></strong>
			<input type="password" name="passwd" id="passwd" class="inputbox" size="18" alt="password" />
		</label>
	</p>
	
	<p id="form-login-submit" class="clearfix">
		<?php if(JPluginHelper::isEnabled('system', 'remember')) : ?>
		<label for="remember">
			<strong><?php echo JText::_('Remember me') ?></strong>
			<input type="checkbox" name="remember" id="remember" value="yes" alt="Remember Me" />
		</label>
		<?php endif; ?>
		<input type="submit" name="Submit" class="button" value="<?php echo JText::_('LOGIN') ?>" />
	</p>

	<ul>
		<li>
			<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=reset' ); ?>">
			<?php echo JText::_('FORGOT_YOUR_PASSWORD'); ?>
			</a>
		</li>
		<li>
			<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=remind' ); ?>">
			<?php echo JText::_('FORGOT_YOUR_USERNAME'); ?>
			</a>
		</li>
		<?php
		$usersConfig = &JComponentHelper::getParams( 'com_users' );
		if ($usersConfig->get('allowUserRegistration')) : ?>
		<li>
			<a href="<?php echo JRoute::_( 'index.php?option=com_user&view=register' ); ?>">
				<?php echo JText::_('REGISTER'); ?>
			</a>
		</li>
		<?php endif; ?>
	</ul>

	<input type="hidden" name="option" value="com_user" />
	<input type="hidden" name="task" value="login" />
	<input type="hidden" name="return" value="<?php echo $return; ?>" />
	<?php echo JHTML::_( 'form.token' ); ?>
</form>
<?php endif; ?>
