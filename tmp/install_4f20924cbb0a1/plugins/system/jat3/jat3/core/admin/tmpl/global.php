<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */
	defined('_JEXEC') or die;
	
	
	
	foreach ($fieldSets as $name => $fieldSet) :?>		
		<fieldset class="panelform">
			<table width="100%" cellspacing="1" class="paramlist admintable">
				<tbody>
					
					<?php foreach ($configform->getFieldset($name) as $field) : ?>
						<tr>
							<?php if($field->label!=''){?>
							<td width="40%" class="paramlist_key">
								<?php echo $field->label; ?>
							</td>
							<?php }?>
							<td class="paramlist_value" <?php if($field->label==''){?> colspan="2" <?php }?>>
								<?php echo $field->input; ?>
							</td>
						</tr>
					<?php endforeach; ?>
					
				</tbody>
			</table>
		</fieldset>
	<?php endforeach;  ?>