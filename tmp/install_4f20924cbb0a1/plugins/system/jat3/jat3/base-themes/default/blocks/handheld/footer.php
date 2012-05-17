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
	<div class="ja-navhelper clearfix">
		<div class="ja-breadcrums clearfix">
			<jdoc:include type="module" name="breadcrumbs" /> 
		</div>
		<div class="ja-links clearfix">
			<?php $this->showBlock('usertools/layout-switcher') ?>
			<a href="<?php echo $this->getCurrentURL();?>#Top" title="Back to Top"><strong>Top</strong></a>
		</div>
	</div>

	<div class="ja-copyright">
		<jdoc:include type="modules" name="footer" />
	</div>