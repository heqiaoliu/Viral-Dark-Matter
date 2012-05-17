<?php
/**
 * @version		$Id: details_img.php 15706 2010-03-30 05:20:06Z infograf768 $
 * @package		Joomla.Administrator
 * @subpackage	com_media
 * @copyright	Copyright (C) 2005 - 2010 Open Source Matters, Inc. All rights reserved.
 * @license		GNU General Public License version 2 or later; see LICENSE.txt
 */

// No direct access.
defined('_JEXEC') or die;
?>
		<tr>
			<td>
				<a>
					<img src="<?php echo $this->_tmp_img->icon_16; ?>" width="16" height="16" border="0" alt="<?php echo $this->_tmp_img->name; ?>" />
                </a>
			</td>
			<td class="description">
				<a href="#" title="<?php echo $this->_tmp_img->name; ?>" rel="preview"><?php echo $this->escape( $this->_tmp_img->name); ?></a>
			</td>
			<td>
				<?php echo $this->_tmp_img->width; ?> x <?php echo $this->_tmp_img->height; ?>
			</td>
			<td>
				<?php echo RepoHelper::parseSize($this->_tmp_img->size); ?>
			</td>
			<td>
				<a class="delete-item" href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=file&amp;task=delete&amp;tmpl=component&amp;<?php echo JUtility::getToken(); ?>=1&amp;folder=<?php echo $this->state->folder; ?>&amp;rm[]=<?php echo $this->_tmp_img->name; ?>" rel="<?php echo $this->_tmp_img->name; ?>">
                <img src="components/<?php echo JACOMPONENT; ?>/assets/images/icons/remove.png" width="16" height="16" border="0" alt="<?php echo JText::_('DELETE' ); ?>" />
                </a>
				<input type="checkbox" name="rm[]" value="<?php echo $this->_tmp_img->name; ?>" />
			</td>
		</tr>
