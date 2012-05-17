<?php
/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// no direct access
defined('_JEXEC') or die('Restricted access');
?>
<table width="100%" class="ja-help-support">
	<tr  class="level2">
		<td>
			<h4 id="ja-head-version" class="block-head block-head-logosetting open" rel="2">
				<span class="block-setting"><?php echo JText::_('Update & Version information')?></span> 
				<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Update & Version information desc')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
				<a onclick="showHideRegion('ja-head-version', 'level2'); return false;"  title="<?php echo JText::_('Click here to expand or collapse')?>" class="toggle-btn">open</a>
			 </h4>
		</td>
	</tr>
	<tr  class="level3">
		<td>
			<br/>
			<span class="version-title"><?php echo JText::_('Version')?>:</span> <span class="version-current"><?php echo $version?></span>
			<div class="help-support-content">
				<?php if($obj->checkexistExtensinsManagement()){?>
					<?php echo JText::_('EXTENSION MANAGEMENT HAS INSTALLED')?>
				<?php }else{?>
					<?php echo JText::_('EXTENSION MANAGEMENT DOES NOT EXIST')?>
				<?php }?>
			</div>
			<br/>
			<br/>
		</td>
	</tr>
	
	<tr  class="level2">
		<td>
			<h4 id="ja-head-help-support" class="block-head block-head-logosetting open" rel="2">
				<span class="block-setting"><?php echo JText::_('Help and Support')?></span> 
				<span class="icon-help editlinktip hasTip" title="<?php echo JText::_('Help and Support desc')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
				<a onclick="showHideRegion('ja-head-help-support', 'level2'); return false;" title="<?php echo JText::_('Click here to expand or collapse')?>"  class="toggle-btn">open</a>
			 </h4>
		</td>
	</tr>
	<tr  class="level3">
		<td>
			<?php echo JText::_('help and support details')?>
			</td>
		</tr>
	</table>	