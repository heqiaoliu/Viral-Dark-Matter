<!-- CONTENT -->
<div id="ja-main" style="width:<?php echo $this->getColumnWidth('m') ?>%">
<div class="inner clearfix">
	
	<jdoc:include type="message" />

	<?php 
	$mass_top = $this->getPositionName ('content-mass-top');
	if($this->countModules($mass_top)) : ?>
	<div class="ja-mass ja-mass-top clearfix">
		<jdoc:include type="modules" name="<?php echo $mass_top;?>" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<div id="ja-contentwrap" class="<?php echo $this->getColumnWidth('cls_m'); ?>">
		<?php
		$inset1 = $this->getPositionName ('inset1');
		$inset2 = $this->getPositionName ('inset2');
		?>
		<div id="ja-content" class="column" style="width:<?php echo $this->getColumnWidth('cw') ?>%">

			<div id="ja-current-content" class="column" style="width:<?php echo $this->getColumnWidth('c') ?>%">
				<?php 
				$content_top = $this->getPositionName ('content-top');
				if($this->countModules($content_top)) : ?>
				<div class="ja-content-top clearfix">
					<jdoc:include type="modules" name="<?php echo $content_top;?>" style="JAxhtml" />
				</div>
				<?php endif; ?>
				
				<?php $contents = $this->getBuffer('component'); 
				if (!preg_match ('/<div class="blog">\s*<\/div>/',$contents)) :?>
				<div class="ja-content-main clearfix">
					<jdoc:include type="component" />
				</div>
				<?php endif; ?>

				<?php 
				$content_bottom = $this->getPositionName ('content-bottom');
				if($this->countModules($content_bottom)) : ?>
				<div class="ja-content-bottom clearfix">
					<jdoc:include type="modules" name="<?php echo $content_bottom;?>" style="JAxhtml" />
				</div>
				<?php endif; ?>
			</div>

			<?php if($this->countModules($inset1)) : ?>
			<div class="ja-col column ja-inset1" style="width:<?php echo $this->getColumnWidth('i1') ?>%">
				<jdoc:include type="modules" name="<?php echo $inset1;?>" style="JAxhtml" />
			</div>
			<?php endif; ?>

		</div>
		
		<?php if($this->countModules($inset2)) : ?>
		<div class="ja-col column ja-inset2" style="width:<?php echo $this->getColumnWidth('i2') ?>%">
			<jdoc:include type="modules" name="<?php echo $inset2;?>" style="JAxhtml" />
		</div>
		<?php endif; ?>
	</div>

	<?php 
	$mass_bottom = $this->getPositionName ('content-mass-bottom');
	if($this->countModules($mass_bottom)) : ?>
	<div class="ja-mass ja-mass-bottom clearfix">
		<jdoc:include type="modules" name="<?php echo $mass_bottom;?>" style="JAxhtml" />
	</div>
	<?php endif; ?>

</div>
</div>
<!-- //CONTENT -->