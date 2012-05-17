<div id="ja-main" class="main clearfix">

	<jdoc:include type="message" />

	<div id="ja-current-content" class="column">
		<?php 
		$content_top = $this->getPositionName ('content-top');
		if($this->countModules($content_top)) : ?>
		<div class="ja-content-top clearfix">
			<jdoc:include type="modules" name="<?php echo $content_top;?>" />
		</div>
		<?php endif; ?>

		<div class="ja-content-main clearfix">
			<jdoc:include type="component" />
		</div>

		<?php 
		$content_bottom = $this->getPositionName ('content-bottom');
		if($this->countModules($content_bottom)) : ?>
		<div class="ja-content-bottom clearfix">
			<jdoc:include type="modules" name="<?php echo $content_bottom;?>" style="raw" />
		</div>
		<?php endif; ?>
	</div>

</div>