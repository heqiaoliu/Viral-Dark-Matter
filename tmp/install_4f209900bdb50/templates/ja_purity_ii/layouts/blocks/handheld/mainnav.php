<div id="ja-mainnav" class="main clearfix">

	<?php if (($jamenu = $this->loadMenu())) $jamenu->genMenu (); ?>
	
	<?php if($this->countModules('search')) : ?>
	<div id="ja-search">
		<jdoc:include type="modules" name="search" />
	</div>
	<?php endif; ?>

</div>
