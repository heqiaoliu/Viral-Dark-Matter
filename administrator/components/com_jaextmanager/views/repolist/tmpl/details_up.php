<?php
/**
 * @version		$Id: details_up.php 17769 2010-06-20 01:50:48Z dextercowley $
 * @package		Joomla.Administrator
 * @subpackage	com_media
 * @copyright	Copyright (C) 2005 - 2010 Open Source Matters, Inc. All rights reserved.
 * @license		GNU General Public License version 2 or later; see LICENSE.txt
 */

// No direct access.
defined('_JEXEC') or die;
?>
		<tr>
			<td class="imgTotal">
				<a href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=repolist&amp;tmpl=component&amp;folder=<?php echo $this->state->parent; ?>" target="folderframe">
					<img src="components/<?php echo JACOMPONENT; ?>/assets/images/icons/folderup_16.png" width="16" height="16" border="0" alt=".." /></a>
			</td>
			<td class="description">
				<a href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=repolist&amp;tmpl=component&amp;folder=<?php echo $this->state->parent; ?>" target="folderframe">..</a>
			</td>
			<td>&#160;</td>
			<td>&#160;</td>
			<td>&#160;</td>
		</tr>
