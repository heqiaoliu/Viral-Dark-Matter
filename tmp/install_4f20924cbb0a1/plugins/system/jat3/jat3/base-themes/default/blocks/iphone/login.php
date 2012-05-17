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
<form action="<?php echo JRoute::_('index.php', true); ?>" method="post" id="login-form">
	<?php echo JText::sprintf( 'MOD_LOGIN_HINAME', $user->get('name') ); ?>
	<div align="center">
		<input type="submit" name="Submit" class="button" value="<?php echo JText::_( 'JLOGOUT'); ?>" />
	</div>
	<input type="hidden" name="option" value="com_users" />
	<input type="hidden" name="task" value="user.logout" />
	<input type="hidden" name="return" value="<?php echo $return; ?>" />
</form>
<?php else : ?>
<form action="<?php echo JRoute::_('index.php', true); ?>" method="post" id="login-form" >
	<p id="form-login-username">
		<label for="modlgn-username"><strong><?php echo JText::_('MOD_LOGIN_VALUE_USERNAME') ?></strong></label>
		<input id="modlgn-username" type="text" name="username" class="inputbox"  size="18" />
	</p>
	<p id="form-login-password">
		<label for="modlgn-passwd"><strong><?php echo JText::_('JGLOBAL_PASSWORD') ?></strong></label>
		<input id="modlgn-passwd" type="password" name="password" class="inputbox" size="18"  />
	</p>
	
	<p id="form-login-submit" class="clearfix">
		<?php if (JPluginHelper::isEnabled('system', 'remember')) : ?>
		<label for="modlgn-remember"><?php echo JText::_('MOD_LOGIN_REMEMBER_ME') ?></label>
		<input id="modlgn-remember" type="checkbox" name="remember" class="inputbox" value="yes"/>
		<?php endif; ?>
		<input type="submit" name="Submit" class="button" value="<?php echo JText::_('JLOGIN') ?>" />
		<input type="hidden" name="option" value="com_users" />
		<input type="hidden" name="task" value="user.login" />
		<input type="hidden" name="return" value="<?php echo $return; ?>" />		
		<?php echo JHtml::_('form.token'); ?>
	</p>
	<ul>
		<li>
			<a href="<?php echo JRoute::_('index.php?option=com_users&view=reset'); ?>">
			<?php echo JText::_('MOD_LOGIN_FORGOT_YOUR_PASSWORD'); ?></a>
		</li>
		<li>
			<a href="<?php echo JRoute::_('index.php?option=com_users&view=remind'); ?>">
			<?php echo JText::_('MOD_LOGIN_FORGOT_YOUR_USERNAME'); ?></a>
		</li>
		<?php
		$usersConfig = JComponentHelper::getParams('com_users');
		if ($usersConfig->get('allowUserRegistration')) : ?>
		<li>
			<a href="<?php echo JRoute::_('index.php?option=com_users&view=registration'); ?>">
				<?php echo JText::_('MOD_LOGIN_REGISTER'); ?></a>
		</li>
		<?php endif; ?>
	</ul>
</form>
<?php endif; ?>
