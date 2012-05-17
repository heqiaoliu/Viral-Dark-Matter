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
<div class="ja-navhelper clearfix">
    <div class="ja-breadcrums clearfix">
        <jdoc:include type="module" name="breadcrumbs" />
    </div>
    <div class="ja-links clearfix">
        <?php $this->showBlock('usertools/layout-switcher') ?>
        <a href="javascript:scroll(0,0)" title="Back to Top"><strong>Top</strong></a>
    </div>
</div>

<div class="ja-copyright">
    <jdoc:include type="modules" name="footer" />
</div>