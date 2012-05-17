<div class="ja-navhelper wrap">
<div class="main clearfix">

	<div class="ja-breadcrums">
		<strong><?php echo JText::_('You are here')?></strong> <jdoc:include type="module" name="breadcrumbs" />
	</div>
    
    <ul class="ja-links">
		<li class="layout-switcher"><?php $this->loadBlock('usertools/layout-switcher') ?>&nbsp;</li>
		<li class="top"><a href="<?php echo $this->getCurrentURL();?>#Top" title="Back to Top" onclick="javascript:scroll(0,0)"><?php echo JText::_('BACK TO TOP')?></a></li>
	</ul>
	
	<ul class="no-display">
		<li><a href="<?php echo $this->getCurrentURL();?>#ja-content" title="<?php echo JText::_("Skip to content");?>"><?php echo JText::_("Skip to content");?></a></li>
	</ul>

</div>
</div>

<div id="ja-footer" class="wrap">
<div class="main clearfix">

<div class="ja-footnav">
	<jdoc:include type="modules" name="footnav" />
</div>
	
<div class="inner">
	<div class="ja-copyright">
		<jdoc:include type="modules" name="footer" />
	</div>
</div>

</div>
</div>