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
include_once (dirname(__FILE__).DS.'libs'.DS.'ja.template.helper.php');
$tmplTools = JATemplateHelper::getInstance($this, array('ui', JA_TOOL_SCREEN, JA_TOOL_MENU, 'main_layout', 'direction'));
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $this->language; ?>" lang="<?php echo $this->language; ?>" dir="<?php echo $this->direction; ?>">

<head>

<jdoc:include type="head" />
<link rel="stylesheet" href="<?php echo $tmplTools->templateurl(); ?>/css/addons.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $tmplTools->templateurl(); ?>/css/template.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $tmplTools->templateurl(); ?>/css/print.css" type="text/css" />

<?php if($tmplTools->getParam('direction')=='rtl' || $this->direction == 'rtl') : ?>
<link href="<?php echo $tmplTools->templateurl(); ?>/css/template_rtl.css" rel="stylesheet" type="text/css" />
<!--[if lt IE 8.0]>
<link rel="stylesheet" href="<?php echo $tmplTools->templateurl(); ?>/css/ie-rtl.css" type="text/css" />
<![endif]-->
<?php endif; ?>
	
</head>

<body class="contentpane">

<div class="column">
	<jdoc:include type="message" />
	<jdoc:include type="component" />
</div>

</body>

</html>
