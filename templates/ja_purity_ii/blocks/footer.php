<?php
/*
# ------------------------------------------------------------------------
# JA T3 System plugin for Joomla 1.6
# ------------------------------------------------------------------------
# Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
# @license - Copyrighted Commercial Software
# Author: J.O.O.M Solutions Co., Ltd
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# This file may not be redistributed in whole or significant part.
# ------------------------------------------------------------------------
*/
?>
<?php if($this->countModules('footnav')) : ?>
<div class="ja-footnav">
	<jdoc:include type="modules" name="footnav" />
</div>
<?php endif; ?>
<?php 
$t3_logo = $this->getParam ('setting_t3logo', 't3-logo-light', 't3-logo-dark');
if ($t3_logo != 'none') : ?>
<div id="ja-poweredby" class="<?php echo $t3_logo ?>">
	<a href="http://t3.joomlart.com" title="Powered By T3 Framework" target="_blank">Powered By T3 Framework</a>
</div>  	
<?php endif; ?>
<div class="ja-copyright">
	<jdoc:include type="modules" name="footer" />
</div>

