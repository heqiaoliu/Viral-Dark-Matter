<?php
/**
 * @version		$Id: details_doc.php 17769 2010-06-20 01:50:48Z dextercowley $
 * @package		Joomla.Administrator
 * @subpackage	com_media
 * @copyright	Copyright (C) 2005 - 2010 Open Source Matters, Inc. All rights reserved.
 * @license		GNU General Public License version 2 or later; see LICENSE.txt
 */

// No direct access.
defined('_JEXEC') or die;
?>
		<tr>
			<td><img src="<?php echo $this->_tmp_doc->icon_16; ?>" width="16" height="16" border="0" alt="<?php echo $this->_tmp_doc->name; ?>" />
			</td>
			<td class="description">
            <?php if($this->_tmp_doc->ext == 'zip'): ?>
            <a class="download-item" href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=file&amp;task=download&amp;tmpl=component&amp;<?php echo JUtility::getToken(); ?>=1&amp;folder=<?php echo $this->state->folder; ?>&amp;rm[]=<?php echo $this->_tmp_doc->name; ?>" rel="<?php echo $this->_tmp_doc->name; ?>">
            <?php endif; ?>
				<?php echo $this->_tmp_doc->name; ?>
            <?php if($this->_tmp_doc->ext == 'zip'): ?>
            </a>
            <?php endif; ?>
			</td>
			<td>&nbsp;

			</td>
			<td>
				<?php echo RepoHelper::parseSize($this->_tmp_doc->size); ?>
			</td>
			<td>
				<a class="delete-item" href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=file&amp;task=delete&amp;tmpl=component&amp;<?php echo JUtility::getToken(); ?>=1&amp;folder=<?php echo $this->state->folder; ?>&amp;rm[]=<?php echo $this->_tmp_doc->name; ?>" rel="<?php echo $this->_tmp_doc->name; ?>"><img src="components/<?php echo JACOMPONENT; ?>/assets/images/icons/remove.png" width="16" height="16" border="0" alt="<?php echo JText::_('DELETE' ); ?>" /></a>
				<input type="checkbox" name="rm[]" value="<?php echo $this->_tmp_doc->name; ?>" />
			</td>
		</tr>
