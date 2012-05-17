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
$this->_basewidth = 20;
$positions = array (
	'left1'					=>'left',
	'left2'					=>'right',
	'left-mass-top'			=>'',
	'left-mass-bottom'		=>'',
	'right1'				=>'',
	'right2'				=>'',
	'right-mass-top'		=>'',
	'right-mass-bottom'		=>'',
	'content-mass-top'		=>'top',
	'content-mass-bottom'	=>'',
	'content-top'			=>'',
	'content-bottom'		=>'',
	'inset1'				=>'',
	'inset2'				=>''
);

//$this->customwidth('right1', 25); <== override right1 column width to 25%. Must call before call definePosition. Can call many time to override many columns.
$this->definePosition ($positions);
?>

<?php if ($this->isIE() && ($this->getParam('direction')=='rtl' || $this->direction == 'rtl')) { ?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<?php } else { ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<?php } ?>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $this->language; ?>" lang="<?php echo $this->language; ?>">

<head>
<?php $this->loadBlock('head') ?>
</head>

<body id="bd" class="fs<?php echo $this->getParam(JA_TOOL_FONT);?> <?php echo $this->browser();?>">

<div id="ja-wrapper">
	<a name="Top" id="Top"></a>

	<!-- HEADER -->
	<?php $this->loadBlock('header') ?>
	<!-- //HEADER -->

	<!-- MAIN NAVIGATION -->
	<?php $this->loadBlock('mainnav') ?>
	<!-- //MAIN NAVIGATION -->
	
	<?php $this->loadBlock('topsl') ?>

	<!-- MAIN CONTAINER -->
	<div id="ja-container" class="wrap <?php echo $this->getColumnWidth('cls_w'); ?>">
	<div class="main clearfix">

		<div id="ja-mainbody" style="width:<?php echo $this->getColumnWidth('mw') ?>%">
			<?php $this->loadBlock('main') ?>
			<?php $this->loadBlock('left') ?>
		</div>

		<?php $this->loadBlock('right-xhtml') ?>

	</div>
	</div>
	<!-- //MAIN CONTAINER -->

	<?php $this->loadBlock('botsl') ?>

	<!-- FOOTER -->
	<?php $this->loadBlock('footer') ?>
	<!-- //FOOTER -->

</div>

<jdoc:include type="modules" name="debug" />

<?php if ($this->isIE6()) : ?>
	<?php $this->loadBlock('ie6/ie6warning') ?>
<?php endif; ?>

</body>

</html>
