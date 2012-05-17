<?php
/**
 * @version		$Id: default_navigation.php 18340 2010-08-06 06:48:12Z infograf768 $
 * @package		Joomla.Administrator
 * @subpackage	com_media
 * @copyright	Copyright (C) 2005 - 2010 Open Source Matters, Inc. All rights reserved.
 * @license		GNU General Public License version 2 or later; see LICENSE.txt
 */

// No direct access
defined('_JEXEC') or die;
$app	= JFactory::getApplication();
//$style = $app->getUserStateFromRequest('media.list.layout', 'layout', 'details', 'word');
$style = "details";
?>
<div id="submenu-box">
	<div class="t">
		<div class="t">
			<div class="t"></div>
		</div>
	</div>
	<div class="m">
		<div class="submenu-box">
			<div class="submenu-pad">
				<ul id="submenu" class="media">
					<li><a title="" href="index.php?option=<?php echo JACOMPONENT; ?>&extionsion_type=&search="> <?php echo JText::_("EXTENSIONS_MANAGER"); ?></a></li>
					<li><a title="" href="index.php?option=<?php echo JACOMPONENT; ?>&view=services"> <?php echo JText::_("SERVICES_MANAGER"); ?></a></li>
					<li><a title="" class="active" href="index.php?option=<?php echo JACOMPONENT; ?>&view=repo"> <?php echo JText::_("REPOSITORY_MANAGER"); ?></a></li>
					<li><a title="" href="index.php?option=<?php echo JACOMPONENT; ?>&view=default&layout=config_service"> <?php echo JText::_("CONFIGURATIONS"); ?></a></li>
					<li><a title="" href="index.php?option=<?php echo JACOMPONENT; ?>&view=default&layout=help_support"> <?php echo JText::_("HELP_AND_SUPPORT"); ?></a></li>
				</ul>
				<div class="clr"></div>
			</div>
		</div>
		<div class="clr"></div>
	</div>
	<div class="b">
		<div class="b">
			<div class="b"></div>
		</div>
	</div>
</div>