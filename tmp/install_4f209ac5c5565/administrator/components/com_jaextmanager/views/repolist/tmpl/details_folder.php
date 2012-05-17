<?php defined('_JEXEC') or die('Restricted access'); ?>
		<tr>
			<td class="imgTotal">
				<a href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=repolist&amp;tmpl=component&amp;folder=<?php echo $this->_tmp_folder->path_relative; ?>" target="folderframe">
					<img src="components/<?php echo JACOMPONENT; ?>/assets/images/icons/folder_sm.png" width="16" height="16" border="0" alt="<?php echo $this->_tmp_folder->name; ?>" /></a>
			</td>
			<td class="description">
				<a href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=repolist&amp;tmpl=component&amp;folder=<?php echo $this->_tmp_folder->path_relative; ?>" target="folderframe"><?php echo $this->_tmp_folder->name; ?></a>
			</td>
			<td>&nbsp;

			</td>
			<td>&nbsp;

			</td>
			<td>
				<a class="delete-item" href="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=folder&amp;task=delete&amp;tmpl=component&amp;folder=<?php echo $this->state->folder; ?>&amp;<?php echo JUtility::getToken(); ?>=1&amp;rm[]=<?php echo $this->_tmp_folder->name; ?>" rel="<?php echo $this->_tmp_folder->name; ?> :: <?php echo $this->_tmp_folder->files+$this->_tmp_folder->folders; ?>"><img src="components/<?php echo JACOMPONENT; ?>/assets/images/icons/remove.png" width="16" height="16" border="0" alt="<?php echo JText::_('DELETE' ); ?>" /></a>
				<input type="checkbox" name="rm[]" value="<?php echo $this->_tmp_folder->name; ?>" />
			</td>
		</tr>
