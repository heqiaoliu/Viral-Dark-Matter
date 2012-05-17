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
$positions = preg_split ('/,/', T3Common::node_data($block));
$parent = 'middle';
$style = $this->getBlockStyle ($block, $parent);
if (!$this->countModules (T3Common::node_data($block))) return;
?>
<?php $this->genMiddleBlockBegin ($block) ?>

<?php foreach ($positions as $position) : 
	if ($this->countModules($position)) : 
	?>
		<jdoc:include type="modules" name="<?php echo $position ?>" style="<?php echo $style ?>" />		
<?php endif; 
endforeach ?>

<?php $this->genMiddleBlockEnd ($block) ?>