<?php
$spotlight = array ('top','user8','user9','user10','user11');
$botsl = $this->calSpotlight ($spotlight,100);
if( $botsl ) :
?>
<!-- TOP SPOTLIGHT -->
<div id="ja-topsl" class="wrap">
<div class="main clearfix">

	<?php if( $this->countModules('top') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['top']['class']; ?>" style="width: <?php echo $botsl['top']['width']; ?>;">
		<jdoc:include type="modules" name="top" style="JAxhtml" />
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

	<?php if( $this->countModules('user11') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user11']['class']; ?>" style="width: <?php echo $botsl['user11']['width']; ?>;">
		<jdoc:include type="modules" name="user11" style="JAxhtml" />
	</div>
	<?php endif; ?>

</div>
</div>
<!-- //TOP SPOTLIGHT -->
<?php endif; ?>