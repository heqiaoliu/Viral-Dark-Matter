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
<div class="ja-copyright">
	<jdoc:include type="modules" name="footer" />
</div>

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
