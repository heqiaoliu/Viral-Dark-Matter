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


// no direct access
defined( '_JEXEC' ) or die( 'Restricted access' );
$positions = array (
	'content-top'			=>'',
	'content-bottom'		=>'content-bot',
);

$this->_basewidth = 20;
$this->definePosition ($positions);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $this->language; ?>" lang="<?php echo $this->language; ?>">

<head>
<?php $this->loadBlock('iphone/head') ?>
</head>

<body id="bd" onload="updateOrientation()" onorientationchange="updateOrientation()">

<div id="ja-wrapper">
	<a name="Top" id="Top"></a>
	
	<!-- NAV -->
	<?php $this->loadBlock('iphone/mainnav') ?>
	<!-- //NAV -->

	<!-- HEADER -->
	<?php $this->loadBlock('handheld/header') ?>
	<!-- //HEADER -->

	<!-- CONTENT -->
	<?php $this->loadBlock('handheld/main') ?>
	<!-- //CONTENT -->

	<!-- FOOTER -->
	<?php $this->loadBlock('handheld/footer') ?>
	<!-- //FOOTER -->

</div>

<jdoc:include type="modules" name="debug" />

</body>

</html>
