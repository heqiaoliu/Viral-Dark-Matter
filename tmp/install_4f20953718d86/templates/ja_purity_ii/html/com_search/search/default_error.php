<?php
/*
#------------------------------------------------------------------------
  JA Purity II for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/


defined('_JEXEC') or die('Restricted access');
?>

<h2 class="error<?php $this->escape($this->params->get( 'pageclass_sfx' )) ?>">
	<?php echo JText::_('Error') ?>
</h2>
<div class="error<?php echo $this->escape($this->params->get( 'pageclass_sfx' )) ?>">
	<p><?php echo $this->escape($this->error); ?></p>
</div>
