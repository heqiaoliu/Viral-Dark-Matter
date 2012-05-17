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