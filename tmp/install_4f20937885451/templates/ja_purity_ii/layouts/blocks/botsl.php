<?php
$spotlight = array ('user6','user7','user8','user9','user10');
$botsl = $this->calSpotlight ($spotlight,100);
if( $botsl ) :
?>
<!-- BOTTOM SPOTLIGHT -->
<div id="ja-botsl" class="wrap">
<div class="main clearfix">

	<?php if( $this->countModules('user6') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user6']['class']; ?>" style="width: <?php echo $botsl['user6']['width']; ?>;">
		<jdoc:include type="modules" name="user6" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<?php if( $this->countModules('user7') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user7']['class']; ?>" style="width: <?php echo $botsl['user7']['width']; ?>;">
		<jdoc:include type="modules" name="user7" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<?php if( $this->countModules('user8') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user8']['class']; ?>" style="width: <?php echo $botsl['user8']['width']; ?>;">
		<jdoc:include type="modules" name="user8" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<?php if( $this->countModules('user9') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user9']['class']; ?>" style="width: <?php echo $botsl['user9']['width']; ?>;">
		<jdoc:include type="modules" name="user9" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<?php if( $this->countModules('user10') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user10']['class']; ?>" style="width: <?php echo $botsl['user10']['width']; ?>;">
		<jdoc:include type="modules" name="user10" style="JAxhtml" />
	</div>
	<?php endif; ?>

</div>
</div>
<!-- //BOTTOM SPOTLIGHT -->
<?php endif; ?>