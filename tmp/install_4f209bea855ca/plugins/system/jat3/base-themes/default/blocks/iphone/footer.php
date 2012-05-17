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
	<div class="ja-navhelper clearfix">
		<div class="ja-breadcrums clearfix">
			<strong>You are here:</strong> <jdoc:include type="module" name="breadcrumbs" /> 
		</div>
		<div class="ja-links clearfix">
			<?php $this->showBlock('usertools/layout-switcher') ?>
			<a href="<?php echo $this->getCurrentURL();?>#Top" title="Back to Top"><strong>Top</strong></a>
		</div>
	</div>

	<div class="ja-copyright">
		<jdoc:include type="modules" name="footer" />
	</div>