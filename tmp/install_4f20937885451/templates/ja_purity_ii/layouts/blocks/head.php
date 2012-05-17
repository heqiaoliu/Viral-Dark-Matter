<jdoc:include type="head" />
<?php JHTML::_('behavior.mootools'); ?>

<link rel="stylesheet" href="<?php echo $this->baseurl(); ?>templates/system/css/system.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->baseurl(); ?>templates/system/css/general.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/addons.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/layout.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/template.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/typo.css" type="text/css" />

<!--[if IE]>
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/ie.css" type="text/css" />
<![endif]-->

<!--[if lt IE 7.0]>
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/ie7minus.css" type="text/css" />
<style>
.main { width: expression(document.body.clientWidth < 770? "770px" : document.body.clientWidth > 1200? "1200px" : "auto"); }
</style>
<![endif]-->

<!--[if IE 7.0]>
<style>
.clearfix { display: inline-block; } /* IE7xhtml*/
</style>
<![endif]-->

<script type="text/javascript">
var siteurl='<?php echo $this->baseurl();?>';
var tmplurl='<?php echo $this->templateurl();?>';
</script>

<script language="javascript" type="text/javascript" src="<?php echo $this->templateurl(); ?>/js/ja.script.js"></script>

<?php if ($this->getParam('ja_cufon')) : ?>
<script language="javascript" type="text/javascript" src="<?php echo $this->templateurl(); ?>/libs/cufon/js/cufon-yui.js"></script>
<script language="javascript" type="text/javascript" src="<?php echo $this->templateurl(); ?>/libs/cufon/fonts/Museo_500_400.font.js"></script>
<script type="text/javascript">
	Cufon.replace(
		'.componentheading, .contentheading, .ja-zintitle a, div.moduletable h3, div.moduletable_menu h3, div.moduletable_text h3, div.moduletable_highlight h3',
		{ fontFamily: 'Museo 500' }
	);
	Cufon.replace (
		'.logo-text h1',
		{ fontFamily: 'Museo 500' }
	);
</script>
<?php endif; ?>

<?php if (($jamenu = $this->loadMenu())) $jamenu->genMenuHead (); ?>

<?php if ($this->isIE()) {  ?>
<!--[if lte IE 6]>
<script type="text/javascript">
window.addEvent ('load', makeTransBG);
function makeTransBG() {
makeTransBg($$('img'));
}
</script>
<![endif]-->
<?php } ?>

<?php if ($this->getParam('rightCollapsible')): ?>
<script language="javascript" type="text/javascript">
var rightCollapseDefault='<?php echo $this->getParam('rightCollapsible-1-rightCollapseDefault'); ?>';
var excludeModules='<?php echo $this->getParam('rightCollapsible-1-excludeModules'); ?>';
</script>
<script language="javascript" type="text/javascript" src="<?php echo $this->templateurl(); ?>/js/ja.rightcol.js"></script>
<?php endif; ?>

<!--Width of template -->
<style type="text/css">
.main {width: <?php echo $this->getParam('tmplWidth', 'auto', true); ?>;margin: 0 auto;}
#ja-wrapper {min-width: <?php echo $this->getParam('tmplWrapMin', 'auto', true); ?>;}
</style>

<?php if($this->getParam('direction')=='rtl' || $this->direction == 'rtl') : ?>
<link href="<?php echo $this->templateurl(); ?>/css/template_rtl.css" rel="stylesheet" type="text/css" />
<!--[if lt IE 8.0]>
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/ie-rtl.css" type="text/css" />
<![endif]-->
<?php endif; ?>
