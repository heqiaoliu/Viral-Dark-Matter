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
<?php
$modules = preg_split ('/,/', T3Common::node_data($block));
$parent = T3Common::node_attributes ($block, 'parent', 'middle');
$style = $this->getBlockStyle ($block, $parent);
if (!$this->countModules (T3Common::node_data($block))) return;
?>
<?php foreach ($modules as $module) : 
	if ($this->countModules($module)) : 
	?>
		<jdoc:include type="module" name="<?php echo $module ?>" style="<?php echo $style ?>" />		
<?php endif; 
endforeach ?>