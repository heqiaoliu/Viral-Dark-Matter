<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// No direct access
defined('_JEXEC') or die;
?>
<?php
//$spotlight = array ('user1','user2','user3','user4','user5');
$spotlight = preg_split ('/,/', T3Common::node_data($block));
$name      = T3Common::node_attributes($block, 'name');
$special   = T3Common::node_attributes($block, 'special');

$specialwidth = T3Common::node_attributes($block, 'specialwidth');
$totalwidth   = T3Common::node_attributes($block, 'totalwidth', 100);

$style = $this->getBlockStyle ($block);
$botsl = $this->calSpotlight ($spotlight,$totalwidth, $specialwidth, $special);
if( $botsl ) :
?>

<!-- SPOTLIGHT -->
<?php foreach ($spotlight as $pos): ?>
<?php if( $this->countModules($pos) ): ?>
<div class="ja-box column ja-box<?php echo $botsl[$pos]['class']; ?>" style="width: <?php echo $botsl[$pos]['width']; ?>;">
    <jdoc:include type="modules" name="<?php echo $pos ?>" style="<?php echo $style ?>" />
</div>
<?php endif; ?>
<?php endforeach ?>
<!-- SPOTLIGHT -->

<script type="text/javascript">
    window.addEvent('load', function (){ equalHeight ('#ja-<?php echo $name ?> .ja-box') });
</script>
<?php endif; ?>