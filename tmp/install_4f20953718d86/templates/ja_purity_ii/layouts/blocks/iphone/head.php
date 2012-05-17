<jdoc:include type="head" />

<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=1;" />
<meta name="apple-touch-fullscreen" content="YES" />

<?php JHTML::_('behavior.mootools'); ?>

<link rel="stylesheet" href="<?php echo $this->baseurl(); ?>templates/system/css/system.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->baseurl(); ?>templates/system/css/general.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/addons.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/layout.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/template.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/typo.css" type="text/css" />

<!-- CSS for handheld devices -->
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/handheld/layout.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/handheld/template.css" type="text/css" />
<!-- //CSS for handheld devices -->

<script type="text/javascript">
var siteurl='<?php echo $this->baseurl();?>';
var tmplurl='<?php echo $this->templateurl();?>';
</script>

<script language="javascript" type="text/javascript" src="<?php echo $this->templateurl(); ?>/js/ja.script.js"></script>

<!-- Menu head -->
<?php if (($jamenu = $this->loadMenu())) $jamenu->genMenuHead (); ?>

<script type="text/javascript">
	//update image size
	function updateOrientation() {
		var maxwidth = 200;
		var orient = window.orientation
        if (orient == 90 || orient == -90) {
			bdcls = 'landscape';
			maxwidth = Math.round(480*40/100); //IPhone
		} else {
			bdcls = 'portrait';
			maxwidth = Math.round(screen.width*40/100);
		}
		document.body.className = bdcls;
		//update images width
		images = document.getElementsByTagName ('img');
		for(i=0;i<images.length;i++) {
			image = images[i];
			if (!image._orgwidth) {
				image._orgwidth = image.offsetWidth;
			}
			if (image._orgwidth > maxwidth) {
				image.width = maxwidth;
			} else if (image._orgwidth > image.offsetWidth) {
				image.width = image._orgwidth;
			}
		}
		window.scrollTo(0,1);
    }
</script>

<!-- CSS/JS for Iphone -->
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/css/handheld/iphone.css" type="text/css" />
<script language="javascript" type="text/javascript" src="<?php echo $this->templateurl(); ?>/js/iphone.js"></script>
<!-- //CSS/JS for Iphone -->

<?php if($this->getParam('direction')=='rtl' || $this->direction == 'rtl') : ?>
	<link href="<?php echo $this->templateurl(); ?>/css/template_rtl.css" rel="stylesheet" type="text/css" />
<?php endif; ?>