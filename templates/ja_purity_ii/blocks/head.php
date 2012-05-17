<?php
/*
# ------------------------------------------------------------------------
# JA Purity II template for Joomla 1.6
# ------------------------------------------------------------------------
# Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
# @license - Copyrighted Commercial Software
# Author: J.O.O.M Solutions Co., Ltd
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# This file may not be redistributed in whole or significant part.
# ------------------------------------------------------------------------
*/
?>
<script type="text/javascript">
var siteurl='<?php echo JURI::base(true) ?>/';
var tmplurl='<?php echo JURI::base(true)."/templates/".T3_ACTIVE_TEMPLATE ?>/';
var isRTL = <?php echo $this->isRTL()?'true':'false' ?>;
</script>

<jdoc:include type="head" />

<?php if (T3Common::mobile_device_detect()=='iphone'):?>
<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1; user-scalable=1;" />
<meta name="apple-touch-fullscreen" content="YES" />
<?php endif;?>

<?php if (T3Common::mobile_device_detect()):?>
<meta name="HandheldFriendly" content="true" />
<?php endif;?>

<link href="<?php echo T3Path::getUrl('images/favicon.ico') ?>" rel="shortcut icon" type="image/x-icon" />

<?php JHTML::stylesheet ('', 'templates/system/css/system.css') ?>
<?php JHTML::stylesheet ('', 'templates/system/css/general.css') ?>

<!--[if IE 7.0]>
<style>
.clearfix { display: inline-block; } /* IE7xhtml*/
</style>
<![endif]-->

<script language="javascript" type="text/javascript">
var rightCollapseDefault='show';
var excludeModules='38';
</script>
<script language="javascript" type="text/javascript" src="<?php echo JURI::base(true) ?>/templates/<?php echo T3_ACTIVE_TEMPLATE ?>/js/ja.rightcol.js"></script>

<style type="text/css">
#ja-header .main {
	background-image: url(<?php echo T3Path::getUrl('/images/header/header'. rand(1,3).'.jpg'); ?>);
}
</style>