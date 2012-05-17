<?php
$spotlight = array ('user1','user2','user5','user6','user7');
$botsl = $this->calSpotlight ($spotlight,100);
if( $botsl ) :
?>
<!-- BOTTOM SPOTLIGHT -->
<div id="ja-botsl" class="wrap">
<div class="main clearfix">

	<?php if( $this->countModules('user1') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user1']['class']; ?>" style="width: <?php echo $botsl['user1']['width']; ?>;">
		<jdoc:include type="modules" name="user1" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<?php if( $this->countModules('user2') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user2']['class']; ?>" style="width: <?php echo $botsl['user2']['width']; ?>;">
		<jdoc:include type="modules" name="user2" style="JAxhtml" />
	</div>
	<?php endif; ?>

	<?php if( $this->countModules('user5') ): ?>
	<div class="ja-box column ja-box<?php echo $botsl['user5']['class']; ?>" style="width: <?php echo $botsl['user5']['width']; ?>;">
		<jdoc:include type="modules" name="user5" style="JAxhtml" />
	</div>
	<?php endif; ?>

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

</div>
</div>
<!-- //BOTTOM SPOTLIGHT -->
<?php endif; ?>